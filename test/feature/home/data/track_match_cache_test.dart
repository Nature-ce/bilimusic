import 'dart:io';

import 'package:bilimusic/feature/home/data/track_match_cache.dart';
import 'package:bilimusic/feature/home/domain/music_chart_catalog.dart';
import 'package:bilimusic/feature/home/domain/music_chart_track.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

const MusicChartTrack _track = MusicChartTrack(
  chart: MusicChartCatalog.defaultChart,
  rank: 1,
  title: '晴天',
  artist: '周杰伦',
  coverUrl: '',
  durationSeconds: 269,
);

void main() {
  late Directory tempDirectory;
  late Box<String> box;
  late TrackMatchCache cache;

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp('track_match_cache');
    Hive.init(tempDirectory.path);
    box = await Hive.openBox<String>('prefs_match_cache_test');
    cache = TrackMatchCache(box);
  });

  tearDown(() async {
    await box.close();
    await tempDirectory.delete(recursive: true);
  });

  test('命中缓存后能读回可播放项', () async {
    await cache.writeHit(
      _track,
      const PlayableItem(
        aid: 117556492898443,
        bvid: 'BV19gxX6iEE9',
        cid: 43314186691,
        page: 1,
        title: '晴天 - 周杰伦',
        author: '某UP主',
        coverUrl: 'https://example.com/a.jpg',
        durationText: '04:29',
      ),
    );

    final PlayableItem? item = cache.readHit(_track);

    expect(item?.bvid, 'BV19gxX6iEE9');
    expect(item?.cid, 43314186691);
    expect(item?.title, '晴天 - 周杰伦');
    expect(cache.isFreshMiss(_track), isFalse);
  });

  test('匹配不到会记一笔负缓存，过期后失效', () async {
    await cache.writeMiss(_track);

    expect(cache.isFreshMiss(_track), isTrue);
    expect(cache.readHit(_track), isNull);

    final TrackMatchCache shortTtl = TrackMatchCache(
      box,
      missTtl: const Duration(milliseconds: 1),
    );
    await Future<void>.delayed(const Duration(milliseconds: 5));
    expect(shortTtl.isFreshMiss(_track), isFalse);
  });

  test('命中缓存过期后不再返回', () async {
    await cache.writeHit(
      _track,
      const PlayableItem(
        aid: 1,
        bvid: 'BV1',
        title: '晴天',
        author: 'up',
        coverUrl: '',
      ),
    );

    final TrackMatchCache shortTtl = TrackMatchCache(
      box,
      hitTtl: const Duration(milliseconds: 1),
    );
    await Future<void>.delayed(const Duration(milliseconds: 5));

    expect(shortTtl.readHit(_track), isNull);
  });
}
