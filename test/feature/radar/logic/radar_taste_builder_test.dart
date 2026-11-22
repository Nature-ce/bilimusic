import 'package:bilimusic/feature/radar/domain/radar_keys.dart';
import 'package:bilimusic/feature/radar/domain/radar_play_record.dart';
import 'package:bilimusic/feature/radar/domain/radar_taste.dart';
import 'package:bilimusic/feature/radar/logic/radar_taste_builder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final DateTime now = DateTime(2026, 11, 22, 12);

  test('听完的歌手比只听几下的歌手口味分更高', () {
    final RadarTaste taste = buildRadarTaste(
      now: now,
      history: <RadarPlayRecord>[
        _play(
          stableId: '1',
          title: '晴天',
          artist: '周杰伦',
          playedMs: 240000,
          durationMs: 240000,
          at: now,
        ),
        _play(
          stableId: '2',
          title: '告白气球',
          artist: '周杰伦',
          playedMs: 200000,
          durationMs: 220000,
          at: now,
        ),
        _play(
          stableId: '3',
          title: '随便一首',
          artist: '路人',
          playedMs: 60000,
          durationMs: 240000,
          at: now,
        ),
      ],
    );

    expect(taste.sampleCount, 3);
    expect(taste.isColdStart, isFalse);
    expect(
      taste.artistAffinity('周杰伦'),
      greaterThan(taste.artistAffinity('路人')),
    );
    expect(taste.artistAffinity('周杰伦'), closeTo(1, 0.001));
  });

  test('听两下就切走的歌记为不喜欢，并拉低该歌手的分', () {
    final RadarTaste taste = buildRadarTaste(
      now: now,
      history: <RadarPlayRecord>[
        _play(
          stableId: '1',
          title: '被跳过的歌',
          artist: '不喜欢的歌手',
          playedMs: 5000,
          durationMs: 240000,
          at: now,
        ),
      ],
    );

    expect(taste.sampleCount, 0);
    expect(taste.dislikeFor(title: '被跳过的歌', artist: '不喜欢的歌手'), greaterThan(0));
    expect(taste.artistAffinity('不喜欢的歌手'), 0);
  });

  test('时间衰减：一个月前的收听权重明显低于今天', () {
    final RadarTaste today = buildRadarTaste(
      now: now,
      history: <RadarPlayRecord>[
        _play(
          stableId: '1',
          title: '晴天',
          artist: '周杰伦',
          playedMs: 240000,
          durationMs: 240000,
          at: now,
        ),
      ],
    );
    final RadarTaste monthAgo = buildRadarTaste(
      now: now,
      history: <RadarPlayRecord>[
        _play(
          stableId: '1',
          title: '晴天',
          artist: '周杰伦',
          playedMs: 240000,
          durationMs: 240000,
          at: now.subtract(const Duration(days: 30)),
        ),
      ],
    );

    expect(
      today.artists[normalizeRadarKey('周杰伦')],
      greaterThan(monthAgo.artists[normalizeRadarKey('周杰伦')]!),
    );
    expect(monthAgo.isColdStart, isFalse);
  });

  test('收藏的歌手和歌名会进入画像', () {
    final RadarTaste taste = buildRadarTaste(
      now: now,
      history: const <RadarPlayRecord>[],
      likedArtists: <String>['孙燕姿'],
      likedTitles: <String>['【Hi-Res无损音质】|《于是》- 郑润泽'],
    );

    expect(taste.isColdStart, isFalse);
    expect(taste.artistAffinity('孙燕姿'), greaterThan(0));
    expect(taste.likesTitle('于是'), isTrue);
    expect(taste.likesTitle('完全不相关的歌'), isFalse);
  });

  test('完全没有收听和收藏时是冷启动', () {
    final RadarTaste taste = buildRadarTaste(
      now: now,
      history: const <RadarPlayRecord>[],
    );

    expect(taste.isColdStart, isTrue);
    expect(taste.maxArtistScore, 0);
    expect(taste.artistAffinity('周杰伦'), 0);
  });

  test('三天内听过的歌会进入「最近听过」，避免马上重复推', () {
    final RadarTaste taste = buildRadarTaste(
      now: now,
      history: <RadarPlayRecord>[
        _play(
          stableId: '1',
          title: '晴天',
          artist: '周杰伦',
          playedMs: 200000,
          durationMs: 240000,
          at: now.subtract(const Duration(hours: 5)),
        ),
        _play(
          stableId: '2',
          title: '十年',
          artist: '陈奕迅',
          playedMs: 200000,
          durationMs: 240000,
          at: now.subtract(const Duration(days: 30)),
        ),
      ],
    );

    expect(taste.playedRecently(title: '晴天', artist: '周杰伦'), isTrue);
    expect(taste.playedRecently(title: '十年', artist: '陈奕迅'), isFalse);
  });
}

RadarPlayRecord _play({
  required String stableId,
  required String title,
  required String artist,
  required int playedMs,
  required int durationMs,
  required DateTime at,
  int playCount = 1,
}) {
  return RadarPlayRecord(
    stableId: stableId,
    title: title,
    artist: artist,
    playedMs: playedMs,
    durationMs: durationMs,
    playCount: playCount,
    updatedAtMs: at.millisecondsSinceEpoch,
  );
}
