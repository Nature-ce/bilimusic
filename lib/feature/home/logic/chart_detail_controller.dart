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

  /// 静默刷新：保留已有数据（页面骨架不闪），刷新失败时保留旧数据。
  /// 返回曲目是否有变化，调用方据此提示「已是最新」。
  Future<bool> refresh() async {
    final ChartDetailData? previous = state.asData?.value;
    final ChartDetailData data = await _load(chart);
    if (!ref.mounted) {
      return false;
    }
    state = AsyncData<ChartDetailData>(data);
    return !_sameTracks(previous, data);
  }

  static bool _sameTracks(ChartDetailData? previous, ChartDetailData next) {
    if (previous == null || previous.tracks.length != next.tracks.length) {
      return false;
    }
    for (int index = 0; index < next.tracks.length; index += 1) {
      if (previous.tracks[index].key != next.tracks[index].key) {
        return false;
      }
    }
    return true;
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
