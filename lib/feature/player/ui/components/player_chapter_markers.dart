import 'package:bilimusic/feature/player/domain/playback_chapter.dart';
import 'package:bilimusic/feature/player/domain/player_chapter_marker_style.dart';
import 'package:bilimusic/feature/player/logic/utils/player_ui_helpers.dart';
import 'package:flutter/material.dart';

class ChapterMarkers extends StatelessWidget {
  const ChapterMarkers({
    super.key,
    required this.chapters,
    required this.total,
    required this.style,
    required this.color,
  });

  final List<PlaybackChapter> chapters;
  final Duration? total;
  final PlayerChapterMarkerStyle style;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ChapterMarkerPainter(
        chapters: chapters,
        total: total,
        style: style,
        color: color,
      ),
    );
  }
}

class ChapterMarkerPainter extends CustomPainter {
  const ChapterMarkerPainter({
    required this.chapters,
    required this.total,
    required this.style,
    required this.color,
  });

  final List<PlaybackChapter> chapters;
  final Duration? total;
  final PlayerChapterMarkerStyle style;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final List<double> ratios = resolveChapterTickRatios(chapters, total);
    if (ratios.isEmpty || size.width <= 0 || size.height <= 0) {
      return;
    }

    const double edgeInset = 3;
    final double trackWidth = size.width - edgeInset * 2;
    if (trackWidth <= 0) {
      return;
    }

    final Paint paint = Paint()
      ..color = color
      ..isAntiAlias = true;
    final double centerY = size.height / 2;

    switch (style) {
      case PlayerChapterMarkerStyle.line:
        paint
          ..strokeWidth = 1
          ..strokeCap = StrokeCap.round;
        final double top = size.height * 0.34;
        final double bottom = size.height * 0.66;
        for (final double ratio in ratios) {
          final double x = edgeInset + trackWidth * ratio;
          canvas.drawLine(Offset(x, top), Offset(x, bottom), paint);
        }
      case PlayerChapterMarkerStyle.dot:
        final double radius = (size.height * 0.05).clamp(1.6, 2.6);
        for (final double ratio in ratios) {
          final double x = edgeInset + trackWidth * ratio;
          canvas.drawCircle(Offset(x, centerY), radius, paint);
        }
      case PlayerChapterMarkerStyle.segment:
        final double blockHeight = (size.height * 0.1).clamp(3.5, 6);
        final double blockRadius = blockHeight / 2;
        for (int index = 0; index < ratios.length; index += 1) {
          final double startRatio = ratios[index];
          final double endRatio = index + 1 < ratios.length
              ? ratios[index + 1]
              : 1;
          final double left = edgeInset + trackWidth * startRatio + 1.5;
          final double right = edgeInset + trackWidth * endRatio - 1.5;
          if (right <= left) {
            continue;
          }
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTRB(
                left,
                centerY - blockHeight / 2,
                right,
                centerY + blockHeight / 2,
              ),
              Radius.circular(blockRadius),
            ),
            Paint()..color = color.withValues(alpha: index.isEven ? 0.5 : 0.22),
          );
        }
      case PlayerChapterMarkerStyle.none:
        break;
    }
  }

  @override
  bool shouldRepaint(covariant ChapterMarkerPainter oldDelegate) {
    return oldDelegate.chapters != chapters ||
        oldDelegate.total != total ||
        oldDelegate.style != style ||
        oldDelegate.color != color;
  }
}
