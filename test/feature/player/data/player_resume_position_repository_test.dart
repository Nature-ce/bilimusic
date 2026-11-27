import 'dart:io';

import 'package:bilimusic/core/hive/hive_keys.dart';
import 'package:bilimusic/feature/player/data/player_resume_position_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

void main() {
  late Directory tempDirectory;
  late Box<String> box;
  late PlayerResumePositionRepository repository;

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp('resume_position');
    Hive.init(tempDirectory.path);
    box = await Hive.openBox<String>('prefs_resume_position_test');
    repository = PlayerResumePositionRepository(box);
  });

  tearDown(() async {
    await box.close();
    await tempDirectory.delete(recursive: true);
  });

  test('写入后能读回同一首歌的续播位置', () async {
    await repository.write(
      stableId: 'BV1:cid:100',
      position: const Duration(minutes: 1, seconds: 23),
    );

    final ({String stableId, Duration position})? restored = repository.read();

    expect(restored?.stableId, 'BV1:cid:100');
    expect(restored?.position, const Duration(minutes: 1, seconds: 23));
    expect(box.get(HiveKeys.playerResumePosition), 'BV1:cid:100|83000');
  });

  test('清除后续播位置为空', () async {
    await repository.write(
      stableId: 'BV1',
      position: const Duration(seconds: 5),
    );
    await repository.clear();

    expect(repository.read(), isNull);
    expect(box.get(HiveKeys.playerResumePosition), isNull);
  });

  test('损坏或空的值被忽略', () async {
    for (final String raw in <String>[
      '',
      'BV1',
      '|1000',
      'BV1|',
      'BV1|abc',
      'BV1|-1',
    ]) {
      await box.put(HiveKeys.playerResumePosition, raw);
      expect(repository.read(), isNull, reason: 'raw=$raw');
    }
  });

  test('空 stableId 或负时长不写入', () async {
    await repository.write(stableId: '', position: const Duration(seconds: 5));
    await repository.write(
      stableId: 'BV1',
      position: const Duration(seconds: -1),
    );

    expect(repository.read(), isNull);
  });
}
