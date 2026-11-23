import 'package:bilimusic/feature/profile/ui/components/weekly_listening_card.dart';
import 'package:bilimusic/feature/statistics/domain/daily_listening.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const List<int> _dayListenedMs = <int>[
  0,
  60000,
  120000,
  3600000,
  120000,
  60000,
  0,
];
const int _peakIndex = 3;

WeeklyListeningSummary _summary({List<DailyListening>? days}) {
  return WeeklyListeningSummary(
    days:
        days ??
        _dayListenedMs
            .map((int listenedMs) => DailyListening(listenedMs: listenedMs))
            .toList(growable: false),
    weekListenedMs: 42 * 60000,
    weekSongs: 42,
    lastWeekSongs: 34,
  );
}

Future<void> _pumpCard(
  WidgetTester tester,
  WeeklyListeningSummary summary,
) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: WeeklyListeningCard(summary: summary, onReportTap: () {}),
      ),
    ),
  );
}

void main() {
  testWidgets('renders summary copy and seven bars', (
    WidgetTester tester,
  ) async {
    await _pumpCard(tester, _summary());

    expect(find.text('本周听了 42 分钟'), findsOneWidget);
    expect(find.text('42'), findsOneWidget);
    expect(find.textContaining('比上周多 8 首'), findsOneWidget);
    expect(find.text('查看报告 ›'), findsOneWidget);

    for (int index = 0; index < 7; index += 1) {
      final Finder bar = find.byKey(
        ValueKey<String>('weekly-listening-bar-$index'),
      );
      expect(bar, findsOneWidget);
      expect(tester.getSize(bar).width, moreOrLessEquals(30, epsilon: 0.1));
    }
  });

  testWidgets('peak bar is taller than the others', (
    WidgetTester tester,
  ) async {
    await _pumpCard(tester, _summary());

    final double peakHeight = tester
        .getSize(
          find.byKey(
            const ValueKey<String>('weekly-listening-bar-$_peakIndex'),
          ),
        )
        .height;

    expect(peakHeight, moreOrLessEquals(60, epsilon: 0.1));

    for (int index = 0; index < 7; index += 1) {
      if (index == _peakIndex) {
        continue;
      }
      final double height = tester
          .getSize(find.byKey(ValueKey<String>('weekly-listening-bar-$index')))
          .height;
      expect(height, lessThan(peakHeight));
    }
  });

  testWidgets('no listening data falls back to zero minutes', (
    WidgetTester tester,
  ) async {
    await _pumpCard(tester, const WeeklyListeningSummary());

    expect(find.text('本周听了 0 分钟'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('weekly-listening-bar-0')),
      findsOneWidget,
    );
  });
}
