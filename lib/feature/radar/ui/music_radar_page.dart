import 'package:bilimusic/common/components/status_view.dart';
import 'package:bilimusic/common/util/player_util.dart';
import 'package:bilimusic/common/util/toast_util.dart';
import 'package:bilimusic/core/theme/app_design.dart';
import 'package:bilimusic/core/theme/theme_colors.dart';
import 'package:bilimusic/feature/home/domain/hot_playlist_track.dart';
import 'package:bilimusic/feature/home/logic/music_chart_resolver.dart';
import 'package:bilimusic/feature/home/ui/components/track_row_tile.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/radar/domain/music_radar_state.dart';
import 'package:bilimusic/feature/radar/logic/music_radar_controller.dart';
import 'package:bilimusic/feature/radar/ui/components/music_radar_visual.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MusicRadarPage extends ConsumerStatefulWidget {
  const MusicRadarPage({super.key});

  @override
  ConsumerState<MusicRadarPage> createState() => _MusicRadarPageState();
}

class _MusicRadarPageState extends ConsumerState<MusicRadarPage> {
  String? _resolvingTrackKey;

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
        sourceLabel: '音乐雷达',
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
    final MusicRadarState state = ref.watch(musicRadarControllerProvider);
    final MusicRadarController controller = ref.read(
      musicRadarControllerProvider.notifier,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('音乐雷达'),
        actions: <Widget>[
          IconButton(
            tooltip: '重新扫描',
            onPressed: state.isScanning ? null : controller.scan,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.scan,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: <Widget>[
            _RadarScanCard(state: state, onScan: controller.scan),
            const SizedBox(height: AppSpacing.xl),
            if (state.isScanning && !state.hasResult)
              const _RadarLoading()
            else if (state.hasError && !state.hasResult)
              StatusView(
                icon: Icons.radar_rounded,
                iconColor: colorScheme.error,
                title: '雷达暂时没有发现',
                description: state.errorMessage,
                onRetry: controller.scan,
              )
            else if (state.isEmpty)
              StatusView(
                icon: Icons.radar_rounded,
                title: '雷达待命中',
                description: '点击「重新扫描」开始新一轮漫游发现',
                onRetry: controller.scan,
              )
            else ...<Widget>[
              _RadarResultHeader(
                count: state.tracks.length,
                scanCount: state.scanCount,
              ),
              for (int index = 0; index < state.tracks.length; index += 1)
                _radarTile(state.tracks[index], index, state.isScanning),
              if (state.isScanning)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  child: Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _radarTile(HotPlaylistTrack track, int index, bool scanning) {
    return TrackRowTile(
      rank: index + 1,
      title: track.title,
      artist: track.artist.isEmpty
          ? track.playlist.platform.label
          : '${track.artist} · ${track.playlist.platform.label}',
      coverUrl: track.coverUrl,
      durationText: track.durationText,
      isResolving: _resolvingTrackKey == track.key,
      onTap: scanning ? () {} : () => _playTrack(track),
    );
  }
}

class _RadarScanCard extends StatelessWidget {
  const _RadarScanCard({required this.state, required this.onScan});

  final MusicRadarState state;
  final Future<void> Function() onScan;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final String statusText = state.isScanning
        ? '正在扫描各平台热门歌单…'
        : state.hasError
        ? '本轮扫描失败，可重试'
        : state.hasResult
        ? '已发现 ${state.tracks.length} 首 · 第 ${state.scanCount} 轮'
        : '等待扫描';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            colorScheme.primary.withValues(alpha: 0.12),
            colorScheme.primary.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: <Widget>[
          MusicRadarVisual(scanning: state.isScanning, size: 132),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '跨平台漫游',
                  style: AppTextStyles.sectionTitle(
                    theme,
                  ).copyWith(fontSize: 17, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: AppSpacing.xs + 2),
                Text(
                  '从网易云 / QQ音乐 / 酷狗的热门歌单里随机发现新歌',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.meta(theme, fontSize: 12).copyWith(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.9),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  statusText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.meta(theme, fontSize: 12).copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                FilledButton.icon(
                  onPressed: state.isScanning ? null : () => onScan(),
                  icon: const Icon(Icons.radar_rounded, size: 18),
                  label: Text(state.hasResult ? '重新扫描' : '开始扫描'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 36),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RadarResultHeader extends StatelessWidget {
  const _RadarResultHeader({required this.count, required this.scanCount});

  final int count;
  final int scanCount;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: <Widget>[
          Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            '本次发现',
            style: AppTextStyles.sectionTitle(theme).copyWith(fontSize: 15),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text('$count 首', style: AppTextStyles.meta(theme, fontSize: 12)),
          const Spacer(),
          Text(
            '第 $scanCount 轮',
            style: AppTextStyles.meta(theme, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _RadarLoading extends StatelessWidget {
  const _RadarLoading();

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
