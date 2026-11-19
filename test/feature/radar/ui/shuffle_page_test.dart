import 'package:bilimusic/core/theme/app_theme.dart';
import 'package:bilimusic/core/theme/theme_catalog.dart';
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
import 'package:bilimusic/feature/radar/ui/components/shuffle_card.dart';
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
    const HotPlaylistTrack(
      playlist: _playlist,
      rank: 1,
      title: '刷歌歌曲一',
      artist: '歌手甲',
      coverUrl: '',
      durationSeconds: 245,
    ),
    const HotPlaylistTrack(
      playlist: _playlist,
      rank: 2,
      title: '刷歌歌曲二',
      artist: '歌手乙',
      coverUrl: '',
    ),
  ];
}

class _LoadedFeed extends MusicRadarController {
  int scanCalls = 0;
  final List<int> ensuredIndexes = <int>[];

  @override
  MusicRadarState build() =>
      MusicRadarState(tracks: _tracks(), scanCount: 1, isScanning: false);

  @override
  Future<void> scan() async {
    scanCalls += 1;
  }

  @override
  void ensureFeedAt(int index) {
    ensuredIndexes.add(index);
  }
}

class _ScanningFeed extends MusicRadarController {
  @override
  MusicRadarState build() => const MusicRadarState(isScanning: true);
}

class _EmptyFeed extends MusicRadarController {
  @override
  MusicRadarState build() => const MusicRadarState();
}

class _FakeSearchRepository implements BiliSearchRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _FakePlayerRepository implements BiliPlayerRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _NullResolver extends MusicChartResolver {
  _NullResolver()
    : super(
        searchRepository: _FakeSearchRepository(),
        playerRepository: _FakePlayerRepository(),
      );

  @override
  Future<PlayableItem?> resolve(MatchableTrack track) async => null;
}

class _FakePlayer extends PlayerController {
  final List<List<PlayableItem>> queued = <List<PlayableItem>>[];
  int toggleCalls = 0;

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
  }

  @override
  Future<void> togglePlayback() async {
    toggleCalls += 1;
  }
}

Future<ProviderContainer> _pumpPage(
  WidgetTester tester, {
  required MusicRadarController Function() controller,
  bool settle = true,
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final ProviderContainer container = ProviderContainer(
    overrides: [
      musicRadarControllerProvider.overrideWith(controller),
      musicChartResolverProvider.overrideWith((Ref ref) => _NullResolver()),
      playerControllerProvider.overrideWith(_FakePlayer.new),
    ],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: AppTheme.lightTheme(defaultThemeVariantId),
        home: const ShufflePage(),
      ),
    ),
  );
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }
  return container;
}

void main() {
  testWidgets('renders the first card as an immersive shuffle page', (
    WidgetTester tester,
  ) async {
    await _pumpPage(tester, controller: _LoadedFeed.new);

    expect(find.byType(ShuffleCard), findsOneWidget);
    expect(find.text('刷歌'), findsOneWidget);
    expect(find.text('1 / 2'), findsOneWidget);
    expect(find.text('刷歌歌曲一'), findsOneWidget);
    expect(find.text('歌手甲'), findsOneWidget);
    expect(find.textContaining('来自 网易云'), findsOneWidget);
    expect(find.text('试试上下滑，发现更多好歌'), findsOneWidget);
    // 第二张卡还没滑到，不应渲染出来。
    expect(find.text('刷歌歌曲二'), findsNothing);
  });

  testWidgets('swiping up moves to the next card and asks for more tracks', (
    WidgetTester tester,
  ) async {
    final ProviderContainer container = await _pumpPage(
      tester,
      controller: _LoadedFeed.new,
    );

    await tester.drag(find.byType(PageView), const Offset(0, -600));
    await tester.pumpAndSettle();

    expect(find.text('刷歌歌曲二'), findsOneWidget);
    expect(find.text('2 / 2'), findsOneWidget);

    final _LoadedFeed feed =
        container.read(musicRadarControllerProvider.notifier) as _LoadedFeed;
    expect(feed.ensuredIndexes, contains(1));
  });

  testWidgets('换一批 asks the controller to rebuild the feed', (
    WidgetTester tester,
  ) async {
    final ProviderContainer container = await _pumpPage(
      tester,
      controller: _LoadedFeed.new,
    );

    await tester.tap(find.byTooltip('换一批'));
    await tester.pump();

    final _LoadedFeed feed =
        container.read(musicRadarControllerProvider.notifier) as _LoadedFeed;
    expect(feed.scanCalls, 1);
  });

  testWidgets('auto matching reports a failed match without crashing', (
    WidgetTester tester,
  ) async {
    await _pumpPage(tester, controller: _LoadedFeed.new);

    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump();

    expect(find.text('没找到匹配的 B 站视频'), findsOneWidget);
    expect(find.text('重试'), findsOneWidget);
  });

  testWidgets('shows the scanning state before results arrive', (
    WidgetTester tester,
  ) async {
    await _pumpPage(tester, controller: _ScanningFeed.new, settle: false);

    expect(find.text('正在为你挑歌'), findsOneWidget);
    expect(find.byType(MusicRadarVisual), findsOneWidget);
    expect(find.byType(ShuffleCard), findsNothing);
  });

  testWidgets('shows an empty state with a rescan action', (
    WidgetTester tester,
  ) async {
    await _pumpPage(tester, controller: _EmptyFeed.new);

    expect(find.text('暂无歌曲'), findsOneWidget);
    expect(find.text('重新扫描'), findsOneWidget);
  });
}
