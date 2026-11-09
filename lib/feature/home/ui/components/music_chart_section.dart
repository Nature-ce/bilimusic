import 'package:bilimusic/common/components/cached_image.dart';
import 'package:bilimusic/common/components/status_view.dart';
import 'package:bilimusic/core/theme/app_design.dart';
import 'package:bilimusic/core/theme/theme_colors.dart';
import 'package:bilimusic/common/util/platform_util.dart';
import 'package:bilimusic/common/util/player_util.dart';
import 'package:bilimusic/common/util/toast_util.dart';
import 'package:bilimusic/feature/home/domain/music_chart.dart';
import 'package:bilimusic/feature/home/domain/music_chart_platform.dart';
import 'package:bilimusic/feature/home/domain/music_chart_state.dart';
import 'package:bilimusic/feature/home/domain/music_chart_track.dart';
import 'package:bilimusic/feature/home/logic/music_chart_controller.dart';
import 'package:bilimusic/feature/home/logic/music_chart_resolver.dart';
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
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final MusicChartState state = ref.watch(musicChartControllerProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '音乐热榜',
                style: AppTextStyles.sectionTitle(theme).copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _ChartPlatformBar(
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

class _ChartPlatformBar extends StatelessWidget {
  const _ChartPlatformBar({required this.selected, required this.onSelected});

  final MusicChartPlatform selected;
  final ValueChanged<MusicChartPlatform> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: <Widget>[
        for (final MusicChartPlatform platform in MusicChartPlatform.values)
          _ChartChip(
            label: platform.label,
            selected: platform == selected,
            emphasis: true,
            onTap: () => onSelected(platform),
          ),
      ],
    );
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
      height: 30,
      child: SingleChildScrollView(
        key: ValueKey<String>(selected.platform.name),
        scrollDirection: Axis.horizontal,
        child: Row(
          children: <Widget>[
            for (final MusicChart chart in charts)
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: _ChartChip(
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

class _ChartChip extends StatelessWidget {
  const _ChartChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.compact = false,
    this.emphasis = false,
  });

  final String label;
  final bool selected;
  final bool compact;

  /// 平台级 chip：选中时用主色实心，视觉权重高于榜单 chip。
  final bool emphasis;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color background = selected
        ? (emphasis
              ? colorScheme.primary
              : appChipBackgroundColor(context, selected: true))
        : appChipBackgroundColor(context, selected: false);
    final Color foreground = selected
        ? (emphasis ? colorScheme.onPrimary : colorScheme.primary)
        : colorScheme.onSurfaceVariant;

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: Padding(
          padding: compact
              ? const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs + 2,
                )
              : const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg - 2,
                  vertical: AppSpacing.sm - 1,
                ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: compact ? 11.5 : 12.5,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
              color: foreground,
              height: 1.15,
            ),
          ),
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
      return Column(
        children: <Widget>[
          for (final MusicChartTrack track in tracks)
            _MusicChartTrackTile(
              track: track,
              isResolving: resolvingTrackKey == track.key,
              onTap: () => onTrackTap(track),
            ),
        ],
      );
    }

    final List<MusicChartTrack> left = <MusicChartTrack>[];
    final List<MusicChartTrack> right = <MusicChartTrack>[];
    for (int index = 0; index < tracks.length; index += 1) {
      (index.isEven ? left : right).add(tracks[index]);
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            children: <Widget>[
              for (final MusicChartTrack track in left)
                _MusicChartTrackTile(
                  track: track,
                  isResolving: resolvingTrackKey == track.key,
                  onTap: () => onTrackTap(track),
                ),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            children: <Widget>[
              for (final MusicChartTrack track in right)
                _MusicChartTrackTile(
                  track: track,
                  isResolving: resolvingTrackKey == track.key,
                  onTap: () => onTrackTap(track),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MusicChartTrackTile extends StatelessWidget {
  const _MusicChartTrackTile({
    required this.track,
    required this.isResolving,
    required this.onTap,
  });

  final MusicChartTrack track;
  final bool isResolving;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs + 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isResolving ? null : onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: AppSpacing.sm - 2,
            ),
            child: Row(
              children: <Widget>[
                _ChartRankBadge(rank: track.rank),
                const SizedBox(width: AppSpacing.md),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  child: CommonCachedImage(
                    imageUrl: track.coverUrl,
                    width: AppSizes.listCover,
                    height: AppSizes.listCover,
                    fit: BoxFit.cover,
                    fallbackIcon: Icons.music_note_rounded,
                    iconColor: colorScheme.onSurfaceVariant,
                    backgroundColor: appSkeletonColor(context),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        track.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.listTitle(theme),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        track.artist.isEmpty ? track.chart.name : track.artist,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.meta(theme, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                if (isResolving)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Text(
                    track.durationText,
                    style: AppTextStyles.meta(theme, fontSize: 12).copyWith(
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.75,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChartRankBadge extends StatelessWidget {
  const _ChartRankBadge({required this.rank});

  final int rank;

  static const double _size = 24;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextStyle baseStyle = TextStyle(
      fontSize: 12,
      height: 1.1,
      fontWeight: FontWeight.w700,
      fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
    );
    final bool highlighted = rank <= 3;

    if (!highlighted) {
      return SizedBox(
        width: _size,
        child: Text(
          '$rank',
          textAlign: TextAlign.center,
          style: baseStyle.copyWith(
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.72),
          ),
        ),
      );
    }

    return Container(
      width: _size,
      height: _size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.xs),
      ),
      child: Text(
        '$rank',
        style: baseStyle.copyWith(
          color: colorScheme.primary,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
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
