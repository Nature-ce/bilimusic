import 'package:bilimusic/core/theme/app_design.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

/// 半透明白雾玻璃：首页队列弹层、操作菜单这类浅色玻璃面板共用。
///
/// 比烟熏玻璃更透，掺一点主题色，深色主题下自动反白。
LiquidGlassSettings appFrostGlassSettings(BuildContext context) {
  final ThemeData theme = Theme.of(context);
  final ColorScheme colorScheme = theme.colorScheme;
  final bool isDark = theme.brightness == Brightness.dark;
  final Color base = isDark ? const Color(0xFF101215) : Colors.white;
  final Color tinted = Color.alphaBlend(
    colorScheme.primary.withValues(alpha: isDark ? 0.14 : 0.05),
    base,
  );

  return LiquidGlassSettings(
    bodyMode: GlassBodyMode.clear,
    glassColor: tinted.withValues(alpha: isDark ? 0.34 : 0.24),
    thickness: 14,
    blur: 30,
    chromaticAberration: 0,
    saturation: 1.55,
    lightIntensity: 0.55,
    refractiveIndex: 1.08,
  );
}

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
    this.tone,
    this.shape = const LiquidRoundedSuperellipse(borderRadius: AppRadius.xl),
    this.padding = EdgeInsets.zero,
    this.clipBehavior = Clip.antiAlias,
    this.settings,
  });

  final Widget child;

  /// 玻璃档位；为 null 时沿用主题 / 父层的玻璃设置（和迷你播放器同一套材质）。
  final GlassTone? tone;
  final LiquidShape shape;
  final EdgeInsetsGeometry padding;
  final Clip clipBehavior;

  /// 覆盖档位的玻璃参数（例如给选中的 chip 染主色）。
  final LiquidGlassSettings? settings;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      useOwnLayer: true,
      quality: GlassQuality.standard,
      clipBehavior: clipBehavior,
      shape: shape,
      settings: settings ?? tone?.settings,
      padding: padding,
      child: child,
    );
  }
}

/// 用某个颜色给玻璃染色，用来做「选中态」的胶囊 chip。
LiquidGlassSettings tintedGlassSettings(Color color, {double alpha = 0.86}) {
  return LiquidGlassSettings(
    bodyMode: GlassBodyMode.clear,
    glassColor: color.withValues(alpha: alpha),
    thickness: 20,
    blur: 6,
    saturation: 1.5,
    lightIntensity: 0.5,
    refractiveIndex: 1.2,
  );
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

/// 播放页底部弹层统一入口：深色玻璃壳（和播放列表一致）+ 深色主题。
Future<T?> showGlassSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = true,
  bool fillHeight = false,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    backgroundColor: Colors.transparent,
    elevation: 0,
    barrierColor: Colors.black.withValues(alpha: 0.3),
    builder: (BuildContext sheetContext) {
      final ThemeData sheetTheme = glassSurfaceTheme(sheetContext);
      return Theme(
        data: sheetTheme,
        // 弹层会从调用方那里继承 DefaultTextStyle（播放页那份仍是黑字），
        // 只有再套一层 Material 才会用新的深色 textTheme 重新铺开。
        child: Material(
          type: MaterialType.transparency,
          child: fillHeight
              ? GlassPanel(
                  tone: GlassTone.smoke,
                  shape: const LiquidVerticalRoundedSuperellipse(
                    topRadius: AppRadius.xl,
                    bottomRadius: 0,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const GlassDragHandle(tone: GlassTone.smoke),
                      Flexible(child: builder(sheetContext)),
                    ],
                  ),
                )
              : GlassSheetPanel(
                  tone: GlassTone.smoke,
                  child: builder(sheetContext),
                ),
        ),
      );
    },
  );
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
///
/// 注意不能因为 `brightness` 已经是 dark 就直接返回：[player_page] 那种「只换
/// colorScheme、textTheme 还是浅色」的主题同样是 dark 亮度，但文字是黑的，
/// 在深色玻璃上会糊成一片。
ThemeData glassSurfaceTheme(BuildContext context) {
  final ThemeData base = Theme.of(context);
  final ColorScheme darkScheme = base.colorScheme.brightness == Brightness.dark
      ? base.colorScheme
      : ColorScheme.fromSeed(
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
    hintColor: darkScheme.onSurfaceVariant,
    inputDecorationTheme: base.inputDecorationTheme.copyWith(
      fillColor: Colors.transparent,
    ),
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

/// 跟随「玻璃材质」开关的半屏弹层：开关打开时用白雾玻璃，关闭时退回白底。
class AppGlassSheet extends StatelessWidget {
  const AppGlassSheet({
    super.key,
    required this.child,
    this.maxHeightFactor = 0.66,
    this.tone = GlassTone.frost,
  });

  final Widget child;

  /// 弹层最高占屏幕高度的比例：内容多时在弹层内上下滑动，而不是占满整页。
  final double maxHeightFactor;

  /// 浅色页面用 frost（白雾 + 深色字），深色播放页用 smoke（烟熏 + 白字）。
  final GlassTone tone;

  @override
  Widget build(BuildContext context) {
    final double maxHeight =
        MediaQuery.sizeOf(context).height * maxHeightFactor;
    final bool smoke = tone == GlassTone.smoke;
    final Widget content = smoke
        ? Theme(data: glassSurfaceTheme(context), child: child)
        : child;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: GlassPanel(
        tone: smoke ? GlassTone.smoke : null,
        settings: smoke ? null : appFrostGlassSettings(context),
        shape: const LiquidVerticalRoundedSuperellipse(
          topRadius: AppRadius.xl,
          bottomRadius: 0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            GlassDragHandle(tone: tone),
            Flexible(child: SafeArea(top: false, child: content)),
          ],
        ),
      ),
    );
  }
}

