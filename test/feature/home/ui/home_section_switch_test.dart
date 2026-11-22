import 'package:bilimusic/feature/home/ui/components/home_section_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pumpSwitch(
  WidgetTester tester, {
  required HomeSection selected,
  required ValueChanged<HomeSection> onSelected,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: HomeSectionSwitch(selected: selected, onSelected: onSelected),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows both sections and reports the tapped one', (
    WidgetTester tester,
  ) async {
    HomeSection? tapped;
    await _pumpSwitch(
      tester,
      selected: HomeSection.charts,
      onSelected: (HomeSection section) => tapped = section,
    );

    expect(find.text('推荐'), findsOneWidget);
    expect(find.text('热门歌单'), findsOneWidget);

    await tester.tap(find.text('热门歌单'));
    await tester.pumpAndSettle();

    expect(tapped, HomeSection.playlists);
  });

  testWidgets('tapping the active section still reports it', (
    WidgetTester tester,
  ) async {
    HomeSection? tapped;
    await _pumpSwitch(
      tester,
      selected: HomeSection.playlists,
      onSelected: (HomeSection section) => tapped = section,
    );

    await tester.tap(find.text('热门歌单'));
    await tester.pumpAndSettle();

    expect(tapped, HomeSection.playlists);
  });

  testWidgets('active tab is bigger and bold, inactive one is muted', (
    WidgetTester tester,
  ) async {
    await _pumpSwitch(
      tester,
      selected: HomeSection.playlists,
      onSelected: (_) {},
    );

    final Text active = tester.widget<Text>(find.text('热门歌单'));
    final Text inactive = tester.widget<Text>(find.text('推荐'));
    final ColorScheme colorScheme = Theme.of(
      tester.element(find.text('热门歌单')),
    ).colorScheme;

    expect(active.style?.fontWeight, FontWeight.w800);
    expect(active.style?.color, colorScheme.onSurface);
    expect(inactive.style?.fontWeight, FontWeight.w600);
    expect(inactive.style?.color, colorScheme.onSurfaceVariant);
    expect(active.style!.fontSize, greaterThan(inactive.style!.fontSize!));
  });

  testWidgets('selected tab shows an underline indicator', (
    WidgetTester tester,
  ) async {
    await _pumpSwitch(tester, selected: HomeSection.charts, onSelected: (_) {});

    final Iterable<AnimatedContainer> bars = tester
        .widgetList<AnimatedContainer>(find.byType(AnimatedContainer));
    expect(bars.length, 2);
    final List<double> widthFactors = bars.map((AnimatedContainer bar) {
      return bar.constraints?.maxWidth ?? 0;
    }).toList();
    expect(widthFactors.where((double width) => width > 0).length, 1);
  });
}
