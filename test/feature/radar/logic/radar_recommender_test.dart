import 'dart:math';

import 'package:bilimusic/feature/home/domain/hot_playlist.dart';
import 'package:bilimusic/feature/home/domain/hot_playlist_track.dart';
import 'package:bilimusic/feature/home/domain/music_chart_platform.dart';
import 'package:bilimusic/feature/radar/domain/radar_keys.dart';
import 'package:bilimusic/feature/radar/domain/radar_pick.dart';
import 'package:bilimusic/feature/radar/domain/radar_taste.dart';
import 'package:bilimusic/feature/radar/logic/radar_recommender.dart';
import 'package:flutter_test/flutter_test.dart';

const RadarRecommender _recommender = RadarRecommender();

void main() {
  test('冷启动时不会只挑榜首：排名靠后和长尾的也会出现', () {
    final List<RadarPick> picks = _recommender.pick(
      pool: _coldPool(),
      taste: const RadarTaste(),
      limit: 9,
      random: Random(7),
    );

    expect(picks, hasLength(9));
    expect(
      picks.every((RadarPick pick) => pick.reason == RadarReason.coldStart),
      isTrue,
    );
    final int beyondTopTen = picks
        .where((RadarPick pick) => pick.track.rank > 10)
        .length;
    expect(beyondTopTen, greaterThanOrEqualTo(3));
    expect(
      picks
          .map((RadarPick pick) => pick.track.playlist.platform)
          .toSet()
          .length,
      greaterThanOrEqualTo(2),
    );
  });

  test('有口味画像时优先推常听歌手的歌，并带上推荐理由', () {
    final RadarTaste taste = RadarTaste(
      artists: <String, double>{normalizeRadarKey('周杰伦'): 3},
      sampleCount: 12,
    );
    final List<RadarPick> picks = _recommender.pick(
      pool: _mixedPool(),
      taste: taste,
      limit: 8,
      random: Random(3),
    );

    final List<RadarPick> familiar = picks
        .where((RadarPick pick) => pick.reason == RadarReason.familiarArtist)
        .toList();
    expect(familiar, isNotEmpty);
    expect(
      familiar.every((RadarPick pick) => pick.track.artist == '周杰伦'),
      isTrue,
    );
    expect(familiar.first.reasonDetail, isNotNull);
    // 也要留拓展口味的比例，不能整批都是同一个人。
    expect(
      picks
          .where((RadarPick pick) => pick.reason != RadarReason.familiarArtist)
          .length,
      greaterThanOrEqualTo(2),
    );
  });

  test('同一个歌手最多两首', () {
    final RadarTaste taste = RadarTaste(
      artists: <String, double>{normalizeRadarKey('周杰伦'): 5},
      sampleCount: 20,
    );
    final List<HotPlaylistTrack> pool = <HotPlaylistTrack>[
      for (int index = 1; index <= 6; index += 1)
        _track(
          title: '周杰伦的歌$index',
          artist: '周杰伦',
          rank: index,
          playlistId: 'j$index',
        ),
    ];

    final List<RadarPick> picks = _recommender.pick(
      pool: pool,
      taste: taste,
      limit: 6,
      random: Random(1),
    );

    expect(
      picks.where((RadarPick pick) => pick.track.artist == '周杰伦').length,
      RadarRecommender.maxPerArtist,
    );
  });

  test('最近听过的歌和已出现过的歌不会被重复推荐', () {
    final List<HotPlaylistTrack> pool = _coldPool();
    final HotPlaylistTrack recent = pool.first;
    final RadarTaste taste = RadarTaste(
      recentTrackKeys: <String>{
        radarTrackKey(title: recent.title, artist: recent.artist),
      },
      sampleCount: 1,
    );

    final List<RadarPick> picks = _recommender.pick(
      pool: pool,
      taste: taste,
      limit: 12,
      random: Random(5),
      excludeKeys: <String>{pool[1].key, pool[2].key},
    );

    expect(picks, hasLength(12));
    expect(
      picks.any((RadarPick pick) => pick.track.key == recent.key),
      isFalse,
    );
    expect(
      picks.any((RadarPick pick) => pick.track.key == pool[1].key),
      isFalse,
    );
    expect(
      picks.any((RadarPick pick) => pick.track.key == pool[2].key),
      isFalse,
    );
  });

  test('多张歌单时按份额分散，一张歌单不会刷屏', () {
    final List<HotPlaylistTrack> pool = <HotPlaylistTrack>[
      for (final String playlistId in <String>['a', 'b'])
        for (int index = 1; index <= 8; index += 1)
          _track(
            title: '$playlistId歌$index',
            artist: '$playlistId歌手$index',
            rank: index,
            playlistId: playlistId,
          ),
    ];

    final List<RadarPick> picks = _recommender.pick(
      pool: pool,
      taste: const RadarTaste(),
      limit: 8,
      random: Random(2),
    );

    expect(picks, hasLength(8));
    final Map<String, int> perPlaylist = <String, int>{};
    for (final RadarPick pick in picks) {
      final String key = pick.track.playlist.key;
      perPlaylist[key] = (perPlaylist[key] ?? 0) + 1;
    }
    expect(perPlaylist.values.every((int count) => count <= 4), isTrue);
  });

  test('听过两下就切走的歌不会被再推', () {
    final List<HotPlaylistTrack> pool = _coldPool();
    final HotPlaylistTrack skipped = pool.first;
    final RadarTaste taste = RadarTaste(
      dislikedTracks: <String, double>{
        radarTrackKey(title: skipped.title, artist: skipped.artist): 1.2,
      },
      sampleCount: 3,
    );

    final List<RadarPick> picks = _recommender.pick(
      pool: pool,
      taste: taste,
      limit: 10,
      random: Random(9),
    );

    expect(
      picks.any((RadarPick pick) => pick.track.key == skipped.key),
      isFalse,
    );
  });
}

