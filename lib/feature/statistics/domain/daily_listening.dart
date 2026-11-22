import 'package:freezed_annotation/freezed_annotation.dart';

part 'daily_listening.freezed.dart';

@freezed
abstract class DailyListening with _$DailyListening {
  const factory DailyListening({
    @Default(0) int listenedMs,
    @Default(0) int songs,
  }) = _DailyListening;
}

@freezed
abstract class WeeklyListeningSummary with _$WeeklyListeningSummary {
  const WeeklyListeningSummary._();

  const factory WeeklyListeningSummary({
    @Default(<DailyListening>[]) List<DailyListening> days,
    @Default(0) int weekListenedMs,
    @Default(0) int weekSongs,
    @Default(0) int lastWeekSongs,
  }) = _WeeklyListeningSummary;

  bool get hasData => weekListenedMs > 0 || weekSongs > 0;

  int get songsDelta => weekSongs - lastWeekSongs;

  bool get hasLastWeekData => lastWeekSongs > 0;

  int get maxDayListenedMs {
    int maxValue = 0;
    for (final DailyListening day in days) {
      if (day.listenedMs > maxValue) {
        maxValue = day.listenedMs;
      }
    }
    return maxValue;
  }

  String get listenedText {
    final int totalMinutes = weekListenedMs ~/ 60000;
    if (totalMinutes <= 0) {
      return '不到 1 分钟';
    }
    final int hours = totalMinutes ~/ 60;
    final int minutes = totalMinutes % 60;
    if (hours <= 0) {
      return '$minutes 分钟';
    }
    if (minutes <= 0) {
      return '$hours 小时';
    }
    return '$hours 小时 $minutes 分';
  }
}
