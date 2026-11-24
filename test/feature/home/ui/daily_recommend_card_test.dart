import 'package:bilimusic/feature/daily/domain/daily_recommendation.dart';
import 'package:bilimusic/feature/daily/domain/daily_recommendation_state.dart';
import 'package:bilimusic/feature/daily/logic/daily_recommendation_controller.dart';
import 'package:bilimusic/feature/home/domain/music_chart_state.dart';
import 'package:bilimusic/feature/home/logic/music_chart_controller.dart';
import 'package:bilimusic/feature/home/ui/components/home_recommend_section.dart';
import 'package:bilimusic/feature/radar/domain/radar_pick.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

DailyRecommendationState _dailyState({
  int count = 30,
  bool isLoading = false,
  String? errorMessage,
}) {
  return DailyRecommendationState(
    isLoading: isLoading,
    dateKey: '2026-11-24',
    errorMessage: errorMessage,
    picks: <DailyPick>[
      for (int index = 0; index < count; index += 1)
        DailyPick(
          title: '每日歌曲 $index',
          artist: '歌手 $index',
          reason: index < 12
              ? RadarReason.familiarArtist
              : RadarReason.relatedPlaylist,
          durationSeconds: 200,
          platform: 'netease',
        ),
    ],
  );
}

ProviderContainer _container({required DailyRecommendationState daily}) {
  final ProviderContainer container = ProviderContainer(
    overrides: [
      musicChartControllerProvider.overrideWith(_FakeCharts.new),
      dailyRecommendationControllerProvider.overrideWith(
        () => _FakeDailyController(daily),
      ),
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
  testWidgets('首页今日推荐墙展示前 10 首与查看全部入口', (WidgetTester tester) async {
    await _pumpSection(tester, container: _container(daily: _dailyState()));

    expect(find.text('今日推荐'), findsOneWidget);
    expect(find.text('查看全部 ›'), findsWidgets);
    expect(find.text('每日歌曲 0'), findsOneWidget);
    expect(find.text('歌手 0'), findsOneWidget);
    await tester.drag(find.text('每日歌曲 0'), const Offset(-700, 0));
    await tester.pumpAndSettle();
    expect(find.text('每日歌曲 9'), findsOneWidget);
    expect(find.text('每日歌曲 10'), findsNothing);
    expect(find.text('排行榜'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('点击封面跳转到每日推荐页', (WidgetTester tester) async {
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
      container: _container(daily: _dailyState()),
      router: router,
    );

    await tester.tap(find.text('每日歌曲 2'));
    await tester.pumpAndSettle();

    expect(find.text('每日推荐页'), findsOneWidget);
  });

  testWidgets('查看全部也能进每日推荐页', (WidgetTester tester) async {
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
      container: _container(daily: _dailyState()),
      router: router,
    );

    await tester.tap(find.text('查看全部 ›').first);
    await tester.pumpAndSettle();

    expect(find.text('每日推荐页'), findsOneWidget);
  });

  testWidgets('生成中显示骨架且不出现查看全部', (WidgetTester tester) async {
    await _pumpSection(
      tester,
      container: _container(daily: _dailyState(count: 0, isLoading: true)),
    );

    expect(find.text('今日推荐'), findsOneWidget);
    expect(find.text('每日歌曲 0'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('生成失败时显示重试并调用 retry', (WidgetTester tester) async {
    final ProviderContainer container = _container(
      daily: _dailyState(count: 0, errorMessage: '每日推荐生成失败，请稍后重试'),
    );
    await _pumpSection(tester, container: container);

    expect(find.text('今日推荐生成失败'), findsOneWidget);
    await tester.tap(find.text('重试'));
    await tester.pumpAndSettle();

    final _FakeDailyController controller =
        container.read(dailyRecommendationControllerProvider.notifier)
            as _FakeDailyController;
    expect(controller.retryCount, 1);
  });
}

class _FakeCharts extends MusicChartController {
  @override
  MusicChartState build() => const MusicChartState();
}

class _FakeDailyController extends DailyRecommendationController {
  _FakeDailyController(this.initial);

  final DailyRecommendationState initial;
  int retryCount = 0;

  @override
  DailyRecommendationState build() => initial;

  @override
  Future<void> ensureUpToDate() async {}

  @override
  Future<void> retry() async {
    retryCount += 1;
  }
}
