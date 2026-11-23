import 'package:bilimusic/feature/home/data/hot_playlist_repository.dart';
import 'package:bilimusic/feature/home/domain/hot_playlist.dart';
import 'package:bilimusic/feature/home/domain/music_chart_platform.dart';
import 'package:bilimusic/feature/home/logic/hot_playlist_controller.dart';
import 'package:bilimusic/feature/home/domain/matchable_track.dart';
import 'package:bilimusic/feature/home/logic/music_chart_resolver.dart';
import 'package:bilimusic/feature/player/data/bili_player_repository.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:bilimusic/feature/search/data/bili_search_repository.dart';
import 'package:bilimusic/feature/home/ui/components/track_row_tile.dart';
import 'package:bilimusic/feature/home/ui/hot_playlist_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const HotPlaylist _playlist = HotPlaylist(
  platform: MusicChartPlatform.netease,
  id: '1',
  name: '测试歌单',
  coverUrl: '',
  playCount: 10000,
  trackCount: 2,
  creator: 'UP主',
);

HotPlaylistRepository _repository({int total = 2}) {
  return HotPlaylistRepository(
    httpGet: (String url, Map<String, dynamic> query, _) async {
      if (url.contains('/api/v6/playlist/detail')) {
        return <String, dynamic>{
          'playlist': <String, dynamic>{
            'trackIds': <Map<String, dynamic>>[
              for (int index = 0; index < total; index += 1)
                <String, dynamic>{'id': index + 1},
            ],
          },
        };
      }
      final String ids = (query['ids'] as String)
          .replaceAll('[', '')
          .replaceAll(']', '');
      final List<String> parts = ids.split(',');
      return <String, dynamic>{
        'songs': <Map<String, dynamic>>[
          for (final String id in parts)
            <String, dynamic>{
              'name': id == '1' ? '晴天' : '歌曲 $id',
              'duration': 269000,
              'artists': <Map<String, dynamic>>[
                <String, dynamic>{'name': '周杰伦'},
              ],
            },
        ],
      };
    },
  );
}

