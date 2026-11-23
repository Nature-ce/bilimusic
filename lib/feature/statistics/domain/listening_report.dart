import 'package:bilimusic/feature/statistics/domain/daily_listening.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'listening_report.freezed.dart';

@freezed
abstract class ListeningReportSong with _$ListeningReportSong {
  const factory ListeningReportSong({
    required String stableId,
    @Default('') String title,
    @Default('') String author,
    @Default('') String coverUrl,
    @Default(0) int listenedMs,
    @Default(0) int plays,
  }) = _ListeningReportSong;
}

@freezed
abstract class ListeningReport with _$ListeningReport {
  const ListeningReport._();

  const factory ListeningReport({
    @Default(<DailyListening>[]) List<DailyListening> days,
    @Default(<DailyListening>[]) List<DailyListening> lastWeekDays,
    @Default(<ListeningReportSong>[]) List<ListeningReportSong> topSongs,
    @Default(0) int weekListenedMs,
    @Default(0) int lastWeekListenedMs,
    @Default(0) int weekSongs,
    @Default(0) int lastWeekSongs,
    @Default(0) int newSongCount,
    @Default(0) int streakDays,
    @Default(0) int elapsedDays,
    @Default(false) bool topSongsAreCumulative,
    DateTime? weekStart,
  }) = _ListeningReport;

  bool get hasData => weekListenedMs > 0 || weekSongs > 0;

  int get listenedDays =>
      days.where((DailyListening day) => day.listenedMs > 0).length;

  int get averageDailyMs {
    final int divisor = elapsedDays <= 0 ? 1 : elapsedDays;
    return weekListenedMs ~/ divisor;
  }

  int get maxDayListenedMs {
    int value = 0;
    for (final DailyListening day in days) {
      if (day.listenedMs > value) {
        value = day.listenedMs;
      }
    }
    return value;
  }

  int get peakDayIndex {
    int index = -1;
    int value = 0;
    for (int position = 0; position < days.length; position += 1) {
      if (days[position].listenedMs > value) {
        value = days[position].listenedMs;
        index = position;
      }
    }
    return index;
  }

  int get minutesDelta =>
      (weekListenedMs - lastWeekListenedMs) ~/ Duration.millisecondsPerMinute;

  int get songsDelta => weekSongs - lastWeekSongs;

  bool get hasLastWeekData => lastWeekListenedMs > 0 || lastWeekSongs > 0;

  String get listenedText => formatListenedMinutes(weekListenedMs);

  String get lastWeekListenedText => formatListenedMinutes(lastWeekListenedMs);

  String get averageDailyText => formatListenedMinutes(averageDailyMs);

  String get weekRangeLabel {
    final DateTime? start = weekStart;
    if (start == null) {
      return '';
    }
    final DateTime end = start.add(const Duration(days: 6));
    return '${start.month}月${start.day}日 - ${end.month}月${end.day}日';
  }

  String get comparisonLabel {
    if (!hasLastWeekData) {
      return '开始记录的第一周';
    }
    if (minutesDelta > 0) {
      return '比上周多 ${formatDelta(minutesDelta, '分钟')}';
    }
    if (minutesDelta < 0) {
      return '比上周少 ${formatDelta(minutesDelta.abs(), '分钟')}';
    }
    return '与上周持平';
  }
}

String formatListenedMinutes(int milliseconds) {
  final int totalMinutes = milliseconds ~/ Duration.millisecondsPerMinute;
  if (totalMinutes <= 0) {
    return '0 分钟';
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

String formatDelta(int value, String unit) {
  final int hours = value ~/ 60;
  if (hours <= 0) {
    return '$value $unit';
  }
  final int minutes = value % 60;
  return minutes <= 0 ? '$hours 小时' : '$hours 小时 $minutes 分';
}
