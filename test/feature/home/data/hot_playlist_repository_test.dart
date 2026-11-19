import 'package:bilimusic/feature/home/data/hot_playlist_repository.dart';
import 'package:bilimusic/feature/home/domain/hot_playlist.dart';
import 'package:bilimusic/feature/home/domain/hot_playlist_track.dart';
import 'package:bilimusic/feature/home/domain/music_chart_platform.dart';
import 'package:flutter_test/flutter_test.dart';

HotPlaylist _playlist(MusicChartPlatform platform, String id) {
  return HotPlaylist(platform: platform, id: id, name: '歌单 $id', coverUrl: '');
}

const Map<String, dynamic> _neteaseListFixture = <String, dynamic>{
  'playlists': <Map<String, dynamic>>[
    <String, dynamic>{
      'id': 18428485896,
      'name': '扩次元日语潮流神曲',
      'coverImgUrl': 'http://p2.music.126.net/abcdef==/109951174111254293.jpg',
      'playCount': 100437,
      'trackCount': 68,
      'creator': <String, dynamic>{'nickname': '索尼音乐国际'},
    },
    <String, dynamic>{
      'id': 14475742002,
      'name': '「情绪Type Beat」',
      'coverImgUrl': 'https://p2.music.126.net/xyz==/1.jpg',
      'playCount': 384769,
      'trackCount': 66,
      'creator': <String, dynamic>{'nickname': '眼泪屡决堤'},
    },
    <String, dynamic>{'id': 0, 'name': ''},
  ],
};

const Map<String, dynamic> _tencentListFixture = <String, dynamic>{
  'code': 0,
  'data': <String, dynamic>{
    'list': <Map<String, dynamic>>[
      <String, dynamic>{
        'dissid': '7707261125',
        'dissname': '甜度爆表 | 旋律说唱狙击少女心',
        'imgurl':
            'http://qpic.y.qq.com/music_cover/s4SoBc0IrDEDpHKlDkDflKbCgbic5ldSQrdsEafqvxULdib5CvKhaibww/300?n=1',
        'listennum': 8561171,
        'introduction': '不怕rapper有文化',
        'creator': <String, dynamic>{'name': '我想要两颗西柚'},
      },
    ],
  },
};

const Map<String, dynamic> _kugouListFixture = <String, dynamic>{
  'plist': <String, dynamic>{
    'list': <String, dynamic>{
      'total': 600,
      'info': <Map<String, dynamic>>[
        <String, dynamic>{
          'specialid': 8268942,
          'specialname': '2026伤感情歌大全',
          'imgurl':
              'https://imgessl.kugou.com/soft/collection/{size}/20250116/1.jpg',
          'playcount': 141776466,
          'songcount': 417,
          'username': '拜托别烦我',
          'intro': '喜欢，本就没什么原因',
        },
      ],
    },
  },
};

const Map<String, dynamic> _neteaseDetailFixture = <String, dynamic>{
  'playlist': <String, dynamic>{
    'trackIds': <Map<String, dynamic>>[
      <String, dynamic>{'id': 186016},
      <String, dynamic>{'id': 1901371647},
    ],
  },
};

const Map<String, dynamic> _neteaseSongsFixture = <String, dynamic>{
  'songs': <Map<String, dynamic>>[
    <String, dynamic>{
      'name': '晴天',
      'duration': 269000,
      'artists': <Map<String, dynamic>>[
        <String, dynamic>{'name': '周杰伦'},
      ],
      'album': <String, dynamic>{
        'picUrl': 'http://p1.music.126.net/qMg2-kgxvYwMRvABdQJ91Q==/1.jpg',
      },
    },
    <String, dynamic>{
      'name': '七里香',
      'dt': 299000,
      'artists': <Map<String, dynamic>>[
        <String, dynamic>{'name': '周杰伦'},
      ],
      'al': <String, dynamic>{'picUrl': 'https://p1.music.126.net/2.jpg'},
    },
    <String, dynamic>{'name': ''},
  ],
};

