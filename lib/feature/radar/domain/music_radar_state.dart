import 'package:bilimusic/feature/home/domain/hot_playlist_track.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'music_radar_state.freezed.dart';

/// 音乐雷达：一轮扫描得到的跨平台发现流。
@freezed
abstract class MusicRadarState with _$MusicRadarState {
  const factory MusicRadarState({
    @Default(<HotPlaylistTrack>[]) List<HotPlaylistTrack> tracks,
    @Default(false) bool isScanning,
    @Default(0) int scanCount,
    String? errorMessage,
  }) = _MusicRadarState;

  const MusicRadarState._();

  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;

  bool get isEmpty => !isScanning && !hasError && tracks.isEmpty;

  bool get hasResult => tracks.isNotEmpty;
}
