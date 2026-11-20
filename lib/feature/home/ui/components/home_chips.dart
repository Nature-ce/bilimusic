import 'package:bilimusic/common/components/glass_panel.dart';
import 'package:bilimusic/core/theme/app_design.dart';
import 'package:bilimusic/feature/home/domain/music_chart_platform.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

/// 首页热榜与热门歌单共用的胶囊 chip（玻璃材质）。
class HomeChip extends StatelessWidget {
  const HomeChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.compact = false,
    this.emphasis = false,
  });

  final String label;
  final bool selected;
  final bool compact;

  /// 平台级 chip：选中时用主色玻璃，视觉权重高于榜单项。
  final bool emphasis;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color foreground = selected
        ? (emphasis ? colorScheme.onPrimary : colorScheme.primary)
        : colorScheme.onSurfaceVariant;

    return GlassPanel(
      shape: const LiquidRoundedSuperellipse(borderRadius: AppRadius.pill),
      settings: selected
          ? tintedGlassSettings(
              colorScheme.primary,
              alpha: emphasis ? 0.86 : 0.24,
            )
          : null,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: Semantics(
            selected: selected,
            button: true,
            child: Padding(
              padding: compact
                  ? const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs + 3,
                    )
                  : const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg - 2,
                      vertical: AppSpacing.sm,
                    ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: compact ? 12 : 12.5,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  color: foreground,
                  height: 1.15,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 平台选择行：选中项用主色玻璃。
class HomePlatformBar extends StatelessWidget {
  const HomePlatformBar({
    super.key,
    required this.platforms,
    required this.selected,
    required this.onSelected,
  });

  final List<MusicChartPlatform> platforms;
  final MusicChartPlatform selected;
  final ValueChanged<MusicChartPlatform> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: <Widget>[
        for (final MusicChartPlatform platform in platforms)
          HomeChip(
            label: platform.label,
            selected: platform == selected,
            emphasis: true,
            onTap: () => onSelected(platform),
          ),
      ],
    );
  }
}
