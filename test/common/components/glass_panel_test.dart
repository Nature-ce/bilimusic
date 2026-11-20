import 'package:bilimusic/common/components/glass_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(body: Center(child: child)),
    ),
  );
  await tester.pumpAndSettle();
}

GlassContainer _firstGlass(WidgetTester tester) {
  return tester.widget<GlassContainer>(find.byType(GlassContainer).first);
}

void main() {
  testWidgets('两档玻璃都用 clear 模式，底色由 glassColor 直接决定', (
    WidgetTester tester,
  ) async {
    for (final GlassTone tone in GlassTone.values) {
      await _pump(
        tester,
        GlassPanel(tone: tone, child: const SizedBox(width: 160, height: 80)),
      );

      final GlassContainer glass = _firstGlass(tester);
      expect(glass.useOwnLayer, isTrue);
      expect(glass.settings?.bodyMode, GlassBodyMode.clear);
      expect(glass.settings?.glassColor, tone.settings.glassColor);
    }
  });

  testWidgets('烟熏黑玻璃配白字，灰白磨砂玻璃配深色字', (WidgetTester tester) async {
    expect(GlassTone.smoke.primaryText.computeLuminance(), greaterThan(0.9));
    expect(GlassTone.frost.primaryText.computeLuminance(), lessThan(0.1));
    expect(
      GlassTone.smoke.secondaryText.a,
      greaterThan(GlassTone.smoke.divider.a),
    );
    expect(
      GlassTone.frost.secondaryText.a,
      greaterThan(GlassTone.frost.divider.a),
    );
  });

  testWidgets('弹层外壳是上方圆角 + 拖动条', (WidgetTester tester) async {
    await _pump(tester, const GlassSheetPanel(child: SizedBox(height: 120)));

    final GlassContainer glass = _firstGlass(tester);
    expect(glass.shape, isA<LiquidVerticalRoundedSuperellipse>());
    final LiquidVerticalRoundedSuperellipse shape =
        glass.shape as LiquidVerticalRoundedSuperellipse;
    expect(shape.topRadius, greaterThan(0));
    expect(shape.bottomRadius, 0);
    expect(find.byType(GlassDragHandle), findsOneWidget);
  });

  testWidgets('玻璃面板把内容裁在形状里', (WidgetTester tester) async {
    await _pump(
      tester,
      GlassPanel(
        shape: const LiquidRoundedSuperellipse(borderRadius: 28),
        child: const SizedBox(width: 160, height: 80),
      ),
    );

    final GlassContainer glass = _firstGlass(tester);
    expect(glass.clipBehavior, Clip.antiAlias);
    expect(glass.padding, EdgeInsets.zero);
  });

  testWidgets('玻璃面板内部的深色主题同时换掉文字与图标颜色', (WidgetTester tester) async {
    late ThemeData surfaceTheme;
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.light(),
        home: Scaffold(
          body: Builder(
            builder: (BuildContext context) {
              surfaceTheme = glassSurfaceTheme(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );

    expect(surfaceTheme.brightness, Brightness.dark);
    expect(
      surfaceTheme.colorScheme.onSurface.computeLuminance(),
      greaterThan(0.5),
    );
    expect(
      surfaceTheme.textTheme.bodyMedium?.color?.computeLuminance(),
      greaterThan(0.5),
    );
    expect(surfaceTheme.iconTheme.color?.computeLuminance(), greaterThan(0.5));
    expect(
      surfaceTheme.appBarTheme.titleTextStyle?.color?.computeLuminance(),
      greaterThan(0.5),
    );
    expect(
      surfaceTheme.listTileTheme.textColor,
      surfaceTheme.colorScheme.onSurface,
    );
  });
}
