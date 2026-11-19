import 'package:bilimusic/core/theme/app_design.dart';
import 'package:bilimusic/core/theme/theme_colors.dart';
import 'package:flutter/material.dart';

enum HomeSection { charts, playlists }

extension HomeSectionLabel on HomeSection {
  String get label {
    return switch (this) {
      HomeSection.charts => '音乐热榜',
      HomeSection.playlists => '热门歌单',
    };
  }
}

/// 首页顶部栏目切换：音乐热榜 / 热门歌单。
///
/// 采用频道 Tab 的范式：无轨道底色，选中项直接是品牌实心胶囊 + 反色文字。
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
    return Row(
      children: <Widget>[
        for (final HomeSection section in HomeSection.values)
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.lg),
            child: _HomeSectionTab(
              label: section.label,
              selected: section == selected,
              onTap: () => onSelected(section),
            ),
          ),
      ],
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
    final Color background = selected
        ? appBrandFillColor(context)
        : Colors.transparent;
    final Color foreground = selected
        ? appOnBrandFillColor(context)
        : colorScheme.onSurface;

    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: AnimatedContainer(
            duration: AppMotion.fast,
            curve: AppMotion.standard,
            padding: selected
                ? const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs + 2,
                  )
                : const EdgeInsets.symmetric(
                    horizontal: 0,
                    vertical: AppSpacing.xs + 2,
                  ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                height: 1.2,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: foreground,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
