import 'package:bilimusic/common/components/glass_panel.dart';
import 'package:bilimusic/core/theme/app_design.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

enum HomeSection { charts, playlists }

extension HomeSectionLabel on HomeSection {
  String get label {
    return switch (this) {
      HomeSection.charts => '音乐热榜',
      HomeSection.playlists => '热门歌单',
    };
  }
}

/// 首页顶部栏目切换：音乐热榜 / 热门歌单（玻璃胶囊）。
class HomeSectionSwitch extends StatelessWidget {
  const HomeSectionSwitch({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final HomeSection selected;
  final ValueChanged<HomeSection> onSelected;

  static const double _height = 44;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: GlassPanel(
          shape: const LiquidRoundedSuperellipse(borderRadius: AppRadius.pill),
          child: SizedBox(
            height: _height,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  for (final HomeSection section in HomeSection.values)
                    Expanded(
                      child: _HomeSectionTab(
                        label: section.label,
                        selected: section == selected,
                        onTap: () => onSelected(section),
                      ),
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

class _HomeSectionTab extends StatelessWidget {
  const _HomeSectionTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final BorderRadius borderRadius = BorderRadius.circular(AppRadius.pill);

    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected
            ? colorScheme.primary.withValues(alpha: 0.16)
            : Colors.transparent,
        borderRadius: borderRadius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                height: 1.15,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                color: selected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
