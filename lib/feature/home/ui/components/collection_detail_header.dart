import 'package:bilimusic/common/components/cached_image.dart';
import 'package:bilimusic/core/theme/app_design.dart';
import 'package:bilimusic/core/theme/theme_colors.dart';
import 'package:flutter/material.dart';

/// 榜单 / 歌单详情页的头部：封面 + 类型 chip + 标题 + 两行说明。
class CollectionDetailHeader extends StatelessWidget {
  const CollectionDetailHeader({
    super.key,
    required this.coverUrl,
    required this.chipLabel,
    required this.title,
    this.meta,
    this.subMeta,
    this.coverFallbackIcon = Icons.queue_music_rounded,
  });

  final String coverUrl;
  final String chipLabel;
  final String title;
  final String? meta;
  final String? subMeta;
  final IconData coverFallbackIcon;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.card),
          child: CommonCachedImage(
            imageUrl: coverUrl,
            width: 98,
            height: 98,
            fit: BoxFit.cover,
            fallbackIcon: coverFallbackIcon,
            iconColor: colorScheme.onSurfaceVariant,
            backgroundColor: appSkeletonColor(context),
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Text(
                    chipLabel,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontSize: 10,
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.listTitle(theme).copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    height: 1.22,
                    letterSpacing: -0.4,
                  ),
                ),
                if ((meta ?? '').isNotEmpty) ...<Widget>[
                  const SizedBox(height: 6),
                  Text(
                    meta!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.meta(
                      theme,
                      fontSize: 11.5,
                    ).copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
                if ((subMeta ?? '').isNotEmpty) ...<Widget>[
                  const SizedBox(height: 3),
                  Text(
                    subMeta!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.meta(theme, fontSize: 11).copyWith(
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.85,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// 详情页操作行：播放全部（主按钮）+ 收藏 + 刷新 / 下载。
class CollectionActionRow extends StatelessWidget {
  const CollectionActionRow({
    super.key,
    required this.playAllKey,
    required this.canPlayAll,
    required this.onPlayAll,
    this.favoriteKey,
    this.isFavorite = false,
    this.onToggleFavorite,
    this.refreshKey,
    this.onRefresh,
    this.downloadKey,
    this.onDownload,
    this.downloadBusy = false,
    this.downloadResolved = 0,
    this.downloadTotal = 0,
    this.busy = false,
    this.resolved = 0,
    this.total = 0,
    this.playAllLabel = '播放全部',
  });

  final Key playAllKey;
  final bool canPlayAll;
  final VoidCallback onPlayAll;
  final Key? favoriteKey;
  final bool isFavorite;
  final VoidCallback? onToggleFavorite;
  final Key? refreshKey;
  final VoidCallback? onRefresh;
  final Key? downloadKey;
  final VoidCallback? onDownload;
  final bool downloadBusy;
  final int downloadResolved;
  final int downloadTotal;
  final bool busy;
  final int resolved;
  final int total;
  final String playAllLabel;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    // 不显示「匹配中 x/y」这类进度：播放已经开始就可能一直在后台补队列，
    // 数字会让用户以为卡住了，只保留 spinner 表示正在准备。
    final String label = playAllLabel;

    return Row(
      children: <Widget>[
        Expanded(
          child: SizedBox(
            height: 42,
            child: FilledButton.icon(
              key: playAllKey,
              onPressed: canPlayAll
                  ? () {
                      // 匹配中外观保持和平时一样，只静默拦掉重复点击。
                      if (busy) {
                        return;
                      }
                      onPlayAll();
                    }
                  : null,
              icon: const Icon(Icons.play_arrow_rounded, size: 22),
              label: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onPrimary,
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                disabledBackgroundColor: colorScheme.primary.withValues(
                  alpha: 0.4,
                ),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm + 2),
        if (favoriteKey != null && onToggleFavorite != null) ...<Widget>[
          _CircleAction(
            actionKey: favoriteKey!,
            icon: isFavorite
                ? Icons.favorite_rounded
                : Icons.favorite_border_rounded,
            iconColor: isFavorite
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant,
            tooltip: isFavorite ? '取消收藏' : '收藏',
            onTap: onToggleFavorite!,
          ),
          const SizedBox(width: AppSpacing.sm + 2),
        ],
        if (refreshKey != null && onRefresh != null) ...<Widget>[
          _CircleAction(
            actionKey: refreshKey!,
            icon: Icons.refresh_rounded,
            iconColor: colorScheme.onSurfaceVariant,
            tooltip: '刷新',
            onTap: onRefresh,
          ),
        ] else if (downloadKey != null && onDownload != null) ...<Widget>[
          _CircleAction(
            actionKey: downloadKey!,
            icon: Icons.download_outlined,
            iconColor: colorScheme.onSurfaceVariant,
            tooltip: downloadBusy
                ? '匹配中 $downloadResolved/$downloadTotal'
                : '下载全部',
            onTap: downloadBusy ? null : onDownload,
            child: downloadBusy
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : null,
          ),
        ],
      ],
    );
  }
}

class _CircleAction extends StatelessWidget {
  const _CircleAction({
    required this.actionKey,
    required this.icon,
    required this.iconColor,
    required this.tooltip,
    required this.onTap,
    this.child,
  });

  final Key actionKey;
  final IconData icon;
  final Color iconColor;
  final String tooltip;
  final VoidCallback? onTap;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 42,
      height: 42,
      child: Tooltip(
        message: tooltip,
        child: Material(
          color: appSurfaceContainerColor(context, alpha: 0.55),
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            key: actionKey,
            onTap: onTap,
            child: Center(
              child: child ?? Icon(icon, size: 20, color: iconColor),
            ),
          ),
        ),
      ),
    );
  }
}
