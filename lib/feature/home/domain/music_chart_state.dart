import 'package:bilimusic/feature/home/domain/music_chart.dart';
import 'package:bilimusic/feature/home/domain/music_chart_platform.dart';
import 'package:bilimusic/feature/home/domain/music_chart_track.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'music_chart_state.freezed.dart';

/// 一个平台的榜单加载结果（首页排行榜卡片 + 下方完整列表共用这一份）。
@freezed
abstract class MusicChartEntry with _$MusicChartEntry {
  const MusicChartEntry._();

  const factory MusicChartEntry({
    required MusicChart chart,
    @Default(<MusicChartTrack>[]) List<MusicChartTrack> tracks,
    @Default(false) bool isLoading,
    String? errorMessage,
    @Default(0) int updatedAtMs,
  }) = _MusicChartEntry;

  List<MusicChartTrack> get topTracks =>
      tracks.length <= 3 ? tracks : tracks.sublist(0, 3);

  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;

  bool get isEmpty => !isLoading && !hasError && tracks.isEmpty;

  DateTime? get updatedAt => updatedAtMs <= 0
      ? null
      : DateTime.fromMillisecondsSinceEpoch(updatedAtMs);
}

@freezed
abstract class MusicChartState with _$MusicChartState {
  const factory MusicChartState({
    @Default(<MusicChartPlatform, MusicChartEntry>{})
    Map<MusicChartPlatform, MusicChartEntry> entries,
    @Default(MusicChartPlatform.netease) MusicChartPlatform selected,
  }) = _MusicChartState;

  const MusicChartState._();

  MusicChartEntry? entryOf(MusicChartPlatform platform) => entries[platform];

  MusicChartEntry? get selectedEntry => entries[selected];

  MusicChartPlatform get platform => selected;

  List<MusicChartTrack> get tracks =>
      selectedEntry?.tracks ?? const <MusicChartTrack>[];

  bool get isLoading => selectedEntry?.isLoading ?? true;

  String? get errorMessage => selectedEntry?.errorMessage;

  bool get hasError => selectedEntry?.hasError ?? false;

  bool get isEmpty => !isLoading && !hasError && tracks.isEmpty;
}
