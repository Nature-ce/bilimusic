import 'dart:math';

import 'package:bilimusic/feature/home/data/hot_playlist_repository.dart';
import 'package:bilimusic/feature/home/domain/hot_playlist.dart';
import 'package:bilimusic/feature/home/domain/hot_playlist_track.dart';
import 'package:bilimusic/feature/home/domain/music_chart_platform.dart';
import 'package:bilimusic/feature/home/logic/hot_playlist_controller.dart';
import 'package:bilimusic/feature/radar/domain/radar_keys.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'radar_pool_loader.g.dart';

@riverpod
RadarPoolLoader radarPoolLoader(Ref ref) {
  return RadarPoolLoader(ref.read(hotPlaylistRepositoryProvider));
}

class RadarPoolResult {
  const RadarPoolResult({required this.tracks, this.lastError});

  final List<HotPlaylistTrack> tracks;
  final Object? lastError;
}

/// 把三个平台的热门歌单汇成候选池：每平台随机挑几张歌单，每张取一页曲目再去重。
///
/// 刷歌与每日推荐都要这一池子歌，放在这里共用。
class RadarPoolLoader {
  const RadarPoolLoader(this._repository);

  static const int defaultPlaylistsPerPlatform = 2;
  static const int tracksPerPlaylist = 40;

  final HotPlaylistRepository _repository;

  Future<RadarPoolResult> load({
    required Random random,
    int playlistsPerPlatform = defaultPlaylistsPerPlatform,
  }) async {
    final List<Future<_PlatformPool>> tasks = <Future<_PlatformPool>>[
      for (final MusicChartPlatform platform in MusicChartPlatform.values)
        _gatherPlatform(
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
    return RadarPoolResult(
      tracks: unique.values.toList(growable: false),
      lastError: anySourceLoaded ? null : lastError,
    );
  }

  Future<_PlatformPool> _gatherPlatform(
    MusicChartPlatform platform,
    Random random, {
    required int playlistsPerPlatform,
  }) async {
    try {
      final List<HotPlaylist> playlists = await _repository.fetchPlaylists(
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
          final HotPlaylistTrackPage page = await _repository.fetchTrackPage(
            playlist,
            limit: tracksPerPlaylist,
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

class _PlatformPool {
  const _PlatformPool({required this.tracks, this.error});

  final List<HotPlaylistTrack> tracks;
  final Object? error;
}
