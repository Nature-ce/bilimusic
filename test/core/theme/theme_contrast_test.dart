import 'package:bilimusic/core/theme/app_contrast.dart';
import 'package:bilimusic/core/theme/app_theme.dart';
import 'package:bilimusic/core/theme/theme_catalog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('theme contrast', () {
    for (final ThemeDefinition definition in themeCatalog) {
      for (final Brightness brightness in Brightness.values) {
        test('${definition.id} ${brightness.name} meets WCAG ratios', () {
          final ThemeData theme = brightness == Brightness.light
              ? AppTheme.lightTheme(definition.id)
              : AppTheme.darkTheme(definition.id);
          final ColorScheme colors = theme.colorScheme;
          final Color surface = brightness == Brightness.light
              ? definition.lightSurfaceColor
              : definition.darkSurfaceColor;
          final Color scaffold = theme.scaffoldBackgroundColor;

          expect(
            AppContrast.ratio(colors.onSurface, surface),
            greaterThanOrEqualTo(4.5),
          );
          expect(
            AppContrast.ratio(colors.onSurfaceVariant, surface),
            greaterThanOrEqualTo(4.5),
          );
          expect(
            AppContrast.ratio(colors.onSurfaceVariant, scaffold),
            greaterThanOrEqualTo(4.5),
          );
          expect(
            AppContrast.ratio(colors.primary, surface),
            greaterThanOrEqualTo(4.5),
          );
          expect(
            AppContrast.ratio(colors.onPrimary, colors.primary),
            greaterThanOrEqualTo(4.5),
          );
        });
      }
    }

    test('frost tea white darkens the raw brand green for readability', () {
      final ThemeData theme = AppTheme.lightTheme('frostTeaWhite');
      expect(theme.colorScheme.primary, isNot(const Color(0xFF00B364)));
      expect(
        AppContrast.ratio(theme.colorScheme.primary, Colors.white),
        greaterThanOrEqualTo(4.5),
      );
    });
  });

  group('contrast helpers', () {
    test('reads black on white and white on black', () {
      expect(AppContrast.ratio(Colors.black, Colors.white), closeTo(21, 0.5));
      expect(AppContrast.readableForeground(Colors.white), Colors.black);
      expect(AppContrast.readableForeground(Colors.black), Colors.white);
    });

    test('ensureRatio lifts a low contrast color until it passes', () {
      const Color pale = Color(0xFF00B364);
      expect(AppContrast.ratio(pale, Colors.white), lessThan(3));
      final Color fixed = AppContrast.ensureRatio(pale, Colors.white);
      expect(AppContrast.ratio(fixed, Colors.white), greaterThanOrEqualTo(4.5));
      expect(AppContrast.ensureRatio(Colors.black, Colors.white), Colors.black);
    });
  });
}
