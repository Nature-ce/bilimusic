import 'dart:io';

import 'package:bilimusic/feature/statistics/data/statistics_local_repository.dart';
import 'package:bilimusic/feature/statistics/domain/song_statistics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

void main() {
  late Box<Map> box;
  late StatisticsLocalRepository repository;

  setUpAll(() {
    Hive.init(Directory.systemTemp.path);
  });

  setUp(() async {
    box = await Hive.openBox<Map>('statistics_repository_test');
    await box.clear();
    repository = StatisticsLocalRepository(box);
  });

  tearDown(() => box.close());

  SongStatistics statistics(String stableId) =>
      SongStatistics(stableId: stableId, title: stableId, playCount: 1);

  test('falls back to the only cid record', () async {
    await repository.write(statistics('bvid:BV1:cid:123'));

    expect(repository.readCompatible('bvid:BV1')?.stableId, 'bvid:BV1:cid:123');
  });

  test('does not guess between multiple cid records', () async {
    await repository.write(statistics('bvid:BV1:cid:123'));
    await repository.write(statistics('bvid:BV1:cid:456'));

    expect(repository.readCompatible('bvid:BV1'), isNull);
  });

  test('exact cid lookup takes precedence', () async {
    await repository.write(statistics('bvid:BV1:cid:123'));
    await repository.write(statistics('bvid:BV1:cid:456'));

    expect(
      repository.readCompatible('bvid:BV1:cid:456')?.stableId,
      'bvid:BV1:cid:456',
    );
  });

  test('counts songs first played inside a range', () async {
    await repository.write(
      const SongStatistics(stableId: 'a', firstPlayedAtEpochMs: 1000),
    );
    await repository.write(
      const SongStatistics(stableId: 'b', firstPlayedAtEpochMs: 2000),
    );
    await repository.write(
      const SongStatistics(stableId: 'c', firstPlayedAtEpochMs: 3000),
    );
    await repository.write(const SongStatistics(stableId: 'd'));

    expect(repository.countFirstPlayedBetween(1000, 3000), 2);
    expect(repository.countFirstPlayedBetween(2000, 4000), 2);
    expect(repository.countFirstPlayedBetween(0, 1000), 0);
  });

  test('lists songs last played in a range sorted by time', () async {
    await repository.write(
      const SongStatistics(
        stableId: 'a',
        lastPlayedAtEpochMs: 5000,
        totalPlayedMs: 1000,
        playCount: 1,
      ),
    );
    await repository.write(
      const SongStatistics(
        stableId: 'b',
        lastPlayedAtEpochMs: 6000,
        totalPlayedMs: 3000,
        playCount: 2,
      ),
    );
    await repository.write(
      const SongStatistics(
        stableId: 'c',
        lastPlayedAtEpochMs: 9000,
        totalPlayedMs: 5000,
        playCount: 3,
      ),
    );

    final List<SongStatistics> songs = repository.songsLastPlayedBetween(
      4000,
      8000,
    );

    expect(songs.map((SongStatistics song) => song.stableId), <String>[
      'b',
      'a',
    ]);
    expect(songs.first.totalPlayedMs, 3000);
  });
}
