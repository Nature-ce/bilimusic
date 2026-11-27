import 'package:bilimusic/common/components/bottom_page_spacer.dart';
import 'package:bilimusic/feature/daily/domain/daily_recommendation.dart';
import 'package:bilimusic/feature/daily/domain/daily_recommendation_state.dart';
import 'package:bilimusic/feature/daily/logic/daily_recommendation_controller.dart';
import 'package:bilimusic/feature/daily/ui/daily_recommendation_page.dart';
import 'package:bilimusic/feature/home/domain/matchable_track.dart';
import 'package:bilimusic/feature/home/logic/music_chart_resolver.dart';
import 'package:bilimusic/feature/home/ui/components/track_row_tile.dart';
import 'package:bilimusic/feature/player/data/bili_player_repository.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:bilimusic/feature/radar/domain/radar_pick.dart';
import 'package:bilimusic/feature/search/data/bili_search_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

DailyRecommendationState _state({bool coldStart = false}) {
  final List<DailyPick> picks = <DailyPick>[
    for (int index = 0; index < 30; index += 1)
      DailyPick(
        title: '每日歌曲 $index',
        artist: '歌手 $index',
        reason: coldStart
            ? RadarReason.coldStart
            : switch (index % 3) {
                0 => RadarReason.familiarArtist,
                1 => RadarReason.relatedPlaylist,
                _ => RadarReason.explorer,
              },
        durationSeconds: 200 + index,
        platform: 'netease',
      ),
  ];
  return DailyRecommendationState(
    picks: picks,
    isLoading: false,
    dateKey: '2026-11-24',
  );
}

Future<_FakeDailyController> _pumpPage(
  WidgetTester tester, {
  required DailyRecommendationState state,
  MusicChartResolver? resolver,
  Size viewportSize = const Size(400, 2800),
  double bottomInset = 0,
}) async {
  tester.view.physicalSize = viewportSize;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final _FakeDailyController controller = _FakeDailyController(state);
  final ProviderContainer container = ProviderContainer(
    overrides: [
      dailyRecommendationControllerProvider.overrideWith(() => controller),
      musicChartResolverProvider.overrideWith(
        (Ref ref) => resolver ?? _ResolvedResolver(),
      ),
      playerControllerProvider.overrideWith(_FakePlayer.new),
    ],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(
            size: viewportSize,
            padding: EdgeInsets.only(bottom: bottomInset),
          ),
          child: const DailyRecommendationPage(),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return controller;
}

void main() {
  testWidgets('渲染头部、播放全部与 30 行曲目', (WidgetTester tester) async {
    await _pumpPage(tester, state: _state());

    expect(find.text('每日推荐'), findsWidgets);
    expect(find.text('每日推荐 · 每天 0 点更新'), findsOneWidget);
    expect(find.text('共 30 首 · 今天更新'), findsOneWidget);
    expect(find.text('按你的收听口味挑选'), findsOneWidget);
    expect(find.text('播放全部'), findsOneWidget);
    expect(find.byKey(const Key('dailyPlayAll')), findsOneWidget);
    expect(find.byType(TrackRowTile), findsNWidgets(30));
    expect(find.text('每日歌曲 0'), findsOneWidget);
    expect(find.text('歌手 29'), findsOneWidget);
    expect(find.text('03:20'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('冷启动时头部换成热门文案', (WidgetTester tester) async {
    await _pumpPage(tester, state: _state(coldStart: true));

    expect(find.text('先按各平台热门挑'), findsOneWidget);
    expect(find.text('共 30 首 · 今天更新'), findsOneWidget);
  });

  testWidgets('点播放全部会用 每日推荐 作为来源起播', (WidgetTester tester) async {
    await _pumpPage(tester, state: _state());

    await tester.tap(find.byKey(const Key('dailyPlayAll')));
    await tester.pumpAndSettle();

    final ProviderContainer container = ProviderScope.containerOf(
      tester.element(find.byType(DailyRecommendationPage)),
      listen: false,
    );
    final _FakePlayer player =
        container.read(playerControllerProvider.notifier) as _FakePlayer;

    expect(player.queuedLabels, isNotEmpty);
    expect(player.queuedLabels.first, '每日推荐');
    expect(player.queued.first, hasLength(1));
    expect(player.enqueued, isNotEmpty);
    // 每日推荐固定 30 首、且已有预解析缓存，保持一次性补满（不是大歌单的 10 首）。
    expect(player.enqueued, hasLength(29));
    expect(find.text('播放全部'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('点单曲会解析后播放', (WidgetTester tester) async {
    await _pumpPage(tester, state: _state());

    await tester.tap(find.text('每日歌曲 0'));
    await tester.pumpAndSettle();

    final ProviderContainer container = ProviderScope.containerOf(
      tester.element(find.byType(DailyRecommendationPage)),
      listen: false,
    );
    final _FakePlayer player =
        container.read(playerControllerProvider.notifier) as _FakePlayer;

    expect(player.queuedLabels.single, '每日推荐');
    expect(player.queued.single.single.title, '每日歌曲 0');
  });

  testWidgets('错误态展示重试，点重试会重新生成', (WidgetTester tester) async {
    final _FakeDailyController controller = await _pumpPage(
      tester,
      state: const DailyRecommendationState(
        isLoading: false,
        errorMessage: '每日推荐生成失败，请稍后重试',
      ),
    );

    expect(find.text('每日推荐加载失败'), findsOneWidget);
    expect(find.text('重试'), findsOneWidget);
    expect(find.byType(TrackRowTile), findsNothing);

    await tester.tap(find.text('重试'));
    await tester.pumpAndSettle();

    expect(controller.retryCalls, 1);
  });

  testWidgets('加载中展示骨架而不是错误态', (WidgetTester tester) async {
    await _pumpPage(tester, state: const DailyRecommendationState());

    expect(find.text('每日推荐加载失败'), findsNothing);
    expect(find.byType(TrackRowTile), findsNothing);
    expect(find.text('播放全部'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('列表最后一行留出底部播放栏空间', (WidgetTester tester) async {
    const double bottomInset = 60;
    await _pumpPage(
      tester,
      state: _state(),
      viewportSize: const Size(400, 900),
      bottomInset: bottomInset,
    );

    final Finder spacer = find.byType(BottomPageSpacer);
    await tester.scrollUntilVisible(spacer, 400);
    await tester.pumpAndSettle();

    expect(spacer, findsOneWidget);
    expect(
      find.descendant(of: find.byType(ListView), matching: spacer),
      findsOneWidget,
    );
    expect(
      tester.getSize(spacer).height,
      greaterThanOrEqualTo(bottomInset + 16 - 0.01),
    );
    expect(
      tester.getRect(find.byType(TrackRowTile).last).bottom,
      lessThanOrEqualTo(tester.view.physicalSize.height - bottomInset),
    );
    expect(tester.takeException(), isNull);
  });
}

class _FakeDailyController extends DailyRecommendationController {
  _FakeDailyController(this.initial);

  final DailyRecommendationState initial;
  int retryCalls = 0;
  int ensureCalls = 0;
  int resolveCalls = 0;

  @override
  DailyRecommendationState build() => initial;

  @override
  Future<void> ensureUpToDate() async {
    ensureCalls += 1;
  }

  @override
  Future<void> resolvePending() async {
    resolveCalls += 1;
  }

  @override
  Future<void> retry() async {
    retryCalls += 1;
  }
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
    enqueued.addAll(items);
  }
}
