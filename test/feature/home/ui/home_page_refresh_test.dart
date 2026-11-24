import 'package:bilimusic/feature/daily/domain/daily_recommendation_state.dart';
import 'package:bilimusic/feature/daily/logic/daily_recommendation_controller.dart';
import 'package:bilimusic/feature/home/domain/hot_playlist_state.dart';
import 'package:bilimusic/feature/home/domain/music_chart_state.dart';
import 'package:bilimusic/feature/home/logic/hot_playlist_controller.dart';
import 'package:bilimusic/feature/home/logic/music_chart_controller.dart';
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

class _FakeDaily extends DailyRecommendationController {
  @override
  DailyRecommendationState build() => const DailyRecommendationState();
}

class _CountingChartController extends MusicChartController {
  static int refreshes = 0;

  @override
  MusicChartState build() => const MusicChartState();

  @override
  Future<void> refresh() async {
    refreshes += 1;
  }
}

class _CountingPlaylistController extends HotPlaylistController {
  static int refreshes = 0;

  @override
  HotPlaylistState build() => const HotPlaylistState();

  @override
  Future<void> refresh() async {
    refreshes += 1;
  }
}

void main() {
  setUp(() {
    _CountingChartController.refreshes = 0;
    _CountingPlaylistController.refreshes = 0;
  });

  testWidgets('首页下拉刷新同时刷新热榜和热门歌单', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          musicRadarControllerProvider.overrideWith(_FakeRadar.new),
          dailyRecommendationControllerProvider.overrideWith(_FakeDaily.new),
          musicChartControllerProvider.overrideWith(
            _CountingChartController.new,
          ),
          hotPlaylistControllerProvider.overrideWith(
            _CountingPlaylistController.new,
          ),
        ],
        child: const MaterialApp(home: HomePage()),
      ),
    );
    await tester.pump();

    final RefreshIndicator indicator = tester.widget<RefreshIndicator>(
      find.byType(RefreshIndicator).first,
    );
    await indicator.onRefresh();

    expect(_CountingChartController.refreshes, 1);
    expect(_CountingPlaylistController.refreshes, 1);
    expect(tester.takeException(), isNull);
  });
}
