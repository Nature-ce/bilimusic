import 'package:bilimusic/feature/home/data/hot_playlist_repository.dart';
import 'package:bilimusic/feature/home/domain/hot_playlist.dart';
import 'package:bilimusic/feature/home/domain/hot_playlist_detail_state.dart';
import 'package:bilimusic/feature/home/domain/music_chart_platform.dart';
import 'package:bilimusic/feature/home/logic/hot_playlist_controller.dart';
import 'package:bilimusic/feature/home/logic/hot_playlist_detail_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const HotPlaylist _playlist = HotPlaylist(
  platform: MusicChartPlatform.netease,
  id: '123',
  name: '测试歌单',
  coverUrl: '',
);

HotPlaylistRepository _repository({bool fail = false, int trackCount = 1}) {
  return HotPlaylistRepository(
    httpGet: (String url, Map<String, dynamic> query, _) async {
      if (fail) {
        throw const HotPlaylistException('歌单曲目加载失败');
      }
      if (url.contains('/api/v6/playlist/detail')) {
        return <String, dynamic>{
          'playlist': <String, dynamic>{
            'trackIds': <Map<String, dynamic>>[
              for (int index = 0; index < trackCount; index += 1)
                <String, dynamic>{'id': 1000 + index},
            ],
          },
        };
      }
      return <String, dynamic>{
        'songs': <Map<String, dynamic>>[
          for (int index = 0; index < trackCount; index += 1)
            <String, dynamic>{
              'name': '歌曲 $index',
              'dt': 200000,
              'artists': <Map<String, dynamic>>[
                <String, dynamic>{'name': '歌手'},
              ],
            },
        ],
      };
    },
  );
}

Future<HotPlaylistDetailState> _settle(ProviderContainer container) async {
  for (int attempt = 0; attempt < 100; attempt += 1) {
    final HotPlaylistDetailState state = container.read(
      hotPlaylistDetailControllerProvider(_playlist),
    );
    if (!state.isLoading) {
      return state;
    }
    await Future<void>.delayed(const Duration(milliseconds: 1));
  }
  return container.read(hotPlaylistDetailControllerProvider(_playlist));
}

ProviderContainer _container(HotPlaylistRepository repository) {
  final ProviderContainer container = ProviderContainer(
    overrides: [hotPlaylistRepositoryProvider.overrideWithValue(repository)],
  );
  addTearDown(container.dispose);
  final ProviderSubscription<HotPlaylistDetailState> subscription = container
      .listen(
        hotPlaylistDetailControllerProvider(_playlist),
        (HotPlaylistDetailState? previous, HotPlaylistDetailState next) {},
      );
  addTearDown(subscription.close);
  return container;
}

void main() {
  test('loads tracks for the playlist', () async {
    final ProviderContainer container = _container(_repository());

    container.read(hotPlaylistDetailControllerProvider(_playlist).notifier);
    final HotPlaylistDetailState state = await _settle(container);

    expect(state.playlist, _playlist);
    expect(state.tracks.single.title, '歌曲 0');
    expect(state.tracks.single.rank, 1);
    expect(state.isLoading, isFalse);
    expect(state.hasError, isFalse);
  });

  test('keeps the playlist on failure', () async {
    final ProviderContainer container = _container(_repository(fail: true));

    container.read(hotPlaylistDetailControllerProvider(_playlist).notifier);
    final HotPlaylistDetailState state = await _settle(container);

    expect(state.playlist, _playlist);
    expect(state.tracks, isEmpty);
    expect(state.hasError, isTrue);
    expect(state.errorMessage, contains('歌单曲目加载失败'));
    expect(state.isEmpty, isFalse);
  });

  test('refresh reloads tracks and bypasses cache', () async {
    int trackRequests = 0;
    final HotPlaylistRepository repository = HotPlaylistRepository(
      httpGet: (String url, Map<String, dynamic> query, _) async {
        if (url.contains('/api/v6/playlist/detail')) {
          return <String, dynamic>{
            'playlist': <String, dynamic>{
              'trackIds': <Map<String, dynamic>>[
                <String, dynamic>{'id': 1},
              ],
            },
          };
        }
        trackRequests += 1;
        return <String, dynamic>{
          'songs': <Map<String, dynamic>>[
            <String, dynamic>{
              'name': '歌曲 $trackRequests',
              'dt': 200000,
              'artists': <Map<String, dynamic>>[
                <String, dynamic>{'name': '歌手'},
              ],
            },
          ],
        };
      },
    );
    final ProviderContainer container = _container(repository);

    container.read(hotPlaylistDetailControllerProvider(_playlist).notifier);
    await _settle(container);
    await container
        .read(hotPlaylistDetailControllerProvider(_playlist).notifier)
        .refresh();
    final HotPlaylistDetailState state = await _settle(container);

    expect(trackRequests, 2);
    expect(state.tracks.single.title, '歌曲 2');
  });
}