const Map<String, dynamic> _tencentTracksFixture = <String, dynamic>{
  'data': <String, dynamic>{
    'cdlist': <Map<String, dynamic>>[
      <String, dynamic>{
        'dissname': '甜度爆表',
        'songlist': <Map<String, dynamic>>[
          <String, dynamic>{
            'name': '你的',
            'interval': 163,
            'album': <String, dynamic>{'mid': '0023VbHy1oT80v'},
            'singer': <Map<String, dynamic>>[
              <String, dynamic>{'name': 'DouDou'},
              <String, dynamic>{'name': 'Viva宋佩豫'},
            ],
          },
        ],
      },
    ],
  },
};

const Map<String, dynamic> _kugouTracksFixture = <String, dynamic>{
  'status': 1,
  'data': <String, dynamic>{
    'info': <Map<String, dynamic>>[
      <String, dynamic>{
        'songname': '解药',
        'duration': 268,
        'filename': '暴躁默 - 解药',
        'authors': <Map<String, dynamic>>[
          <String, dynamic>{'author_name': '暴躁默'},
        ],
        'trans_param': <String, dynamic>{
          'union_cover': 'http://imge.kugou.com/stdmusic/{size}/a.jpg',
        },
      },
      <String, dynamic>{
        'songname': '',
        'duration': 209,
        'filename': '树妖 - 是我不够好',
        'authors': <Map<String, dynamic>>[],
      },
    ],
  },
};

