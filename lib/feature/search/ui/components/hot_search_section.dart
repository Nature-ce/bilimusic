import 'package:bilimusic/feature/search/domain/hot_search_item.dart';
import 'package:flutter/material.dart';

const Color _hotSearchFirstRankColor = Color(0xFFF04438);
const Color _hotSearchSecondRankColor = Color(0xFFF2731F);
const Color _hotSearchHotBadgeColor = Color(0xFFF2731F);
const Color _hotSearchNewBadgeColor = Color(0xFFF04438);

class HotSearchSection extends StatelessWidget {
  const HotSearchSection({
    super.key,
    required this.items,
    required this.onSelectKeyword,
  });

  final List<HotSearchItem> items;
  final ValueChanged<String> onSelectKeyword;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '热搜',
          style: TextStyle(
            fontSize: 14,
            height: 1.2,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 2),
        for (int index = 0; index < items.length; index++)
          _HotSearchRow(
            index: index,
            item: items[index],
            onTap: () => onSelectKeyword(items[index].keyword),
          ),
      ],
    );
  }
}

class _HotSearchRow extends StatelessWidget {
  const _HotSearchRow({
    required this.index,
    required this.item,
    required this.onTap,
  });

  final int index;
  final HotSearchItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final int rank = index + 1;
    final Color rankColor = switch (rank) {
      1 => _hotSearchFirstRankColor,
      2 => _hotSearchSecondRankColor,
      3 => colorScheme.primary,
      _ => colorScheme.onSurfaceVariant.withValues(alpha: 0.65),
    };
    final Widget? badge = switch (rank) {
      1 => const _HotSearchBadge(label: '热', color: _hotSearchHotBadgeColor),
      _ when item.isNew => const _HotSearchBadge(
        label: '新',
        color: _hotSearchNewBadgeColor,
      ),
      _ => null,
    };

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 7),
          child: Row(
            children: <Widget>[
              SizedBox(
                width: 22,
                child: Text(
                  '$rank',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.2,
                    fontWeight: rank <= 3 ? FontWeight.w800 : FontWeight.w600,
                    color: rankColor,
                    fontFeatures: const <FontFeature>[
                      FontFeature.tabularFigures(),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Row(
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        item.keyword,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14.5,
                          height: 1.25,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    if (item.hasDistinctShowName) ...<Widget>[
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          item.showName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.25,
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onSurfaceVariant.withValues(
                              alpha: 0.9,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (badge != null) ...<Widget>[const SizedBox(width: 6), badge],
            ],
          ),
        ),
      ),
    );
  }
}

class _HotSearchBadge extends StatelessWidget {
  const _HotSearchBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          height: 1.2,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}
