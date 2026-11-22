import 'package:bilimusic/core/theme/app_design.dart';
import 'package:bilimusic/core/theme/theme_colors.dart';
import 'package:flutter/material.dart';

class ProfileStatsCard extends StatelessWidget {
  const ProfileStatsCard({
    super.key,
    required this.likedCount,
    required this.playlistCount,
    required this.recentCount,
    required this.downloadCount,
    required this.onLikedTap,
    required this.onLikedLongPressStart,
    required this.onRecentTap,
    required this.onDownloadTap,
  });

  final int likedCount;
  final int playlistCount;
  final int recentCount;
  final int downloadCount;
  final VoidCallback onLikedTap;
  final GestureLongPressStartCallback onLikedLongPressStart;
  final VoidCallback onRecentTap;
  final VoidCallback onDownloadTap;

  @override
  Widget build(BuildContext context) {
    final Color dividerColor = appDividerColor(context).withValues(alpha: 0.55);
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: appElevatedCardDecoration(context, radius: AppRadius.lg),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _ProfileStatCell(
              label: '喜欢',
              count: likedCount,
              onTap: onLikedTap,
              onLongPressStart: onLikedLongPressStart,
            ),
          ),
          _ProfileStatDivider(color: dividerColor),
          Expanded(
            child: _ProfileStatCell(label: '歌单', count: playlistCount),
          ),
          _ProfileStatDivider(color: dividerColor),
          Expanded(
            child: _ProfileStatCell(
              label: '最近播放',
              count: recentCount,
              onTap: onRecentTap,
            ),
          ),
          _ProfileStatDivider(color: dividerColor),
          Expanded(
            child: _ProfileStatCell(
              label: '下载',
              count: downloadCount,
              onTap: onDownloadTap,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileStatDivider extends StatelessWidget {
  const _ProfileStatDivider({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 26, color: color);
  }
}

class _ProfileStatCell extends StatelessWidget {
  const _ProfileStatCell({
    required this.label,
    required this.count,
    this.onTap,
    this.onLongPressStart,
  });

  final String label;
  final int count;
  final VoidCallback? onTap;
  final GestureLongPressStartCallback? onLongPressStart;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    return GestureDetector(
      onLongPressStart: onLongPressStart,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.md),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 22,
                    height: 1.05,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                    fontFeatures: const <FontFeature>[
                      FontFeature.tabularFigures(),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.meta(
                    theme,
                    fontSize: 11.5,
                  ).copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
