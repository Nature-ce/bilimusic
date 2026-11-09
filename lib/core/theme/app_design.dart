import 'package:flutter/material.dart';

/// 统一的间距栅格（8pt 体系，配合 4pt 微调）。
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
}

/// 圆角分层：小控件 < 卡片 < 面板，chip 与按钮用 pill。
abstract final class AppRadius {
  static const double xs = 8;
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 18;
  static const double card = 20;
  static const double xl = 24;
  static const double pill = 999;
}

abstract final class AppSizes {
  static const double listCover = 48;
  static const double tileCover = 56;
  static const double listRowHeight = 62;
  static const double miniPlayerHeight = 64;
  static const double minTapTarget = 48;
  static const double minIconTapTarget = 44;
}

/// 动效 token：短交互、常规过渡、滚动/入场三段，统一曲线并尊重系统「减弱动效」。
abstract final class AppMotion {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration base = Duration(milliseconds: 220);
  static const Duration slow = Duration(milliseconds: 320);

  static const Curve standard = Curves.easeOutCubic;
  static const Curve emphasized = Curves.easeOutQuart;

  static Duration resolve(BuildContext context, Duration duration) {
    return MediaQuery.maybeDisableAnimationsOf(context) ?? false
        ? Duration.zero
        : duration;
  }
}

/// 字阶：页面标题 / 分区标题 / 列表主文案 / 辅助信息，统一从 ColorScheme 取色。
abstract final class AppTextStyles {
  static TextStyle pageTitleFrom(ColorScheme colors) {
    return TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.4,
      height: 1.15,
      color: colors.onSurface,
    );
  }

  static TextStyle sectionTitleFrom(ColorScheme colors) {
    return TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.3,
      height: 1.2,
      color: colors.onSurface,
    );
  }

  static TextStyle listTitleFrom(ColorScheme colors) {
    return TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 1.25,
      color: colors.onSurface,
    );
  }

  static TextStyle metaFrom(ColorScheme colors, {double fontSize = 12}) {
    return TextStyle(
      fontSize: fontSize,
      height: 1.35,
      color: colors.onSurfaceVariant,
    );
  }

  static TextStyle pageTitle(ThemeData theme) =>
      pageTitleFrom(theme.colorScheme);

  static TextStyle sectionTitle(ThemeData theme) =>
      sectionTitleFrom(theme.colorScheme);

  static TextStyle listTitle(ThemeData theme) =>
      listTitleFrom(theme.colorScheme);

  static TextStyle meta(ThemeData theme, {double fontSize = 12}) =>
      metaFrom(theme.colorScheme, fontSize: fontSize);
}
