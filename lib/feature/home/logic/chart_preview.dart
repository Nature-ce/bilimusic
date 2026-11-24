import 'package:bilimusic/feature/home/domain/music_chart.dart';
import 'package:bilimusic/feature/home/domain/music_chart_track.dart';
import 'package:bilimusic/feature/home/logic/music_chart_controller.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'chart_preview.g.dart';

/// 榜单本身没有封面图，用榜单里第 1 首有效封面顶替。
///
/// `fetchTracks` 有内存缓存，网格是懒加载的，滑到哪张才请求哪张榜单，
/// 之后进入榜单详情还能直接复用这份缓存。
@Riverpod(keepAlive: true)
Future<String?> chartPreviewCover(Ref ref, MusicChart chart) async {
  final List<MusicChartTrack> tracks = await ref
      .read(musicChartRepositoryProvider)
      .fetchTracks(chart);
  for (final MusicChartTrack track in tracks) {
    final String cover = track.coverUrl.trim();
    if (cover.isNotEmpty) {
      return cover;
    }
  }
  return null;
}
