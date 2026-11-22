import 'package:bilimusic/common/components/status_view.dart';
import 'package:bilimusic/common/util/player_util.dart';
import 'package:bilimusic/common/util/toast_util.dart';
import 'package:bilimusic/core/theme/app_design.dart';
import 'package:bilimusic/core/theme/theme_colors.dart';
import 'package:bilimusic/feature/home/domain/chart_detail_data.dart';
import 'package:bilimusic/feature/home/domain/music_chart.dart';
import 'package:bilimusic/feature/home/domain/music_chart_track.dart';
import 'package:bilimusic/feature/home/logic/chart_detail_controller.dart';
import 'package:bilimusic/feature/home/logic/collection_play_all.dart';
import 'package:bilimusic/feature/home/logic/favorite_music_chart_controller.dart';
import 'package:bilimusic/feature/home/logic/music_chart_resolver.dart';
import 'package:bilimusic/feature/home/ui/components/collection_detail_header.dart';
import 'package:bilimusic/feature/home/ui/components/track_row_tile.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChartDetailPage extends ConsumerStatefulWidget {
  const ChartDetailPage({super.key, required this.chart});

  final MusicChart chart;

  @override
  ConsumerState<ChartDetailPage> createState() => _ChartDetailPageState();
}

class _ChartDetailPageState extends ConsumerState<ChartDetailPage> {
  String? _resolvingTrackKey;
  bool _isPlayingAll = false;
  int _playAllResolved = 0;
  int _playAllTotal = 0;

  Future<void> _playTrack(MusicChartTrack track) async {
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
        sourceLabel: widget.chart.name,
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

  Future<void> _playAllTracks(List<MusicChartTrack> tracks) async {
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
        sourceLabel: widget.chart.name,
        onProgress: (int resolved, int total) {
          if (!mounted) {
            return;
          }
          setState(() {
            _playAllResolved = resolved;
            _playAllTotal = total;
          });
        },
        isActive: () => mounted,
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

  Future<void> _refresh() {
    return ref
        .read(chartDetailControllerProvider(widget.chart).notifier)
        .refresh();
  }

  static String _formatUpdatedAt(int updatedAtMs) {
    if (updatedAtMs <= 0) {
      return '--:--';
    }
    final DateTime time = DateTime.fromMillisecondsSinceEpoch(updatedAtMs);
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final MusicChart chart = widget.chart;
    final AsyncValue<ChartDetailData> detail = ref.watch(
      chartDetailControllerProvider(chart),
    );
    final bool isFavorite = ref.watch(
      favoriteMusicChartsProvider.select(
        (List<MusicChart> charts) =>
            charts.any((MusicChart item) => item.key == chart.key),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(chart.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: detail.when<List<Widget>>(
            data: (ChartDetailData data) => _buildContent(data, isFavorite),
            loading: () => const <Widget>[_ChartDetailLoading()],
            error: (Object error, StackTrace stackTrace) => <Widget>[
              StatusView(
                icon: Icons.cloud_off_rounded,
                iconColor: colorScheme.error,
                title: '榜单加载失败',
                description: '网络不太稳定，请稍后重试',
                onRetry: _refresh,
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildContent(ChartDetailData data, bool isFavorite) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final MusicChart chart = widget.chart;
    final List<MusicChartTrack> tracks = data.tracks;

    if (tracks.isEmpty) {
      return <Widget>[
        StatusView(
          icon: Icons.queue_music_rounded,
          title: '暂无曲目',
          description: '这个榜单暂时没有可播放的歌曲',
          onRetry: _refresh,
        ),
      ];
    }

    return <Widget>[
      CollectionDetailHeader(
        coverUrl: tracks.first.coverUrl.trim(),
        chipLabel: '${chart.platform.label} · 榜单',
        title: chart.name,
        meta: '共 ${tracks.length} 首 · ${_formatUpdatedAt(data.updatedAtMs)} 更新',
        subMeta: '按热度排序 · 数据来自${chart.platform.label}',
      ),
      const SizedBox(height: AppSpacing.lg),
      CollectionActionRow(
        playAllKey: const Key('chartDetailPlayAll'),
        canPlayAll: true,
        onPlayAll: () => _playAllTracks(tracks),
        favoriteKey: const Key('chartDetailFavorite'),
        isFavorite: isFavorite,
        onToggleFavorite: () =>
            ref.read(favoriteMusicChartsProvider.notifier).toggle(chart),
        refreshKey: const Key('chartDetailRefresh'),
        onRefresh: _refresh,
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
          Text(
            '按热度排序',
            style: AppTextStyles.meta(theme, fontSize: 11.5).copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      const SizedBox(height: AppSpacing.sm),
      for (final MusicChartTrack track in tracks)
        TrackRowTile(
          rank: track.rank,
          title: track.title,
          artist: track.artist,
          coverUrl: track.coverUrl,
          durationText: track.durationText,
          isResolving: _resolvingTrackKey == track.key,
          onTap: () => _playTrack(track),
        ),
    ];
  }
}

class _ChartDetailLoading extends StatelessWidget {
  const _ChartDetailLoading();

  @override
  Widget build(BuildContext context) {
    final Color placeholder = appSkeletonColor(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 98,
              height: 98,
              decoration: BoxDecoration(
                color: placeholder,
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 68,
                    height: 18,
                    decoration: BoxDecoration(
                      color: placeholder,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    height: 20,
                    decoration: BoxDecoration(
                      color: placeholder,
                      borderRadius: BorderRadius.circular(AppRadius.xs),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    width: 132,
                    height: 12,
                    decoration: BoxDecoration(
                      color: placeholder.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Container(
          height: 42,
          decoration: BoxDecoration(
            color: placeholder,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Container(
          width: 72,
          height: 16,
          decoration: BoxDecoration(
            color: placeholder,
            borderRadius: BorderRadius.circular(AppRadius.xs),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        for (int index = 0; index < 6; index += 1) const _TrackRowSkeleton(),
      ],
    );
  }
}

class _TrackRowSkeleton extends StatelessWidget {
  const _TrackRowSkeleton();

  @override
  Widget build(BuildContext context) {
    final Color placeholder = appSkeletonColor(context);
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
                color: placeholder,
                borderRadius: BorderRadius.circular(AppRadius.xs),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Container(
              width: AppSizes.listCover,
              height: AppSizes.listCover,
              decoration: BoxDecoration(
                color: placeholder,
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
                      color: placeholder,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    width: 120,
                    height: 10,
                    decoration: BoxDecoration(
                      color: placeholder.withValues(alpha: 0.8),
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
  }
}
