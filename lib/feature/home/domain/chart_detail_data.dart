import 'package:bilimusic/feature/home/domain/music_chart_track.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'chart_detail_data.freezed.dart';

@freezed
abstract class ChartDetailData with _$ChartDetailData {
  const factory ChartDetailData({
    required List<MusicChartTrack> tracks,
    required int updatedAtMs,
  }) = _ChartDetailData;
}
