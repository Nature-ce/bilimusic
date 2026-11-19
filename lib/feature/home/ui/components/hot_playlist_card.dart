import 'package:bilimusic/common/components/cached_image.dart';
import 'package:bilimusic/core/theme/app_design.dart';
import 'package:bilimusic/core/theme/theme_colors.dart';
import 'package:bilimusic/feature/home/domain/hot_playlist.dart';
import 'package:flutter/material.dart';

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
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AspectRatio(
              aspectRatio: 1,
              child: CommonCachedImage(
                imageUrl: playlist.coverUrl,
                fit: BoxFit.cover,
                borderRadius: BorderRadius.circular(AppRadius.md),
                fallbackIcon: Icons.queue_music_rounded,
                iconColor: colorScheme.onSurfaceVariant,
                backgroundColor: appSkeletonColor(context),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              playlist.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.listTitle(
                theme,
              ).copyWith(height: 1.3, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.xs + 1),
            Text(
              playlist.summaryText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.meta(theme, fontSize: 12).copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.85),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
