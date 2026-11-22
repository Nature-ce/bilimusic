import 'package:bilimusic/common/components/status_view.dart';
import 'package:bilimusic/core/theme/app_design.dart';
import 'package:bilimusic/core/theme/theme_colors.dart';
import 'package:bilimusic/feature/home/domain/hot_playlist.dart';
import 'package:bilimusic/feature/home/domain/hot_playlist_state.dart';
import 'package:bilimusic/feature/home/domain/music_chart_platform.dart';
import 'package:bilimusic/feature/home/logic/hot_playlist_controller.dart';
import 'package:bilimusic/feature/home/ui/components/home_chips.dart';
import 'package:bilimusic/feature/home/ui/components/hot_playlist_card.dart';
import 'package:bilimusic/feature/home/ui/components/hot_playlist_feature_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HotPlaylistSection extends ConsumerWidget {
  const HotPlaylistSection({super.key, this.onPlaylistTap});

  /// 未提供时跳转到歌单详情路由；测试可注入以断言点击行为。
  final ValueChanged<HotPlaylist>? onPlaylistTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final HotPlaylistState state = ref.watch(hotPlaylistControllerProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          HomePlatformBar(
            platforms: MusicChartPlatform.playlistPlatforms,
            selected: state.platform,
            onSelected: (MusicChartPlatform platform) {
              ref
                  .read(hotPlaylistControllerProvider.notifier)
                  .selectPlatform(platform);
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          if (state.playlists.isNotEmpty) ...<Widget>[
            _FeatureRow(
              playlists: state.playlists,
              onTap: (HotPlaylist playlist) =>
                  _handlePlaylistTap(context, playlist),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          Row(
            children: <Widget>[
              Text(
                '热门歌单',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: state.isLoading
                    ? null
                    : () => ref
                          .read(hotPlaylistControllerProvider.notifier)
                          .refresh(),
                iconAlignment: IconAlignment.end,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('换一批'),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          if (state.isLoading)
            const _HotPlaylistLoadingGrid()
          else if (state.hasError)
            StatusView(
              icon: Icons.cloud_off_rounded,
              iconColor: colorScheme.error,
              title: '热门歌单加载失败',
              description: state.errorMessage,
              onRetry: () =>
                  ref.read(hotPlaylistControllerProvider.notifier).refresh(),
            )
          else if (state.isEmpty)
            const StatusView(icon: Icons.queue_music_rounded, title: '暂无热门歌单')
          else
            _HotPlaylistGrid(
              playlists: state.playlists,
              onPlaylistTap: (HotPlaylist playlist) =>
                  _handlePlaylistTap(context, playlist),
            ),
        ],
      ),
    );
  }

  void _handlePlaylistTap(BuildContext context, HotPlaylist playlist) {
    final ValueChanged<HotPlaylist>? onPlaylistTap = this.onPlaylistTap;
    if (onPlaylistTap != null) {
      onPlaylistTap(playlist);
      return;
    }
    context.push(
      '/home/playlist/${playlist.platform.name}/${playlist.id}',
      extra: playlist,
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.playlists, required this.onTap});

  final List<HotPlaylist> playlists;
  final ValueChanged<HotPlaylist> onTap;

  @override
  Widget build(BuildContext context) {
    final List<HotPlaylist> featured = playlists
        .take(2)
        .toList(growable: false);
    if (featured.isEmpty) {
      return const SizedBox.shrink();
    }
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Text(
            '编辑甄选',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: <Widget>[
              for (final HotPlaylist playlist in featured)
                Padding(
                  padding: EdgeInsets.only(
                    right: playlist == featured.last ? 0 : AppSpacing.sm + 2,
                  ),
                  child: HotPlaylistFeatureCard(
                    playlist: playlist,
                    onTap: () => onTap(playlist),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HotPlaylistGrid extends StatelessWidget {
  const _HotPlaylistGrid({
    required this.playlists,
    required this.onPlaylistTap,
  });

  final List<HotPlaylist> playlists;
  final ValueChanged<HotPlaylist> onPlaylistTap;

  static const double _crossSpacing = AppSpacing.md;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = constraints.maxWidth;
        final int columns = hotPlaylistGridColumns(width);
        final double itemWidth =
            (width - _crossSpacing * (columns - 1)) / columns;
        return Wrap(
          spacing: _crossSpacing,
          runSpacing: AppSpacing.lg,
          children: <Widget>[
            for (final HotPlaylist playlist in playlists)
              SizedBox(
                width: itemWidth,
                child: HotPlaylistCard(
                  playlist: playlist,
                  onTap: () => onPlaylistTap(playlist),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// 热门歌单网格列数：手机三列，宽屏四列。
@visibleForTesting
int hotPlaylistGridColumns(double width) {
  return width >= 880 ? 4 : 3;
}

class _HotPlaylistLoadingGrid extends StatelessWidget {
  const _HotPlaylistLoadingGrid();

  @override
  Widget build(BuildContext context) {
    final Color placeholderColor = appSkeletonColor(context);
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = constraints.maxWidth;
        final int columns = hotPlaylistGridColumns(width);
        const double crossSpacing = AppSpacing.md;
        final double itemWidth =
            (width - crossSpacing * (columns - 1)) / columns;
        return Wrap(
          spacing: crossSpacing,
          runSpacing: AppSpacing.lg,
          children: <Widget>[
            for (int index = 0; index < columns * 2; index += 1)
              SizedBox(
                width: itemWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    AspectRatio(
                      aspectRatio: 1,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: placeholderColor,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      height: 12,
                      decoration: BoxDecoration(
                        color: placeholderColor,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      width: itemWidth * 0.55,
                      height: 10,
                      decoration: BoxDecoration(
                        color: placeholderColor.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
