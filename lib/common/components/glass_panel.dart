import 'package:bilimusic/core/theme/app_design.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

/// 播放页复用的两档玻璃材质。
///
/// 玻璃本体走 [GlassBodyMode.clear]，让 glassColor 的 alpha 直接决定透明度，
/// 而不是被着色器做一遍保亮度归一化 —— 这样深色玻璃才会真的变深、
/// 白字才压得住，浅色玻璃也才能稳定落在「灰白磨砂」这一档。
enum GlassTone {
  /// 烟熏黑玻璃：模糊后的封面透出来，配白色文字。
  smoke(
    primaryText: Color(0xFFFFFFFF),
    secondaryText: Color(0xB8FFFFFF),
    divider: Color(0x1FFFFFFF),
  ),

  /// 灰白磨砂玻璃：配深色文字。
  frost(
    primaryText: Color(0xFF171A1C),
    secondaryText: Color(0x99171A1C),
    divider: Color(0x1F171A1C),
  );

  const GlassTone({
    required this.primaryText,
    required this.secondaryText,
    required this.divider,
  });

  final Color primaryText;
  final Color secondaryText;
  final Color divider;

  LiquidGlassSettings get settings {
    switch (this) {
      case GlassTone.smoke:
        // 深色玻璃用「薄白纱 + 暗底」两层：白纱让玻璃比背景亮一档、透出模糊背景，
        // backerColor 压住封面亮部，白字才不会在浅色区域糊掉。
        return const LiquidGlassSettings(
          bodyMode: GlassBodyMode.clear,
          glassColor: Color(0x29FFFFFF),
          backerColor: Color(0x4D000000),
          thickness: 20,
          blur: 20,
          chromaticAberration: 0,
          saturation: 1.25,
          lightIntensity: 0.7,
          refractiveIndex: 1.18,
        );
      case GlassTone.frost:
        return const LiquidGlassSettings(
          bodyMode: GlassBodyMode.clear,
          glassColor: Color(0xE6E3E7E9),
          thickness: 16,
          blur: 14,
          chromaticAberration: 0,
          saturation: 1.1,
          lightIntensity: 0.5,
          refractiveIndex: 1.16,
        );
    }
  }
}

/// 一块玻璃面板：圆角可配，内容裁在形状里。
class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.tone = GlassTone.frost,
    this.shape = const LiquidRoundedSuperellipse(borderRadius: AppRadius.xl),
    this.padding = EdgeInsets.zero,
    this.clipBehavior = Clip.antiAlias,
  });

  final Widget child;
  final GlassTone tone;
  final LiquidShape shape;
  final EdgeInsetsGeometry padding;
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      useOwnLayer: true,
      quality: GlassQuality.standard,
      clipBehavior: clipBehavior,
      shape: shape,
      settings: tone.settings,
      padding: padding,
      child: child,
    );
  }
}

/// 底部弹层用的玻璃壳：上方圆角、下方直角，顶部带拖动条。
///
/// [child] 会直接放进内部 Column，需要占满剩余高度时传 [Flexible]。
class GlassSheetPanel extends StatelessWidget {
  const GlassSheetPanel({
    super.key,
    required this.child,
    this.tone = GlassTone.smoke,
  });

  final Widget child;
  final GlassTone tone;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      tone: tone,
      shape: const LiquidVerticalRoundedSuperellipse(
        topRadius: AppRadius.xl,
        bottomRadius: 0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          GlassDragHandle(tone: tone),
          child,
        ],
      ),
    );
  }
}

class GlassDragHandle extends StatelessWidget {
  const GlassDragHandle({super.key, this.tone = GlassTone.smoke});

  final GlassTone tone;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.sm),
      child: Center(
        child: Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: tone.primaryText.withValues(alpha: 0.32),
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
        ),
      ),
    );
  }
}

/// 玻璃面板内部用的深色主题。
///
/// 只换 [ThemeData.colorScheme] 是不够的：`textTheme`、`iconTheme`、`listTileTheme`
/// 仍然是浅色主题那一份，会出现「深色玻璃 + 黑字」。这里把它们一次性换成深色。
ThemeData glassSurfaceTheme(BuildContext context) {
  final ThemeData base = Theme.of(context);
  if (base.brightness == Brightness.dark) {
    return base;
  }

  final ColorScheme darkScheme = ColorScheme.fromSeed(
    seedColor: base.colorScheme.primary,
    brightness: Brightness.dark,
  );
  final TextTheme textTheme = base.textTheme.apply(
    bodyColor: darkScheme.onSurface,
    displayColor: darkScheme.onSurface,
  );
  final TextStyle? appBarTitleStyle =
      (base.appBarTheme.titleTextStyle ?? base.textTheme.titleLarge)?.copyWith(
        color: darkScheme.onSurface,
      );

  return base.copyWith(
    brightness: Brightness.dark,
    colorScheme: darkScheme,
    textTheme: textTheme,
    primaryTextTheme: base.primaryTextTheme.apply(
      bodyColor: darkScheme.onSurface,
      displayColor: darkScheme.onSurface,
    ),
    iconTheme: IconThemeData(color: darkScheme.onSurface),
    listTileTheme: base.listTileTheme.copyWith(
      textColor: darkScheme.onSurface,
      iconColor: darkScheme.onSurface,
    ),
    appBarTheme: base.appBarTheme.copyWith(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      foregroundColor: darkScheme.onSurface,
      titleTextStyle: appBarTitleStyle,
      iconTheme: IconThemeData(color: darkScheme.onSurface),
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    scaffoldBackgroundColor: Colors.transparent,
    canvasColor: Colors.transparent,
  );
}
