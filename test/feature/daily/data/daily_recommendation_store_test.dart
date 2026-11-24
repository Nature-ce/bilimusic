import 'dart:io';

import 'package:bilimusic/core/hive/hive_keys.dart';
import 'package:bilimusic/feature/daily/data/daily_recommendation_store.dart';
import 'package:bilimusic/feature/daily/domain/daily_recommendation.dart';
import 'package:bilimusic/feature/radar/domain/radar_pick.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

void main() {
  late Directory tempDirectory;
  late Box<String> box;
  late DailyRecommendationStore store;

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp('daily_recommend');
    Hive.init(tempDirectory.path);
    box = await Hive.openBox<String>('prefs_daily_recommendation_test');
    store = DailyRecommendationStore(box);
  });

  tearDown(() async {
    await box.close();
    await tempDirectory.delete(recursive: true);
  });

  test('保存后能原样读回', () async {
    await store.save(
      DailyRecommendation(
        dateKey: '2026-11-24',
        generatedAtEpochMs: 1732435200000,
        picks: <DailyPick>[
          const DailyPick(
            title: '晴天',
            artist: '周杰伦',
            reason: RadarReason.familiarArtist,
            reasonDetail: '周杰伦',
            coverUrl: 'https://example.com/cover.jpg',
            durationSeconds: 269,
            platform: 'netease',
          ),
          const DailyPick(
            title: '于是',
            artist: '郑润泽',
            reason: RadarReason.explorer,
            platform: 'tencent',
          ),
        ],
      ),
    );

    final DailyRecommendation? loaded = store.load();

    expect(loaded, isNotNull);
    expect(loaded!.dateKey, '2026-11-24');
    expect(loaded.generatedAtEpochMs, 1732435200000);
    expect(loaded.picks, hasLength(2));
    expect(loaded.picks.first.title, '晴天');
    expect(loaded.picks.first.artist, '周杰伦');
    expect(loaded.picks.first.reason, RadarReason.familiarArtist);
    expect(loaded.picks.first.reasonDetail, '周杰伦');
    expect(loaded.picks.first.coverUrl, 'https://example.com/cover.jpg');
    expect(loaded.picks.first.durationSeconds, 269);
    expect(loaded.picks.first.durationText, '04:29');
    expect(loaded.picks.first.platform, 'netease');
    expect(loaded.picks.last.reason, RadarReason.explorer);
    expect(loaded.picks.last.reasonDetail, isNull);
    expect(loaded.picks.last.durationText, '--:--');
    expect(box.get(HiveKeys.dailyRecommendation), contains('familiarArtist'));
  });

  test('坏数据返回 null', () async {
    await box.put(HiveKeys.dailyRecommendation, '{"dateKey":');
    expect(store.load(), isNull);

    await box.put(HiveKeys.dailyRecommendation, '[]');
    expect(store.load(), isNull);

    await box.put(HiveKeys.dailyRecommendation, '{"dateKey":" "}');
    expect(store.load(), isNull);

    await box.put(
      HiveKeys.dailyRecommendation,
      '{"dateKey":"2026-11-24","picks":[{"title":"缺歌手","reason":"explorer"}]}',
    );
    expect(store.load(), isNull);
  });

  test('没存过返回 null，清空后又变回 null', () async {
    expect(store.load(), isNull);

    await store.save(const DailyRecommendation(dateKey: '2026-11-24'));
    expect(store.load(), isNotNull);

    await store.clear();
    expect(store.load(), isNull);
  });
}
