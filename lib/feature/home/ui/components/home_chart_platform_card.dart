import 'package:bilimusic/common/components/cached_image.dart';
import 'package:bilimusic/core/theme/app_design.dart';
import 'package:bilimusic/core/theme/theme_colors.dart';
import 'package:bilimusic/feature/home/domain/music_chart_catalog.dart';
import 'package:bilimusic/feature/home/domain/music_chart_state.dart';
import 'package:bilimusic/feature/home/domain/music_chart_track.dart';
import 'package:bilimusic/feature/home/ui/components/music_platform_badge.dart';
import 'package:flutter/material.dart';

/// 首页排行榜的平台卡片（对应设计稿 C-A）：
/// 封面扇 + 榜单名 + 播放按钮 + 更新时间 + 前三名 + 进入平台榜单页的入口。
class HomeChartPlatformCard extends StatelessWidget {
  const HomeChartPlatformCard({
    super.key,
    required this.entry,
    required this.onOpen,
    required this.onPlay,
    required this.onTrackTap,
  });

  static const double width = 268;

  final MusicChartEntry entry;
  final VoidCallback onOpen;
  final VoidCallback onPlay;
  final ValueChanged<MusicChartTrack> onTrackTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final Color surface = appCardSurfaceColor(context);

    return SizedBox(
      width: width,
      child: Material(
        color: surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onOpen,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.4),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _CoverFan(entry: entry),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Row(
                        children: <Widget>[
                          Flexible(
                            child: Text(
                              entry.chart.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          _PlayButton(onTap: onPlay),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      entry.updatedAt == null
                          ? '加载中'
                          : '${_twoDigits(entry.updatedAt!.hour)}:'
                                '${_twoDigits(entry.updatedAt!.minute)} 更新',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                if (entry.isLoading && entry.topTracks.isEmpty)
                  const _CardSkeleton()
                else if (entry.hasError)
                  _CardError(onRetry: onPlay)
                else
                  for (
                    int index = 0;
                    index < entry.topTracks.length;
                    index += 1
                  ) ...<Widget>[
                    if (index > 0)
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: colorScheme.outlineVariant.withValues(
                          alpha: 0.3,
                        ),
                      ),
                    _TopRow(
                      track: entry.topTracks[index],
                      onTap: () => onTrackTap(entry.topTracks[index]),
                    ),
                  ],
                const SizedBox(height: AppSpacing.sm),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: colorScheme.outlineVariant.withValues(alpha: 0.35),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: <Widget>[
                    MusicPlatformBadge(
                      platform: entry.chart.platform,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${entry.chart.platform.label} · 共 ${MusicChartCatalog.chartsFor(entry.chart.platform).length} 个榜单',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      '查看全部 ›',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _twoDigits(int value) => value.toString().padLeft(2, '0');
}

class _CoverFan extends StatelessWidget {
  const _CoverFan({required this.entry});

  final MusicChartEntry entry;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color borderColor = appCardSurfaceColor(context);
    final List<String> covers = <String>[
      for (final MusicChartTrack track in entry.topTracks)
        if (track.coverUrl.trim().isNotEmpty) track.coverUrl.trim(),
    ];

    return Container(
      height: 104,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.md),
        color: colorScheme.primary.withValues(alpha: 0.06),
      ),
      child: covers.isEmpty
          ? Center(
              child: Icon(
                Icons.album_outlined,
                color: colorScheme.primary.withValues(alpha: 0.45),
              ),
            )
          : LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final List<double> sizes = switch (covers.length) {
                  1 => const <double>[76],
                  2 => const <double>[72, 72],
                  _ => const <double>[68, 76, 68],
                };
                const double gap = 5;
                final int count = sizes.length;
                double fanWidth = gap * (count - 1);
                for (final double size in sizes) {
                  fanWidth += size;
                }
                final double startLeft = (constraints.maxWidth - fanWidth) / 2;
                final List<double> lefts = <double>[];
                double cursor = startLeft;
                for (int index = 0; index < count; index += 1) {
                  lefts.add(cursor);
                  cursor += sizes[index] + gap;
                }
                return Stack(
                  clipBehavior: Clip.none,
                  children: <Widget>[
                    for (int index = 0; index < count; index += 1)
                      Positioned(
                        left: lefts[index],
                        top: (104 - sizes[index]) / 2,
                        child: Transform.rotate(
                          angle: count == 1
                              ? 0
                              : (index == 0
                                    ? -0.05
                                    : index == count - 1
                                    ? 0.05
                                    : 0),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: borderColor, width: 3),
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.12),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: CommonCachedImage(
                              imageUrl: covers[index],
                              width: sizes[index],
                              height: sizes[index],
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
    );
  }
}

class _PlayButton extends StatelessWidget {
  const _PlayButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return InkResponse(
      onTap: onTap,
      radius: 20,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: colorScheme.primary.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.play_arrow_rounded,
          size: 18,
          color: colorScheme.primary,
        ),
      ),
    );
  }
}

class _TopRow extends StatelessWidget {
  const _TopRow({required this.track, required this.onTap});

  final MusicChartTrack track;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: <Widget>[
            SizedBox(
              width: 14,
              child: Text(
                '${track.rank}',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    track.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    track.artist.isEmpty ? track.chart.name : track.artist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
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

class _CardSkeleton extends StatelessWidget {
  const _CardSkeleton();

  @override
  Widget build(BuildContext context) {
    final Color placeholder = appSkeletonColor(context);
    return Column(
      children: List<Widget>.generate(3, (int index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: <Widget>[
              Container(width: 14, height: 10, color: placeholder),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Container(height: 10, color: placeholder)),
            ],
          ),
        );
      }),
    );
  }
}

class _CardError extends StatelessWidget {
  const _CardError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.cloud_off_rounded,
            size: 16,
            color: theme.colorScheme.error,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              '加载失败',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('重试')),
        ],
      ),
    );
  }
}
