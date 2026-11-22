import 'package:bilimusic/core/theme/app_design.dart';
import 'package:flutter/material.dart';

enum HomeSection { charts, playlists }

extension HomeSectionLabel on HomeSection {
  String get label {
    return switch (this) {
      HomeSection.charts => '推荐',
      HomeSection.playlists => '热门歌单',
    };
  }
}

/// 首页顶部栏目切换：推荐 / 热门歌单（文字 tab + 底部指示条）。
class HomeSectionSwitch extends StatelessWidget {
  const HomeSectionSwitch({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final HomeSection selected;
  final ValueChanged<HomeSection> onSelected;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (final HomeSection section in HomeSection.values)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.xxl),
              child: _HomeSectionTab(
                label: section.label,
                selected: section == selected,
                activeColor: colorScheme.primary,
                inactiveColor: colorScheme.onSurfaceVariant,
                onTap: () => onSelected(section),
              ),
            ),
        ],
      ),
    );
  }
}

class _HomeSectionTab extends StatelessWidget {
  const _HomeSectionTab({
    required this.label,
    required this.selected,
    required this.activeColor,
    required this.inactiveColor,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color activeColor;
  final Color inactiveColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Semantics(
      selected: selected,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                label,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: selected ? 19 : 17,
                  height: 1.2,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  letterSpacing: -0.3,
                  color: selected ? theme.colorScheme.onSurface : inactiveColor,
                ),
              ),
              const SizedBox(height: AppSpacing.xs + 1),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                width: selected ? 20 : 0,
                height: 3,
                decoration: BoxDecoration(
                  color: activeColor,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
