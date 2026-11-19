import 'package:bilimusic/core/theme/theme_colors.dart';
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

    expect(find.text('音乐热榜'), findsOneWidget);
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

  testWidgets('active tab uses the brand fill with a readable foreground', (
    WidgetTester tester,
  ) async {
    await _pumpSwitch(
      tester,
      selected: HomeSection.playlists,
      onSelected: (_) {},
    );

    final Text active = tester.widget<Text>(find.text('热门歌单'));
    final Text inactive = tester.widget<Text>(find.text('音乐热榜'));
    final BuildContext context = tester.element(find.text('热门歌单'));
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    expect(active.style?.color, appOnBrandFillColor(context));
    expect(active.style?.fontWeight, FontWeight.w700);
    expect(inactive.style?.color, colorScheme.onSurface);
  });
}
