import 'package:bilimusic/common/components/cached_image.dart';
import 'package:bilimusic/core/theme/app_design.dart';
import 'package:bilimusic/core/theme/theme_colors.dart';
import 'package:flutter/material.dart';

/// 曲目行：序号 + 封面 + 标题/副标题 + 时长，热榜与歌单共用。
class TrackRowTile extends StatelessWidget {
  const TrackRowTile({
    super.key,
    required this.rank,
    required this.title,
    required this.artist,
    required this.durationText,
    required this.onTap,
    this.coverUrl = '',
    this.isResolving = false,
  });

  final int rank;
  final String title;
  final String artist;
  final String durationText;
  final String coverUrl;
  final bool isResolving;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs + 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isResolving ? null : onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: AppSpacing.sm - 2,
            ),
            child: Row(
              children: <Widget>[
                _TrackRankBadge(rank: rank),
                const SizedBox(width: AppSpacing.md),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  child: CommonCachedImage(
                    imageUrl: coverUrl,
                    width: AppSizes.listCover,
                    height: AppSizes.listCover,
                    fit: BoxFit.cover,
                    fallbackIcon: Icons.music_note_rounded,
                    iconColor: colorScheme.onSurfaceVariant,
                    backgroundColor: appSkeletonColor(context),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.listTitle(theme),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        artist,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.meta(theme, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                if (isResolving)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Text(
                    durationText,
                    style: AppTextStyles.meta(theme, fontSize: 12).copyWith(
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.75,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TrackRankBadge extends StatelessWidget {
  const _TrackRankBadge({required this.rank});

  final int rank;

  static const double _size = 24;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextStyle baseStyle = TextStyle(
      fontSize: 12,
      height: 1.1,
      fontWeight: FontWeight.w700,
      fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
    );
    final bool highlighted = rank > 0 && rank <= 3;

    if (!highlighted) {
      return SizedBox(
        width: _size,
        child: Text(
          rank > 0 ? '$rank' : '·',
          textAlign: TextAlign.center,
          style: baseStyle.copyWith(
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.72),
          ),
        ),
      );
    }

    return Container(
      width: _size,
      height: _size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.xs),
      ),
      child: Text(
        '$rank',
        style: baseStyle.copyWith(
          color: colorScheme.primary,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
