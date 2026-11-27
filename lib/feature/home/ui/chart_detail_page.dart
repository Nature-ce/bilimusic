import 'dart:async';

import 'package:bilimusic/common/components/bottom_page_spacer.dart';
import 'package:bilimusic/common/components/glass_panel.dart';
import 'package:bilimusic/common/components/page_app_bar.dart';
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
import 'package:bilimusic/feature/home/logic/music_chart_resolver.dart';
import 'package:bilimusic/feature/home/ui/components/collection_detail_header.dart';
import 'package:bilimusic/feature/home/ui/components/track_row_tile.dart';
import 'package:bilimusic/feature/download/logic/download_controller.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/setting/logic/appearance_setting_logic.dart';
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
  bool _isRefreshing = false;
  bool _isDownloading = false;
  int _downloadResolved = 0;
  int _downloadTotal = 0;

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

  Future<void> _downloadAllTracks(List<MusicChartTrack> tracks) async {
    if (_isDownloading || tracks.isEmpty) {
      return;
    }
    final bool? confirmed = await showAppConfirmDialog(
      context: context,
      useGlass: ref.read(appearanceSettingLogicProvider),
      title: '下载整张榜单？',
      message: '将解析这 ${tracks.length} 首并加入下载队列。',
      confirmLabel: '开始下载',
    );
    if (confirmed != true || !mounted) {
      return;
    }
    setState(() {
      _isDownloading = true;
      _downloadResolved = 0;
      _downloadTotal = tracks.length;
    });
    final MusicChartResolver resolver = ref.read(musicChartResolverProvider);
    final DownloadController downloadController = ref.read(
      downloadControllerProvider.notifier,
    );
    int queued = 0;
    int resolved = 0;
    try {
      for (final MusicChartTrack track in tracks) {
        PlayableItem? item;
        try {
          item = await resolver.resolve(track);
        } on Object {
          item = null;
        }
        resolved += 1;
        if (item != null && await downloadController.download(item)) {
          queued += 1;
        }
        if (!mounted) {
          return;
        }
        setState(() => _downloadResolved = resolved);
      }
      if (!mounted) {
        return;
      }
      ToastUtil.show(queued == 0 ? '没有可下载的新曲目' : '已加入下载队列 $queued 首');
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }

  Future<void> _playAllTracks(List<MusicChartTrack> tracks) async {
    if (_isPlayingAll || tracks.isEmpty) {
      return;
    }
    setState(() => _isPlayingAll = true);
    try {
      await CollectionPlayAllRunner(
        context: context,
        ref: ref,
        sourceLabel: widget.chart.name,
        onInitialFilled: () {
          if (mounted) {
            setState(() => _isPlayingAll = false);
          }
        },
      ).run(tracks);
    } finally {
      if (mounted && _isPlayingAll) {
        setState(() => _isPlayingAll = false);
      }
    }
  }

  Future<void> _refresh() async {
    if (_isRefreshing) {
      return;
    }
    setState(() => _isRefreshing = true);
    try {
      final bool changed = await ref
          .read(chartDetailControllerProvider(widget.chart).notifier)
          .refresh();
      if (!mounted) {
        return;
      }
      if (!changed) {
        ToastUtil.show('已是最新');
      }
    } on Object {
      if (mounted) {
        ToastUtil.show('刷新失败，稍后再试');
      }
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
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
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final MusicChart chart = widget.chart;
    final AsyncValue<ChartDetailData> detail = ref.watch(
      chartDetailControllerProvider(chart),
    );
    return Scaffold(
      appBar: PageAppBar(
        title: Text(chart.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          children: <Widget>[
            ...detail.when<List<Widget>>(
              data: (ChartDetailData data) => _buildContent(data),
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
            const BottomPageSpacer(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildContent(ChartDetailData data) {
    final ThemeData theme = Theme.of(context);
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
        meta: _isRefreshing
            ? '共 ${tracks.length} 首 · 更新中…'
            : '共 ${tracks.length} 首 · ${_formatUpdatedAt(data.updatedAtMs)} 更新',
        subMeta: '按热度排序 · 数据来自${chart.platform.label}',
      ),
      const SizedBox(height: AppSpacing.lg),
      CollectionActionRow(
        playAllKey: const Key('chartDetailPlayAll'),
        canPlayAll: true,
        onPlayAll: () => _playAllTracks(tracks),
        downloadKey: const Key('chartDetailDownload'),
        onDownload: () => _downloadAllTracks(tracks),
        downloadBusy: _isDownloading,
        downloadResolved: _downloadResolved,
        downloadTotal: _downloadTotal,
        busy: _isPlayingAll,
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
