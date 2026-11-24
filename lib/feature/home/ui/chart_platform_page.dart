import 'dart:async';

import 'package:bilimusic/common/components/cached_image.dart';
import 'package:bilimusic/common/components/page_app_bar.dart';
import 'package:bilimusic/core/theme/app_design.dart';
import 'package:bilimusic/core/theme/theme_colors.dart';
import 'package:bilimusic/feature/home/domain/music_chart.dart';
import 'package:bilimusic/feature/home/domain/music_chart_catalog.dart';
import 'package:bilimusic/feature/home/domain/music_chart_platform.dart';
import 'package:bilimusic/feature/home/domain/music_chart_state.dart';
import 'package:bilimusic/feature/home/domain/music_chart_track.dart';
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
      appBar: PageAppBar(title: Text(widget.platform.label)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: <Widget>[
          _buildDefaultCard(entry: entry, chart: chart),
          const SizedBox(height: AppSpacing.xl),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: <Widget>[
                Text(
                  '全部榜单',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                Text(
                  '共 ${charts.length} 个榜单',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final double tileWidth = (constraints.maxWidth - 12) / 2;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: <Widget>[
                  for (final MusicChart item in otherCharts)
                    SizedBox(
                      width: tileWidth,
                      child: _ChartCoverTile(
                        chart: item,
                        platformLabel: widget.platform.label,
                        colors: _chartTileColors(charts.indexOf(item)),
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
      onTap: () => _openChart(chart),
    );
  }
}

class _DefaultChartCard extends StatelessWidget {
  const _DefaultChartCard({
    required this.chart,
    required this.entry,
    required this.onTap,
  });

  final MusicChart chart;
  final MusicChartEntry entry;
  final VoidCallback onTap;

  static String _twoDigits(int value) => value.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
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
      clipBehavior: Clip.antiAlias,
      height: 160,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              _DefaultChartCover(coverUrl: covers.isEmpty ? '' : covers.first),
              const ColoredBox(color: Color(0x42000000)),
              Positioned(
                left: 16,
                right: 16,
                bottom: 12,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        chart.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 22,
                          height: 1.15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4,
                          color: Colors.white,
                          shadows: <Shadow>[
                            Shadow(
                              color: Color(0x8C000000),
                              blurRadius: 12,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Text(
                      updatedLabel,
                      style: const TextStyle(
                        fontSize: 11,
                        height: 1.2,
                        fontWeight: FontWeight.w800,
                        color: Color(0xF2FFFFFF),
                        shadows: <Shadow>[
                          Shadow(color: Color(0x73000000), blurRadius: 8),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DefaultChartCover extends StatelessWidget {
  const _DefaultChartCover({required this.coverUrl});

  final String coverUrl;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final String url = coverUrl.trim();
    if (url.isEmpty) {
      return ColoredBox(
        color: colorScheme.primary.withValues(alpha: 0.08),
        child: Center(
          child: Icon(
            Icons.album_outlined,
            size: 32,
            color: colorScheme.primary.withValues(alpha: 0.45),
          ),
        ),
      );
    }
    return CommonCachedImage(
      imageUrl: url,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
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

const List<(Color, Color)> _chartTilePalette = <(Color, Color)>[
  (Color(0xFFF07A3C), Color(0xFFB54E1F)),
  (Color(0xFF2FB37B), Color(0xFF12724F)),
  (Color(0xFF4C86D8), Color(0xFF245087)),
  (Color(0xFF8B5CC4), Color(0xFF5B3691)),
  (Color(0xFF2E8FA6), Color(0xFF175669)),
  (Color(0xFFD9658E), Color(0xFF9C3358)),
  (Color(0xFF5D6B84), Color(0xFF2C3547)),
  (Color(0xFFC9A227), Color(0xFF8A6A0E)),
];

(Color, Color) _chartTileColors(int index) {
  return _chartTilePalette[index % _chartTilePalette.length];
}

/// 「全部榜单」的封面式网格卡：榜单无封面，用固定渐变色块 + 榜单名 + 平台名。
class _ChartCoverTile extends StatelessWidget {
  const _ChartCoverTile({
    required this.chart,
    required this.platformLabel,
    required this.colors,
    required this.onTap,
  });

  final MusicChart chart;
  final String platformLabel;
  final (Color, Color) colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[colors.$1, colors.$2],
          ),
        ),
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 104,
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.5),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 22,
                  child: Text(
                    chart.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                      color: Colors.white,
                    ),
                  ),
                ),
                Positioned(
                  left: 12,
                  bottom: 8,
                  child: Text(
                    platformLabel,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withValues(alpha: 0.86),
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
