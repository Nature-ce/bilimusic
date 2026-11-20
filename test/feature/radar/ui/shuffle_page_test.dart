import 'package:bilimusic/feature/home/domain/hot_playlist.dart';
import 'package:bilimusic/feature/home/domain/hot_playlist_track.dart';
import 'package:bilimusic/feature/home/domain/matchable_track.dart';
import 'package:bilimusic/feature/home/domain/music_chart_platform.dart';
import 'package:bilimusic/feature/home/logic/music_chart_resolver.dart';
import 'package:bilimusic/feature/player/data/bili_player_repository.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:bilimusic/feature/radar/domain/music_radar_state.dart';
import 'package:bilimusic/feature/radar/logic/music_radar_controller.dart';
import 'package:bilimusic/feature/radar/ui/components/music_radar_visual.dart';
import 'package:bilimusic/feature/radar/ui/shuffle_page.dart';
import 'package:bilimusic/feature/search/data/bili_search_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const HotPlaylist _playlist = HotPlaylist(
  platform: MusicChartPlatform.netease,
  id: '1',
  name: '网易歌单',
  coverUrl: '',
);

List<HotPlaylistTrack> _tracks() {
  return <HotPlaylistTrack>[
    for (int index = 0; index < 12; index += 1)
      HotPlaylistTrack(
        playlist: _playlist,
        rank: index + 1,
        title: '刷歌歌曲$index',
        artist: '歌手$index',
        coverUrl: '',
        durationSeconds: 200,
      ),
  ];
}

class _LoadedFeed extends MusicRadarController {
  int scanCalls = 0;
  int extendCalls = 0;

  @override
  MusicRadarState build() =>
      MusicRadarState(tracks: _tracks(), scanCount: 1, isScanning: false);

  @override
  Future<void> scan() async {
    scanCalls += 1;
  }

  @override
  Future<void> extendFeed() async {
    extendCalls += 1;
  }
}

class _EmptyFeed extends MusicRadarController {
  @override
  MusicRadarState build() => const MusicRadarState();

  @override
  Future<void> scan() async {}

  @override
  Future<void> extendFeed() async {}
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
  _ResolvedResolver({this.fail = false, this.failTitles = const <String>{}})
    : super(
        searchRepository: _FakeSearchRepository(),
        playerRepository: _FakePlayerRepository(),
      );

  final bool fail;
  final Set<String> failTitles;

