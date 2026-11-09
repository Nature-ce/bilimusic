import 'package:bilimusic/core/theme/app_theme.dart';
import 'package:bilimusic/core/theme/theme_catalog.dart';
import 'package:bilimusic/core/theme/theme_colors.dart';
import 'package:bilimusic/feature/home/domain/music_chart_catalog.dart';
import 'package:bilimusic/feature/home/domain/music_chart_state.dart';
import 'package:bilimusic/feature/home/domain/music_chart_track.dart';
import 'package:bilimusic/feature/home/logic/music_chart_controller.dart';
import 'package:bilimusic/feature/home/ui/components/music_chart_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _LoadingCharts extends MusicChartController {
  @override
  MusicChartState build() => const MusicChartState(isLoading: true);
}

class _LoadedCharts extends MusicChartController {
  @override
  MusicChartState build() => MusicChartState(
    isLoading: false,
    tracks: <MusicChartTrack>[
      MusicChartTrack(
        chart: MusicChartCatalog.defaultChart,
        rank: 1,
        title: '晴天',
        artist: '周杰伦',
        coverUrl: '',
      ),
    ],
  );
}

Future<void> _pumpSection(
  WidgetTester tester, {
  required MusicChartController Function() controller,
  required ThemeData theme,
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [musicChartControllerProvider.overrideWith(controller)],
      child: MaterialApp(
        theme: theme,
        home: const Scaffold(
          body: SingleChildScrollView(child: MusicChartSection()),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('the loading skeleton uses the theme container color', (
    WidgetTester tester,
  ) async {
    await _pumpSection(
      tester,
      controller: _LoadingCharts.new,
      theme: AppTheme.lightTheme(defaultThemeVariantId),
    );

    final BuildContext context = tester.element(find.byType(MusicChartSection));
    final Color expected = appSkeletonColor(context);
    final bool hasSkeleton = tester
        .widgetList<Container>(find.byType(Container))
        .any((Container container) {
          final Decoration? decoration = container.decoration;
          return decoration is BoxDecoration && decoration.color == expected;
        });

    expect(hasSkeleton, isTrue);
  });

  testWidgets('the selected chip uses the theme primary tint', (
    WidgetTester tester,
  ) async {
    await _pumpSection(
      tester,
      controller: _LoadedCharts.new,
      theme: AppTheme.lightTheme(defaultThemeVariantId),
    );

    final BuildContext context = tester.element(find.byType(MusicChartSection));
    final Color selectedBackground = appChipBackgroundColor(
      context,
      selected: true,
    );
    final bool hasSelectedChip = tester
        .widgetList<Material>(find.byType(Material))
        .any((Material material) => material.color == selectedBackground);

    expect(hasSelectedChip, isTrue);
  });
}
