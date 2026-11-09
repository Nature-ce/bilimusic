import 'package:bilimusic/common/util/platform_util.dart';
import 'package:bilimusic/core/theme/app_design.dart';
import 'package:bilimusic/core/theme/components/no_transition_builder.dart';
import 'package:bilimusic/core/theme/desktop_chinese_font.dart';
import 'package:bilimusic/core/theme/theme_catalog.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

final class AppTheme {
  const AppTheme._();

  static ThemeData lightTheme(String variantId) {
    return _buildTheme(variantId, Brightness.light);
  }

  static ThemeData darkTheme(String variantId) {
    return _buildTheme(variantId, Brightness.dark);
  }

  static ThemeData _buildTheme(String variantId, Brightness brightness) {
    final ThemeDefinition definition = themeDefinitionOf(variantId);
    final bool isDark = brightness == Brightness.dark;
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: definition.seedColor,
      brightness: brightness,
    ).copyWith(primary: definition.primaryColor);

    const StadiumBorder pillBorder = StadiumBorder();
    final RoundedRectangleBorder cardBorder = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.lg),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      textTheme: _textTheme(brightness),
      colorScheme: colorScheme,
      scaffoldBackgroundColor: isDark
          ? definition.darkScaffoldBackgroundColor
          : definition.lightScaffoldBackgroundColor,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.pageTitleFrom(colorScheme),
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: isDark
            ? definition.darkSurfaceColor
            : definition.lightSurfaceColor,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: isDark
            ? definition.darkSurfaceColor
            : definition.lightSurfaceColor,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: isDark
            ? definition.darkSurfaceColor
            : definition.lightSurfaceColor,
        surfaceTintColor: Colors.transparent,
        shape: cardBorder,
      ),
      chipTheme: ChipThemeData(
        shape: pillBorder,
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs + 2,
        ),
        labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurfaceVariant,
        ),
        backgroundColor: colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.55,
        ),
        selectedColor: colorScheme.primary.withValues(alpha: 0.14),
        secondarySelectedColor: colorScheme.primary.withValues(alpha: 0.14),
        showCheckmark: false,
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        minVerticalPadding: AppSpacing.sm + 2,
        iconColor: colorScheme.onSurfaceVariant,
        titleTextStyle: AppTextStyles.listTitleFrom(colorScheme),
        subtitleTextStyle: AppTextStyles.metaFrom(colorScheme),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        thickness: 0.5,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 2,
        ),
        hintStyle: TextStyle(
          fontSize: 13,
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(
            color: colorScheme.primary.withValues(alpha: 0.7),
            width: 1.2,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: pillBorder,
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: pillBorder,
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: pillBorder,
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {TargetPlatform.windows: NoTransitionBuilder()},
      ),
    );
  }

  static TextTheme _textTheme(Brightness brightness) {
    final TextTheme textTheme = TextTheme().useSystemChineseFont(brightness);

    if (PlatformUtil.isDesktop) {
      return textTheme.apply(fontFamily: DesktopChineseFont.fontFamily);
    }

    return textTheme;
  }
}
