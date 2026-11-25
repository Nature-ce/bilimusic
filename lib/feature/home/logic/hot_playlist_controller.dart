import 'dart:async';

import 'package:bilimusic/feature/home/data/hot_playlist_repository.dart';
import 'package:bilimusic/feature/home/domain/hot_playlist.dart';
import 'package:bilimusic/feature/home/domain/hot_playlist_state.dart';
import 'package:bilimusic/feature/home/domain/music_chart_platform.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'hot_playlist_controller.g.dart';

/// 仓库要活到整个会话：它内部记住“当前翻到第几页”，被回收后下拉刷新就永远停在第一批。
@Riverpod(keepAlive: true)
HotPlaylistRepository hotPlaylistRepository(Ref ref) {
  return HotPlaylistRepository();
}

@Riverpod(keepAlive: true)
class HotPlaylistController extends _$HotPlaylistController {
  int _requestId = 0;

  @override
  HotPlaylistState build() {
    unawaited(Future<void>.microtask(_load));
    return const HotPlaylistState(isLoading: true);
  }

  Future<void> refresh() => _load(forceRefresh: true);

  Future<void> _load({bool forceRefresh = false}) async {
    final int requestId = ++_requestId;
    if (!state.isLoading) {
      state = state.copyWith(isLoading: true, errorMessage: null);
    }
    final List<List<HotPlaylist>> groups = <List<HotPlaylist>>[];
    Object? firstError;
    for (final MusicChartPlatform platform in MusicChartPlatform.values) {
      try {
        groups.add(
          await ref
              .read(hotPlaylistRepositoryProvider)
              .fetchPlaylists(platform, forceRefresh: forceRefresh),
        );
      } on Object catch (error) {
        firstError ??= error;
      }
    }
    if (!ref.mounted || requestId != _requestId) {
      return;
    }
    final List<HotPlaylist> playlists = _interleave(groups);
    if (playlists.isEmpty && firstError != null) {
      state = state.copyWith(
        playlists: const <HotPlaylist>[],
        isLoading: false,
        errorMessage: firstError.toString(),
      );
      return;
    }
    state = state.copyWith(
      playlists: playlists,
      isLoading: false,
      errorMessage: null,
    );
    unawaited(_backfillTrackCounts(playlists));
  }

  /// QQ 音乐的列表接口不带曲目数：进页面后小批并发补齐，补到就刷新卡片角标。
  Future<void> _backfillTrackCounts(List<HotPlaylist> playlists) async {
    final List<HotPlaylist> missing = playlists
        .where((HotPlaylist playlist) => playlist.trackCount <= 0)
        .toList(growable: false);
    if (missing.isEmpty) {
      return;
    }
    final HotPlaylistRepository repository = ref.read(
      hotPlaylistRepositoryProvider,
    );
    const int batchSize = HotPlaylistRepository.trackCountConcurrency;
    for (int start = 0; start < missing.length; start += batchSize) {
      if (!ref.mounted) {
        return;
      }
      final int end = start + batchSize > missing.length
          ? missing.length
          : start + batchSize;
      final List<MapEntry<String, int>> resolved = await Future.wait(
        missing.sublist(start, end).map((HotPlaylist playlist) async {
          try {
            final int count = await repository.fetchTrackCount(playlist);
            return MapEntry<String, int>(playlist.key, count);
          } on Object {
            return MapEntry<String, int>(playlist.key, 0);
          }
        }),
      );
      if (!ref.mounted) {
        return;
      }
      final Map<String, int> counts = <String, int>{
        for (final MapEntry<String, int> entry in resolved)
          if (entry.value > 0) entry.key: entry.value,
      };
      if (counts.isEmpty) {
        continue;
      }
      state = state.copyWith(
        playlists: <HotPlaylist>[
          for (final HotPlaylist playlist in state.playlists)
            counts.containsKey(playlist.key)
                ? playlist.copyWith(trackCount: counts[playlist.key] ?? 0)
                : playlist,
        ],
      );
    }
  }

  /// 三个平台各自按热度排好后再交错，避免整段同平台。
  static List<HotPlaylist> _interleave(List<List<HotPlaylist>> groups) {
    final List<HotPlaylist> merged = <HotPlaylist>[];
    final int longest = groups.fold<int>(
      0,
      (int value, List<HotPlaylist> group) =>
          group.length > value ? group.length : value,
    );
    for (int index = 0; index < longest; index += 1) {
      for (final List<HotPlaylist> group in groups) {
        if (index < group.length) {
          merged.add(group[index]);
        }
      }
    }
    return merged;
  }
}
