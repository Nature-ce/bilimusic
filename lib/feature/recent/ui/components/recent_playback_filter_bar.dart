import 'package:bilimusic/common/domain/collection_kind.dart';
import 'package:bilimusic/core/theme/app_design.dart';
import 'package:bilimusic/feature/recent/domain/recent_playback_entry.dart';
import 'package:flutter/material.dart';

enum RecentPlaybackFilter {
  all('全部'),
  music('音乐'),
  spoken('口播');

  const RecentPlaybackFilter(this.label);

  final String label;

  bool matches(RecentPlaybackEntry entry) {
    return switch (this) {
      RecentPlaybackFilter.all => true,
      RecentPlaybackFilter.music => entry.kind == CollectionKind.music,
      RecentPlaybackFilter.spoken => entry.kind == CollectionKind.spoken,
    };
  }
}

class RecentPlaybackFilterBar extends StatelessWidget {
  const RecentPlaybackFilterBar({
    super.key,
    required this.filter,
    required this.onSelected,
  });

  final RecentPlaybackFilter filter;
  final ValueChanged<RecentPlaybackFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.xs,
      ),
      child: Row(
        children: <Widget>[
          for (final RecentPlaybackFilter option in RecentPlaybackFilter.values)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: _RecentFilterPill(
                label: option.label,
                selected: option == filter,
                onTap: () => onSelected(option),
              ),
            ),
        ],
      ),
    );
  }
}

class _RecentFilterPill extends StatelessWidget {
  const _RecentFilterPill({
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
        color: selected
            ? colorScheme.primary
            : colorScheme.surfaceContainerHighest,
        shape: const StadiumBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md + 2,
              vertical: AppSpacing.sm - 1,
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                height: 1.15,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                color: selected
                    ? colorScheme.onPrimary
                    : colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
