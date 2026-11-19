import 'package:bilimusic/feature/home/data/hot_playlist_repository.dart';
import 'package:bilimusic/feature/home/domain/hot_playlist_state.dart';
import 'package:bilimusic/feature/home/domain/music_chart_platform.dart';
import 'package:bilimusic/feature/home/logic/hot_playlist_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

MusicChartPlatform _platformOf(String url) {
  if (url.contains('music.163.com')) {
    return MusicChartPlatform.netease;
  }
  if (url.contains('y.qq.com')) {
    return MusicChartPlatform.tencent;
  }
  return MusicChartPlatform.kugou;
}

HotPlaylistRepository _repository({
  List<MusicChartPlatform>? requested,
  bool fail = false,
}) {
  return HotPlaylistRepository(
    httpGet: (String url, _, _) async {
      final MusicChartPlatform platform = _platformOf(url);
      requested?.add(platform);
      if (fail) {
        throw const HotPlaylistException('歌单加载失败');
      }
      return switch (platform) {
        MusicChartPlatform.netease => <String, dynamic>{
          'playlists': <Map<String, dynamic>>[
            <String, dynamic>{
              'id': 1,
              'name': '网易云歌单',
              'coverImgUrl': '',
              'playCount': 1000,
              'trackCount': 10,
              'creator': <String, dynamic>{'nickname': 'a'},
            },
          ],
        },
        MusicChartPlatform.tencent => <String, dynamic>{
          'code': 0,
          'data': <String, dynamic>{
            'list': <Map<String, dynamic>>[
              <String, dynamic>{
                'dissid': '2',
                'dissname': 'QQ歌单',
                'imgurl': '',
                'listennum': 2000,
                'creator': <String, dynamic>{'name': 'b'},
              },
            ],
          },
        },
        MusicChartPlatform.kugou => <String, dynamic>{
          'plist': <String, dynamic>{
            'list': <String, dynamic>{
              'info': <Map<String, dynamic>>[
                <String, dynamic>{
                  'specialid': 3,
                  'specialname': '酷狗歌单',
                  'imgurl': '',
                  'playcount': 3000,
                  'songcount': 30,
                  'username': 'c',
                },
              ],
            },
          },
        },
        MusicChartPlatform.bilibili => <String, dynamic>{},
      };
    },
  );
}

Future<HotPlaylistState> _settle(ProviderContainer container) async {
  for (int attempt = 0; attempt < 100; attempt += 1) {
    final HotPlaylistState state = container.read(
      hotPlaylistControllerProvider,
    );
    if (!state.isLoading) {
      return state;
    }
    await Future<void>.delayed(const Duration(milliseconds: 1));
  }
  return container.read(hotPlaylistControllerProvider);
}

Future<HotPlaylistState> _start(ProviderContainer container) async {
  container.read(hotPlaylistControllerProvider.notifier);
  return _settle(container);
}

ProviderContainer _container(HotPlaylistRepository repository) {
  final ProviderContainer container = ProviderContainer(
    overrides: [hotPlaylistRepositoryProvider.overrideWithValue(repository)],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('loads netease hot playlists by default', () async {
    final List<MusicChartPlatform> requested = <MusicChartPlatform>[];
    final ProviderContainer container = _container(
      _repository(requested: requested),
    );

    final HotPlaylistState state = await _start(container);

    expect(state.platform, MusicChartPlatform.netease);
    expect(state.playlists.single.name, '网易云歌单');
    expect(state.isLoading, isFalse);
    expect(state.hasError, isFalse);
    expect(requested.single, MusicChartPlatform.netease);
  });

  test('switching platform reloads its playlists', () async {
    final List<MusicChartPlatform> requested = <MusicChartPlatform>[];
    final ProviderContainer container = _container(
      _repository(requested: requested),
    );
    await _start(container);

    await container
        .read(hotPlaylistControllerProvider.notifier)
        .selectPlatform(MusicChartPlatform.kugou);
    final HotPlaylistState state = await _settle(container);

    expect(state.platform, MusicChartPlatform.kugou);
    expect(state.playlists.single.name, '酷狗歌单');
    expect(requested.last, MusicChartPlatform.kugou);
  });

  test('bilibili cannot be selected for playlists', () async {
    final ProviderContainer container = _container(_repository());
    await _start(container);

    await container
        .read(hotPlaylistControllerProvider.notifier)
        .selectPlatform(MusicChartPlatform.bilibili);

    expect(
      container.read(hotPlaylistControllerProvider).platform,
      MusicChartPlatform.netease,
    );
  });

  test('surfaces the failure message', () async {
    final ProviderContainer container = _container(_repository(fail: true));

    final HotPlaylistState state = await _start(container);

    expect(state.hasError, isTrue);
    expect(state.errorMessage, contains('歌单加载失败'));
    expect(state.playlists, isEmpty);
    expect(state.isEmpty, isFalse);
  });

  test('refresh re-requests the active platform', () async {
    final List<MusicChartPlatform> requested = <MusicChartPlatform>[];
    final ProviderContainer container = _container(
      _repository(requested: requested),
    );
    await _start(container);

    await container.read(hotPlaylistControllerProvider.notifier).refresh();
    await _settle(container);

    expect(requested, hasLength(2));
  });
}
