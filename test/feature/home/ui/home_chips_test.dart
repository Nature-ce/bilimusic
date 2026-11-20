import 'package:bilimusic/common/components/glass_panel.dart';
import 'package:bilimusic/feature/home/ui/components/home_chips.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

Future<void> _pumpChip(WidgetTester tester, Widget chip) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(body: Center(child: chip)),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('未选中的 chip 用灰白磨砂玻璃', (WidgetTester tester) async {
    await _pumpChip(
      tester,
      HomeChip(label: '网易云', selected: false, onTap: () {}),
    );

    final GlassPanel panel = tester.widget<GlassPanel>(find.byType(GlassPanel));
    expect(panel.settings, isNull);
    expect(panel.tone, GlassTone.frost);
    final GlassContainer glass = tester.widget<GlassContainer>(
      find.byType(GlassContainer),
    );
    expect(glass.settings?.glassColor, GlassTone.frost.settings.glassColor);
  });

  testWidgets('选中的平台 chip 用主色玻璃 + onPrimary 文字', (WidgetTester tester) async {
    await _pumpChip(
      tester,
      HomeChip(label: '网易云', selected: true, emphasis: true, onTap: () {}),
    );

    final BuildContext context = tester.element(find.text('网易云'));
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final GlassPanel panel = tester.widget<GlassPanel>(find.byType(GlassPanel));
    expect(panel.settings?.bodyMode, GlassBodyMode.clear);
    expect(panel.settings?.glassColor.r, closeTo(colorScheme.primary.r, 0.001));
    expect(
      tester.widget<Text>(find.text('网易云')).style?.color,
      colorScheme.onPrimary,
    );
  });

  testWidgets('选中的榜单 chip 用浅主色玻璃 + 主色文字', (WidgetTester tester) async {
    await _pumpChip(
      tester,
      HomeChip(label: '热歌榜', selected: true, compact: true, onTap: () {}),
    );

    final BuildContext context = tester.element(find.text('热歌榜'));
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final GlassPanel panel = tester.widget<GlassPanel>(find.byType(GlassPanel));
    expect(panel.settings!.glassColor.a, closeTo(0.24, 0.001));
    expect(
      tester.widget<Text>(find.text('热歌榜')).style?.color,
      colorScheme.primary,
    );
  });

  testWidgets('点击 chip 会回调', (WidgetTester tester) async {
    bool tapped = false;
    await _pumpChip(
      tester,
      HomeChip(label: 'QQ音乐', selected: false, onTap: () => tapped = true),
    );

    await tester.tap(find.text('QQ音乐'));
    await tester.pumpAndSettle();

    expect(tapped, isTrue);
    expect(tester.takeException(), isNull);
  });
}
