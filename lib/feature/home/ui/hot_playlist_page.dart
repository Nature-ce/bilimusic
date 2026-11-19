import 'package:bilimusic/common/components/cached_image.dart';
import 'package:bilimusic/common/components/status_view.dart';
import 'package:bilimusic/common/util/player_util.dart';
import 'package:bilimusic/common/util/toast_util.dart';
import 'package:bilimusic/core/theme/app_design.dart';
import 'package:bilimusic/core/theme/theme_colors.dart';
import 'package:bilimusic/feature/home/domain/hot_playlist.dart';
import 'package:bilimusic/feature/home/domain/hot_playlist_detail_state.dart';
import 'package:bilimusic/feature/home/domain/hot_playlist_track.dart';
import 'package:bilimusic/feature/home/domain/music_chart_platform.dart';
import 'package:bilimusic/feature/home/logic/hot_playlist_detail_controller.dart';
import 'package:bilimusic/feature/home/logic/music_chart_resolver.dart';
import 'package:bilimusic/feature/home/ui/components/track_row_tile.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HotPlaylistPage extends ConsumerStatefulWidget {
  const HotPlaylistPage({
    super.key,
    required this.platform,
    required this.playlistId,
    this.initialPlaylist,
  });

  final MusicChartPlatform platform;
  final String playlistId;

  /// 从首页进入时携带，避免重复请求歌单元信息。
  final HotPlaylist? initialPlaylist;

  @override
  ConsumerState<HotPlaylistPage> createState() => _HotPlaylistPageState();
}

class _HotPlaylistPageState extends ConsumerState<HotPlaylistPage> {
  String? _resolvingTrackKey;

  HotPlaylist get _playlist =>
      widget.initialPlaylist ??
      HotPlaylist(
        platform: widget.platform,
        id: widget.playlistId,
        name: '热门歌单',
        coverUrl: '',
      );

  Future<void> _playTrack(HotPlaylistTrack track) async {
    if (_resolvingTrackKey != null) {
      return;
    }
    setState(() => _resolvingTrackKey = track.key);
    try {
      final PlayableItem? item = await ref
          .read(musicChartResolverProvider)
          .resolve(track);
      if (!mounted) {
        return;
      }
      if (item == null) {
        ToastUtil.show('没找到匹配的 B 站视频');
        return;
      }
      await PlayerUtil.playItemAndOpenPlayer(
        context,
        ref,
        item: item,
        sourceLabel: track.playlist.name,
      );
    } on Object {
      if (mounted) {
        ToastUtil.show('匹配失败，请稍后再试');
      }
    } finally {
      if (mounted) {
        setState(() => _resolvingTrackKey = null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final HotPlaylist playlist = _playlist;
    final HotPlaylistDetailState state = ref.watch(
      hotPlaylistDetailControllerProvider(playlist),
    );
    final String title = playlist.name.trim().isEmpty ? '热门歌单' : playlist.name;

    return Scaffold(
      appBar: AppBar(
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: <Widget>[
          IconButton(
            tooltip: '刷新',
            onPressed: state.isLoading
                ? null
                : () => ref
                      .read(
                        hotPlaylistDetailControllerProvider(playlist).notifier,
                      )
                      .refresh(),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref
            .read(hotPlaylistDetailControllerProvider(playlist).notifier)
            .refresh(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: <Widget>[
            _HotPlaylistHeader(playlist: playlist),
            const SizedBox(height: AppSpacing.xl),
            if (state.isLoading)
              const _HotPlaylistTracksLoading()
            else if (state.hasError)
              StatusView(
                icon: Icons.cloud_off_rounded,
                iconColor: colorScheme.error,
                title: '歌单加载失败',
                description: state.errorMessage,
                onRetry: () => ref
                    .read(
                      hotPlaylistDetailControllerProvider(playlist).notifier,
                    )
                    .refresh(),
              )
            else if (state.isEmpty)
              StatusView(
                icon: Icons.queue_music_rounded,
                title: '暂无曲目',
                description: '这个歌单暂时没有可播放的歌曲',
                onRetry: () => ref
                    .read(
                      hotPlaylistDetailControllerProvider(playlist).notifier,
                    )
                    .refresh(),
              )
            else
              for (final HotPlaylistTrack track in state.tracks)
                TrackRowTile(
                  rank: track.rank,
                  title: track.title,
                  artist: track.artist,
                  coverUrl: track.coverUrl,
                  durationText: track.durationText,
                  isResolving: _resolvingTrackKey == track.key,
                  onTap: () => _playTrack(track),
                ),
          ],
        ),
      ),
    );
  }
}

class _HotPlaylistHeader extends StatelessWidget {
  const _HotPlaylistHeader({required this.playlist});

  final HotPlaylist playlist;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final List<String> meta = <String>[
      playlist.platform.label,
      if (playlist.playCount > 0) '${playlist.playCountText}次播放',
      if (playlist.trackCount > 0) playlist.trackCountText,
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: CommonCachedImage(
            imageUrl: playlist.coverUrl,
            width: 96,
            height: 96,
            fit: BoxFit.cover,
            fallbackIcon: Icons.queue_music_rounded,
            iconColor: colorScheme.onSurfaceVariant,
            backgroundColor: appSkeletonColor(context),
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                playlist.name.trim().isEmpty ? '热门歌单' : playlist.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.listTitle(theme).copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: AppSpacing.xs + 2),
              Text(
                meta.join(' · '),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.meta(theme, fontSize: 12),
              ),
              if (playlist.creator.isNotEmpty) ...<Widget>[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'by ${playlist.creator}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.meta(theme, fontSize: 12).copyWith(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.85),
                  ),
                ),
              ],
              if (playlist.description.isNotEmpty) ...<Widget>[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  playlist.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.meta(theme, fontSize: 12).copyWith(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.85),
                    height: 1.4,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _HotPlaylistTracksLoading extends StatelessWidget {
  const _HotPlaylistTracksLoading();

  @override
  Widget build(BuildContext context) {
    final Color placeholderColor = appSkeletonColor(context);
    return Column(
      children: List<Widget>.generate(6, (int index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.xs + 2),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: AppSpacing.sm - 2,
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: placeholderColor,
                    borderRadius: BorderRadius.circular(AppRadius.xs),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Container(
                  width: AppSizes.listCover,
                  height: AppSizes.listCover,
                  decoration: BoxDecoration(
                    color: placeholderColor,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        height: 12,
                        decoration: BoxDecoration(
                          color: placeholderColor,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Container(
                        width: 120,
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
            ),
          ),
        );
      }),
    );
  }
}
