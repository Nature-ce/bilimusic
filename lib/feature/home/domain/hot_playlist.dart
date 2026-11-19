import 'package:bilimusic/common/util/format_util.dart';
import 'package:bilimusic/feature/home/domain/music_chart_platform.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'hot_playlist.freezed.dart';

/// 其它音乐平台的热门歌单。
@freezed
abstract class HotPlaylist with _$HotPlaylist {
  const factory HotPlaylist({
    required MusicChartPlatform platform,
    required String id,
    required String name,
    required String coverUrl,
    @Default(0) int playCount,
    @Default(0) int trackCount,
    @Default('') String creator,
    @Default('') String description,
  }) = _HotPlaylist;

  const HotPlaylist._();

  String get key => '${platform.name}:$id';

  String get playCountText => formatCompactCount(playCount);

  String get trackCountText => '$trackCount 首';

  /// 卡片第二行：播放量 · 曲数（曲数未知时只显示播放量）。
  String get summaryText {
    final List<String> segments = <String>[
      if (playCount > 0) playCountText,
      if (trackCount > 0) trackCountText,
    ];
    return segments.join(' · ');
  }
}
