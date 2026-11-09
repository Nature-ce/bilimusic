import 'package:bilimusic/core/theme/app_design.dart';
import 'package:flutter/material.dart';

Color neutralColorForBrightness(
  Brightness brightness, {
  double lightAlpha = 0.86,
  double darkAlpha = 0.88,
}) {
  return switch (brightness) {
    Brightness.light => Colors.black.withValues(alpha: lightAlpha),
    Brightness.dark => Colors.white.withValues(alpha: darkAlpha),
  };
}

Color neutralColorOf(
  BuildContext context, {
  double lightAlpha = 0.86,
  double darkAlpha = 0.88,
}) {
  return neutralColorForBrightness(
    Theme.of(context).brightness,
    lightAlpha: lightAlpha,
    darkAlpha: darkAlpha,
  );
}

// 主题派生色：统一从这里取色，避免各处写死蓝/灰/黑导致和主题色不协调。

/// 「收藏/点赞」这类需要跳出主题色的强调色。
const Color appFavoriteColor = Color(0xFFF33939);

Color appMutedTextColor(BuildContext context) {
  return Theme.of(context).colorScheme.onSurfaceVariant;
}

Color appSubtleTextColor(BuildContext context, {double alpha = 0.72}) {
  return Theme.of(context).colorScheme.onSurface.withValues(alpha: alpha);
}

Color appSkeletonColor(BuildContext context) {
  return Theme.of(context).colorScheme.surfaceContainerHighest;
}

/// 卡片/悬浮控件的底色：亮色主题下用纯白（避免 seed 带来的冷调），暗色主题用 surface。
Color appCardSurfaceColor(BuildContext context) {
  final ThemeData theme = Theme.of(context);
  return theme.brightness == Brightness.dark
      ? theme.colorScheme.surface
      : Colors.white;
}

Color appSurfaceContainerColor(BuildContext context, {double alpha = 1}) {
  return Theme.of(
    context,
  ).colorScheme.surfaceContainerHighest.withValues(alpha: alpha);
}

Color appChipBackgroundColor(BuildContext context, {required bool selected}) {
  final ColorScheme colorScheme = Theme.of(context).colorScheme;
  return selected
      ? colorScheme.primary.withValues(alpha: 0.12)
      : colorScheme.surfaceContainerHighest.withValues(alpha: 0.6);
}

Color appChipForegroundColor(BuildContext context, {required bool selected}) {
  final ColorScheme colorScheme = Theme.of(context).colorScheme;
  return selected ? colorScheme.primary : colorScheme.onSurfaceVariant;
}

Color appDividerColor(BuildContext context) {
  return Theme.of(context).colorScheme.outlineVariant;
}

/// 浮起的卡片容器：白底（暗色主题用 surface）+ 细描边 + 柔和投影。
BoxDecoration appElevatedCardDecoration(
  BuildContext context, {
  double radius = AppRadius.card,
}) {
  final ThemeData theme = Theme.of(context);
  final ColorScheme colorScheme = theme.colorScheme;
  final bool isDark = theme.brightness == Brightness.dark;
  return BoxDecoration(
    color: appCardSurfaceColor(context),
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(
      color: colorScheme.outlineVariant.withValues(alpha: isDark ? 0.5 : 0.45),
      width: 0.8,
    ),
    boxShadow: <BoxShadow>[
      BoxShadow(
        color: appShadowColor(context),
        blurRadius: isDark ? 20 : 18,
        offset: const Offset(0, 6),
      ),
    ],
  );
}

Color appShadowColor(BuildContext context) {
  final bool isDark = Theme.of(context).brightness == Brightness.dark;
  return Colors.black.withValues(alpha: isDark ? 0.42 : 0.06);
}

/// 放在任意底色上的前景色：亮底用近黑，暗底用白色。
Color onColorFor(Color background) {
  return ThemeData.estimateBrightnessForColor(background) == Brightness.dark
      ? Colors.white
      : Colors.black;
}
