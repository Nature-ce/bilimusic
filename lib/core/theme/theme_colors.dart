import 'package:bilimusic/core/theme/app_brand_colors.dart';
import 'package:bilimusic/core/theme/app_design.dart';
import 'package:flutter/material.dart';

/// QQ音乐风格的中性色板：页面冷灰底 + 纯白卡面，层级靠底色差表达。
abstract final class AppNeutralColors {
  static const Color pageBackground = Color(0xFFF1F5F7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color fill = Color(0xFFE2E7EC);
  static const Color sheet = Color(0xFFEDF1F2);
  static const Color borderSubtle = Color(0xFFEBEEF0);
  static const Color divider = Color(0xFFF0F0F0);
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF494A4B);
  static const Color textTertiary = Color(0xFFA8ABAC);
  static const Color chartHot = Color(0xFFFF6B4A);
}

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

bool _isDark(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark;
}

/// 品牌实心填充色：选中态胶囊、主 CTA 的底色，配 [appOnBrandFillColor] 的文字。
Color appBrandFillColor(BuildContext context) {
  final AppBrandColors? brand = Theme.of(context).extension<AppBrandColors>();
  return brand?.fill ?? Theme.of(context).colorScheme.primary;
}

Color appOnBrandFillColor(BuildContext context) {
  final AppBrandColors? brand = Theme.of(context).extension<AppBrandColors>();
  return brand?.onFill ?? onColorFor(Theme.of(context).colorScheme.primary);
}

/// 页面底色：亮色用冷灰，暗色用主题背景。
Color appPageBackgroundColor(BuildContext context) {
  return Theme.of(context).scaffoldBackgroundColor;
}

Color appMutedTextColor(BuildContext context) {
  return Theme.of(context).colorScheme.onSurfaceVariant;
}

Color appSubtleTextColor(BuildContext context, {double alpha = 0.72}) {
  return Theme.of(context).colorScheme.onSurface.withValues(alpha: alpha);
}

/// 三级文字：计数、占位、极弱说明。
Color appTertiaryTextColor(BuildContext context) {
  return _isDark(context)
      ? Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.72)
      : AppNeutralColors.textTertiary;
}

Color appSecondaryTextColor(BuildContext context) {
  return _isDark(context)
      ? Theme.of(context).colorScheme.onSurfaceVariant
      : AppNeutralColors.textSecondary;
}

Color appSkeletonColor(BuildContext context) {
  return _isDark(context)
      ? Theme.of(context).colorScheme.surfaceContainerHighest
      : AppNeutralColors.sheet;
}

/// 卡片/悬浮控件的底色：亮色主题下用纯白（避免 seed 带来的冷调），暗色主题用 surface。
Color appCardSurfaceColor(BuildContext context) {
  final ThemeData theme = Theme.of(context);
  return theme.brightness == Brightness.dark
      ? theme.colorScheme.surface
      : Colors.white;
}

/// 输入框、搜索条的实心填充底。
Color appFillColor(BuildContext context) {
  return _isDark(context)
      ? Theme.of(context).colorScheme.surfaceContainerHighest
      : AppNeutralColors.fill;
}

/// 半屏面板底色：比页面深一档。
Color appSheetBackgroundColor(BuildContext context) {
  return _isDark(context)
      ? Theme.of(context).colorScheme.surfaceContainerHigh
      : AppNeutralColors.sheet;
}

Color appSurfaceContainerColor(BuildContext context, {double alpha = 1}) {
  return Theme.of(
    context,
  ).colorScheme.surfaceContainerHighest.withValues(alpha: alpha);
}

/// 选中态 chip：品牌实心填充 + 反色文字；未选中：透明底 + 次级文字。
Color appChipBackgroundColor(BuildContext context, {required bool selected}) {
  return selected ? appBrandFillColor(context) : Colors.transparent;
}

Color appChipForegroundColor(BuildContext context, {required bool selected}) {
  return selected
      ? appOnBrandFillColor(context)
      : Theme.of(context).colorScheme.onSurfaceVariant;
}

Color appDividerColor(BuildContext context) {
  return Theme.of(context).colorScheme.outlineVariant;
}

/// 白卡容器：纯白底 + 12dp 圆角。
///
/// 设计规范明确「极少用阴影」，层级靠底色差（冷灰底 vs 白卡）+ 留白表达，
/// 所以默认不带描边也不带投影。
BoxDecoration appCardDecoration(
  BuildContext context, {
  double radius = AppRadius.card,
}) {
  return BoxDecoration(
    color: appCardSurfaceColor(context),
    borderRadius: BorderRadius.circular(radius),
  );
}

/// 需要浮起时（面板、胶囊、悬浮按钮）才用的柔和投影。
List<BoxShadow> appSoftShadow(BuildContext context, {double blur = 18}) {
  return <BoxShadow>[
    BoxShadow(
      color: appShadowColor(context),
      blurRadius: blur,
      offset: const Offset(0, 4),
    ),
  ];
}

/// 兼容旧调用：白卡容器，行为同 [appCardDecoration]。
BoxDecoration appElevatedCardDecoration(
  BuildContext context, {
  double radius = AppRadius.card,
}) {
  return appCardDecoration(context, radius: radius);
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
