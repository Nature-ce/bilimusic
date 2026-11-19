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

/// 音乐雷达：扫描各平台热榜歌单，随机抽取曲目组成「漫游发现流」。
@Riverpod(keepAlive: true)
class MusicRadarController extends _$MusicRadarController {
  static const int _tracksPerPlatform = 8;
  static const int _maxTracks = 24;
  static const int _sourcePageSize = 30;

  int _scanId = 0;

  @override
  MusicRadarState build() {
    unawaited(Future<void>.microtask(scan));
    return const MusicRadarState(isScanning: true);
  }

  Future<void> scan() async {
    final int scanId = ++_scanId;
    final Random random = ref.read(musicRadarRandomProvider);
    final HotPlaylistRepository repository = ref.read(
      hotPlaylistRepositoryProvider,
    );
    state = state.copyWith(isScanning: true, errorMessage: null);
    final List<HotPlaylistTrack> discovered = <HotPlaylistTrack>[];
    final Set<String> seen = <String>{};
    Object? lastError;
    bool anySourceLoaded = false;

    for (final MusicChartPlatform platform
        in MusicChartPlatform.playlistPlatforms) {
      if (discovered.length >= _maxTracks) {
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
          if (picked >= _tracksPerPlatform || discovered.length >= _maxTracks) {
            break;
          }
          if (!seen.add(_dedupeKey(track))) {
            continue;
          }
          discovered.add(track);
          picked += 1;
        }
      } on Object catch (error) {
        lastError = error;
      }
    }

    if (!ref.mounted || scanId != _scanId) {
      return;
    }
    if (!anySourceLoaded || discovered.isEmpty) {
      state = state.copyWith(
        isScanning: false,
        tracks: const <HotPlaylistTrack>[],
        errorMessage: (lastError ?? const HotPlaylistException('雷达暂时没有发现'))
            .toString(),
      );
      return;
    }
    discovered.shuffle(random);
    state = state.copyWith(
      tracks: List<HotPlaylistTrack>.unmodifiable(discovered),
      isScanning: false,
      scanCount: state.scanCount + 1,
      errorMessage: null,
    );
  }

  static String _dedupeKey(HotPlaylistTrack track) {
    return '${track.title.toLowerCase()}|${track.artist.toLowerCase()}';
  }
}