Future<void> _pumpPage(
  WidgetTester tester, {
  HotPlaylist? initialPlaylist = _playlist,
  int total = 2,
  MusicChartResolver? resolver,
  PlayerController? player,
  HotPlaylistPlayAll? playAll,
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        hotPlaylistRepositoryProvider.overrideWithValue(
          _repository(total: total),
        ),
        if (resolver != null)
          musicChartResolverProvider.overrideWithValue(resolver),
        if (player != null) playerControllerProvider.overrideWith(() => player),
      ],
      child: MaterialApp(
        home: HotPlaylistPage(
          platform: MusicChartPlatform.netease,
          playlistId: '1',
          initialPlaylist: initialPlaylist,
          playAll: playAll,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('renders the playlist header and its tracks', (
    WidgetTester tester,
  ) async {
    await _pumpPage(tester);

    expect(find.text('测试歌单'), findsWidgets);
    expect(find.textContaining('1.0万次播放'), findsOneWidget);
    expect(find.text('晴天'), findsOneWidget);
    expect(find.text('04:29'), findsWidgets);
    expect(find.text('周杰伦'), findsWidgets);
    expect(find.byIcon(Icons.download_outlined), findsOneWidget);
  });

  testWidgets('uses a placeholder title when opened without metadata', (
    WidgetTester tester,
  ) async {
    await _pumpPage(tester, initialPlaylist: null);

    expect(find.text('热门歌单'), findsWidgets);
    expect(find.text('晴天'), findsOneWidget);
  });

  testWidgets('loads every page automatically without a load-more button', (
    WidgetTester tester,
  ) async {
    await _pumpPage(tester, total: 120);

    expect(find.textContaining('加载更多'), findsNothing);
    expect(find.textContaining('已加载全部'), findsNothing);
    await tester.scrollUntilVisible(
      find.text('歌曲 120'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('歌曲 120'), findsOneWidget);
    expect(find.byType(TrackRowTile), findsWidgets);
  });

  testWidgets('shows favorite and play-all buttons', (
    WidgetTester tester,
  ) async {
    await _pumpPage(tester);

    expect(find.byKey(const Key('hotPlaylistPlayAll')), findsOneWidget);
    expect(find.byKey(const Key('hotPlaylistFavorite')), findsOneWidget);
    expect(find.byKey(const Key('hotPlaylistDownload')), findsOneWidget);
    expect(find.byKey(const Key('hotPlaylistRefresh')), findsNothing);
    expect(find.text('播放全部'), findsOneWidget);
    expect(find.byIcon(Icons.favorite_border_rounded), findsOneWidget);
  });

  testWidgets('favorite button toggles the playlist in favorites', (
    WidgetTester tester,
  ) async {
    await _pumpPage(tester);

    await tester.tap(find.byKey(const Key('hotPlaylistFavorite')));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);

    await tester.tap(find.byKey(const Key('hotPlaylistFavorite')));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.favorite_border_rounded), findsOneWidget);
  });

  testWidgets('download button asks before queueing the whole playlist', (
    WidgetTester tester,
  ) async {
    await _pumpPage(tester);

    await tester.tap(find.byKey(const Key('hotPlaylistDownload')));
    await tester.pumpAndSettle();
    expect(find.text('下载整张歌单？'), findsOneWidget);

    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();
    expect(find.text('下载整张歌单？'), findsNothing);
  });

  testWidgets('play-all resolves tracks and hands them to the player', (
    WidgetTester tester,
  ) async {
    final _FakeResolver resolver = _FakeResolver();
    final _PlayAllRecorder player = _PlayAllRecorder();
    List<PlayableItem>? played;
    String? playedLabel;
    await _pumpPage(
      tester,
      resolver: resolver,
      player: player,
      playAll:
          (
            BuildContext context,
            WidgetRef ref,
            List<PlayableItem> items,
            String sourceLabel,
          ) async {
            played = items;
            playedLabel = sourceLabel;
          },
    );

    await tester.tap(find.byKey(const Key('hotPlaylistPlayAll')));
    await tester.pumpAndSettle();

    expect(resolver.resolveCalls, 2);
    expect(played, hasLength(2));
    expect(playedLabel, '测试歌单');
    expect(player.modes, contains(PlayerQueueMode.sequence));
    // 播放中按钮恢复成可点状态。
    expect(find.text('播放全部'), findsOneWidget);
  });

  testWidgets('play-all skips tracks without a bilibili match', (
    WidgetTester tester,
  ) async {
    final _FakeResolver resolver = _FakeResolver(failTitles: <String>{'歌曲 2'});
    List<PlayableItem>? played;
    await _pumpPage(
      tester,
      resolver: resolver,
      player: _PlayAllRecorder(),
      playAll:
          (
            BuildContext context,
            WidgetRef ref,
            List<PlayableItem> items,
            String sourceLabel,
          ) async {
            played = items;
          },
    );

    await tester.tap(find.byKey(const Key('hotPlaylistPlayAll')));
    await tester.pumpAndSettle();

    expect(played, hasLength(1));
    expect(played!.single.title, '晴天');
  });

  testWidgets('play-all queues the remaining tracks in batches', (
    WidgetTester tester,
  ) async {
    final _PlayAllRecorder player = _PlayAllRecorder();
    List<PlayableItem>? played;
    await _pumpPage(
      tester,
      total: 12,
      resolver: _FakeResolver(),
      player: player,
      playAll:
          (
            BuildContext context,
            WidgetRef ref,
            List<PlayableItem> items,
            String sourceLabel,
          ) async {
            played = items;
          },
    );

    await tester.tap(find.byKey(const Key('hotPlaylistPlayAll')));
    await tester.pumpAndSettle();

    // 先拿前 5 首开播，剩下的 7 首补进队列。
    expect(played, hasLength(5));
    expect(player.enqueued, hasLength(2));
    expect(player.enqueued.first, hasLength(5));
    expect(player.enqueued.last, hasLength(2));
    expect(
      player.enqueued.expand((List<PlayableItem> items) => items),
      hasLength(7),
    );
  });
}

class _FakeSearchRepository implements BiliSearchRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _FakePlayerRepository implements BiliPlayerRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _FakeResolver extends MusicChartResolver {
  _FakeResolver({this.failTitles = const <String>{}})
    : super(
        searchRepository: _FakeSearchRepository(),
        playerRepository: _FakePlayerRepository(),
      );

  final Set<String> failTitles;
  int resolveCalls = 0;

  @override
  Future<PlayableItem?> resolve(MatchableTrack track) async {
    resolveCalls += 1;
    if (failTitles.contains(track.title)) {
      return null;
    }
    return PlayableItem(
      aid: track.title.hashCode.abs(),
      bvid: 'BV${track.title.hashCode.abs()}',
      cid: 1,
      title: track.title,
      author: track.artist,
      coverUrl: '',
    );
  }
}

class _PlayAllRecorder extends PlayerController {
  final List<PlayerQueueMode> modes = <PlayerQueueMode>[];
  final List<List<PlayableItem>> enqueued = <List<PlayableItem>>[];

  @override
  PlayerState build() => const PlayerState();

  @override
  void setQueueMode(PlayerQueueMode mode) {
    modes.add(mode);
  }

  @override
  Future<void> enqueue(List<PlayableItem> items) async {
    enqueued.add(items);
  }
}
