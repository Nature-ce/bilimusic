import 'dart:math';

import 'package:bilimusic/feature/home/data/hot_playlist_repository.dart';
import 'package:bilimusic/feature/home/domain/music_chart_platform.dart';
import 'package:bilimusic/feature/home/logic/hot_playlist_controller.dart';
import 'package:bilimusic/feature/radar/domain/music_radar_state.dart';
import 'package:bilimusic/feature/radar/logic/music_radar_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const Map<String, dynamic> _neteaseList = <String, dynamic>{
  'playlists': <Map<String, dynamic>>[
    <String, dynamic>{'id': '11', 'name': '网易歌单A', 'coverImgUrl': ''},
    <String, dynamic>{'id': '12', 'name': '网易歌单B', 'coverImgUrl': ''},
  ],
};

const Map<String, dynamic> _tencentList = <String, dynamic>{
  'code': 0,
  'data': <String, dynamic>{
    'list': <Map<String, dynamic>>[
      <String, dynamic>{'dissid': '21', 'dissname': 'QQ歌单A', 'imgurl': ''},
    ],
  },
};

const Map<String, dynamic> _kugouList = <String, dynamic>{
  'plist': <String, dynamic>{
    'list': <String, dynamic>{
      'info': <Map<String, dynamic>>[
        <String, dynamic>{
          'specialid': 31,
          'specialname': '酷狗歌单A',
          'imgurl': '',
          'songcount': 10,
          'playcount': 1,
        },
      ],
    },
  },
};

List<Map<String, dynamic>> _neteaseSongs() {
  return <Map<String, dynamic>>[
    for (int index = 0; index < 30; index += 1)
      <String, dynamic>{
        'name': index < 2 ? '重复歌曲 $index' : '网易歌曲 $index',
        'duration': 200000,
        'artists': <Map<String, dynamic>>[
          <String, dynamic>{'name': index < 2 ? '共同歌手' : '网易歌手 $index'},
        ],
      },
  ];
}

List<Map<String, dynamic>> _tencentSongs() {
  return <Map<String, dynamic>>[
    for (int index = 0; index < 30; index += 1)
      <String, dynamic>{
        'name': index < 2 ? '重复歌曲 $index' : 'QQ歌曲 $index',
        'interval': 200,
        'singer': <Map<String, dynamic>>[
          <String, dynamic>{'name': index < 2 ? '共同歌手' : 'QQ歌手 $index'},
        ],
      },
  ];
}

List<Map<String, dynamic>> _kugouSongs() {
  return <Map<String, dynamic>>[
    for (int index = 0; index < 30; index += 1)
      <String, dynamic>{
        'songname': '酷狗歌曲 $index',
        'duration': 200,
        'authors': <Map<String, dynamic>>[
          <String, dynamic>{'author_name': '酷狗歌手 $index'},
        ],
      },
  ];
}

HotPlaylistRepository _repository({
  Set<MusicChartPlatform> failingTrackSources = const <MusicChartPlatform>{},
}) {
  return HotPlaylistRepository(
    httpGet: (String url, Map<String, dynamic> query, _) async {
      if (url.contains('music.163.com/api/playlist/list')) {
        return _neteaseList;
      }
      if (url.contains('fcg_get_diss_by_tag')) {
        return _tencentList;
      }
      if (url.contains('m.kugou.com/plist')) {
        return _kugouList;
      }
      if (url.contains('/api/v6/playlist/detail')) {
        return <String, dynamic>{
          'playlist': <String, dynamic>{
            'trackIds': <Map<String, dynamic>>[
              for (int index = 0; index < 30; index += 1)
                <String, dynamic>{'id': index},
            ],
          },
        };
      }
      if (url.contains('/api/song/detail')) {
        if (failingTrackSources.contains(MusicChartPlatform.netease)) {
          throw const HotPlaylistException('网易云失败');
        }
        return <String, dynamic>{'songs': _neteaseSongs()};
      }
      if (url.contains('fcg_v8_playlist_cp')) {
        if (failingTrackSources.contains(MusicChartPlatform.tencent)) {
          throw const HotPlaylistException('QQ失败');
        }
        return <String, dynamic>{
          'data': <String, dynamic>{
            'cdlist': <Map<String, dynamic>>[
              <String, dynamic>{
                'total_song_num': 30,
                'songlist': _tencentSongs(),
              },
            ],
          },
        };
      }
      if (url.contains('special/song')) {
        if (failingTrackSources.contains(MusicChartPlatform.kugou)) {
          throw const HotPlaylistException('酷狗失败');
        }
        return <String, dynamic>{
          'status': 1,
          'data': <String, dynamic>{'total': 30, 'info': _kugouSongs()},
        };
      }
      throw const HotPlaylistException('unexpected url');
    },
  );
}

