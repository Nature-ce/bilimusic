import 'package:bilimusic/core/theme/app_contrast.dart';
import 'package:flutter/material.dart';

/// 品牌「实心填充」色板。
///
/// 设计规范：品牌色只用于「可点击的行动」与「已选中状态」，且一律作**实心填充 + 黑字**，
/// 不用作大面积装饰。它与 [ColorScheme.primary] 分开是因为后者会被对比度校正压暗，
/// 适合做文字/图标前景；而填充需要保持鲜亮，靠黑字保证可读性。
@immutable
class AppBrandColors extends ThemeExtension<AppBrandColors> {
  const AppBrandColors({required this.fill, required this.onFill});

  factory AppBrandColors.fromFill(Color fill) {
    return AppBrandColors(
      fill: fill,
      onFill:
          AppContrast.ratio(Colors.white, fill) >=
              AppContrast.ratio(Colors.black, fill)
          ? Colors.white
          : Colors.black,
    );
  }

  final Color fill;
  final Color onFill;

  @override
  AppBrandColors copyWith({Color? fill, Color? onFill}) {
    return AppBrandColors(
      fill: fill ?? this.fill,
      onFill: onFill ?? this.onFill,
    );
  }

  @override
  AppBrandColors lerp(covariant AppBrandColors? other, double t) {
    if (other == null) {
      return this;
    }
    return AppBrandColors(
      fill: Color.lerp(fill, other.fill, t)!,
      onFill: Color.lerp(onFill, other.onFill, t)!,
    );
  }
}
