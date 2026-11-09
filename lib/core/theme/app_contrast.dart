import 'dart:math' as math;

import 'package:flutter/material.dart';

/// WCAG 对比度工具：主题构建与测试共用。
abstract final class AppContrast {
  static double relativeLuminance(Color color) {
    double channel(double value) {
      final double normalized = value / 255;
      return normalized <= 0.03928
          ? normalized / 12.92
          : math.pow((normalized + 0.055) / 1.055, 2.4).toDouble();
    }

    return 0.2126 * channel(color.r * 255) +
        0.7152 * channel(color.g * 255) +
        0.0722 * channel(color.b * 255);
  }

  static double ratio(Color first, Color second) {
    final double firstLuminance = relativeLuminance(first) + 0.05;
    final double secondLuminance = relativeLuminance(second) + 0.05;
    return firstLuminance > secondLuminance
        ? firstLuminance / secondLuminance
        : secondLuminance / firstLuminance;
  }

  /// 在亮/暗两个候选前景里挑与 [background] 对比度更高的那个。
  static Color readableForeground(
    Color background, {
    Color light = Colors.white,
    Color dark = Colors.black,
  }) {
    return ratio(light, background) >= ratio(dark, background) ? light : dark;
  }

  /// 把 [foreground] 逐步压暗或提亮，直到与 [background] 的对比度达到 [minRatio]。
  static Color ensureRatio(
    Color foreground,
    Color background, {
    double minRatio = 4.5,
  }) {
    if (ratio(foreground, background) >= minRatio) {
      return foreground;
    }
    final bool darken = relativeLuminance(background) > 0.5;
    final Color target = darken ? Colors.black : Colors.white;
    Color current = foreground;
    for (int step = 1; step <= 24; step += 1) {
      current = Color.lerp(foreground, target, step / 24)!;
      if (ratio(current, background) >= minRatio) {
        return current;
      }
    }
    return target;
  }
}
