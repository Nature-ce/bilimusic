import 'package:bilimusic/feature/home/domain/hot_playlist.dart';
import 'package:bilimusic/feature/home/domain/hot_playlist_state.dart';
import 'package:bilimusic/feature/home/domain/music_chart_catalog.dart';
import 'package:bilimusic/feature/home/domain/music_chart_platform.dart';
import 'package:bilimusic/feature/home/domain/music_chart_state.dart';
import 'package:bilimusic/feature/home/domain/music_chart_track.dart';
import 'package:bilimusic/feature/home/logic/home_back_to_top.dart';
import 'package:bilimusic/feature/home/logic/hot_playlist_controller.dart';
import 'package:bilimusic/feature/home/logic/music_chart_controller.dart';
import 'package:bilimusic/feature/home/ui/components/home_back_to_top_button.dart';
import 'package:bilimusic/feature/home/ui/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bilimusic/feature/radar/domain/music_radar_state.dart';
import 'package:bilimusic/feature/radar/logic/music_radar_controller.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRadar extends MusicRadarController {
  @override
  MusicRadarState build() => const MusicRadarState();
}

class _FakeCharts extends MusicChartController {
  @override
  MusicChartState build() {
    final List<MusicChartTrack> tracks = <MusicChartTrack>[
      for (int index = 0; index < 60; index += 1)
        MusicChartTrack(
          chart: MusicChartCatalog.defaultChart,
          rank: index + 1,
          title: '歌曲 $index',
          artist: '歌手',
          coverUrl: '',
        ),
    ];
    return MusicChartState(
      entries: <MusicChartPlatform, MusicChartEntry>{
        for (final MusicChartPlatform platform in MusicChartPlatform.values)
          platform: MusicChartEntry(
            chart: MusicChartCatalog.defaultChartOf(platform),
            tracks: tracks,
          ),
      },
    );
  }
}

class _FakePlaylists extends HotPlaylistController {
  @override
  HotPlaylistState build() {
    return HotPlaylistState(
      platform: MusicChartPlatform.netease,
      playlists: <HotPlaylist>[
        for (int index = 0; index < 24; index += 1)
          HotPlaylist(
            platform: MusicChartPlatform.netease,
            id: '$index',
            name: '歌单 $index',
            coverUrl: '',
            playCount: 1000 + index,
            trackCount: 20,
            creator: 'UP主',
          ),
      ],
    );
  }
}

class _FakeChartList extends StatelessWidget {
  const _FakeChartList({required this.controller});

  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: controller,
      children: <Widget>[
        for (int index = 0; index < 40; index += 1)
          SizedBox(height: 80, child: Text('列表行 $index')),
      ],
    );
  }
}

void main() {
  test('visibility only flips when the value changes', () {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(homeBackToTopVisibilityProvider), isFalse);
    container.read(homeBackToTopVisibilityProvider.notifier).setVisible(true);
    expect(container.read(homeBackToTopVisibilityProvider), isTrue);
    container.read(homeBackToTopVisibilityProvider.notifier).setVisible(true);
    expect(container.read(homeBackToTopVisibilityProvider), isTrue);
    container.read(homeBackToTopVisibilityProvider.notifier).setVisible(false);
    expect(container.read(homeBackToTopVisibilityProvider), isFalse);
  });

  testWidgets('the button scrolls the shared list back to the top', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final ScrollController controller = ScrollController();
    addTearDown(controller.dispose);
    final ProviderContainer container = ProviderContainer(
      overrides: [
        homeScrollControllerProvider.overrideWith((ref) => controller),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(
            floatingActionButton: const HomeBackToTopButton(),
            body: _FakeChartList(controller: controller),
          ),
        ),
      ),
    );

    await tester.drag(find.byType(ListView), const Offset(0, -1200));
    await tester.pumpAndSettle();
    expect(controller.offset, greaterThan(480));

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(controller.offset, 0);
  });

  testWidgets('home page shows the back-to-top state after scrolling', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final ProviderContainer container = ProviderContainer(
      overrides: [
        musicChartControllerProvider.overrideWith(_FakeCharts.new),
        musicRadarControllerProvider.overrideWith(_FakeRadar.new),
        hotPlaylistControllerProvider.overrideWith(_FakePlaylists.new),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: HomePage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(container.read(homeBackToTopVisibilityProvider), isFalse);

    // 推荐 tab 改成卡片入口后一屏放得下，改用更长的热门歌单 tab 验证滚动状态。
    await tester.tap(find.text('热门歌单'));
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView), const Offset(0, -900));
    await tester.pumpAndSettle();
    expect(container.read(homeBackToTopVisibilityProvider), isTrue);

    await tester.drag(find.byType(ListView), const Offset(0, 900));
    await tester.pumpAndSettle();
    expect(container.read(homeBackToTopVisibilityProvider), isFalse);
  });
}
