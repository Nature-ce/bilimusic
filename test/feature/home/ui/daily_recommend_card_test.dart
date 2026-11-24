import 'package:bilimusic/feature/daily/domain/daily_recommendation.dart';
import 'package:bilimusic/feature/daily/domain/daily_recommendation_state.dart';
import 'package:bilimusic/feature/daily/logic/daily_recommendation_controller.dart';
import 'package:bilimusic/feature/home/domain/matchable_track.dart';
import 'package:bilimusic/feature/home/domain/music_chart_state.dart';
import 'package:bilimusic/feature/home/logic/music_chart_controller.dart';
import 'package:bilimusic/feature/home/logic/music_chart_resolver.dart';
import 'package:bilimusic/feature/home/ui/components/home_recommend_section.dart';
import 'package:bilimusic/feature/player/data/bili_player_repository.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:bilimusic/feature/radar/domain/radar_pick.dart';
import 'package:bilimusic/feature/search/data/bili_search_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

DailyRecommendationState _personalizedState() {
  return DailyRecommendationState(
    isLoading: false,
    dateKey: '2026-11-24',
    picks: <DailyPick>[
      for (int index = 0; index < 30; index += 1)
        DailyPick(
          title: '每日歌曲 $index',
          artist: '歌手 $index',
          reason: index < 12
              ? RadarReason.familiarArtist
              : index < 21
              ? RadarReason.relatedPlaylist
              : RadarReason.explorer,
          durationSeconds: 200,
          platform: 'netease',
        ),
    ],
  );
}

DailyRecommendationState _coldStartState() {
  return DailyRecommendationState(
    isLoading: false,
    dateKey: '2026-11-24',
    picks: <DailyPick>[
      for (int index = 0; index < 30; index += 1)
        DailyPick(
          title: '热门歌曲 $index',
          artist: '热门歌手 $index',
          reason: RadarReason.coldStart,
          durationSeconds: 200,
          platform: 'tencent',
        ),
    ],
  );
}

ProviderContainer _container({
  required DailyRecommendationState daily,
  MusicChartResolver? resolver,
}) {
  final ProviderContainer container = ProviderContainer(
    overrides: [
      musicChartControllerProvider.overrideWith(_FakeCharts.new),
      dailyRecommendationControllerProvider.overrideWith(
        () => _FakeDailyController(daily),
      ),
      musicChartResolverProvider.overrideWith(
        (Ref ref) => resolver ?? _ResolvedResolver(),
      ),
      playerControllerProvider.overrideWith(_FakePlayer.new),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

Future<void> _pumpSection(
  WidgetTester tester, {
  required ProviderContainer container,
  GoRouter? router,
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final Widget child = router == null
      ? const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(child: HomeRecommendSection()),
          ),
        )
      : MaterialApp.router(routerConfig: router);

  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: child),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('首页卡片显示每日推荐与今天挑歌数量', (WidgetTester tester) async {
    await _pumpSection(
      tester,
      container: _container(daily: _personalizedState()),
    );

    expect(find.text('每日推荐'), findsOneWidget);
    expect(find.text('每日推荐 · 每天 0 点更新'), findsOneWidget);
    expect(find.text('今天为你挑了 30 首'), findsOneWidget);
    expect(find.text('常听歌手 40% · 同歌单 30% · 换口味 30%'), findsOneWidget);
    expect(find.text('开始听'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('冷启动时副标题换成先从各平台热门里挑', (WidgetTester tester) async {
    await _pumpSection(tester, container: _container(daily: _coldStartState()));

    expect(find.text('今天为你挑了 30 首'), findsOneWidget);
    expect(find.text('先从各平台热门里挑'), findsOneWidget);
  });

  testWidgets('点击卡片跳转到每日推荐页', (WidgetTester tester) async {
    final GoRouter router = GoRouter(
      initialLocation: '/home',
      routes: <RouteBase>[
        GoRoute(
          path: '/home',
          builder: (BuildContext context, GoRouterState state) {
            return const Scaffold(
              body: SingleChildScrollView(child: HomeRecommendSection()),
            );
          },
        ),
        GoRoute(
          path: '/daily',
          builder: (BuildContext context, GoRouterState state) {
            return const Scaffold(body: Text('每日推荐页'));
          },
        ),
      ],
    );
    addTearDown(router.dispose);

    await _pumpSection(
      tester,
      container: _container(daily: _personalizedState()),
      router: router,
    );

    await tester.tap(find.text('今天为你挑了 30 首'));
    await tester.pumpAndSettle();

    expect(find.text('每日推荐页'), findsOneWidget);
  });

  testWidgets('开始听会直接播放全部 30 首', (WidgetTester tester) async {
    final ProviderContainer container = _container(daily: _personalizedState());
    await _pumpSection(tester, container: container);

    await tester.tap(find.byKey(const Key('dailyHeroPlayAll')));
    await tester.pumpAndSettle();

    final _FakePlayer player =
        container.read(playerControllerProvider.notifier) as _FakePlayer;
    expect(player.queuedLabels, isNotEmpty);
    expect(player.queuedLabels.first, '每日推荐');
    expect(player.queued.first, hasLength(5));
    expect(player.enqueued, isNotEmpty);
    expect(find.text('开始听'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _FakeCharts extends MusicChartController {
  @override
  MusicChartState build() => const MusicChartState();
}

class _FakeDailyController extends DailyRecommendationController {
  _FakeDailyController(this.initial);

  final DailyRecommendationState initial;

  @override
  DailyRecommendationState build() => initial;

  @override
  Future<void> ensureUpToDate() async {}
}

class _FakeSearchRepository implements BiliSearchRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _FakePlayerRepository implements BiliPlayerRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _ResolvedResolver extends MusicChartResolver {
  _ResolvedResolver()
    : super(
        searchRepository: _FakeSearchRepository(),
        playerRepository: _FakePlayerRepository(),
      );

  @override
  Future<PlayableItem?> resolve(MatchableTrack track) async {
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

class _FakePlayer extends PlayerController {
  final List<String?> queuedLabels = <String?>[];
  final List<List<PlayableItem>> queued = <List<PlayableItem>>[];
  List<PlayableItem> enqueued = <PlayableItem>[];

  @override
  PlayerState build() => const PlayerState();

  @override
  void setQueueMode(PlayerQueueMode mode) {}

  @override
  Future<void> setQueue(
    List<PlayableItem> items, {
    int startIndex = 0,
    String? sourceLabel,
    bool autoplay = true,
    Duration initialPosition = Duration.zero,
  }) async {
    queued.add(items);
    queuedLabels.add(sourceLabel);
  }

  @override
  Future<void> enqueue(List<PlayableItem> items) async {
    enqueued = items;
  }
}
