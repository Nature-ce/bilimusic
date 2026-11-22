import 'package:bilimusic/common/components/glass_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('浅色主题下会换成深色文字主题', (WidgetTester tester) async {
    late ThemeData resolved;
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(colorSchemeSeed: Colors.teal),
        home: Builder(
          builder: (BuildContext context) {
            resolved = glassSurfaceTheme(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(resolved.brightness, Brightness.dark);
    expect(
      resolved.textTheme.bodyMedium?.color,
      resolved.colorScheme.onSurface,
    );
    expect(resolved.listTileTheme.textColor, resolved.colorScheme.onSurface);
    expect(
      resolved.textTheme.bodyMedium!.color!.computeLuminance(),
      greaterThan(0.6),
    );
  });

  testWidgets('只有 brightness=dark、文字仍是黑色的主题也要被纠正', (WidgetTester tester) async {
    final ThemeData lightBase = ThemeData(colorSchemeSeed: Colors.teal);
    final ThemeData halfDark = lightBase.copyWith(
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.teal,
        brightness: Brightness.dark,
      ),
    );
    expect(
      halfDark.textTheme.bodyMedium?.color,
      lightBase.textTheme.bodyMedium?.color,
      reason: '复现播放页那种「深色亮度 + 黑色文字」的主题',
    );
    expect(
      halfDark.textTheme.bodyMedium!.color!.computeLuminance(),
      lessThan(0.3),
    );

    late ThemeData resolved;
    await tester.pumpWidget(
      MaterialApp(
        theme: halfDark,
        home: Builder(
          builder: (BuildContext context) {
            resolved = glassSurfaceTheme(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    for (final Color? color in <Color?>[
      resolved.textTheme.bodyMedium?.color,
      resolved.textTheme.titleLarge?.color,
      resolved.iconTheme.color,
    ]) {
      expect(color, resolved.colorScheme.onSurface);
      expect(color!.computeLuminance(), greaterThan(0.6));
    }
  });
}
