import 'package:bilimusic/feature/daily/domain/daily_recommendation.dart';
import 'package:bilimusic/feature/daily/domain/daily_recommendation_state.dart';
import 'package:bilimusic/feature/daily/logic/daily_recommendation_controller.dart';
import 'package:bilimusic/feature/home/domain/hot_playlist.dart';
import 'package:bilimusic/feature/home/domain/hot_playlist_state.dart';
import 'package:bilimusic/feature/home/domain/music_chart_platform.dart';
import 'package:bilimusic/feature/home/domain/music_chart_state.dart';
import 'package:bilimusic/feature/home/logic/hot_playlist_controller.dart';
import 'package:bilimusic/feature/home/logic/music_chart_controller.dart';
import 'package:bilimusic/feature/home/ui/home_page.dart';
import 'package:bilimusic/feature/radar/domain/music_radar_state.dart';
import 'package:bilimusic/feature/radar/logic/music_radar_controller.dart';
import 'package:bilimusic/feature/radar/domain/radar_pick.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRadar extends MusicRadarController {
  @override
  MusicRadarState build() => const MusicRadarState();
}

class _FakeDaily extends DailyRecommendationController {
  @override
  DailyRecommendationState build() => DailyRecommendationState(
    isLoading: false,
    dateKey: '2026-11-24',
    picks: <DailyPick>[
      for (int index = 0; index < 6; index += 1)
        DailyPick(
          title: '每日歌曲 $index',
          artist: '歌手 $index',
          reason: RadarReason.familiarArtist,
          durationSeconds: 200,
          platform: 'netease',
        ),
    ],
  );
}

class _FakeCharts extends MusicChartController {
  @override
  MusicChartState build() => const MusicChartState();
}

class _FakePlaylists extends HotPlaylistController {
  @override
  HotPlaylistState build() => const HotPlaylistState(
    platform: MusicChartPlatform.netease,
    playlists: <HotPlaylist>[
      HotPlaylist(
        platform: MusicChartPlatform.netease,
        id: '1',
        name: '滑动测试歌单',
        coverUrl: '',
        playCount: 1000,
        trackCount: 20,
        creator: 'UP主',
      ),
    ],
  );
}

Future<void> _pumpHome(
  WidgetTester tester, {
  bool disableAnimations = false,
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        musicRadarControllerProvider.overrideWith(_FakeRadar.new),
        dailyRecommendationControllerProvider.overrideWith(_FakeDaily.new),
        musicChartControllerProvider.overrideWith(_FakeCharts.new),
        hotPlaylistControllerProvider.overrideWith(_FakePlaylists.new),
      ],
      child: MediaQuery(
        data: MediaQueryData(disableAnimations: disableAnimations),
        child: const MaterialApp(home: HomePage()),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('左滑切到热门歌单、右滑切回推荐', (WidgetTester tester) async {
    await _pumpHome(tester);

    expect(find.text('今日推荐'), findsOneWidget);
    expect(find.text('编辑甄选'), findsNothing);

    await tester.fling(find.text('今日推荐'), const Offset(-400, 0), 1200);
    await tester.pumpAndSettle();

    expect(find.text('编辑甄选'), findsOneWidget);
    expect(find.text('今日推荐'), findsNothing);

    await tester.fling(find.text('编辑甄选'), const Offset(400, 0), 1200);
    await tester.pumpAndSettle();

    expect(find.text('今日推荐'), findsOneWidget);
    expect(find.text('编辑甄选'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('点击顶部栏目也能切换 section', (WidgetTester tester) async {
    await _pumpHome(tester);

    expect(find.text('今日推荐'), findsOneWidget);

    await tester.tap(find.text('热门歌单'));
    await tester.pumpAndSettle();

    expect(find.text('编辑甄选'), findsOneWidget);
    expect(find.text('今日推荐'), findsNothing);

    await tester.tap(find.text('推荐'));
    await tester.pumpAndSettle();

    expect(find.text('今日推荐'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('系统关闭动画时点击栏目也能切换 section', (WidgetTester tester) async {
    await _pumpHome(tester, disableAnimations: true);

    expect(find.text('今日推荐'), findsOneWidget);

    await tester.tap(find.text('热门歌单'));
    await tester.pumpAndSettle();

    expect(find.text('编辑甄选'), findsOneWidget);
    expect(find.text('今日推荐'), findsNothing);
    expect(tester.takeException(), isNull);
  });
  testWidgets('小幅横拖不会切换 section', (WidgetTester tester) async {
    await _pumpHome(tester);

    await tester.drag(find.text('今日推荐'), const Offset(-40, 0));
    await tester.pumpAndSettle();

    expect(find.text('今日推荐'), findsOneWidget);
    expect(find.text('编辑甄选'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
