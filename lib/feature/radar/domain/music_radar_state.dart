import 'package:bilimusic/feature/home/domain/hot_playlist_track.dart';
import 'package:bilimusic/feature/radar/domain/radar_pick.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'music_radar_state.freezed.dart';

/// 刷歌流：私人雷达推出来的可持续下滑队列。
@freezed
abstract class MusicRadarState with _$MusicRadarState {
  const factory MusicRadarState({
    @Default(<HotPlaylistTrack>[]) List<HotPlaylistTrack> tracks,
    @Default(<RadarPick>[]) List<RadarPick> picks,
    @Default(false) bool isScanning,
    @Default(false) bool isLoadingMore,
    @Default(0) int scanCount,
    @Default(0) int listenedCount,
    @Default(false) bool isPersonalized,
    String? errorMessage,
  }) = _MusicRadarState;

  const MusicRadarState._();

  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;

  bool get isEmpty => !isScanning && !hasError && tracks.isEmpty;

  bool get hasResult => tracks.isNotEmpty;

  /// 是否还有未加载的曲目（刷歌流可持续下滑，恒为 true）。
  bool get isLoadingMoreError => errorMessage != null && tracks.isNotEmpty;
}
