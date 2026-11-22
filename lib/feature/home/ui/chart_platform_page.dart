import 'dart:async';

import 'package:bilimusic/common/components/cached_image.dart';
import 'package:bilimusic/common/util/toast_util.dart';
import 'package:bilimusic/core/theme/app_design.dart';
import 'package:bilimusic/core/theme/theme_colors.dart';
import 'package:bilimusic/feature/home/domain/music_chart.dart';
import 'package:bilimusic/feature/home/domain/music_chart_catalog.dart';
import 'package:bilimusic/feature/home/domain/music_chart_platform.dart';
import 'package:bilimusic/feature/home/domain/music_chart_state.dart';
import 'package:bilimusic/feature/home/domain/music_chart_track.dart';
import 'package:bilimusic/feature/home/logic/collection_play_all.dart';
import 'package:bilimusic/feature/home/logic/music_chart_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ChartPlatformPage extends ConsumerStatefulWidget {
  const ChartPlatformPage({super.key, required this.platform});

  final MusicChartPlatform platform;

  @override
  ConsumerState<ChartPlatformPage> createState() => _ChartPlatformPageState();
}

class _ChartPlatformPageState extends ConsumerState<ChartPlatformPage> {
  bool _isPlayingAll = false;

  @override
  void initState() {
    super.initState();
    unawaited(Future<void>.microtask(_ensureEntryLoaded));
  }

  Future<void> _ensureEntryLoaded() async {
    if (!mounted) {
      return;
    }
    final MusicChartState state = ref.read(musicChartControllerProvider);
    if (state.entries.isEmpty) {
      return;
    }
    final MusicChartEntry? entry = state.entryOf(widget.platform);
    if (entry == null || (entry.isEmpty && !entry.isLoading)) {
      await ref.read(musicChartControllerProvider.notifier).refresh();
    }
  }

  void _openChart(MusicChart chart) {
    context.push('/home/charts/${widget.platform.name}/${chart.chartId}');
  }

