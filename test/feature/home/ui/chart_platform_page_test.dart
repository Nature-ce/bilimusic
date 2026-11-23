import 'package:bilimusic/feature/home/domain/music_chart.dart';
import 'package:bilimusic/feature/home/domain/music_chart_catalog.dart';
import 'package:bilimusic/feature/home/domain/music_chart_platform.dart';
import 'package:bilimusic/feature/home/domain/music_chart_state.dart';
import 'package:bilimusic/feature/home/domain/music_chart_track.dart';
import 'package:bilimusic/feature/home/logic/music_chart_controller.dart';
import 'package:bilimusic/feature/home/ui/chart_platform_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeCharts extends MusicChartController {
  @override
  MusicChartState build() {
    final MusicChart chart = MusicChartCatalog.defaultChartOf(
      MusicChartPlatform.netease,
    );
    final List<MusicChartTrack> tracks = <MusicChartTrack>[
      for (int index = 0; index < 3; index += 1)
        MusicChartTrack(
          chart: chart,
          rank: index + 1,
          title: '榜单歌曲 $index',
          artist: '歌手',
          coverUrl: '',
        ),
    ];
    return MusicChartState(
      entries: <MusicChartPlatform, MusicChartEntry>{
        MusicChartPlatform.netease: MusicChartEntry(
          chart: chart,
          tracks: tracks,
          updatedAtMs: DateTime(2026, 1, 1, 8, 30).millisecondsSinceEpoch,
        ),
      },
    );
  }
}

Future<void> _pumpPage(WidgetTester tester) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final ProviderContainer container = ProviderContainer(
    overrides: [musicChartControllerProvider.overrideWith(_FakeCharts.new)],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(
        home: ChartPlatformPage(platform: MusicChartPlatform.netease),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('lists the default chart card and every other chart', (
    WidgetTester tester,
  ) async {
    await _pumpPage(tester);

    expect(find.widgetWithText(AppBar, '网易云'), findsOneWidget);
    expect(find.text('全部榜单'), findsOneWidget);
    expect(find.textContaining('默认榜'), findsNothing);
    expect(find.text('热歌榜'), findsOneWidget);
    expect(find.text('飙升榜'), findsOneWidget);
    expect(find.text('新歌榜'), findsOneWidget);
    expect(find.textContaining('08:30 更新'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