  @override
  Future<PlayableItem?> resolve(MatchableTrack track) async {
    if (fail || failTitles.contains(track.title)) {
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

class _FakePlayer extends PlayerController {
  final List<String?> queuedLabels = <String?>[];
  final List<List<PlayableItem>> queued = <List<PlayableItem>>[];
  int skipNextCalls = 0;
  int skipPreviousCalls = 0;
  List<PlayableItem> enqueued = <PlayableItem>[];

  @override
  PlayerState build() => const PlayerState();

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
  Future<void> skipToNext() async {
    skipNextCalls += 1;
  }

  @override
  Future<void> skipToPrevious() async {
    skipPreviousCalls += 1;
  }

  @override
  Future<void> enqueue(List<PlayableItem> items) async {
    enqueued = items;
  }
}

Future<ProviderContainer> _pumpPage(
  WidgetTester tester, {
  required MusicRadarController Function() controller,
  MusicChartResolver? resolver,
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final ProviderContainer container = ProviderContainer(
    overrides: [
      musicRadarControllerProvider.overrideWith(controller),
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
      child: const MaterialApp(home: ShufflePage()),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

void main() {
  testWidgets('进入刷歌时一次只装 5 首进队列', (WidgetTester tester) async {
    final ProviderContainer container = await _pumpPage(
      tester,
      controller: _LoadedFeed.new,
    );

    final _FakePlayer player =
        container.read(playerControllerProvider.notifier) as _FakePlayer;
    expect(player.queued, hasLength(1));
    expect(player.queuedLabels.single, '刷歌');
    expect(player.queued.single, hasLength(5));
    expect(
      player.queued.single.map((PlayableItem item) => item.title),
      <String>['刷歌歌曲0', '刷歌歌曲1', '刷歌歌曲2', '刷歌歌曲3', '刷歌歌曲4'],
    );
  });

  testWidgets('匹配失败会继续往后取候选，仍能凑够一批', (WidgetTester tester) async {
    // 前 3 首匹配失败，仍然要从剩下的候选里补足 5 首。
    final ProviderContainer container = await _pumpPage(
      tester,
      controller: _LoadedFeed.new,
      resolver: _ResolvedResolver(
        failTitles: <String>{'刷歌歌曲0', '刷歌歌曲1', '刷歌歌曲2'},
      ),
    );

    final _FakePlayer player =
        container.read(playerControllerProvider.notifier) as _FakePlayer;
    expect(player.queued.single, hasLength(5));
    expect(
      player.queued.single.map((PlayableItem item) => item.title),
      isNot(contains('刷歌歌曲0')),
    );
  });

  testWidgets('队列建好后展示完整播放页', (WidgetTester tester) async {
    final ProviderContainer container = await _pumpPage(
      tester,
      controller: _LoadedFeed.new,
    );
    // 队列装好但当前没有播放项时，仍然是刷歌的待命态。
    expect(find.text('正在为你挑歌'), findsNothing);
    expect(container.read(playerControllerProvider).currentItem, isNull);
    expect(find.text('暂无歌曲'), findsOneWidget);
  });

  testWidgets('每首都匹配不到时给出可重试的错误态', (WidgetTester tester) async {
    await _pumpPage(
      tester,
      controller: _LoadedFeed.new,
      resolver: _ResolvedResolver(fail: true),
    );

    expect(find.text('刷歌暂时没有发现'), findsOneWidget);
    expect(find.text('推荐歌曲暂时都没匹配到 B 站视频，换个批次再试'), findsOneWidget);
    expect(find.text('重新取样'), findsOneWidget);
  });

  testWidgets('推荐为空时也能给出提示与重试', (WidgetTester tester) async {
    await _pumpPage(tester, controller: _EmptyFeed.new);

    expect(find.text('刷歌暂时没有发现'), findsOneWidget);
    expect(find.text('重新取样'), findsOneWidget);
    expect(find.byType(MusicRadarVisual), findsNothing);
  });

  group('shouldTopUpShuffleQueue', () {
    test('非刷歌队列一律不补货', () {
      expect(
        shouldTopUpShuffleQueue(
          sourceLabel: '我喜欢',
          queueLength: 1,
          currentIndex: 0,
          lead: 1,
        ),
        isFalse,
      );
      expect(
        shouldTopUpShuffleQueue(
          sourceLabel: null,
          queueLength: 1,
          currentIndex: 0,
          lead: 1,
        ),
        isFalse,
      );
    });

    test('队列中间段不补货', () {
      expect(
        shouldTopUpShuffleQueue(
          sourceLabel: '刷歌 · 网易云',
          queueLength: 5,
          currentIndex: 0,
          lead: 1,
        ),
        isFalse,
      );
      expect(
        shouldTopUpShuffleQueue(
          sourceLabel: '刷歌',
          queueLength: 5,
          currentIndex: 3,
          lead: 1,
        ),
        isFalse,
      );
    });

    test('播到最后一首时补货', () {
      expect(
        shouldTopUpShuffleQueue(
          sourceLabel: '刷歌',
          queueLength: 5,
          currentIndex: 4,
          lead: 1,
        ),
        isTrue,
      );
    });

    test('只有一首歌时立刻补货', () {
      expect(
        shouldTopUpShuffleQueue(
          sourceLabel: '刷歌',
          queueLength: 1,
          currentIndex: 0,
          lead: 1,
        ),
        isTrue,
      );
      expect(
        shouldTopUpShuffleQueue(
          sourceLabel: '刷歌',
          queueLength: 1,
          currentIndex: null,
          lead: 1,
        ),
        isTrue,
      );
    });
  });
}
