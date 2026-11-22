import 'package:bilimusic/feature/home/domain/chart_detail_data.dart';
import 'package:bilimusic/feature/home/domain/music_chart.dart';
import 'package:bilimusic/feature/home/domain/music_chart_track.dart';
import 'package:bilimusic/feature/home/logic/music_chart_controller.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'chart_detail_controller.g.dart';

@riverpod
class ChartDetailController extends _$ChartDetailController {
  @override
  Future<ChartDetailData> build(MusicChart chart) {
    return _load(chart);
  }

  Future<void> refresh() async {
    state = const AsyncLoading<ChartDetailData>();
    try {
      final ChartDetailData data = await _load(chart);
      if (!ref.mounted) {
        return;
      }
      state = AsyncData<ChartDetailData>(data);
    } on Object catch (error, stackTrace) {
      if (!ref.mounted) {
        return;
      }
      state = AsyncError<ChartDetailData>(error, stackTrace);
    }
  }

  Future<ChartDetailData> _load(MusicChart chart) async {
    final List<MusicChartTrack> tracks = await ref
        .read(musicChartRepositoryProvider)
        .fetchTracks(chart);
    return ChartDetailData(
      tracks: tracks,
      updatedAtMs: DateTime.now().millisecondsSinceEpoch,
    );
  }
}
