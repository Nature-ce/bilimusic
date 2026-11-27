import 'package:bilimusic/feature/setting/logic/appearance_setting_logic.dart';
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
        appearanceSettingLogicProvider.overrideWith(_GlassAppearance.new),
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

class _GlassAppearance extends AppearanceSettingLogic {
  @override
  bool build() => true;
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
    // 匹配到第一首就起播，剩下的边匹配边入队，不再攒够 5 首才开播。
    expect(played, hasLength(1));
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
    // 没匹配到的歌要明确告诉用户，不能静默少放几首。
    expect(find.textContaining('首未匹配'), findsOneWidget);
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

    // 第一首匹配完立刻起播，其余 11 首按小批次陆续补进队列。
    expect(played, hasLength(1));
    expect(
      player.enqueued.expand((List<PlayableItem> items) => items),
      hasLength(11),
    );
    expect(
      player.enqueued.every((List<PlayableItem> items) => items.length <= 2),
      isTrue,
    );
  });

  testWidgets('大歌单首批只补 10 首进队列', (WidgetTester tester) async {
    final _PlayAllRecorder player = _PlayAllRecorder();
    await _pumpPage(
      tester,
      total: 40,
      resolver: _FakeResolver(),
      player: player,
      playAll:
          (
            BuildContext context,
            WidgetRef ref,
            List<PlayableItem> items,
            String sourceLabel,
          ) async {},
    );

    await tester.tap(find.byKey(const Key('hotPlaylistPlayAll')));
    await tester.pumpAndSettle();

    // 起播 1 首 + 补到 10 首，剩下的跟着播放进度补。
    expect(player.enqueuedTotal, 9);
    await _drainTimers(tester);
  });

  testWidgets('退出歌单页后仍然继续补满首批 10 首', (WidgetTester tester) async {
    final _PlayAllRecorder player = _PlayAllRecorder();
    await _pumpPage(
      tester,
      total: 60,
      resolver: _FakeResolver(),
      player: player,
      playAll:
          (
            BuildContext context,
            WidgetRef ref,
            List<PlayableItem> items,
            String sourceLabel,
          ) async {},
    );

    await tester.tap(find.byKey(const Key('hotPlaylistPlayAll')));
    await tester.pump();

    // 模拟用户点返回，歌单页被销毁。
    await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
    await tester.pumpAndSettle();

    // 页面没了也要继续匹配，补满首批 10 首（起播 1 + 入队 9）。
    expect(player.enqueuedTotal, 9);
    await _drainTimers(tester);
  });

  testWidgets('播放接近队尾时再按 5 首补充', (WidgetTester tester) async {
    final _PlayAllRecorder player = _PlayAllRecorder()
      ..reportQueueNearEnd = true;
    await _pumpPage(
      tester,
      total: 40,
      resolver: _FakeResolver(),
      player: player,
      playAll:
          (
            BuildContext context,
            WidgetRef ref,
            List<PlayableItem> items,
            String sourceLabel,
          ) async {},
    );

    await tester.tap(find.byKey(const Key('hotPlaylistPlayAll')));
    await tester.pumpAndSettle();

    // 每轮补歌要等冷却（25s）+ 两次采样，这里推进足够时间。
    await _drainTimers(tester, seconds: 200);

    // 队列走到尾声后继续补，直到整张歌单补完（40 首 = 1 + 39）。
    expect(player.enqueuedTotal, 39);
    expect(
      player.enqueued.any((List<PlayableItem> items) => items.length == 5),
      isTrue,
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

  /// 为 true 时假装队列已播到尾声，用来触发懒加载补歌。
  bool reportQueueNearEnd = false;

  int get enqueuedTotal => enqueued.fold(
    0,
    (int sum, List<PlayableItem> items) => sum + items.length,
  );

  @override
  PlayerState build() => const PlayerState();

  @override
  PlayerState get sessionState {
    if (!reportQueueNearEnd) {
      return super.sessionState;
    }
    final int length = 1 + enqueuedTotal;
    final int queueLength = length < 30 ? 30 : length;
    final int index = queueLength > 3 ? queueLength - 3 : 0;
    return PlayerState(
      queue: List<PlayableItem>.generate(
        queueLength,
        (int i) => PlayableItem(
          aid: i + 1,
          bvid: 'BV$i',
          title: 'track$i',
          author: 'artist',
          coverUrl: '',
        ),
      ),
      currentQueueIndex: index,
    );
  }

  @override
  void setQueueMode(PlayerQueueMode mode) {
    modes.add(mode);
  }

  @override
  Future<void> enqueue(List<PlayableItem> items) async {
    enqueued.add(items);
  }
}

Future<void> _drainTimers(WidgetTester tester, {int seconds = 40}) async {
  for (int index = 0; index < seconds; index += 1) {
    await tester.pump(const Duration(seconds: 1));
  }
}
