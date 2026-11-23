import 'dart:io';

import 'package:bilimusic/feature/up/data/favorite_up_update_repository.dart';
import 'package:bilimusic/feature/up/domain/favorite_up_update.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

void main() {
  late Directory directory;
  late Box<String> box;
  late FavoriteUpUpdateRepository repository;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp(
      'favorite_up_update_repository_test',
    );
    Hive.init(directory.path);
    box = await Hive.openBox<String>(favoriteUpUpdatesBoxName);
    repository = FavoriteUpUpdateRepository(box);
  });

  tearDown(() async {
    await Hive.close();
    await directory.delete(recursive: true);
  });

  test('round-trips updates through the JSON cache', () async {
    const FavoriteUpUpdate update = FavoriteUpUpdate(
      mid: 11,
      fetchedAtEpochMs: 1000,
      latestPublishAtEpochMs: 900,
      todayVideoCount: 2,
    );

    await repository.save(update);

    final Map<int, FavoriteUpUpdate> loaded = repository.load();

    expect(loaded.keys.toList(), <int>[11]);
    expect(loaded[11], update);
  });

  test('keeps failed updates with defaulted json fields', () async {
    await repository.save(
      const FavoriteUpUpdate(mid: 22, fetchedAtEpochMs: 2000, failed: true),
    );

    final FavoriteUpUpdate? loaded = repository.load()[22];

    expect(loaded, isNotNull);
    expect(loaded?.failed, isTrue);
    expect(loaded?.todayVideoCount, 0);
    expect(loaded?.latestPublishAtEpochMs, isNull);
  });

  test('ignores corrupted cache entries', () async {
    await box.put(33, 'not-json');
    await box.put(44, '{"mid": 44}');
    await repository.save(
      const FavoriteUpUpdate(mid: 55, fetchedAtEpochMs: 5000),
    );

    final Map<int, FavoriteUpUpdate> loaded = repository.load();

    expect(loaded.keys.toList(), <int>[55]);
  });

  test('clear empties the cache', () async {
    await repository.save(
      const FavoriteUpUpdate(mid: 66, fetchedAtEpochMs: 6000),
    );

    await repository.clear();

    expect(repository.load(), isEmpty);
  });
}
