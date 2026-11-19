import 'package:bilimusic/common/components/cached_image.dart';
import 'package:bilimusic/core/theme/app_design.dart';
import 'package:bilimusic/core/theme/theme_colors.dart';
import 'package:flutter/material.dart';

/// 曲目行：序号 + 封面 + 标题/副标题 + 时长，热榜与歌单共用。
///
/// 规格对齐设计规范：封面 50dp / 圆角 8dp、标题 14sp、副标题 12sp、
/// 序号 14sp（前三名橙色加粗），整行左右 20dp 安全边距由外层负责。
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
              vertical: AppSpacing.xs + 2,
            ),
            child: Row(
              children: <Widget>[
                _TrackRankBadge(rank: rank),
                const SizedBox(width: AppSpacing.sm),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  child: CommonCachedImage(
                    imageUrl: coverUrl,
                    width: AppSizes.listCover,
                    height: AppSizes.listCover,
                    fit: BoxFit.cover,
                    fallbackIcon: Icons.music_note_rounded,
                    iconColor: appTertiaryTextColor(context),
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
                      const SizedBox(height: 2),
                      Text(
                        artist,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.meta(
                          theme,
                        ).copyWith(color: appSecondaryTextColor(context)),
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
                    style: AppTextStyles.meta(
                      theme,
                    ).copyWith(color: appTertiaryTextColor(context)),
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

  static const double _size = 20;

  @override
  Widget build(BuildContext context) {
    final bool highlighted = rank > 0 && rank <= 3;
    final TextStyle style = TextStyle(
      fontSize: 14,
      height: 1.2,
      fontWeight: highlighted ? FontWeight.w700 : FontWeight.w500,
      fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
      color: highlighted
          ? AppNeutralColors.chartHot
          : appTertiaryTextColor(context),
    );

    return SizedBox(
      width: _size,
      child: Text(
        rank > 0 ? '$rank' : '·',
        textAlign: TextAlign.center,
        style: style,
      ),
    );
  }
}
