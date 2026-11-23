import 'dart:io';

import 'package:bilimusic/feature/statistics/data/daily_listening_repository.dart';
import 'package:bilimusic/feature/statistics/domain/daily_listening.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

void main() {
  late Directory directory;
  late Box<Map> box;
  late DailyListeningRepository repository;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('daily_listening_test');
    Hive.init(directory.path);
    box = await Hive.openBox<Map>('daily_listening_box');
    repository = DailyListeningRepository(box);
  });

  tearDown(() async {
    await Hive.close();
    await directory.delete(recursive: true);
  });

  test('accumulates listening time and songs per day', () async {
    final DateTime day = DateTime(2026, 11, 18);
    await repository.addListenedMs(day, 60000);
    await repository.addListenedMs(day, 30000);
    await repository.addSong(day);

    final DailyListening value = repository.read(day);
    expect(value.listenedMs, 90000);
    expect(value.songs, 1);
    expect(repository.read(DateTime(2026, 11, 19)).listenedMs, 0);
  });

  test('summarizes this week and compares with last week', () async {
    final DateTime monday = DateTime(2026, 11, 16);
    await repository.addListenedMs(monday, 600000);
    await repository.addListenedMs(monday.add(const Duration(days: 2)), 300000);
    for (int index = 0; index < 3; index += 1) {
      await repository.addSong(monday.add(const Duration(days: 2)));
    }
    for (int index = 0; index < 4; index += 1) {
      await repository.addSong(monday.subtract(const Duration(days: 5)));
    }

    final WeeklyListeningSummary summary = repository.summary(
      DateTime(2026, 11, 22, 21, 30),
    );

    expect(summary.days, hasLength(7));
    expect(summary.weekListenedMs, 900000);
    expect(summary.weekSongs, 3);
    expect(summary.lastWeekSongs, 4);
    expect(summary.songsDelta, -1);
    expect(summary.maxDayListenedMs, 600000);
    expect(summary.hasData, isTrue);
    expect(summary.listenedText, '15 分钟');
  });

  test('reports an empty week without data', () {
    final WeeklyListeningSummary summary = repository.summary(
      DateTime(2026, 11, 22),
    );

    expect(summary.hasData, isFalse);
    expect(summary.weekSongs, 0);
    expect(summary.listenedText, '不到 1 分钟');
  });

  test('reads week start and a range of days', () {
    final DateTime weekStart = repository.weekStartOf(
      DateTime(2026, 11, 22, 21, 30),
    );

    expect(weekStart, DateTime(2026, 11, 16));
    expect(repository.readDays(weekStart), hasLength(7));
    expect(
      repository
          .readDays(weekStart, count: 3)
          .map((DailyListening day) => day.listenedMs),
      <int>[0, 0, 0],
    );
  });

  test('counts consecutive listening days', () async {
    final DateTime today = DateTime(2026, 11, 22);
    await repository.addListenedMs(today, 60000);
    await repository.addListenedMs(
      today.subtract(const Duration(days: 1)),
      60000,
    );
    await repository.addListenedMs(
      today.subtract(const Duration(days: 2)),
      60000,
    );
    await repository.addListenedMs(
      today.subtract(const Duration(days: 4)),
      60000,
    );

    expect(repository.listenedDaysInRow(today), 3);
  });

  test('streak falls back to yesterday when today is empty', () async {
    final DateTime today = DateTime(2026, 11, 22);
    await repository.addListenedMs(
      today.subtract(const Duration(days: 1)),
      60000,
    );

    expect(repository.listenedDaysInRow(today), 1);
  });
}
