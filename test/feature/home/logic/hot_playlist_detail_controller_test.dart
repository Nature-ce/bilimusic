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
  for (int attempt = 0; attempt < 200; attempt += 1) {
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
  test('loads the first page and marks the end', () async {
    final ProviderContainer container = _container(_repository());

    _controller(container);
    final HotPlaylistDetailState state = await _settle(container);

    expect(state.playlist, _playlist);
    expect(state.tracks.single.title, '歌曲 1');
    expect(state.tracks.single.rank, 1);
    expect(state.totalCount, 1);
    expect(state.hasMore, isFalse);
    expect(state.hasError, isFalse);
    expect(state.progressText, '1 / 1');
  });

  test('keeps the playlist on failure', () async {
    final ProviderContainer container = _container(_repository(fail: true));

    _controller(container);
    final HotPlaylistDetailState state = await _settle(container);

    expect(state.playlist, _playlist);
    expect(state.tracks, isEmpty);
    expect(state.hasError, isTrue);
    expect(state.errorMessage, contains('歌单曲目加载失败'));
    expect(state.isEmpty, isFalse);
  });

  test(
    'loadMore appends the next page until the playlist is complete',
    () async {
      final ProviderContainer container = _container(_repository(total: 35));

      _controller(container);
      final HotPlaylistDetailState first = await _settle(container);
      expect(first.tracks, hasLength(30));
      expect(first.hasMore, isTrue);
      expect(first.totalCount, 35);
      expect(first.progressText, '30 / 35');

      await _controller(container).loadMore();
      final HotPlaylistDetailState second = await _settle(container);

      expect(second.tracks, hasLength(35));
      expect(second.tracks.first.rank, 1);
      expect(second.tracks.last.rank, 35);
      expect(second.hasMore, isFalse);
      expect(second.isLoadingMore, isFalse);
      expect(second.progressText, '35 / 35');
    },
  );

  test('loadMore keeps loaded tracks when the next page fails', () async {
    final ProviderContainer container = _container(
      _repository(total: 35, failAfterFirstPage: true),
    );

    _controller(container);
    await _settle(container);
    await _controller(container).loadMore();
    final HotPlaylistDetailState state = await _settle(container);

    expect(state.tracks, hasLength(30));
    expect(state.hasMore, isTrue);
    expect(state.hasMoreError, isTrue);
    expect(state.moreErrorMessage, contains('下一页加载失败'));
  });

  test('loadMore is a no-op once everything is loaded', () async {
    final ProviderContainer container = _container(_repository(total: 5));

    _controller(container);
    await _settle(container);
    await _controller(container).loadMore();
    final HotPlaylistDetailState state = await _settle(container);

    expect(state.tracks, hasLength(5));
    expect(state.hasMore, isFalse);
  });

  test('refresh reloads from the first page', () async {
    final ProviderContainer container = _container(_repository(total: 35));

    _controller(container);
    await _settle(container);
    await _controller(container).loadMore();
    await _settle(container);

    await _controller(container).refresh();
    final HotPlaylistDetailState state = await _settle(container);

    expect(state.tracks, hasLength(30));
    expect(state.hasMore, isTrue);
    expect(state.totalCount, 35);
  });
}
