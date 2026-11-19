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
        child: Container(
          height: _height,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: appSurfaceContainerColor(context, alpha: 0.55),
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Row(
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
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: AnimatedContainer(
            duration: AppMotion.fast,
            curve: AppMotion.standard,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected
                  ? appCardSurfaceColor(context)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              boxShadow: selected
                  ? <BoxShadow>[
                      BoxShadow(
                        color: appShadowColor(context),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
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
