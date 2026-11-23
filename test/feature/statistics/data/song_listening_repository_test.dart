import 'dart:io';

import 'package:bilimusic/feature/statistics/data/song_listening_repository.dart';
import 'package:bilimusic/feature/statistics/domain/listening_report.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

void main() {
  late Directory directory;
  late Box<Map> box;
  late SongListeningDailyRepository repository;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('song_listening_test');
    Hive.init(directory.path);
    box = await Hive.openBox<Map>('song_listening_box');
    repository = SongListeningDailyRepository(box);
  });

  tearDown(() async {
    await Hive.close();
    await directory.delete(recursive: true);
  });

  Future<void> record(
    DateTime day,
    String stableId, {
    int listenedMs = 60000,
    int plays = 1,
    String title = '',
  }) {
    return repository.record(
      day,
      stableId: stableId,
      title: title.isEmpty ? stableId : title,
      author: 'author',
      coverUrl: 'cover',
      listenedMs: listenedMs,
      plays: plays,
    );
  }

  test('accumulates listening time and plays per song per day', () async {
    final DateTime day = DateTime(2026, 11, 18);
    await record(day, 'bvid:BV1', listenedMs: 60000, plays: 1);
    await record(day, 'bvid:BV1', listenedMs: 30000, plays: 0);

    final List<ListeningReportSong> songs = repository.topSongs(
      DateTime(2026, 11, 16),
    );

    expect(songs, hasLength(1));
    expect(songs.single.stableId, 'bvid:BV1');
    expect(songs.single.listenedMs, 90000);
    expect(songs.single.plays, 1);
  });

  test('aggregates the week and ignores other weeks', () async {
    final DateTime weekStart = DateTime(2026, 11, 16);
    await record(weekStart, 'song-a', listenedMs: 120000, plays: 2);
    await record(
      weekStart.add(const Duration(days: 6)),
      'song-a',
      listenedMs: 120000,
      plays: 1,
    );
    await record(
      weekStart.add(const Duration(days: 3)),
      'song-b',
      listenedMs: 300000,
      plays: 1,
    );
    await record(
      weekStart.subtract(const Duration(days: 1)),
      'song-c',
      listenedMs: 900000,
      plays: 5,
    );

    final List<ListeningReportSong> songs = repository.topSongs(weekStart);

    expect(songs.map((ListeningReportSong song) => song.stableId), <String>[
      'song-b',
      'song-a',
    ]);
    expect(songs.first.listenedMs, 300000);
    expect(songs.last.listenedMs, 240000);
    expect(songs.last.plays, 3);
  });

  test('respects the limit and skips empty records', () async {
    final DateTime weekStart = DateTime(2026, 11, 16);
    await record(weekStart, 'song-a', listenedMs: 1000);
    await record(weekStart, 'song-b', listenedMs: 2000);
    await record(weekStart, 'song-c', listenedMs: 3000);
    await repository.record(
      weekStart,
      stableId: 'empty',
      title: 'empty',
      author: 'author',
      coverUrl: 'cover',
      listenedMs: 0,
      plays: 0,
    );

    final List<ListeningReportSong> songs = repository.topSongs(
      weekStart,
      limit: 2,
    );

    expect(songs.map((ListeningReportSong song) => song.stableId), <String>[
      'song-c',
      'song-b',
    ]);
  });
}
