import 'package:bilimusic/feature/statistics/domain/daily_listening.dart';
import 'package:bilimusic/feature/statistics/domain/listening_report.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const List<DailyListening> days = <DailyListening>[
    DailyListening(listenedMs: 600000),
    DailyListening(listenedMs: 0),
    DailyListening(listenedMs: 1800000),
    DailyListening(listenedMs: 0),
    DailyListening(listenedMs: 600000),
    DailyListening(listenedMs: 0),
    DailyListening(listenedMs: 0),
  ];

  const List<DailyListening> lastWeekDays = <DailyListening>[
    DailyListening(listenedMs: 300000),
    DailyListening(listenedMs: 0),
    DailyListening(listenedMs: 0),
    DailyListening(listenedMs: 0),
    DailyListening(listenedMs: 0),
    DailyListening(listenedMs: 0),
    DailyListening(listenedMs: 0),
  ];

  ListeningReport report({
    List<DailyListening> dayList = days,
    List<DailyListening> lastWeek = lastWeekDays,
    int weekListenedMs = 3000000,
    int lastWeekListenedMs = 300000,
    int weekSongs = 42,
    int lastWeekSongs = 34,
    int elapsedDays = 7,
    int newSongCount = 6,
    int streakDays = 3,
  }) {
    return ListeningReport(
      days: dayList,
      lastWeekDays: lastWeek,
      weekListenedMs: weekListenedMs,
      lastWeekListenedMs: lastWeekListenedMs,
      weekSongs: weekSongs,
      lastWeekSongs: lastWeekSongs,
      newSongCount: newSongCount,
      streakDays: streakDays,
      elapsedDays: elapsedDays,
      weekStart: DateTime(2026, 11, 16),
    );
  }

  test('derives weekly metrics from the current week', () {
    final ListeningReport value = report();

    expect(value.hasData, isTrue);
    expect(value.listenedDays, 3);
    expect(value.maxDayListenedMs, 1800000);
    expect(value.peakDayIndex, 2);
    expect(value.averageDailyMs, 3000000 ~/ 7);
    expect(value.weekRangeLabel, '11月16日 - 11月22日');
    expect(value.listenedText, '50 分钟');
  });

  test('uses elapsed days for the daily average', () {
    final ListeningReport value = report(elapsedDays: 3);

    expect(value.averageDailyMs, 1000000);
  });

  test('describes the comparison with last week', () {
    final ListeningReport ahead = report();
    expect(ahead.minutesDelta, (3000000 - 300000) ~/ 60000);
    expect(ahead.comparisonLabel, startsWith('比上周多'));

    final ListeningReport behind = report(weekListenedMs: 120000);
    expect(behind.comparisonLabel, startsWith('比上周少'));

    final ListeningReport equal = report(weekListenedMs: 300000);
    expect(equal.comparisonLabel, '与上周持平');
  });

  test('falls back when last week has no data', () {
    final ListeningReport value = report(
      lastWeek: const <DailyListening>[],
      lastWeekListenedMs: 0,
      lastWeekSongs: 0,
    );

    expect(value.hasLastWeekData, isFalse);
    expect(value.comparisonLabel, '开始记录的第一周');
  });

  test('formats listening durations', () {
    expect(formatListenedMinutes(0), '0 分钟');
    expect(formatListenedMinutes(60000), '1 分钟');
    expect(formatListenedMinutes(3600000), '1 小时');
    expect(formatListenedMinutes(3900000), '1 小时 5 分');
    expect(formatDelta(75, '分钟'), '1 小时 15 分');
    expect(formatDelta(45, '分钟'), '45 分钟');
  });
}
