import 'package:flutter/material.dart';

const String defaultThemeVariantId = 'frostTeaWhite';

/// 页面底色：冷灰而非纯白，这是靠「底色差」而非阴影拉层级的基础。
const Color _pageBackground = Color(0xFFF1F5F7);

class ThemeDefinition {
  const ThemeDefinition({
    required this.id,
    required this.label,
    required this.description,
    required this.seedColor,
    this.primaryColor,
    this.brandFillColor,
    this.lightScaffoldBackgroundColor = _pageBackground,
    this.lightSurfaceColor = Colors.white,
    this.darkScaffoldBackgroundColor = const Color(0xFF101010),
    this.darkSurfaceColor = const Color(0xFF1C1C1C),
  });

  final String id;
  final String label;
  final String description;
  final Color seedColor;
  final Color? primaryColor;

  /// 选中态/主 CTA 的实心填充色，配黑字；为空时退回 [seedColor]。
  final Color? brandFillColor;
  final Color lightScaffoldBackgroundColor;
  final Color lightSurfaceColor;
  final Color darkScaffoldBackgroundColor;
  final Color darkSurfaceColor;

  Color get resolvedBrandFillColor => brandFillColor ?? seedColor;
}

const List<ThemeDefinition> themeCatalog = <ThemeDefinition>[
  ThemeDefinition(
    id: 'classicGreen',
    label: '经典绿',
    description: '默认',
    seedColor: Color(0xFF31C27C),
    primaryColor: Color(0xFF31C27C),
    brandFillColor: Color(0xFF3AD98C),
    darkScaffoldBackgroundColor: Color(0xFF09120F),
    darkSurfaceColor: Color(0xFF13211D),
  ),
  ThemeDefinition(
    id: defaultThemeVariantId,
    label: '霜茶白',
    description: '白色打底的低饱和浅色主题',
    seedColor: Color(0xFFF6F6F6),
    primaryColor: Color(0xFF00B364),
    brandFillColor: Color(0xFF00EB81),
  ),
  ThemeDefinition(
    id: 'skyBlue',
    label: '海盐蓝',
    description: '更清爽通透的浅色蓝调',
    seedColor: Color(0xFF3B82F6),
    lightScaffoldBackgroundColor: Color(0xFFF0F4FA),
    lightSurfaceColor: Color(0xFFFCFDFF),
    brandFillColor: Color(0xFF5AA6FF),
    darkScaffoldBackgroundColor: Color(0xFF08111F),
    darkSurfaceColor: Color(0xFF101D33),
  ),
  ThemeDefinition(
    id: 'irisPurple',
    label: '鸢尾紫',
    description: '柔和克制的浅色紫调',
    seedColor: Color(0xFF7C6CF2),
    lightScaffoldBackgroundColor: Color(0xFFF3F1FA),
    lightSurfaceColor: Color(0xFFFFFCFF),
    brandFillColor: Color(0xFF9A8CFF),
    darkScaffoldBackgroundColor: Color(0xFF120D1E),
    darkSurfaceColor: Color(0xFF211932),
  ),
  ThemeDefinition(
    id: 'blossomPink',
    label: '花雾粉',
    description: '轻盈明快的浅色粉调',
    seedColor: Color(0xFFF1CADC),
    primaryColor: Color(0xFFD45C8E),
    lightScaffoldBackgroundColor: Color(0xFFFAF2F5),
    brandFillColor: Color(0xFFF6A6C4),
    darkScaffoldBackgroundColor: Color(0xFF1D0E16),
    darkSurfaceColor: Color(0xFF2E1924),
  ),
  ThemeDefinition(
    id: 'sunsetOrange',
    label: '日落橙',
    description: '更有活力的暖色浅色主题',
    seedColor: Color(0xFFFF8A3D),
    lightScaffoldBackgroundColor: Color(0xFFFAF3ED),
    brandFillColor: Color(0xFFFFA76B),
    darkScaffoldBackgroundColor: Color(0xFF1E1008),
    darkSurfaceColor: Color(0xFF2F1B10),
  ),
];

ThemeDefinition themeDefinitionOf(String id) {
  for (final ThemeDefinition definition in themeCatalog) {
    if (definition.id == id) {
      return definition;
    }
  }

  return themeCatalog.first;
}

bool isKnownThemeVariantId(String id) {
  return themeCatalog.any((ThemeDefinition definition) => definition.id == id);
}
