import 'package:bilimusic/feature/home/domain/matchable_track.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/radar/domain/radar_pick.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'daily_recommendation.freezed.dart';
part 'daily_recommendation.g.dart';

String dailyDateKey(DateTime date) {
  final String month = date.month.toString().padLeft(2, '0');
  final String day = date.day.toString().padLeft(2, '0');
  return '${date.year.toString().padLeft(4, '0')}-$month-$day';
}

/// 每日推荐里的一首：只留重播所需的字段，换设备 / 重启后照样能搜回来。
@freezed
abstract class DailyPick with _$DailyPick implements MatchableTrack {
  const DailyPick._();

  const factory DailyPick({
    required String title,
    required String artist,
    required RadarReason reason,
    @Default('') String coverUrl,
    @Default(0) int durationSeconds,
    @Default('') String platform,
    String? reasonDetail,
    @Default('') String bvid,
    @Default(0) int aid,
    int? cid,
    int? page,
    @Default('') String videoTitle,
    @Default('') String videoAuthor,
    @Default('') String videoCoverUrl,
    @Default('') String videoDurationText,
  }) = _DailyPick;

  factory DailyPick.fromJson(Map<String, dynamic> json) =>
      _$DailyPickFromJson(json);

  /// 生成推荐时就把 B 站视频解析好存下来：每日推荐当天不变，
  /// 「播放全部」不该每次都重新搜一遍。
  bool get isResolved => bvid.isNotEmpty || aid > 0;

  @override
  PlayableItem? get directItem {
    if (!isResolved) {
      return null;
    }
    return PlayableItem(
      aid: aid,
      bvid: bvid,
      title: videoTitle.isEmpty ? title : videoTitle,
      author: videoAuthor,
      coverUrl: videoCoverUrl.isEmpty ? coverUrl : videoCoverUrl,
      cid: cid,
      page: page,
      durationText: videoDurationText.isEmpty ? null : videoDurationText,
    );
  }

  String get key => '$title|$artist';

  @override
  String get searchKeyword => '$title $artist'.trim();

  String get durationText {
    if (durationSeconds <= 0) {
      return '--:--';
    }
    final int minutes = durationSeconds ~/ 60;
    final int seconds = durationSeconds % 60;
    if (minutes >= 60) {
      final int hours = minutes ~/ 60;
      return '${hours.toString().padLeft(2, '0')}:'
          '${(minutes % 60).toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }
}

/// 当天固定的一份推荐；`dateKey` 变了就该重新生成。
@freezed
abstract class DailyRecommendation with _$DailyRecommendation {
  const DailyRecommendation._();

  const factory DailyRecommendation({
    required String dateKey,
    @Default(0) int generatedAtEpochMs,
    @Default(<DailyPick>[]) List<DailyPick> picks,
  }) = _DailyRecommendation;

  factory DailyRecommendation.fromJson(Map<String, dynamic> json) =>
      _$DailyRecommendationFromJson(json);
}