ProviderContainer _container(HotPlaylistRepository repository) {
  final ProviderContainer container = ProviderContainer(
    overrides: [
      hotPlaylistRepositoryProvider.overrideWithValue(repository),
      musicRadarRandomProvider.overrideWithValue(Random(7)),
    ],
  );
  addTearDown(container.dispose);
  final ProviderSubscription<MusicRadarState> subscription = container.listen(
    musicRadarControllerProvider,
    (MusicRadarState? previous, MusicRadarState next) {},
  );
  addTearDown(subscription.close);
  return container;
}

Future<MusicRadarState> _settle(ProviderContainer container) async {
  for (int attempt = 0; attempt < 400; attempt += 1) {
    final MusicRadarState state = container.read(musicRadarControllerProvider);
    if (!state.isScanning && !state.isLoadingMore) {
      return state;
    }
    await Future<void>.delayed(const Duration(milliseconds: 1));
  }
  return container.read(musicRadarControllerProvider);
}

void main() {
  test('scans every playlist platform and mixes the results', () async {
    final ProviderContainer container = _container(_repository());

    container.read(musicRadarControllerProvider.notifier);
    final MusicRadarState state = await _settle(container);

    expect(state.isScanning, isFalse);
    expect(state.hasError, isFalse);
    expect(state.scanCount, 1);
    expect(state.tracks, hasLength(24));
    expect(
      state.tracks.map((track) => track.playlist.platform).toSet().length,
      3,
    );
    final Set<String> titles = state.tracks
        .map((track) => '${track.title}|${track.artist}')
        .toSet();
    expect(titles.length, state.tracks.length);
  });

  test('keeps scanning when one platform fails', () async {
    final ProviderContainer container = _container(
      _repository(
        failingTrackSources: const <MusicChartPlatform>{
          MusicChartPlatform.kugou,
        },
      ),
    );

    container.read(musicRadarControllerProvider.notifier);
    final MusicRadarState state = await _settle(container);

    expect(state.hasError, isFalse);
    expect(state.tracks, hasLength(16));
    expect(
      state.tracks.map((track) => track.playlist.platform).toSet(),
      isNot(contains(MusicChartPlatform.kugou)),
    );
  });

  test('reports an error when every platform fails', () async {
    final ProviderContainer container = _container(
      _repository(
        failingTrackSources: const <MusicChartPlatform>{
          MusicChartPlatform.netease,
          MusicChartPlatform.tencent,
          MusicChartPlatform.kugou,
        },
      ),
    );

    container.read(musicRadarControllerProvider.notifier);
    final MusicRadarState state = await _settle(container);

    expect(state.tracks, isEmpty);
    expect(state.hasError, isTrue);
    expect(state.isScanning, isFalse);
  });

  test('rescanning replaces the previous discovery', () async {
    final ProviderContainer container = _container(_repository());

    container.read(musicRadarControllerProvider.notifier);
    await _settle(container);
    await container.read(musicRadarControllerProvider.notifier).scan();
    final MusicRadarState state = await _settle(container);

    expect(state.tracks, hasLength(24));
    expect(state.scanCount, 2);
  });

  test('extending the feed appends deduped tracks', () async {
    final ProviderContainer container = _container(_repository());

    container.read(musicRadarControllerProvider.notifier);
    final MusicRadarState first = await _settle(container);
    expect(first.tracks, hasLength(24));

    await container.read(musicRadarControllerProvider.notifier).extendFeed();
    final MusicRadarState extended = await _settle(container);

    expect(extended.scanCount, first.scanCount);
    expect(extended.tracks.length, greaterThan(first.tracks.length));
    expect(extended.isLoadingMore, isFalse);
    final Set<String> keys = extended.tracks
        .map((track) => '${track.title}|${track.artist}')
        .toSet();
    expect(keys.length, extended.tracks.length);
  });

  test('scan resets the dedupe window for a fresh feed', () async {
    final ProviderContainer container = _container(_repository());

    container.read(musicRadarControllerProvider.notifier);
    final MusicRadarState first = await _settle(container);
    await container.read(musicRadarControllerProvider.notifier).extendFeed();
    final MusicRadarState extended = await _settle(container);
    expect(extended.tracks.length, greaterThan(first.tracks.length));

    await container.read(musicRadarControllerProvider.notifier).scan();
    final MusicRadarState rescanned = await _settle(container);

    expect(rescanned.tracks, hasLength(24));
    expect(rescanned.scanCount, 2);
  });

  test('ensureFeedAt only tops up near the end of the feed', () async {
    final ProviderContainer container = _container(_repository());

    container.read(musicRadarControllerProvider.notifier);
    final MusicRadarState first = await _settle(container);
    final MusicRadarController controller = container.read(
      musicRadarControllerProvider.notifier,
    );

    controller.ensureFeedAt(0);
    await _settle(container);
    expect(
      container.read(musicRadarControllerProvider).tracks,
      hasLength(first.tracks.length),
    );

    controller.ensureFeedAt(first.tracks.length - 1);
    final MusicRadarState toppedUp = await _settle(container);
    expect(toppedUp.tracks.length, greaterThan(first.tracks.length));
  });
}
