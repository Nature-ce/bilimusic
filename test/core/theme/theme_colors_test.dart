import 'package:bilimusic/core/theme/app_contrast.dart';
import 'package:bilimusic/core/theme/app_design.dart';
import 'package:bilimusic/core/theme/app_theme.dart';
import 'package:bilimusic/core/theme/theme_catalog.dart';
import 'package:bilimusic/core/theme/theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<BuildContext> _pumpTheme(
  WidgetTester tester, {
  required ThemeData theme,
}) async {
  late BuildContext capturedContext;
  await tester.pumpWidget(
    MaterialApp(
      theme: theme,
      themeAnimationDuration: Duration.zero,
      home: Builder(
        builder: (BuildContext context) {
          capturedContext = context;
          return const SizedBox.shrink();
        },
      ),
    ),
  );
  return capturedContext;
}

void main() {
  test('onColorFor picks a readable foreground', () {
    expect(onColorFor(Colors.white), Colors.black);
    expect(onColorFor(const Color(0xFFF6F6F6)), Colors.black);
    expect(onColorFor(Colors.black), Colors.white);
    expect(onColorFor(const Color(0xFF00B364)), Colors.white);
  });

  testWidgets('light theme tokens come from the color scheme', (
    WidgetTester tester,
  ) async {
    final BuildContext context = await _pumpTheme(
      tester,
      theme: AppTheme.lightTheme(defaultThemeVariantId),
    );
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    expect(appMutedTextColor(context), colorScheme.onSurfaceVariant);
    expect(appSkeletonColor(context), AppNeutralColors.sheet);
    expect(
      appChipBackgroundColor(context, selected: true),
      appBrandFillColor(context),
    );
    expect(
      appChipBackgroundColor(context, selected: false),
      Colors.transparent,
    );
    expect(
      appChipForegroundColor(context, selected: true),
      appOnBrandFillColor(context),
    );
    expect(
      appChipForegroundColor(context, selected: false),
      colorScheme.onSurfaceVariant,
    );
    expect(appShadowColor(context), isNot(Colors.transparent));
  });

  testWidgets('dark theme tokens follow the dark color scheme', (
    WidgetTester tester,
  ) async {
    final BuildContext lightContext = await _pumpTheme(
      tester,
      theme: AppTheme.lightTheme(defaultThemeVariantId),
    );
    final Color lightSkeleton = appSkeletonColor(lightContext);

    final BuildContext darkContext = await _pumpTheme(
      tester,
      theme: AppTheme.darkTheme(defaultThemeVariantId),
    );
    final ColorScheme darkScheme = Theme.of(darkContext).colorScheme;

    expect(Theme.of(darkContext).brightness, Brightness.dark);
    expect(appSkeletonColor(darkContext), darkScheme.surfaceContainerHighest);
    expect(appSkeletonColor(darkContext), isNot(lightSkeleton));
    expect(
      appChipForegroundColor(darkContext, selected: false),
      darkScheme.onSurfaceVariant,
    );
  });

  testWidgets(
    'elevated card decoration is a plain white surface without shadow',
    (WidgetTester tester) async {
      final BuildContext context = await _pumpTheme(
        tester,
        theme: AppTheme.lightTheme(defaultThemeVariantId),
      );
      final BoxDecoration decoration = appElevatedCardDecoration(context);

      expect(decoration.color, Colors.white);
      expect(decoration.boxShadow, anyOf(isNull, isEmpty));
      expect(decoration.borderRadius, BorderRadius.circular(AppRadius.card));
      expect(decoration.border, isNull);
    },
  );

  testWidgets('theme variants expose a readable primary color', (
    WidgetTester tester,
  ) async {
    final ThemeDefinition definition = themeDefinitionOf(defaultThemeVariantId);
    final BuildContext context = await _pumpTheme(
      tester,
      theme: AppTheme.lightTheme(defaultThemeVariantId),
    );
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    expect(definition.primaryColor, isNotNull);
    expect(colorScheme.primary, isNot(definition.primaryColor));
    expect(
      AppContrast.ratio(colorScheme.primary, Colors.white),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      appChipForegroundColor(context, selected: true),
      appOnBrandFillColor(context),
    );
  });

  testWidgets('light theme layers a cold grey page under white cards', (
    WidgetTester tester,
  ) async {
    final BuildContext context = await _pumpTheme(
      tester,
      theme: AppTheme.lightTheme(defaultThemeVariantId),
    );

    expect(
      Theme.of(context).scaffoldBackgroundColor,
      AppNeutralColors.pageBackground,
    );
    expect(appCardSurfaceColor(context), Colors.white);
    expect(appFillColor(context), AppNeutralColors.fill);
    expect(appSheetBackgroundColor(context), AppNeutralColors.sheet);
    expect(appTertiaryTextColor(context), AppNeutralColors.textTertiary);
  });
}