HotPlaylistTrack _track({
  required String title,
  required String artist,
  required int rank,
  String playlistId = 'p1',
  MusicChartPlatform platform = MusicChartPlatform.netease,
}) {
  return HotPlaylistTrack(
    playlist: HotPlaylist(
      platform: platform,
      id: playlistId,
      name: '歌单$playlistId',
      coverUrl: '',
    ),
    rank: rank,
    title: title,
    artist: artist,
    coverUrl: '',
  );
}

/// 三个平台各两张歌单、每张歌单 1..12 名，模拟真实候选池。
List<HotPlaylistTrack> _coldPool() {
  final List<HotPlaylistTrack> pool = <HotPlaylistTrack>[];
  int index = 0;
  for (final MusicChartPlatform platform
      in MusicChartPlatform.playlistPlatforms) {
    for (int playlist = 1; playlist <= 2; playlist += 1) {
      for (int rank = 1; rank <= 12; rank += 1) {
        index += 1;
        pool.add(
          _track(
            title: '${platform.name}歌$index',
            artist: '${platform.name}歌手$index',
            rank: rank,
            playlistId: '${platform.name}$playlist',
            platform: platform,
          ),
        );
      }
    }
  }
  return pool;
}

/// 混入一批周杰伦的歌，用来验证「常听歌手优先」。
List<HotPlaylistTrack> _mixedPool() {
  final List<HotPlaylistTrack> pool = _coldPool();
  for (int index = 1; index <= 4; index += 1) {
    pool.add(
      _track(
        title: '周杰伦的歌$index',
        artist: '周杰伦',
        rank: index * 5,
        playlistId: 'jay$index',
      ),
    );
  }
  for (int index = 1; index <= 3; index += 1) {
    pool.add(
      _track(
        title: '其它歌手$index',
        artist: '其它歌手$index',
        rank: 20 + index,
        playlistId: 'other$index',
      ),
    );
  }
  return pool;
}
