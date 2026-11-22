import 'package:bilimusic/common/components/cached_image.dart';
import 'package:bilimusic/core/theme/app_design.dart';
import 'package:bilimusic/feature/home/domain/hot_playlist.dart';
import 'package:flutter/material.dart';

/// 「编辑甄选」大卡：封面铺满 + 底部渐变 + 名称/平台，横向滑动。
class HotPlaylistFeatureCard extends StatelessWidget {
  const HotPlaylistFeatureCard({
    super.key,
    required this.playlist,
    required this.onTap,
  });

  static const double width = 232;
  static const double height = 124;

  final HotPlaylist playlist;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool hasCover = playlist.coverUrl.trim().isNotEmpty;

    return SizedBox(
      width: width,
      height: height,
      child: Material(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        clipBehavior: Clip.antiAlias,
        color: theme.colorScheme.primary.withValues(alpha: 0.12),
        child: InkWell(
          onTap: onTap,
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              if (hasCover)
                CommonCachedImage(
                  imageUrl: playlist.coverUrl,
                  fit: BoxFit.cover,
                ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                      Colors.transparent,
                      Colors.black.withValues(alpha: hasCover ? 0.55 : 0.15),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: AppSpacing.md,
                top: AppSpacing.md,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.32),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Text(
                    playlist.platform.label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: AppSpacing.md,
                right: AppSpacing.md,
                bottom: AppSpacing.md,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      '编辑推荐',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      playlist.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