void main() {
  group('list parsers', () {
    test('netease playlists normalize cover and creator', () {
      final List<HotPlaylist> playlists =
          HotPlaylistRepository.parseNeteasePlaylists(_neteaseListFixture);

      expect(playlists, hasLength(2));
      expect(playlists.first.id, '18428485896');
      expect(playlists.first.platform, MusicChartPlatform.netease);
      expect(playlists.first.coverUrl, startsWith('https://'));
      expect(playlists.first.playCount, 100437);
      expect(playlists.first.trackCount, 68);
      expect(playlists.first.creator, '索尼音乐国际');
      expect(playlists.first.summaryText, contains('万'));
      expect(playlists.first.summaryText, contains('首'));
    });

    test('tencent playlists read dissid and listen count', () {
      final List<HotPlaylist> playlists =
          HotPlaylistRepository.parseTencentPlaylists(_tencentListFixture);

      expect(playlists.single.id, '7707261125');
      expect(playlists.single.platform, MusicChartPlatform.tencent);
      expect(playlists.single.playCount, 8561171);
      expect(playlists.single.creator, '我想要两颗西柚');
      expect(playlists.single.coverUrl, startsWith('https://'));
    });

    test('kugou playlists replace size placeholder', () {
      final List<HotPlaylist> playlists =
          HotPlaylistRepository.parseKugouPlaylists(_kugouListFixture);

      expect(playlists.single.id, '8268942');
      expect(playlists.single.trackCount, 417);
      expect(playlists.single.playCount, 141776466);
      expect(playlists.single.coverUrl, contains('/300/'));
      expect(playlists.single.coverUrl, isNot(contains('{size}')));
    });

    test('malformed payloads throw a typed exception', () {
      expect(
        () => HotPlaylistRepository.parseNeteasePlaylists(null),
        throwsA(isA<HotPlaylistException>()),
      );
      expect(
        () => HotPlaylistRepository.parseKugouPlaylists(<String, dynamic>{}),
        throwsA(isA<HotPlaylistException>()),
      );
    });
  });

  group('track parsers', () {
    test('netease tracks keep singer, duration and cover', () {
      final List<HotPlaylistTrack> tracks =
          HotPlaylistRepository.parseNeteaseTracks(
            _neteaseSongsFixture,
            _playlist(MusicChartPlatform.netease, '1'),
          );

      expect(tracks, hasLength(2));
      expect(tracks.first.title, '晴天');
      expect(tracks.first.artist, '周杰伦');
      expect(tracks.first.durationSeconds, 269);
      expect(tracks.first.durationText, '04:29');
      expect(tracks.first.rank, 1);
      expect(tracks.first.coverUrl, startsWith('https://'));
      expect(tracks.last.durationSeconds, 299);
      expect(tracks.last.rank, 2);
    });

    test('tencent tracks join multiple singers', () {
      final List<HotPlaylistTrack> tracks =
          HotPlaylistRepository.parseTencentTracks(
            _tencentTracksFixture,
            _playlist(MusicChartPlatform.tencent, '2'),
          );

      expect(tracks.single.artist, 'DouDou / Viva宋佩豫');
      expect(tracks.single.durationSeconds, 163);
      expect(tracks.single.coverUrl, contains('0023VbHy1oT80v'));
    });

    test('kugou tracks fall back to filename when songname is empty', () {
      final List<HotPlaylistTrack> tracks =
          HotPlaylistRepository.parseKugouTracks(
            _kugouTracksFixture,
            _playlist(MusicChartPlatform.kugou, '3'),
          );

      expect(tracks, hasLength(2));
      expect(tracks.first.title, '解药');
      expect(tracks.first.coverUrl, contains('/300/'));
      expect(tracks.last.title, '是我不够好');
      expect(tracks.last.artist, '树妖');
      expect(tracks.last.rank, 2);
    });

    test('kugou failure payload throws', () {
      expect(
        () => HotPlaylistRepository.parseKugouTracks(<String, dynamic>{
          'status': 0,
        }, _playlist(MusicChartPlatform.kugou, '4')),
        throwsA(isA<HotPlaylistException>()),
      );
    });
  });

  group('fetching', () {
    test('netease tracks use playlist detail then batch song detail', () async {
      final List<String> urls = <String>[];
      final List<Map<String, dynamic>> queries = <Map<String, dynamic>>[];
      final HotPlaylistRepository repository = HotPlaylistRepository(
        httpGet: (String url, Map<String, dynamic> query, _) async {
          urls.add(url);
          queries.add(query);
          if (url.contains('/api/v6/playlist/detail')) {
            return _neteaseDetailFixture;
          }
          if (url.contains('/api/song/detail')) {
            return _neteaseSongsFixture;
          }
          throw const HotPlaylistException('unexpected url');
        },
      );

      final List<HotPlaylistTrack> tracks = await repository.fetchTracks(
        _playlist(MusicChartPlatform.netease, '18428485896'),
      );

      expect(urls, hasLength(2));
      expect(queries.first['id'], '18428485896');
      expect(queries.last['ids'], '[186016,1901371647]');
      expect(tracks.first.title, '晴天');
    });

    test('playlists are cached per platform', () async {
      int calls = 0;
      final HotPlaylistRepository repository = HotPlaylistRepository(
        httpGet: (String url, _, _) async {
          calls += 1;
          return _neteaseListFixture;
        },
      );

      await repository.fetchPlaylists(MusicChartPlatform.netease);
      await repository.fetchPlaylists(MusicChartPlatform.netease);

      expect(calls, 1);
    });

    test('refresh bypasses the cache', () async {
      int calls = 0;
      final HotPlaylistRepository repository = HotPlaylistRepository(
        httpGet: (String url, _, _) async {
          calls += 1;
          return _neteaseListFixture;
        },
      );

      await repository.fetchPlaylists(MusicChartPlatform.netease);
      await repository.fetchPlaylists(
        MusicChartPlatform.netease,
        forceRefresh: true,
      );

      expect(calls, 2);
    });

    test('bilibili is rejected', () async {
      final HotPlaylistRepository repository = HotPlaylistRepository(
        httpGet: (String url, _, _) async => _neteaseListFixture,
      );

      expect(
        () => repository.fetchPlaylists(MusicChartPlatform.bilibili),
        throwsA(isA<HotPlaylistException>()),
      );
    });
  });
}
