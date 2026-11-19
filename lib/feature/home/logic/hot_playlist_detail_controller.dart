import 'dart:async';

import 'package:bilimusic/feature/home/data/hot_playlist_repository.dart';
import 'package:bilimusic/feature/home/domain/hot_playlist.dart';
import 'package:bilimusic/feature/home/domain/hot_playlist_detail_state.dart';
import 'package:bilimusic/feature/home/domain/hot_playlist_track.dart';
import 'package:bilimusic/feature/home/logic/hot_playlist_controller.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'hot_playlist_detail_controller.g.dart';

@riverpod
class HotPlaylistDetailController extends _$HotPlaylistDetailController {
  int _requestId = 0;
  int _offset = 0;

  static const int _pageSize = HotPlaylistRepository.defaultTrackPageSize;

  @override
  HotPlaylistDetailState build(HotPlaylist playlist) {
    unawaited(Future<void>.microtask(load));
    return HotPlaylistDetailState(playlist: playlist, isLoading: true);
  }

  Future<void> refresh() => load(forceRefresh: true);

  Future<void> load({bool forceRefresh = false}) async {
    final int requestId = ++_requestId;
    _offset = 0;
    if (!state.isLoading) {
      state = state.copyWith(
        isLoading: true,
        isLoadingMore: false,
        errorMessage: null,
        moreErrorMessage: null,
      );
    }
    try {
      final HotPlaylistTrackPage page = await ref
          .read(hotPlaylistRepositoryProvider)
          .fetchTrackPage(
            state.playlist,
            offset: 0,
            limit: _pageSize,
            forceRefresh: forceRefresh,
          );
      if (!ref.mounted || requestId != _requestId) {
        return;
      }
      _offset = _pageSize;
      state = state.copyWith(
        tracks: page.tracks,
        isLoading: false,
        isLoadingMore: false,
        hasMore: page.hasMore,
        totalCount: page.totalCount,
        errorMessage: null,
        moreErrorMessage: null,
      );
    } on Object catch (error) {
      if (!ref.mounted || requestId != _requestId) {
        return;
      }
      state = state.copyWith(
        tracks: const <HotPlaylistTrack>[],
        isLoading: false,
        isLoadingMore: false,
        hasMore: false,
        errorMessage: error.toString(),
      );
    }
  }

  /// 追加下一页；失败时保留已加载内容，只在底部提示可重试。
  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) {
      return;
    }
    final int requestId = _requestId;
    final int offset = _offset;
    state = state.copyWith(isLoadingMore: true, moreErrorMessage: null);
    try {
      final HotPlaylistTrackPage page = await ref
          .read(hotPlaylistRepositoryProvider)
          .fetchTrackPage(state.playlist, offset: offset, limit: _pageSize);
      if (!ref.mounted || requestId != _requestId) {
        return;
      }
      final List<HotPlaylistTrack> merged = _merge(state.tracks, page.tracks);
      final bool grew = merged.length > state.tracks.length;
      _offset = offset + _pageSize;
      state = state.copyWith(
        tracks: merged,
        isLoadingMore: false,
        hasMore: page.hasMore && (grew || page.tracks.isNotEmpty),
        totalCount: page.totalCount > 0 ? page.totalCount : state.totalCount,
      );
    } on Object catch (error) {
      if (!ref.mounted || requestId != _requestId) {
        return;
      }
      state = state.copyWith(
        isLoadingMore: false,
        moreErrorMessage: error.toString(),
      );
    }
  }

  static List<HotPlaylistTrack> _merge(
    List<HotPlaylistTrack> loaded,
    List<HotPlaylistTrack> incoming,
  ) {
    final List<HotPlaylistTrack> merged = <HotPlaylistTrack>[...loaded];
    final Set<String> seen = <String>{
      for (final HotPlaylistTrack track in loaded) _dedupeKey(track),
    };
    for (final HotPlaylistTrack track in incoming) {
      if (!seen.add(_dedupeKey(track))) {
        continue;
      }
      merged.add(track.copyWith(rank: merged.length + 1));
    }
    return List<HotPlaylistTrack>.unmodifiable(merged);
  }

  static String _dedupeKey(HotPlaylistTrack track) {
    return '${track.title.toLowerCase()}|${track.artist.toLowerCase()}';
  }
}
