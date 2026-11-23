import 'dart:io';

import 'package:bilimusic/feature/statistics/data/statistics_local_repository.dart';
import 'package:bilimusic/feature/statistics/domain/song_statistics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

void main() {
  late Directory directory;
  late Box<Map> box;
  late StatisticsLocalRepository repository;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp(
      'statistics_author_totals_test',
    );
    Hive.init(directory.path);
    box = await Hive.openBox<Map>('statistics_author_totals_box');
    repository = StatisticsLocalRepository(box);
  });

  tearDown(() async {
    await Hive.close();
    await directory.delete(recursive: true);
  });

  test('aggregates played time per trimmed author', () async {
    await repository.write(
      const SongStatistics(stableId: 'a', author: 'UP甲', totalPlayedMs: 1000),
    );
    await repository.write(
      const SongStatistics(stableId: 'b', author: ' UP甲 ', totalPlayedMs: 2000),
    );
    await repository.write(
      const SongStatistics(stableId: 'c', author: 'UP乙', totalPlayedMs: 3000),
    );

    expect(repository.totalPlayedMsByAuthor(), <String, int>{
      'UP甲': 3000,
      'UP乙': 3000,
    });
  });

  test('skips empty authors and zero listening time', () async {
    await repository.write(
      const SongStatistics(stableId: 'a', author: '', totalPlayedMs: 500),
    );
    await repository.write(
      const SongStatistics(stableId: 'b', author: '   ', totalPlayedMs: 500),
    );
    await repository.write(
      const SongStatistics(stableId: 'c', author: 'UP丙', totalPlayedMs: 0),
    );

    expect(repository.totalPlayedMsByAuthor(), isEmpty);
  });
}
