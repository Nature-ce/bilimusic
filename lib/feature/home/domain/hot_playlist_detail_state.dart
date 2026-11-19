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
    String? errorMessage,
  }) = _HotPlaylistDetailState;

  const HotPlaylistDetailState._();

  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;

  bool get isEmpty => !isLoading && !hasError && tracks.isEmpty;
}
