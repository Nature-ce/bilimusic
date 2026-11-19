import 'dart:async';

import 'package:bilimusic/feature/home/domain/hot_playlist.dart';
import 'package:bilimusic/feature/home/domain/hot_playlist_detail_state.dart';
import 'package:bilimusic/feature/home/domain/hot_playlist_track.dart';
import 'package:bilimusic/feature/home/logic/hot_playlist_controller.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'hot_playlist_detail_controller.g.dart';

@riverpod
class HotPlaylistDetailController extends _$HotPlaylistDetailController {
  int _requestId = 0;

  @override
  HotPlaylistDetailState build(HotPlaylist playlist) {
    unawaited(Future<void>.microtask(load));
    return HotPlaylistDetailState(playlist: playlist, isLoading: true);
  }

  Future<void> refresh() => load(forceRefresh: true);

  Future<void> load({bool forceRefresh = false}) async {
    final int requestId = ++_requestId;
    if (!state.isLoading) {
      state = state.copyWith(isLoading: true, errorMessage: null);
    }
    try {
      final List<HotPlaylistTrack> tracks = await ref
          .read(hotPlaylistRepositoryProvider)
          .fetchTracks(state.playlist, forceRefresh: forceRefresh);
      if (!ref.mounted || requestId != _requestId) {
        return;
      }
      state = state.copyWith(
        tracks: tracks,
        isLoading: false,
        errorMessage: null,
      );
    } on Object catch (error) {
      if (!ref.mounted || requestId != _requestId) {
        return;
      }
      state = state.copyWith(
        tracks: const <HotPlaylistTrack>[],
        isLoading: false,
        errorMessage: error.toString(),
      );
    }
  }
}
