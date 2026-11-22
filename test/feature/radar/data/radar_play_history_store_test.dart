import 'dart:io';

import 'package:bilimusic/core/settings/app_settings_store.dart';
import 'package:bilimusic/feature/radar/data/radar_play_history_store.dart';
import 'package:bilimusic/feature/radar/domain/radar_play_record.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

void main() {
  late Directory tempDirectory;
  late Box<String> box;
  late RadarPlayHistoryStore store;

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp('radar_history');
    Hive.init(tempDirectory.path);
    box = await Hive.openBox<String>('prefs_radar_test');
    store = RadarPlayHistoryStore(AppSettingsStore(box));
  });

  tearDown(() async {
    await box.close();
    await tempDirectory.delete(recursive: true);
  });

  test('保存后能原样读回', () async {
    await store.save(<RadarPlayRecord>[
      _record(
        stableId: '1',
        title: '晴天',
        artist: '周杰伦',
        playedMs: 180000,
        at: DateTime(2026, 11, 20),
      ),
      _record(
        stableId: '2',
        title: '于是',
        artist: '郑润泽',
        playedMs: 90000,
        at: DateTime(2026, 11, 22),
      ),
    ]);

    final List<RadarPlayRecord> loaded = store.load();

    expect(loaded, hasLength(2));
    expect(loaded.first.title, '于是');
    expect(loaded.first.artist, '郑润泽');
    expect(loaded.last.playedMs, 180000);
  });

  test('超过上限时只保留最近更新的记录', () async {
    final DateTime base = DateTime(2026, 11, 1);
    await store.save(<RadarPlayRecord>[
      for (int index = 0; index < 300; index += 1)
        _record(
          stableId: 's$index',
          title: '歌$index',
          artist: '歌手$index',
          playedMs: 60000,
          at: base.add(Duration(minutes: index)),
        ),
    ]);

    final List<RadarPlayRecord> loaded = store.load();

    expect(loaded, hasLength(RadarPlayHistoryStore.maxRecords));
    expect(loaded.first.title, '歌299');
    expect(
      loaded.any((RadarPlayRecord record) => record.title == '歌0'),
      isFalse,
    );
  });

  test('坏数据不会让整个历史读崩', () async {
    await box.put('radar.play_history', '[{"stableId":"ok","title":"晴天"},');
    expect(store.load(), isEmpty);

    await box.put(
      'radar.play_history',
      '[{"bad":1},{"stableId":"1","title":"晴天","artist":"周杰伦"}]',
    );
    final List<RadarPlayRecord> loaded = store.load();
    expect(loaded, hasLength(1));
    expect(loaded.single.title, '晴天');
  });
}

RadarPlayRecord _record({
  required String stableId,
  required String title,
  required String artist,
  required int playedMs,
  DateTime? at,
}) {
  return RadarPlayRecord(
    stableId: stableId,
    title: title,
    artist: artist,
    playedMs: playedMs,
    durationMs: 200000,
    updatedAtMs: (at ?? DateTime(2026, 11, 22)).millisecondsSinceEpoch,
  );
}
