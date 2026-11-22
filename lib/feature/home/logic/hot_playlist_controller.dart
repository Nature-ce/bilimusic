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

  Future<void> selectPlatform(MusicChartPlatform platform) async {
    if (state.platform == platform || !platform.supportsPlaylists) {
      return;
    }
    state = state.copyWith(
      platform: platform,
      playlists: const <HotPlaylist>[],
      isLoading: true,
      errorMessage: null,
    );
    await _load();
  }

  Future<void> _load({bool forceRefresh = false}) async {
    final int requestId = ++_requestId;
    if (!state.isLoading) {
      state = state.copyWith(isLoading: true, errorMessage: null);
    }
    final List<List<HotPlaylist>> groups = <List<HotPlaylist>>[];
    Object? firstError;
    for (final MusicChartPlatform platform
        in MusicChartPlatform.playlistPlatforms) {
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
