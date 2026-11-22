import 'package:bilimusic/common/components/cached_image.dart';
import 'package:bilimusic/core/theme/app_design.dart';
import 'package:bilimusic/core/theme/theme_colors.dart';
import 'package:bilimusic/feature/home/domain/hot_playlist.dart';
import 'package:flutter/material.dart';

/// 热门歌单网格卡片：圆角封面 + 右下角「N 首」+ 单行名称 + 播放量。
class HotPlaylistCard extends StatelessWidget {
  const HotPlaylistCard({
    super.key,
    required this.playlist,
    required this.onTap,
  });

  final HotPlaylist playlist;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AspectRatio(
              aspectRatio: 1,
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  CommonCachedImage(
                    imageUrl: playlist.coverUrl,
                    fit: BoxFit.cover,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    fallbackIcon: Icons.queue_music_rounded,
                    iconColor: colorScheme.onSurfaceVariant,
                    backgroundColor: appSkeletonColor(context),
                  ),
                  if (playlist.trackCount > 0)
                    Positioned(
                      right: AppSpacing.xs + 2,
                      bottom: AppSpacing.xs + 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.38),
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        child: Text(
                          '${playlist.trackCount} 首',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm - 1),
            Text(
              playlist.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.listTitle(theme).copyWith(
                fontSize: 12.5,
                height: 1.3,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              playlist.playCount > 0
                  ? playlist.playCountText
                  : playlist.summaryText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.meta(theme, fontSize: 10.5).copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.85),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