  Future<void> _playChart(MusicChart chart) async {
    if (_isPlayingAll) {
      return;
    }
    final MusicChartEntry? entry = ref
        .read(musicChartControllerProvider)
        .entryOf(widget.platform);
    final List<MusicChartTrack> tracks =
        entry?.tracks ?? const <MusicChartTrack>[];
    if (tracks.isEmpty) {
      ToastUtil.show('榜单还没加载完');
      return;
    }
    setState(() => _isPlayingAll = true);
    try {
      await CollectionPlayAllRunner(
        context: context,
        ref: ref,
        sourceLabel: chart.name,
        isActive: () => mounted,
      ).run(tracks);
    } finally {
      if (mounted) {
        setState(() => _isPlayingAll = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final MusicChartState state = ref.watch(musicChartControllerProvider);
    final MusicChartEntry? entry = state.entryOf(widget.platform);
    final MusicChart chart =
        entry?.chart ?? MusicChartCatalog.defaultChartOf(widget.platform);
    final List<MusicChart> charts = MusicChartCatalog.chartsFor(
      widget.platform,
    );
    final List<MusicChart> otherCharts = <MusicChart>[
      for (final MusicChart item in charts)
        if (item.key != chart.key) item,
    ];

    return Scaffold(
      appBar: AppBar(title: Text(widget.platform.label)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: <Widget>[
          _buildDefaultCard(entry: entry, chart: chart),
          const SizedBox(height: AppSpacing.xl),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              '全部榜单',
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final double cardWidth = (constraints.maxWidth - 10) / 2;
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: <Widget>[
                  for (final MusicChart item in otherCharts)
                    SizedBox(
                      width: cardWidth,
                      child: _ChartGridCard(
                        chart: item,
                        platformLabel: widget.platform.label,
                        onTap: () => _openChart(item),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultCard({
    required MusicChartEntry? entry,
    required MusicChart chart,
  }) {
    if (entry == null || (entry.isLoading && entry.tracks.isEmpty)) {
      return const _DefaultChartCardSkeleton();
    }
    if (entry.hasError) {
      return _DefaultChartCardError(
        onRetry: () => ref
            .read(musicChartControllerProvider.notifier)
            .retry(widget.platform),
      );
    }
    return _DefaultChartCard(
      chart: chart,
      entry: entry,
      playing: _isPlayingAll,
      totalCharts: MusicChartCatalog.chartsFor(widget.platform).length,
      onTap: () => _openChart(chart),
      onPlay: () => _playChart(chart),
    );
  }
}

class _DefaultChartCard extends StatelessWidget {
  const _DefaultChartCard({
    required this.chart,
    required this.entry,
    required this.playing,
    required this.totalCharts,
    required this.onTap,
    required this.onPlay,
  });

  final MusicChart chart;
  final MusicChartEntry entry;
  final bool playing;
  final int totalCharts;
  final VoidCallback onTap;
  final VoidCallback onPlay;

  static String _twoDigits(int value) => value.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final List<String> covers = <String>[
      for (final MusicChartTrack track in entry.topTracks)
        if (track.coverUrl.trim().isNotEmpty) track.coverUrl.trim(),
    ];
    final DateTime? updatedAt = entry.updatedAt;
    final String updatedLabel = updatedAt == null
        ? '点击加载'
        : '${_twoDigits(updatedAt.hour)}:${_twoDigits(updatedAt.minute)} 更新';

    return Container(
      decoration: appElevatedCardDecoration(context),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.card),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _ChartCoverFan(covers: covers),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Row(
                        children: <Widget>[
                          Flexible(
                            child: Text(
                              chart.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          _ChartPlayButton(playing: playing, onTap: onPlay),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Text(
                      updatedLabel,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs + 2),
                Text(
                  '默认榜 · 共 $totalCharts 个榜单',
                  style: AppTextStyles.meta(theme, fontSize: 11),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChartCoverFan extends StatelessWidget {
  const _ChartCoverFan({required this.covers});

  final List<String> covers;

  static const double _size = 56;
  static const double _focusSize = 62;
  static const double _overlap = 12;
  static const double _height = 64;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color borderColor = appCardSurfaceColor(context);

    if (covers.isEmpty) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          width: _focusSize,
          height: _focusSize,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Icon(
            Icons.album_outlined,
            size: 26,
            color: colorScheme.primary.withValues(alpha: 0.45),
          ),
        ),
      );
    }

    final List<String> shown = covers.take(3).toList(growable: false);
    final int focusIndex = shown.length == 1 ? 0 : 1;
    final List<double> sizes = <double>[
      for (int index = 0; index < shown.length; index += 1)
        index == focusIndex ? _focusSize : _size,
    ];
    final List<double> lefts = <double>[];
    double cursor = 0;
    for (int index = 0; index < shown.length; index += 1) {
      lefts.add(cursor);
      cursor += sizes[index] - _overlap;
    }
    final double totalWidth = cursor + _overlap;

    return SizedBox(
      height: _height,
      child: Align(
        alignment: Alignment.centerLeft,
        child: SizedBox(
          width: totalWidth,
          height: _height,
          child: Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              for (int index = 0; index < shown.length; index += 1)
                Positioned(
                  left: lefts[index],
                  top: index == focusIndex ? 0 : 8,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      border: Border.all(color: borderColor, width: 2),
                    ),
                    child: CommonCachedImage(
                      imageUrl: shown[index],
                      width: sizes[index],
                      height: sizes[index],
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChartPlayButton extends StatelessWidget {
  const _ChartPlayButton({required this.playing, required this.onTap});

  final bool playing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return InkResponse(
      onTap: playing ? null : onTap,
      radius: 20,
      child: Container(
        width: 26,
        height: 26,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colorScheme.primary.withValues(alpha: playing ? 0.06 : 0.12),
          shape: BoxShape.circle,
        ),
        child: playing
            ? SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colorScheme.primary,
                ),
              )
            : Icon(
                Icons.play_arrow_rounded,
                size: 18,
                color: colorScheme.primary,
              ),
      ),
    );
  }
}

class _DefaultChartCardSkeleton extends StatelessWidget {
  const _DefaultChartCardSkeleton();

  @override
  Widget build(BuildContext context) {
    final Color placeholder = appSkeletonColor(context);
    return Container(
      decoration: appElevatedCardDecoration(context),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: placeholder,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  height: 16,
                  decoration: BoxDecoration(
                    color: placeholder,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Container(
                width: 64,
                height: 12,
                decoration: BoxDecoration(
                  color: placeholder.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            width: 96,
            height: 10,
            decoration: BoxDecoration(
              color: placeholder.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
          ),
        ],
      ),
    );
  }
}

class _DefaultChartCardError extends StatelessWidget {
  const _DefaultChartCardError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    return Container(
      decoration: appElevatedCardDecoration(context),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onRetry,
          borderRadius: BorderRadius.circular(AppRadius.card),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.xl,
            ),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.cloud_off_rounded,
                  size: 20,
                  color: colorScheme.error,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    '加载失败，点击重试',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  Icons.refresh_rounded,
                  size: 18,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChartGridCard extends StatelessWidget {
  const _ChartGridCard({
    required this.chart,
    required this.platformLabel,
    required this.onTap,
  });

  final MusicChart chart;
  final String platformLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final String badgeText = chart.name.length > 2
        ? chart.name.substring(0, 2)
        : chart.name;

    return Container(
      decoration: BoxDecoration(
        color: appCardSurfaceColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: <Widget>[
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(11),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: <Color>[
                        colorScheme.primary,
                        colorScheme.primary.withValues(alpha: 0.62),
                      ],
                    ),
                  ),
                  child: Text(
                    badgeText,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm + 2),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        chart.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        platformLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.meta(theme, fontSize: 10.5),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  '›',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1,
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
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
