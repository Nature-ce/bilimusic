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
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 一键播放：把歌单曲目解析成可播放条目后开播。
typedef HotPlaylistPlayAll =
    Future<void> Function(
      BuildContext context,
      WidgetRef ref,
      List<PlayableItem> items,
      String sourceLabel,
    );

class HotPlaylistPage extends ConsumerStatefulWidget {
  const HotPlaylistPage({
    super.key,
    required this.platform,
    required this.playlistId,
    this.initialPlaylist,
    this.playAll,
  });

  final MusicChartPlatform platform;
  final String playlistId;

  /// 从首页进入时携带，避免重复请求歌单元信息。
  final HotPlaylist? initialPlaylist;

  /// 一键播放的落地方式，测试可注入以断言开播行为。
  final HotPlaylistPlayAll? playAll;

  @override
  ConsumerState<HotPlaylistPage> createState() => _HotPlaylistPageState();
}

class _HotPlaylistPageState extends ConsumerState<HotPlaylistPage> {
  /// 先解析够这么多首就开播，剩下的边解析边补进队列。
  static const int _playAllStartSize = 5;

  /// 播放中每攒够这么多首就往队列尾部补一批。
  static const int _playAllBatchSize = 5;

  String? _resolvingTrackKey;
  bool _isPlayingAll = false;
  int _playAllResolved = 0;
  int _playAllTotal = 0;

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

  /// 一键播放整个歌单。
  ///
  /// 每首歌都要在 B 站里搜一次，所以先解析够 [_playAllStartSize] 首就开播，
  /// 剩下的继续在后台解析，攒够一批就补到队列尾部。
  Future<void> _playAllTracks(List<HotPlaylistTrack> tracks) async {
    if (_isPlayingAll || tracks.isEmpty) {
      return;
    }
    final MusicChartResolver resolver = ref.read(musicChartResolverProvider);
    final PlayerController player = ref.read(playerControllerProvider.notifier);
    final String sourceLabel = _playlist.name;
    setState(() {
      _isPlayingAll = true;
      _playAllResolved = 0;
      _playAllTotal = tracks.length;
    });

    final List<PlayableItem> resolved = <PlayableItem>[];
    final Set<String> seen = <String>{};
    int queued = 0;
    bool started = false;

    try {
      for (final HotPlaylistTrack track in tracks) {
        if (!mounted) {
          break;
        }
        PlayableItem? item;
        try {
          item = await resolver.resolve(track);
        } on Object {
          item = null;
        }
        if (item != null && seen.add(item.stableId)) {
          resolved.add(item);
        }
        if (mounted) {
          setState(() => _playAllResolved += 1);
        }
        if (!started && resolved.length >= _playAllStartSize) {
          started = true;
          await _startPlayback(resolved, sourceLabel);
          player.setQueueMode(PlayerQueueMode.sequenceOnce);
          queued = resolved.length;
        } else if (started && resolved.length - queued >= _playAllBatchSize) {
          await player.enqueue(resolved.sublist(queued));
          queued = resolved.length;
        }
      }

      if (!started && resolved.isNotEmpty) {
        started = true;
        await _startPlayback(resolved, sourceLabel);
        player.setQueueMode(PlayerQueueMode.sequenceOnce);
        queued = resolved.length;
      }
      if (started && resolved.length > queued) {
        await player.enqueue(resolved.sublist(queued));
      } else if (!started && mounted) {
        ToastUtil.show('这个歌单没有匹配到可播放的 B 站视频');
      }
    } on Object {
      if (mounted) {
        ToastUtil.show('一键播放失败，请稍后再试');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPlayingAll = false;
          _playAllResolved = 0;
          _playAllTotal = 0;
        });
      }
    }
  }

  Future<void> _startPlayback(
    List<PlayableItem> items,
    String sourceLabel,
  ) async {
    if (!mounted) {
      return;
    }
    final HotPlaylistPlayAll? playAll = widget.playAll;
    if (playAll != null) {
      await playAll(context, ref, List<PlayableItem>.of(items), sourceLabel);
      return;
    }
    await PlayerUtil.playQueueAndOpenPlayer(
      context,
      ref,
      items: List<PlayableItem>.of(items),
      sourceLabel: sourceLabel,
    );
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
    final bool canPlayAll =
        !state.isLoading && !state.hasError && state.tracks.isNotEmpty;

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
            _HotPlaylistHeader(
              playlist: playlist,
              totalCount: state.totalCount,
            ),
            if (canPlayAll) ...<Widget>[
              const SizedBox(height: AppSpacing.lg),
              _PlayAllButton(
                isPlaying: _isPlayingAll,
                resolved: _playAllResolved,
                total: _playAllTotal,
                trackCount: state.tracks.length,
                onPressed: () => _playAllTracks(state.tracks),
              ),
            ],
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
            else ...<Widget>[
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
              _HotPlaylistFooter(
                state: state,
                onRetry: () => ref
                    .read(
                      hotPlaylistDetailControllerProvider(playlist).notifier,
                    )
                    .retryLoadRemaining(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 一键播放按钮：解析曲目时显示匹配进度。
class _PlayAllButton extends StatelessWidget {
  const _PlayAllButton({
    required this.isPlaying,
    required this.resolved,
    required this.total,
    required this.trackCount,
    required this.onPressed,
  });

  final bool isPlaying;
  final int resolved;
  final int total;
  final int trackCount;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final String label = isPlaying
        ? '匹配中 $resolved/$total'
        : '播放全部 $trackCount 首';
    return Align(
      alignment: Alignment.centerLeft,
      child: FilledButton.icon(
        key: const Key('hotPlaylistPlayAll'),
        onPressed: isPlaying ? null : onPressed,
        icon: isPlaying
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.play_arrow_rounded),
        label: Text(label),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
        ),
      ),
    );
  }
}

class _HotPlaylistFooter extends StatelessWidget {
  const _HotPlaylistFooter({required this.state, required this.onRetry});

  final HotPlaylistDetailState state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    if (state.isLoading || state.hasError || state.isEmpty) {
      return const SizedBox.shrink();
    }
    if (state.hasMoreError) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Center(
          child: TextButton(onPressed: onRetry, child: const Text('加载中断，点击重试')),
        ),
      );
    }
    if (state.isLoadingMore) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              '正在加载全部（${state.progressText}）',
              style: AppTextStyles.meta(theme, fontSize: 12),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

class _HotPlaylistHeader extends StatelessWidget {
  const _HotPlaylistHeader({required this.playlist, this.totalCount = 0});

  final HotPlaylist playlist;

  /// 列表接口可能不返回曲目数（如 QQ音乐），加载首屏后用它补齐。
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final int effectiveTrackCount = playlist.trackCount > 0
        ? playlist.trackCount
        : totalCount;
    final List<String> meta = <String>[
      playlist.platform.label,
      if (playlist.playCount > 0) '${playlist.playCountText}次播放',
      if (effectiveTrackCount > 0) '$effectiveTrackCount 首',
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
