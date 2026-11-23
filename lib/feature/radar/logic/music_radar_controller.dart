import 'dart:async';
import 'dart:math';

import 'package:bilimusic/feature/home/data/hot_playlist_repository.dart';
import 'package:bilimusic/feature/home/domain/hot_playlist.dart';
import 'package:bilimusic/feature/home/domain/hot_playlist_track.dart';
import 'package:bilimusic/feature/home/domain/music_chart_platform.dart';
import 'package:bilimusic/feature/home/logic/hot_playlist_controller.dart';
import 'package:bilimusic/feature/radar/domain/music_radar_state.dart';
import 'package:bilimusic/feature/radar/domain/radar_keys.dart';
import 'package:bilimusic/feature/radar/domain/radar_pick.dart';
import 'package:bilimusic/feature/radar/domain/radar_taste.dart';
import 'package:bilimusic/feature/radar/logic/radar_recommender.dart';
import 'package:bilimusic/feature/radar/logic/radar_taste_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'music_radar_controller.g.dart';

@riverpod
Random musicRadarRandom(Ref ref) => Random();

/// 刷歌流：把各平台热门歌单汇成候选池，再按「私人雷达」的口味画像挑选。
///
/// 不再是「随机挑一张歌单的前几首」——那样整条流都是各平台榜首，很单调。
/// 现在会按常听歌手 / 同歌单 / 换口味三档混合，并限制同一歌手、同一歌单的占比。
@Riverpod(keepAlive: true)
class MusicRadarController extends _$MusicRadarController {
  static const int _batchTracks = 24;
  static const int _extendTracks = 12;
  static const int _firstWavePlaylists = 1;
  static const int _secondWavePlaylists = 2;
  static const int _tracksPerPlaylist = 40;

  int _scanId = 0;
  int _extendId = 0;

  /// 整个刷歌流期间已出现过的曲目，跨批次去重。
  final Set<String> _seenKeys = <String>{};

  List<HotPlaylistTrack> _pool = const <HotPlaylistTrack>[];
  RadarTaste _taste = const RadarTaste();

  @override
  MusicRadarState build() {
    unawaited(Future<void>.microtask(scan));
    return const MusicRadarState(isScanning: true);
  }

  /// 换一批：清空已看过的曲目，重新采一批候选池并按当前口味挑。
  Future<void> scan() async {
    final int scanId = ++_scanId;
    ++_extendId;
    final Random random = ref.read(musicRadarRandomProvider);
    _seenKeys.clear();
    state = state.copyWith(
      isScanning: true,
      isLoadingMore: false,
      errorMessage: null,
    );
    final _PoolResult pool = await _gatherPool(
      random,
      playlistsPerPlatform: _firstWavePlaylists,
    );
    if (!ref.mounted || scanId != _scanId) {
      return;
    }
    _taste = await ref.read(radarTasteProvider.future);
    if (!ref.mounted || scanId != _scanId) {
      return;
    }
    final List<RadarPick> picks = const RadarRecommender().pick(
      pool: pool.tracks,
      taste: _taste,
      limit: _batchTracks,
      random: random,
      excludeKeys: _seenKeys,
    );
    if (picks.isEmpty) {
      state = state.copyWith(
        isScanning: false,
        tracks: const <HotPlaylistTrack>[],
        picks: const <RadarPick>[],
        errorMessage: (pool.lastError ?? const HotPlaylistException('刷歌暂时没有发现'))
            .toString(),
      );
      return;
    }
    _pool = pool.tracks;
    _remember(picks);
    state = state.copyWith(
      tracks: List<HotPlaylistTrack>.unmodifiable(
        picks.map((RadarPick pick) => pick.track),
      ),
      picks: List<RadarPick>.unmodifiable(picks),
      isScanning: false,
      scanCount: state.scanCount + 1,
      listenedCount: _taste.sampleCount,
      isPersonalized: !_taste.isColdStart,
      errorMessage: null,
    );
  }

