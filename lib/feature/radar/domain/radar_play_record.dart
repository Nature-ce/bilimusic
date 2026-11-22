import 'package:bilimusic/feature/radar/domain/radar_keys.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'radar_play_record.freezed.dart';
part 'radar_play_record.g.dart';

/// 一次收听记录，雷达用它判断「你最近爱听什么、什么歌你听两下就切走」。
@freezed
abstract class RadarPlayRecord with _$RadarPlayRecord {
  const RadarPlayRecord._();

  const factory RadarPlayRecord({
    required String stableId,
    required String title,
    required String artist,
    @Default(0) int playedMs,
    @Default(0) int durationMs,
    @Default(1) int playCount,
    @Default(0) int updatedAtMs,
  }) = _RadarPlayRecord;

  factory RadarPlayRecord.fromJson(Map<String, dynamic> json) =>
      _$RadarPlayRecordFromJson(json);

  String get trackKey => radarTrackKey(title: title, artist: artist);

  String get artistKey => normalizeRadarKey(artist);

  /// 听完的比例；时长未知时按「听了 90 秒」估作听完。
  double get completionRatio {
    final int base = durationMs > 0 ? durationMs : 90000;
    return (playedMs / base).clamp(0.0, 1.0);
  }

  /// 播放量不足一成半就切走，当作「不喜欢」这类歌。
  bool get isSkip => playedMs >= 3000 && completionRatio < 0.15;

  DateTime get updatedAt => DateTime.fromMillisecondsSinceEpoch(updatedAtMs);
}
