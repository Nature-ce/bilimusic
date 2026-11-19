import 'package:flutter/material.dart';

/// 统一的间距栅格（2dp 栅格，常用 4/8/12/16/20/24）。
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;

  /// 页面左右安全边距，全站一致。
  static const double pageMargin = xl;

  /// 区块之间的垂直留白。
  static const double sectionGap = xxl;
}

/// 圆角分层：小标签 4、封面/小卡 8、白卡 12、输入框 16、半屏面板 20，按钮与胶囊全圆角。
abstract final class AppRadius {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double card = md;
  static const double xl = 20;
  static const double pill = 999;
}

abstract final class AppSizes {
  static const double listCover = 50;
  static const double tileCover = 50;
  static const double songRowHeight = 50;
  static const double listRowHeight = songRowHeight;
  static const double miniPlayerHeight = 52;
  static const double navigationBarHeight = 58;
  static const double searchBarHeight = 36;
  static const double sectionHeaderHeight = 40;
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
      fontWeight: FontWeight.w700,
      height: 1.3,
      color: colors.onSurface,
    );
  }

  static TextStyle sectionTitleFrom(ColorScheme colors) {
    return TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      height: 1.3,
      color: colors.onSurface,
    );
  }

  static TextStyle listTitleFrom(ColorScheme colors) {
    return TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 1.3,
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