  /// 补货：从候选池里继续挑，池子见底就换一批歌单。
  Future<void> extendFeed() async {
    if (state.isScanning || state.isLoadingMore) {
      return;
    }
    final int extendId = ++_extendId;
    final Random random = ref.read(musicRadarRandomProvider);
    state = state.copyWith(isLoadingMore: true, errorMessage: null);
    if (_pool.isEmpty) {
      final _PoolResult pool = await _gatherPool(random);
      if (!ref.mounted || extendId != _extendId) {
        return;
      }
      _pool = pool.tracks;
    }
    _taste = await ref.read(radarTasteProvider.future);
    if (!ref.mounted || extendId != _extendId) {
      return;
    }
    List<RadarPick> picks = const RadarRecommender().pick(
      pool: _pool,
      taste: _taste,
      limit: _extendTracks,
      random: random,
      excludeKeys: _seenKeys,
    );
    if (picks.isEmpty) {
      final _PoolResult pool = await _gatherPool(random);
      if (!ref.mounted || extendId != _extendId) {
        return;
      }
      _pool = pool.tracks;
      picks = const RadarRecommender().pick(
        pool: _pool,
        taste: _taste,
        limit: _extendTracks,
        random: random,
        excludeKeys: _seenKeys,
      );
    }
    if (picks.isEmpty) {
      state = state.copyWith(isLoadingMore: false, errorMessage: '刷歌暂时没有更多歌曲了');
      return;
    }
    _remember(picks);
    state = state.copyWith(
      tracks: List<HotPlaylistTrack>.unmodifiable(<HotPlaylistTrack>[
        ...state.tracks,
        ...picks.map((RadarPick pick) => pick.track),
      ]),
      picks: List<RadarPick>.unmodifiable(<RadarPick>[
        ...state.picks,
        ...picks,
      ]),
      isLoadingMore: false,
      listenedCount: _taste.sampleCount,
      isPersonalized: !_taste.isColdStart,
      errorMessage: null,
    );
  }

  void _remember(List<RadarPick> picks) {
    for (final RadarPick pick in picks) {
      _seenKeys.add(pick.key);
    }
  }

  Future<_PoolResult> _gatherPool(
    Random random, {
    int playlistsPerPlatform = _secondWavePlaylists,
  }) async {
    final HotPlaylistRepository repository = ref.read(
      hotPlaylistRepositoryProvider,
    );
    final List<Future<_PlatformPool>> tasks = <Future<_PlatformPool>>[
      for (final MusicChartPlatform platform in MusicChartPlatform.values)
        _gatherPlatform(
          repository,
          platform,
          random,
          playlistsPerPlatform: playlistsPerPlatform,
        ),
    ];
    final List<_PlatformPool> groups = await Future.wait(tasks);
    final Map<String, HotPlaylistTrack> unique = <String, HotPlaylistTrack>{};
    Object? lastError;
    bool anySourceLoaded = false;
    for (final _PlatformPool group in groups) {
      if (group.tracks.isNotEmpty) {
        anySourceLoaded = true;
      }
      lastError ??= group.error;
      for (final HotPlaylistTrack track in group.tracks) {
        unique.putIfAbsent(
          radarTrackKey(title: track.title, artist: track.artist),
          () => track,
        );
      }
    }
    return _PoolResult(
      tracks: unique.values.toList(growable: false),
      lastError: anySourceLoaded ? null : lastError,
    );
  }

  Future<_PlatformPool> _gatherPlatform(
    HotPlaylistRepository repository,
    MusicChartPlatform platform,
    Random random, {
    int playlistsPerPlatform = _secondWavePlaylists,
  }) async {
    try {
      final List<HotPlaylist> playlists = await repository.fetchPlaylists(
        platform,
      );
      if (playlists.isEmpty) {
        return const _PlatformPool(tracks: <HotPlaylistTrack>[], error: null);
      }
      final List<HotPlaylist> selected = List<HotPlaylist>.of(playlists)
        ..shuffle(random);
      final List<HotPlaylistTrack> tracks = <HotPlaylistTrack>[];
      Object? lastError;
      for (final HotPlaylist playlist in selected.take(playlistsPerPlatform)) {
        try {
          final HotPlaylistTrackPage page = await repository.fetchTrackPage(
            playlist,
            limit: _tracksPerPlaylist,
          );
          tracks.addAll(page.tracks);
        } on Object catch (error) {
          lastError = error;
        }
      }
      return _PlatformPool(tracks: tracks, error: lastError);
    } on Object catch (error) {
      return _PlatformPool(tracks: const <HotPlaylistTrack>[], error: error);
    }
  }
}

class _PoolResult {
  const _PoolResult({required this.tracks, this.lastError});

  final List<HotPlaylistTrack> tracks;
  final Object? lastError;
}

class _PlatformPool {
  const _PlatformPool({required this.tracks, this.error});

  final List<HotPlaylistTrack> tracks;
  final Object? error;
}
