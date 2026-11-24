import 'package:bilimusic/feature/statistics/domain/daily_listening.dart';
import 'package:bilimusic/feature/statistics/domain/listening_report.dart';
import 'package:bilimusic/feature/statistics/logic/listening_report.dart';
import 'package:bilimusic/feature/statistics/ui/listening_report_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final ListeningReport report = ListeningReport(
    days: <DailyListening>[
      DailyListening(listenedMs: 600000, songs: 2),
      DailyListening(listenedMs: 0),
      DailyListening(listenedMs: 1800000, songs: 3),
      DailyListening(listenedMs: 0),
      DailyListening(listenedMs: 0),
      DailyListening(listenedMs: 0),
      DailyListening(listenedMs: 0),
    ],
    lastWeekDays: <DailyListening>[DailyListening(listenedMs: 600000)],
    topSongs: <ListeningReportSong>[
      ListeningReportSong(
        stableId: 'bvid:BV1',
        title: '【𝐇𝐢-𝐑𝐞𝐬无损音质】测试',
        author: '𝐕𝐕音乐局',
        listenedMs: 2400000,
        plays: 3,
      ),
    ],
    weekListenedMs: 2400000,
    lastWeekListenedMs: 600000,
    weekSongs: 5,
    lastWeekSongs: 2,
    newSongCount: 4,
    streakDays: 3,
    elapsedDays: 5,
    weekStart: DateTime(2026, 11, 16),
  );

  Widget wrap(ListeningReport value) {
    return ProviderScope(
      overrides: [listeningReportProvider.overrideWithValue(value)],
      child: const MaterialApp(home: ListeningReportPage()),
    );
  }

  testWidgets('renders the weekly report sections', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(wrap(report));

    expect(find.text('听歌报告'), findsOneWidget);
    expect(find.text('本周听歌'), findsOneWidget);
    expect(find.text('40 分钟'), findsWidgets);
    expect(find.text('5 首 · 比上周多 30 分钟'), findsOneWidget);
    expect(find.text('11月16日 - 11月22日'), findsOneWidget);
    expect(find.text('听歌天数'), findsOneWidget);
    expect(find.text('2/5 天'), findsOneWidget);
    expect(find.text('连续听歌'), findsOneWidget);
    expect(find.text('本周新增'), findsOneWidget);
    expect(find.text('4 首'), findsOneWidget);
    expect(find.text('本周最常听'), findsOneWidget);
    expect(find.text('【Hi-Res无损音质】测试'), findsOneWidget);
    expect(find.text('VV音乐局'), findsOneWidget);
    expect(find.textContaining('𝐇𝐢'), findsNothing);
    expect(find.text('本周'), findsOneWidget);
    expect(find.text('上周'), findsOneWidget);
  });

  testWidgets('shows an empty state without data', (WidgetTester tester) async {
    await tester.pumpWidget(wrap(const ListeningReport()));

    expect(find.text('还没有听歌数据'), findsOneWidget);
    expect(find.text('本周最常听'), findsNothing);
  });
}
