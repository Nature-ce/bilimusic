import 'package:bilimusic/core/theme/app_brand_colors.dart';
import 'package:bilimusic/core/theme/app_contrast.dart';
import 'package:bilimusic/core/theme/app_theme.dart';
import 'package:bilimusic/core/theme/theme_catalog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('brand fill palette', () {
    test('picks a readable foreground for every brightness', () {
      expect(
        AppBrandColors.fromFill(const Color(0xFF00EB81)).onFill,
        Colors.black,
      );
      expect(
        AppBrandColors.fromFill(const Color(0xFF1B3A2C)).onFill,
        Colors.white,
      );
    });

    test('keeps the fill as given so it stays vivid', () {
      const Color fill = Color(0xFF00EB81);
      expect(AppBrandColors.fromFill(fill).fill, fill);
    });

    test('foreground and fill stay above the WCAG body-text floor', () {
      for (final ThemeDefinition definition in themeCatalog) {
        final AppBrandColors colors = AppBrandColors.fromFill(
          definition.resolvedBrandFillColor,
        );
        expect(
          AppContrast.ratio(colors.onFill, colors.fill),
          greaterThanOrEqualTo(4.5),
          reason: '${definition.id} brand fill must stay readable',
        );
      }
    });
  });

  group('theme registration', () {
    for (final ThemeDefinition definition in themeCatalog) {
      for (final Brightness brightness in Brightness.values) {
        test('${definition.id} ${brightness.name} exposes brand colors', () {
          final ThemeData theme = brightness == Brightness.light
              ? AppTheme.lightTheme(definition.id)
              : AppTheme.darkTheme(definition.id);
          final AppBrandColors? brand = theme.extension<AppBrandColors>();

          expect(brand, isNotNull);
          expect(brand!.fill, definition.resolvedBrandFillColor);
        });
      }
    }
  });
}
