import 'dart:async';
import 'dart:math';

import 'package:bilimusic/feature/home/data/hot_playlist_repository.dart';
import 'package:bilimusic/feature/home/domain/hot_playlist.dart';
import 'package:bilimusic/feature/home/domain/hot_playlist_track.dart';
import 'package:bilimusic/feature/home/domain/music_chart_platform.dart';
import 'package:bilimusic/feature/home/logic/hot_playlist_controller.dart';
import 'package:bilimusic/feature/radar/domain/music_radar_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'music_radar_controller.g.dart';

@riverpod
Random musicRadarRandom(Ref ref) => Random();

/// 刷歌流：扫描各平台热榜歌单，随机抽取曲目组成可持续下滑的发现流。
@Riverpod(keepAlive: true)
class MusicRadarController extends _$MusicRadarController {
  static const int _tracksPerPlatform = 8;
  static const int _batchTracks = 24;
  static const int _extendTracks = 12;
  static const int _sourcePageSize = 30;
  static const int _feedLookahead = 3;

  int _scanId = 0;
  int _extendId = 0;

  /// 整个刷歌流期间已出现过的曲目，跨批次去重。
  final Set<String> _seenKeys = <String>{};

  @override
  MusicRadarState build() {
    unawaited(Future<void>.microtask(scan));
    return const MusicRadarState(isScanning: true);
  }

  /// 换一批：清空已看过的曲目并重新采样。
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
    final _BatchResult result = await _collectBatch(
      limit: _batchTracks,
      random: random,
    );
    if (!ref.mounted || scanId != _scanId) {
      return;
    }
    if (result.tracks.isEmpty) {
      state = state.copyWith(
        isScanning: false,
        tracks: const <HotPlaylistTrack>[],
        errorMessage:
            (result.lastError ?? const HotPlaylistException('刷歌暂时没有发现'))
                .toString(),
      );
      return;
    }
    final List<HotPlaylistTrack> tracks = List<HotPlaylistTrack>.of(
      result.tracks,
    )..shuffle(random);
    state = state.copyWith(
      tracks: List<HotPlaylistTrack>.unmodifiable(tracks),
      isScanning: false,
      scanCount: state.scanCount + 1,
      errorMessage: null,
    );
  }

  /// 补货：再抽一批追加到流末尾，滑到后面时无缝继续。
  Future<void> extendFeed() async {
    if (state.isScanning || state.isLoadingMore) {
      return;
    }
    final int extendId = ++_extendId;
    final Random random = ref.read(musicRadarRandomProvider);
    state = state.copyWith(isLoadingMore: true, errorMessage: null);
    final _BatchResult result = await _collectBatch(
      limit: _extendTracks,
      random: random,
    );
    if (!ref.mounted || extendId != _extendId) {
      return;
    }
    if (result.tracks.isEmpty) {
      state = state.copyWith(
        isLoadingMore: false,
        errorMessage: result.lastError?.toString() ?? '刷歌暂时没有更多歌曲了',
      );
      return;
    }
    final List<HotPlaylistTrack> appended = List<HotPlaylistTrack>.of(
      result.tracks,
    )..shuffle(random);
    state = state.copyWith(
      tracks: List<HotPlaylistTrack>.unmodifiable(<HotPlaylistTrack>[
        ...state.tracks,
        ...appended,
      ]),
      isLoadingMore: false,
      errorMessage: null,
    );
  }

  /// 滑到接近末尾时自动补货。
  void ensureFeedAt(int index) {
    if (index < state.tracks.length - _feedLookahead) {
      return;
    }
    unawaited(extendFeed());
  }

  Future<_BatchResult> _collectBatch({
    required int limit,
    required Random random,
  }) async {
    final HotPlaylistRepository repository = ref.read(
      hotPlaylistRepositoryProvider,
    );
    final List<HotPlaylistTrack> discovered = <HotPlaylistTrack>[];
    Object? lastError;
    bool anySourceLoaded = false;

    for (final MusicChartPlatform platform
        in MusicChartPlatform.playlistPlatforms) {
      if (discovered.length >= limit) {
        break;
      }
      try {
        final List<HotPlaylist> playlists = await repository.fetchPlaylists(
          platform,
        );
        if (playlists.isEmpty) {
          continue;
        }
        final List<HotPlaylist> candidates = List<HotPlaylist>.of(playlists)
          ..shuffle(random);
        final HotPlaylist source = candidates.first;
        final HotPlaylistTrackPage page = await repository.fetchTrackPage(
          source,
          limit: _sourcePageSize,
        );
        if (page.tracks.isEmpty) {
          continue;
        }
        anySourceLoaded = true;
        final List<HotPlaylistTrack> pool = List<HotPlaylistTrack>.of(
          page.tracks,
        )..shuffle(random);
        int picked = 0;
        for (final HotPlaylistTrack track in pool) {
          if (picked >= _tracksPerPlatform || discovered.length >= limit) {
            break;
          }
          if (!_seenKeys.add(_dedupeKey(track))) {
            continue;
          }
          discovered.add(track);
          picked += 1;
        }
      } on Object catch (error) {
        lastError = error;
      }
    }

    return _BatchResult(
      tracks: discovered,
      lastError: anySourceLoaded ? null : lastError,
    );
  }

  static String _dedupeKey(HotPlaylistTrack track) {
    return '${track.title.toLowerCase()}|${track.artist.toLowerCase()}';
  }
}

class _BatchResult {
  const _BatchResult({required this.tracks, this.lastError});

  final List<HotPlaylistTrack> tracks;
  final Object? lastError;
}
