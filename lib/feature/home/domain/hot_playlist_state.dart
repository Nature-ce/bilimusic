import 'package:bilimusic/feature/home/domain/hot_playlist.dart';
import 'package:bilimusic/feature/home/domain/music_chart_platform.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'hot_playlist_state.freezed.dart';

@freezed
abstract class HotPlaylistState with _$HotPlaylistState {
  const factory HotPlaylistState({
    @Default(MusicChartPlatform.netease) MusicChartPlatform platform,
    @Default(<HotPlaylist>[]) List<HotPlaylist> playlists,
    @Default(false) bool isLoading,
    String? errorMessage,
  }) = _HotPlaylistState;

  const HotPlaylistState._();

  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;

  bool get isEmpty => !isLoading && !hasError && playlists.isEmpty;
}
