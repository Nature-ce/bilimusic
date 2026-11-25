import 'package:bilimusic/common/components/glass_panel.dart';
import 'package:bilimusic/common/components/page_app_bar.dart';
import 'package:bilimusic/common/components/bottom_page_spacer.dart';
import 'package:bilimusic/common/components/status_view.dart';
import 'package:bilimusic/common/util/player_util.dart';
import 'package:bilimusic/common/util/toast_util.dart';
import 'package:bilimusic/core/theme/app_design.dart';
import 'package:bilimusic/feature/setting/logic/appearance_setting_logic.dart';
import 'package:bilimusic/core/theme/theme_colors.dart';
import 'package:bilimusic/feature/download/logic/download_controller.dart';
import 'package:bilimusic/feature/home/domain/hot_playlist.dart';
import 'package:bilimusic/feature/home/domain/hot_playlist_detail_state.dart';
import 'package:bilimusic/feature/home/domain/hot_playlist_track.dart';
import 'package:bilimusic/feature/home/domain/music_chart_platform.dart';
import 'package:bilimusic/feature/home/logic/collection_play_all.dart';
import 'package:bilimusic/feature/home/logic/favorite_hot_playlist_controller.dart';
import 'package:bilimusic/feature/home/logic/hot_playlist_detail_controller.dart';
import 'package:bilimusic/feature/home/logic/music_chart_resolver.dart';
import 'package:bilimusic/feature/home/ui/components/collection_detail_header.dart';
import 'package:bilimusic/feature/home/ui/components/track_row_tile.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
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
  String? _resolvingTrackKey;
  bool _isPlayingAll = false;
  int _playAllResolved = 0;
  int _playAllTotal = 0;
  bool _isDownloadingAll = false;
  int _downloadResolved = 0;
  int _downloadTotal = 0;

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

  Future<void> _playAll(List<HotPlaylistTrack> tracks) async {
    if (_isPlayingAll || tracks.isEmpty) {
      return;
    }
    setState(() {
      _isPlayingAll = true;
      _playAllResolved = 0;
      _playAllTotal = tracks.length;
    });
    try {
      await CollectionPlayAllRunner(
        context: context,
        ref: ref,
        sourceLabel: _playlist.name,
        isActive: () => mounted,
        startPlayback: widget.playAll,
        onProgress: (int resolved, int total) {
          if (!mounted) {
            return;
          }
          setState(() {
            _playAllResolved = resolved;
            _playAllTotal = total;
          });
        },
      ).run(tracks);
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

  Future<void> _downloadAll(List<HotPlaylistTrack> tracks) async {
    if (_isDownloadingAll || tracks.isEmpty) {
      return;
    }
    final bool useGlass = ref.read(appearanceSettingLogicProvider);
    final String confirmMessage =
        '将匹配并下载 ${tracks.length} 首歌曲，匹配过程需要一点时间，完成后会加入下载队列。';
    final bool? confirmed = useGlass
        ? await showAppGlassDialog<bool>(
            context: context,
            builder: (BuildContext dialogContext) => AppGlassAlertDialog(
              title: '下载整张歌单？',
              message: confirmMessage,
              cancelLabel: '取消',
              confirmLabel: '开始下载',
            ),
          )
        : await showDialog<bool>(
            context: context,
            builder: (BuildContext dialogContext) => AlertDialog(
              title: const Text('下载整张歌单？'),
              content: Text(confirmMessage),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('取消'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text('开始下载'),
                ),
              ],
            ),
          );
    if (confirmed != true || !mounted) {
      return;
    }
    setState(() {
      _isDownloadingAll = true;
      _downloadResolved = 0;
      _downloadTotal = tracks.length;
    });
    final MusicChartResolver resolver = ref.read(musicChartResolverProvider);
    final DownloadController downloadController = ref.read(
      downloadControllerProvider.notifier,
    );
    int queued = 0;
    try {
      for (final HotPlaylistTrack track in tracks) {
        if (!mounted) {
          return;
        }
        PlayableItem? item;
        try {
          item = await resolver.resolve(track);
        } on Object {
          item = null;
        }
        if (!mounted) {
          return;
        }
        if (item != null && await downloadController.download(item)) {
          queued += 1;
        }
        setState(() {
          _downloadResolved += 1;
        });
      }
      ToastUtil.show(queued == 0 ? '没有匹配到可下载的 B 站视频' : '已加入下载队列 $queued 首');
    } finally {
      if (mounted) {
        setState(() {
          _isDownloadingAll = false;
          _downloadResolved = 0;
          _downloadTotal = 0;
        });
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
    final int effectiveTrackCount = playlist.trackCount > 0
        ? playlist.trackCount
        : state.totalCount;
    final List<String> meta = <String>[
      if (playlist.playCount > 0) '${playlist.playCountText}次播放',
      if (effectiveTrackCount > 0) '$effectiveTrackCount 首',
    ];
    final bool canPlayAll =
        !state.isLoading && !state.hasError && state.tracks.isNotEmpty;
    final bool isFavorite = ref.watch(
      favoriteHotPlaylistsProvider.select(
        (List<HotPlaylist> playlists) =>
            playlists.any((HotPlaylist item) => item.key == playlist.key),
      ),
    );

    return Scaffold(
      appBar: PageAppBar(
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref
            .read(hotPlaylistDetailControllerProvider(playlist).notifier)
            .refresh(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          children: <Widget>[
            CollectionDetailHeader(
              coverUrl: playlist.coverUrl,
              chipLabel: '${playlist.platform.label} · 歌单',
              title: title,
              meta: meta.isEmpty ? null : meta.join(' · '),
              subMeta: playlist.creator.isNotEmpty
                  ? 'by ${playlist.creator}'
                  : null,
            ),
            if (playlist.description.isNotEmpty) ...<Widget>[
              const SizedBox(height: AppSpacing.sm),
              Text(
                playlist.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.meta(
                  theme,
                  fontSize: 12,
                ).copyWith(color: colorScheme.onSurfaceVariant, height: 1.4),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            CollectionActionRow(
              playAllKey: const Key('hotPlaylistPlayAll'),
              canPlayAll: canPlayAll,
              onPlayAll: () => _playAll(state.tracks),
              favoriteKey: const Key('hotPlaylistFavorite'),
              isFavorite: isFavorite,
              onToggleFavorite: () => ref
                  .read(favoriteHotPlaylistsProvider.notifier)
                  .toggle(playlist),
              downloadKey: const Key('hotPlaylistDownload'),
              onDownload: () => _downloadAll(state.tracks),
              downloadBusy: _isDownloadingAll,
              downloadResolved: _downloadResolved,
              downloadTotal: _downloadTotal,
              busy: _isPlayingAll,
              resolved: _playAllResolved,
              total: _playAllTotal,
              playAllLabel: '播放全部',
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: <Widget>[
                Text(
                  '歌曲',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                if (state.tracks.isNotEmpty)
                  Text(
                    '共 ${state.tracks.length} 首',
                    style: AppTextStyles.meta(theme, fontSize: 11.5).copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
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
            const BottomPageSpacer(),
          ],
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
