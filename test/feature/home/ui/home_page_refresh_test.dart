import 'package:bilimusic/feature/home/domain/hot_playlist_state.dart';
import 'package:bilimusic/feature/home/domain/music_chart_state.dart';
import 'package:bilimusic/feature/home/logic/hot_playlist_controller.dart';
import 'package:bilimusic/feature/home/logic/music_chart_controller.dart';
import 'package:bilimusic/feature/home/ui/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

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
      find.byType(RefreshIndicator),
    );
    await indicator.onRefresh();

    expect(_CountingChartController.refreshes, 1);
    expect(_CountingPlaylistController.refreshes, 1);
    expect(tester.takeException(), isNull);
  });
}
