import 'dart:convert';
import 'dart:io';

import 'package:bilimusic/feature/home/data/track_match_cache.dart';
import 'package:bilimusic/feature/home/domain/music_chart_catalog.dart';
import 'package:bilimusic/feature/home/domain/music_chart_track.dart';
import 'package:bilimusic/feature/home/logic/chart_track_matcher.dart';
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

String _keyFor(String title, String artist) {
  return 'match.v4|${ChartTrackMatcher.normalize(title)}|'
      '${ChartTrackMatcher.normalize(artist)}';
}

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

  test('负缓存默认有效期是 2 小时', () async {
    final int now = DateTime.now().millisecondsSinceEpoch;
    Future<void> writeMissAged(Duration age) {
      return box.put(
        _keyFor('晴天', '周杰伦'),
        jsonEncode(<String, dynamic>{
          'hit': false,
          'schema': 2,
          'reason': 'no-match',
          'at': now - age.inMilliseconds,
        }),
      );
    }

    await writeMissAged(const Duration(minutes: 119));
    expect(cache.isFreshMiss(_track), isTrue);

    await writeMissAged(const Duration(minutes: 121));
    expect(cache.isFreshMiss(_track), isFalse);
  });

  test('升级前的旧负缓存（没有 schema）不再生效', () async {
    // 12 小时语义的旧条目里混着软限流等误判，升级后必须立刻失效。
    await box.put(
      _keyFor('晴天', '周杰伦'),
      jsonEncode(<String, dynamic>{
        'hit': false,
        'at': DateTime.now().millisecondsSinceEpoch,
      }),
    );

    expect(cache.isFreshMiss(_track), isFalse);
  });

  test('负缓存写入带格式版本与原因', () async {
    await cache.writeMiss(_track);

    final String raw = box.get(_keyFor('晴天', '周杰伦')) ?? '';
    final Map<String, dynamic> entry = jsonDecode(raw) as Map<String, dynamic>;
    expect(entry['hit'], isFalse);
    expect(entry['schema'], 2);
    expect(entry['reason'], 'no-match');
  });
}
