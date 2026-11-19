import 'package:bilimusic/feature/home/domain/hot_playlist.dart';
import 'package:bilimusic/feature/home/domain/hot_playlist_track.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'hot_playlist_detail_state.freezed.dart';

@freezed
abstract class HotPlaylistDetailState with _$HotPlaylistDetailState {
  const factory HotPlaylistDetailState({
    required HotPlaylist playlist,
    @Default(<HotPlaylistTrack>[]) List<HotPlaylistTrack> tracks,
    @Default(false) bool isLoading,
    @Default(false) bool isLoadingMore,
    @Default(true) bool hasMore,
    @Default(0) int totalCount,
    String? errorMessage,
    String? moreErrorMessage,
  }) = _HotPlaylistDetailState;

  const HotPlaylistDetailState._();

  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;

  bool get hasMoreError =>
      moreErrorMessage != null && moreErrorMessage!.isNotEmpty;

  bool get isEmpty => !isLoading && !hasError && tracks.isEmpty;

  int get loadedCount => tracks.length;

  /// 底部「加载更多」按钮文案里的进度，例如 `30 / 417`。
  String get progressText =>
      totalCount > 0 ? '$loadedCount / $totalCount' : '$loadedCount';
}
