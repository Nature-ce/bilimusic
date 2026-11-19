import 'package:bilimusic/common/components/status_view.dart';
import 'package:bilimusic/common/util/platform_util.dart';
import 'package:bilimusic/common/util/player_util.dart';
import 'package:bilimusic/common/util/toast_util.dart';
import 'package:bilimusic/core/theme/app_design.dart';
import 'package:bilimusic/core/theme/theme_colors.dart';
import 'package:bilimusic/feature/home/domain/music_chart.dart';
import 'package:bilimusic/feature/home/domain/music_chart_platform.dart';
import 'package:bilimusic/feature/home/domain/music_chart_state.dart';
import 'package:bilimusic/feature/home/domain/music_chart_track.dart';
import 'package:bilimusic/feature/home/logic/music_chart_controller.dart';
import 'package:bilimusic/feature/home/logic/music_chart_resolver.dart';
import 'package:bilimusic/feature/home/ui/components/home_chips.dart';
import 'package:bilimusic/feature/home/ui/components/track_row_tile.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MusicChartSection extends ConsumerStatefulWidget {
  const MusicChartSection({super.key});

  @override
  ConsumerState<MusicChartSection> createState() => _MusicChartSectionState();
}

class _MusicChartSectionState extends ConsumerState<MusicChartSection> {
  String? _resolvingTrackKey;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final MusicChartState state = ref.watch(musicChartControllerProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          HomePlatformBar(
            platforms: MusicChartPlatform.values,
            selected: state.platform,
            onSelected: (MusicChartPlatform platform) {
              ref
                  .read(musicChartControllerProvider.notifier)
                  .selectPlatform(platform);
            },
          ),
          const SizedBox(height: AppSpacing.md),
          _ChartNameBar(
            charts: state.charts,
            selected: state.chart,
            onSelected: (MusicChart chart) {
              ref
                  .read(musicChartControllerProvider.notifier)
                  .selectChart(chart);
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          if (state.isLoading)
            const _MusicChartLoading()
          else if (state.hasError)
            StatusView(
              icon: Icons.signal_wifi_statusbar_connected_no_internet_4_rounded,
              iconColor: colorScheme.error,
              title: '热榜加载失败',
              description: state.errorMessage,
            )
          else if (state.isEmpty)
            const StatusView(icon: Icons.leaderboard_outlined, title: '暂无热榜内容')
          else
            _MusicChartTracks(
              tracks: state.tracks,
              resolvingTrackKey: _resolvingTrackKey,
              onTrackTap: (MusicChartTrack track) => _playTrack(track),
            ),
        ],
      ),
    );
  }

  Future<void> _playTrack(MusicChartTrack track) async {
    final PlayableItem? directItem = track.directItem;
    if (directItem != null) {
      await PlayerUtil.playItemAndOpenPlayer(
        context,
        ref,
        item: directItem,
        sourceLabel: track.chart.displayTitle,
      );
      return;
    }
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
        sourceLabel: track.chart.displayTitle,
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
}

class _ChartNameBar extends StatelessWidget {
  const _ChartNameBar({
    required this.charts,
    required this.selected,
    required this.onSelected,
  });

  final List<MusicChart> charts;
  final MusicChart selected;
  final ValueChanged<MusicChart> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: SingleChildScrollView(
        key: ValueKey<String>(selected.platform.name),
        scrollDirection: Axis.horizontal,
        child: Row(
          children: <Widget>[
            for (final MusicChart chart in charts)
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: HomeChip(
                  label: chart.name,
                  selected: chart == selected,
                  compact: true,
                  onTap: () => onSelected(chart),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MusicChartTracks extends StatelessWidget {
  const _MusicChartTracks({
    required this.tracks,
    required this.resolvingTrackKey,
    required this.onTrackTap,
  });

  final List<MusicChartTrack> tracks;
  final String? resolvingTrackKey;
  final ValueChanged<MusicChartTrack> onTrackTap;

  @override
  Widget build(BuildContext context) {
    if (!PlatformUtil.isDesktop) {
      return Column(children: _buildTiles(tracks));
    }

    final List<MusicChartTrack> left = <MusicChartTrack>[];
    final List<MusicChartTrack> right = <MusicChartTrack>[];
    for (int index = 0; index < tracks.length; index += 1) {
      (index.isEven ? left : right).add(tracks[index]);
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(child: Column(children: _buildTiles(left))),
        const SizedBox(width: 24),
        Expanded(child: Column(children: _buildTiles(right))),
      ],
    );
  }

  List<Widget> _buildTiles(List<MusicChartTrack> tracks) {
    return <Widget>[
      for (final MusicChartTrack track in tracks)
        TrackRowTile(
          rank: track.rank,
          title: track.title,
          artist: track.artist.isEmpty ? track.chart.name : track.artist,
          coverUrl: track.coverUrl,
          durationText: track.durationText,
          isResolving: resolvingTrackKey == track.key,
          onTap: () => onTrackTap(track),
        ),
    ];
  }
}

class _MusicChartLoading extends StatelessWidget {
  const _MusicChartLoading();

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
                    mainAxisAlignment: MainAxisAlignment.center,
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
