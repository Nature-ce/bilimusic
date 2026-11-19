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

List<Map<String, dynamic>> _ids(int total) {
  return <Map<String, dynamic>>[
    for (int index = 0; index < total; index += 1)
      <String, dynamic>{'id': index + 1},
  ];
}

HotPlaylistRepository _repository({
  int total = 1,
  bool fail = false,
  bool failAfterFirstPage = false,
}) {
  int songRequests = 0;
  return HotPlaylistRepository(
    httpGet: (String url, Map<String, dynamic> query, _) async {
      if (url.contains('/api/v6/playlist/detail')) {
        if (fail) {
          throw const HotPlaylistException('歌单曲目加载失败');
        }
        return <String, dynamic>{
          'playlist': <String, dynamic>{'trackIds': _ids(total)},
        };
      }
      songRequests += 1;
      if (fail) {
        throw const HotPlaylistException('歌单曲目加载失败');
      }
      if (failAfterFirstPage && songRequests > 1) {
        throw const HotPlaylistException('下一页加载失败');
      }
      final String ids = (query['ids'] as String)
          .replaceAll('[', '')
          .replaceAll(']', '');
      return <String, dynamic>{
        'songs': <Map<String, dynamic>>[
          for (final String id in ids.split(','))
            <String, dynamic>{
              'name': '歌曲 $id',
              'duration': 200000,
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
  for (int attempt = 0; attempt < 500; attempt += 1) {
    final HotPlaylistDetailState state = container.read(
      hotPlaylistDetailControllerProvider(_playlist),
    );
    if (!state.isLoading && !state.isLoadingMore) {
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

HotPlaylistDetailController _controller(ProviderContainer container) {
  return container.read(
    hotPlaylistDetailControllerProvider(_playlist).notifier,
  );
}

void main() {
  test('loads the whole playlist automatically without user taps', () async {
    final ProviderContainer container = _container(_repository(total: 250));

    _controller(container);
    final HotPlaylistDetailState state = await _settle(container);

    expect(state.tracks, hasLength(250));
    expect(state.tracks.first.rank, 1);
    expect(state.tracks.last.rank, 250);
    expect(state.totalCount, 250);
    expect(state.hasMore, isFalse);
    expect(state.isLoadingMore, isFalse);
    expect(state.hasError, isFalse);
    expect(state.progressText, '250 / 250');
  });

  test('single page playlists settle immediately', () async {
    final ProviderContainer container = _container(_repository(total: 5));

    _controller(container);
    final HotPlaylistDetailState state = await _settle(container);

    expect(state.tracks, hasLength(5));
    expect(state.hasMore, isFalse);
    expect(state.totalCount, 5);
  });

  test('keeps the playlist on failure', () async {
    final ProviderContainer container = _container(_repository(fail: true));

    _controller(container);
    final HotPlaylistDetailState state = await _settle(container);

    expect(state.playlist, _playlist);
    expect(state.tracks, isEmpty);
    expect(state.hasError, isTrue);
    expect(state.errorMessage, contains('歌单曲目加载失败'));
  });

  test(
    'auto loading stops and keeps loaded tracks when a page fails',
    () async {
      final ProviderContainer container = _container(
        _repository(total: 250, failAfterFirstPage: true),
      );

      _controller(container);
      final HotPlaylistDetailState state = await _settle(container);

      expect(state.tracks, hasLength(100));
      expect(state.hasMore, isTrue);
      expect(state.isLoadingMore, isFalse);
      expect(state.hasMoreError, isTrue);
      expect(state.moreErrorMessage, contains('下一页加载失败'));
    },
  );

  test('retry is a no-op once everything is loaded', () async {
    final ProviderContainer container = _container(_repository(total: 5));

    _controller(container);
    await _settle(container);
    await _controller(container).retryLoadRemaining();
    final HotPlaylistDetailState state = await _settle(container);

    expect(state.tracks, hasLength(5));
    expect(state.hasMoreError, isFalse);
  });

  test(
    'refresh restarts from the first page and re-loads everything',
    () async {
      final ProviderContainer container = _container(_repository(total: 250));

      _controller(container);
      await _settle(container);

      await _controller(container).refresh();
      final HotPlaylistDetailState state = await _settle(container);

      expect(state.tracks, hasLength(250));
      expect(state.tracks.last.rank, 250);
      expect(state.totalCount, 250);
      expect(state.hasMore, isFalse);
    },
  );
}