/// 跟随玻璃开关的「内容型对话框」外壳：带输入框、列表等自定义内容的对话框用。
class AppGlassDialogShell extends StatelessWidget {
  const AppGlassDialogShell({
    super.key,
    required this.child,
    this.maxWidth = 360,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    // 不用 Dialog 包：Dialog 会对内容做 intrinsic 测量，里面放 ListView 会抛
    // 「would require instantiating every child of the viewport」。
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: maxWidth,
            maxHeight: MediaQuery.sizeOf(context).height * 0.62,
          ),
          child: GlassPanel(
            settings: appFrostGlassSettings(context),
            shape: LiquidRoundedSuperellipse(
              borderRadius: 28,
              side: BorderSide(
                color: colorScheme.outline.withValues(alpha: 0.2),
                width: 0.8,
              ),
            ),
            child: Material(type: MaterialType.transparency, child: child),
          ),
        ),
      ),
    );
  }
}

/// 跟随玻璃开关的确认对话框：玻璃开走玻璃面板（轻遮罩），关走原来的 AlertDialog。
Future<bool?> showAppConfirmDialog({
  required BuildContext context,
  required bool useGlass,
  required String title,
  required String message,
  required String confirmLabel,
  String cancelLabel = '取消',
  bool danger = false,
}) {
  if (useGlass) {
    return showAppGlassDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AppGlassAlertDialog(
        title: title,
        message: message,
        cancelLabel: cancelLabel,
        confirmLabel: confirmLabel,
        danger: danger,
      ),
    );
  }
  return showDialog<bool>(
    context: context,
    builder: (BuildContext dialogContext) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(cancelLabel),
        ),
        FilledButton(
          style: danger
              ? FilledButton.styleFrom(
                  backgroundColor: Theme.of(dialogContext).colorScheme.error,
                  foregroundColor: Theme.of(dialogContext).colorScheme.onError,
                )
              : null,
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
}

/// 玻璃弹层用的遮罩：比 Material 默认的 54% 黑轻很多，整页不会被压得太暗。
Color appGlassBarrierColor({double alpha = 0.16}) {
  return Colors.black.withValues(alpha: alpha);
}

/// 跟随「玻璃材质」开关的对话框（遮罩同样偏轻）。
Future<T?> showAppGlassDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
}) {
  return showDialog<T>(
    context: context,
    barrierColor: appGlassBarrierColor(alpha: 0.18),
    builder: builder,
  );
}

/// 跟随「玻璃材质」开关的底部弹层。
Future<T?> showAppHalfSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  double maxHeightFactor = 0.66,
  GlassTone tone = GlassTone.frost,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    elevation: 0,
    barrierColor: appGlassBarrierColor(),
    builder: (BuildContext sheetContext) {
      return AppGlassSheet(
        maxHeightFactor: maxHeightFactor,
        tone: tone,
        child: Builder(builder: builder),
      );
    },
  );
}

/// 跟随「玻璃材质」开关的确认对话框。
class AppGlassAlertDialog extends StatelessWidget {
  const AppGlassAlertDialog({
    super.key,
    required this.title,
    required this.message,
    required this.cancelLabel,
    required this.confirmLabel,
    this.danger = false,
  });

  final String title;
  final String message;
  final String cancelLabel;
  final String confirmLabel;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 32),
        child: GlassPanel(
          settings: appFrostGlassSettings(context),
          shape: LiquidRoundedSuperellipse(
            borderRadius: 28,
            side: BorderSide(
              color: colorScheme.outline.withValues(alpha: 0.2),
              width: 0.8,
            ),
          ),
          child: Material(
            type: MaterialType.transparency,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    message,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      height: 1.45,
                      color: colorScheme.onSurface.withValues(alpha: 0.72),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text(cancelLabel),
                      ),
                      const SizedBox(width: 4),
                      FilledButton(
                        style: danger
                            ? FilledButton.styleFrom(
                                backgroundColor: colorScheme.error,
                                foregroundColor: colorScheme.onError,
                              )
                            : null,
                        onPressed: () => Navigator.of(context).pop(true),
                        child: Text(confirmLabel),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
