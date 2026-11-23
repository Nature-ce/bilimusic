import 'package:color_palette_plus/color_palette_plus.dart';
import 'package:flutter/material.dart';

class ColorUtil {
  ColorUtil._();

  /// 获取某个具体 shade
  static Color getShade(Color baseColor, int shadeValue) {
    return ColorPalette.getShade(baseColor, shadeValue);
  }

  /// 获取全部 shades Map
  static Map<int, Color> getAllShades(Color baseColor) {
    return ColorPalette.getAllShades(baseColor);
  }

  static Color getLight(Color baseColor) => getShade(baseColor, 100); // 浅色
}
