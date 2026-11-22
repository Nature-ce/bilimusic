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

/// 首页顶部栏目切换：推荐 / 热门歌单（选中项是主色胶囊）。
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
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (final HomeSection section in HomeSection.values)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: _HomeSectionTab(
                label: section.label,
                selected: section == selected,
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
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Semantics(
      selected: selected,
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md + 2,
            vertical: AppSpacing.sm - 1,
          ),
          decoration: BoxDecoration(
            color: selected ? colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            boxShadow: selected
                ? <BoxShadow>[
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.24),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14.5,
              height: 1.2,
              letterSpacing: -0.2,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
              color: selected
                  ? colorScheme.onPrimary
                  : colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
