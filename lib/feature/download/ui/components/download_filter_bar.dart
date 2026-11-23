import 'package:bilimusic/core/theme/app_design.dart';
import 'package:flutter/material.dart';

enum DownloadFilter { all, downloading, completed }

extension DownloadFilterLabel on DownloadFilter {
  String get label {
    return switch (this) {
      DownloadFilter.all => '全部',
      DownloadFilter.downloading => '下载中',
      DownloadFilter.completed => '已完成',
    };
  }
}

class DownloadFilterBar extends StatelessWidget {
  const DownloadFilterBar({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final DownloadFilter selected;
  final ValueChanged<DownloadFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        for (final DownloadFilter filter in DownloadFilter.values)
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: _DownloadFilterPill(
              label: filter.label,
              selected: filter == selected,
              onTap: () => onSelected(filter),
            ),
          ),
      ],
    );
  }
}

class _DownloadFilterPill extends StatelessWidget {
  const _DownloadFilterPill({
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
      button: true,
      selected: selected,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppMotion.resolve(context, AppMotion.fast),
          curve: AppMotion.standard,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md + 2,
            vertical: AppSpacing.sm - 1,
          ),
          decoration: BoxDecoration(
            color: selected
                ? colorScheme.primary
                : colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              height: 1.2,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
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
