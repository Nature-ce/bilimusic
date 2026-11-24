import 'package:bilimusic/core/theme/app_design.dart';
import 'package:bilimusic/core/theme/theme_colors.dart';
import 'package:bilimusic/common/components/glass_panel.dart';
import 'package:bilimusic/feature/home/logic/home_back_to_top.dart';
import 'package:bilimusic/feature/setting/logic/appearance_setting_logic.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

class HomeBackToTopButton extends ConsumerWidget {
  const HomeBackToTopButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final bool useGlass = ref.watch(appearanceSettingLogicProvider);
    void onPressed() => _scrollToTop(context, ref);

    if (!useGlass) {
      return FloatingActionButton.small(
        tooltip: '回到顶部',
        heroTag: 'home_back_to_top',
        backgroundColor: appCardSurfaceColor(context),
        foregroundColor: colorScheme.primary,
        elevation: 3,
        highlightElevation: 5,
        shape: CircleBorder(
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.7),
          ),
        ),
        onPressed: onPressed,
        child: const Icon(Icons.arrow_upward_rounded),
      );
    }

    return SizedBox(
      width: 48,
      height: 48,
      child: GlassPanel(
        settings: _backToTopGlassSettings(context),
        shape: LiquidRoundedSuperellipse(
          borderRadius: 24,
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.55),
            width: 0.8,
          ),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkResponse(
            onTap: onPressed,
            radius: 24,
            customBorder: const CircleBorder(),
            child: Tooltip(
              message: '回到顶部',
              child: SizedBox(
                width: 48,
                height: 48,
                child: Icon(
                  Icons.arrow_upward_rounded,
                  size: 22,
                  color: colorScheme.primary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _scrollToTop(BuildContext context, WidgetRef ref) {
    final ScrollController controller = ref.read(homeScrollControllerProvider);
    if (!controller.hasClients) {
      return;
    }
    final Duration duration = AppMotion.resolve(context, AppMotion.slow);
    if (duration <= Duration.zero) {
      controller.jumpTo(0);
      return;
    }
    controller.animateTo(0, duration: duration, curve: AppMotion.standard);
  }
}

/// 回到顶部按钮的玻璃参数：和卡片小按钮同一档透明度。
LiquidGlassSettings _backToTopGlassSettings(BuildContext context) {
  final ThemeData theme = Theme.of(context);
  final ColorScheme colorScheme = theme.colorScheme;
  final bool isDark = theme.brightness == Brightness.dark;
  final Color base = isDark ? const Color(0xFF12151A) : Colors.white;
  final Color tinted = Color.alphaBlend(
    colorScheme.primary.withValues(alpha: isDark ? 0.16 : 0.07),
    base,
  );

  return LiquidGlassSettings(
    bodyMode: GlassBodyMode.clear,
    glassColor: tinted.withValues(alpha: isDark ? 0.36 : 0.32),
    thickness: 14,
    blur: 22,
    chromaticAberration: 0,
    saturation: 1.5,
    lightIntensity: 0.6,
    refractiveIndex: 1.08,
  );
}
