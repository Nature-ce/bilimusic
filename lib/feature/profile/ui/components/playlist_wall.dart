import 'dart:math' as math;
import 'dart:ui' show PathMetric;

import 'package:bilimusic/common/components/cached_image.dart';
import 'package:bilimusic/common/util/relative_time.dart';
import 'package:bilimusic/core/theme/app_design.dart';
import 'package:bilimusic/feature/home/domain/music_chart_platform.dart';
import 'package:bilimusic/feature/home/ui/components/music_platform_badge.dart';
import 'package:flutter/material.dart';

const double playlistWallCoverSize = 96;
const double favoritePlaylistWallCoverSize = 112;
const double playlistWallGap = 10;
const double _coverRadius = 16;

class PlaylistWallCard extends StatelessWidget {
  const PlaylistWallCard({
    super.key,
    required this.title,
    required this.trackCount,
    required this.coverUrl,
    required this.onTap,
    this.updatedAt,
    this.platform,
    this.coverSize = playlistWallCoverSize,
    this.onLongPressStart,
  });

  final String title;
  final int trackCount;
  final String? coverUrl;
  final VoidCallback onTap;
  final DateTime? updatedAt;
  final MusicChartPlatform? platform;
  final double coverSize;
  final ValueChanged<LongPressStartDetails>? onLongPressStart;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final MusicChartPlatform? platform = this.platform;
    final String meta = platform != null
        ? '$trackCount 首 · ${platform.label}'
        : (relativeUpdatedLabel(updatedAt) ?? '$trackCount 首');

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      onLongPressStart: onLongPressStart,
      child: SizedBox(
        width: coverSize,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              width: coverSize,
              height: coverSize,
              child: Stack(
                children: <Widget>[
                  Positioned.fill(
                    child: CommonCachedImage(
                      imageUrl: coverUrl,
                      width: coverSize,
                      height: coverSize,
                      fit: BoxFit.cover,
                      borderRadius: BorderRadius.circular(_coverRadius),
                      placeholder: const _WallCoverFallback(),
                      errorWidget: const _WallCoverFallback(),
                    ),
                  ),
                  Positioned(
                    right: 4,
                    bottom: 4,
                    child: _CountBadge(trackCount: trackCount),
                  ),
                  if (platform != null)
                    Positioned(
                      right: 5,
                      top: 5,
                      child: MusicPlatformBadge(platform: platform),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 7),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.5,
                height: 1.25,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              meta,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.meta(theme, fontSize: 10.5),
            ),
          ],
        ),
      ),
    );
  }
}

class CreatePlaylistWallCard extends StatelessWidget {
  const CreatePlaylistWallCard({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: playlistWallCoverSize,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            CustomPaint(
              painter: _DashedBorderPainter(
                color: colorScheme.outline.withValues(alpha: 0.34),
                radius: _coverRadius,
              ),
              child: SizedBox(
                width: playlistWallCoverSize,
                height: playlistWallCoverSize,
                child: Center(
                  child: Icon(
                    Icons.add,
                    size: 24,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 7),
            Text(
              '新建歌单',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.5,
                height: 1.25,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.trackCount});

  final int trackCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        '$trackCount',
        style: const TextStyle(
          fontSize: 9.5,
          height: 1.2,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

class _WallCoverFallback extends StatelessWidget {
  const _WallCoverFallback();

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).colorScheme.primary;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            primary.withValues(alpha: 0.18),
            primary.withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(_coverRadius),
      ),
      child: Icon(Icons.queue_music_rounded, color: primary, size: 30),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  static const double _dash = 5;
  static const double _gap = 4;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    final Path path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
      );
    for (final PathMetric metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final double end = math.min(distance + _dash, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance += _dash + _gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.radius != radius;
  }
}
