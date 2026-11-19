import 'dart:math' as math;

import 'package:flutter/material.dart';

/// 雷达扫描动画：同心圆 + 旋转扫描线 + 若干光点。
class MusicRadarVisual extends StatefulWidget {
  const MusicRadarVisual({
    super.key,
    required this.scanning,
    this.size = 148,
    this.blipCount = 7,
  });

  final bool scanning;
  final double size;
  final int blipCount;

  @override
  State<MusicRadarVisual> createState() => _MusicRadarVisualState();
}

class _MusicRadarVisualState extends State<MusicRadarVisual>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  );

  bool _animating = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncAnimation();
  }

  @override
  void didUpdateWidget(MusicRadarVisual oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scanning != widget.scanning) {
      _syncAnimation();
    }
  }

  void _syncAnimation() {
    final bool reduceMotion =
        MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final bool shouldAnimate = widget.scanning && !reduceMotion;
    if (shouldAnimate == _animating) {
      return;
    }
    _animating = shouldAnimate;
    if (shouldAnimate) {
      _controller.repeat();
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, Widget? child) {
          return CustomPaint(
            painter: _RadarPainter(
              progress: _controller.value,
              gridColor: colorScheme.outlineVariant.withValues(alpha: 0.7),
              sweepColor: colorScheme.primary,
              blipCount: widget.blipCount,
            ),
          );
        },
      ),
    );
  }
}

class _RadarPainter extends CustomPainter {
  _RadarPainter({
    required this.progress,
    required this.gridColor,
    required this.sweepColor,
    required this.blipCount,
  });

  final double progress;
  final Color gridColor;
  final Color sweepColor;
  final int blipCount;

  static const int _ringCount = 3;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = size.shortestSide / 2 - 1;
    final Paint gridPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = gridColor;

    for (int ring = 1; ring <= _ringCount; ring += 1) {
      canvas.drawCircle(center, radius * ring / _ringCount, gridPaint);
    }
    canvas.drawLine(
      Offset(center.dx - radius, center.dy),
      Offset(center.dx + radius, center.dy),
      gridPaint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - radius),
      Offset(center.dx, center.dy + radius),
      gridPaint,
    );

    final double angle = progress * math.pi * 2 - math.pi / 2;
    final Rect circleRect = Rect.fromCircle(center: center, radius: radius);
    final Paint sweepPaint = Paint()
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: math.pi * 2,
        colors: <Color>[
          sweepColor.withValues(alpha: 0.32),
          sweepColor.withValues(alpha: 0.06),
          sweepColor.withValues(alpha: 0),
        ],
        stops: const <double>[0, 0.16, 0.34],
        transform: GradientRotation(angle),
      ).createShader(circleRect);
    canvas.drawCircle(center, radius, sweepPaint);

    final Paint beamPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..color = sweepColor.withValues(alpha: 0.55);
    canvas.drawLine(
      center,
      Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      ),
      beamPaint,
    );

    for (int index = 0; index < blipCount; index += 1) {
      final double blipAngle = _blipAngle(index);
      final double distance = _blipDistance(index) * radius;
      final double delta = _angularDelta(blipAngle, angle);
      final double glow = (1 - delta / 1.6).clamp(0.0, 1.0);
      final Color color = sweepColor.withValues(alpha: 0.25 + glow * 0.7);
      final Offset point = Offset(
        center.dx + distance * math.cos(blipAngle),
        center.dy + distance * math.sin(blipAngle),
      );
      canvas.drawCircle(point, 2.4 + glow * 1.8, Paint()..color = color);
    }
  }

  double _blipAngle(int index) {
    final double seed = (index + 1) * 2.399963;
    return seed % (math.pi * 2);
  }

  double _blipDistance(int index) {
    return 0.28 + ((index * 0.37) % 0.62);
  }

  double _angularDelta(double first, double second) {
    double delta = (first - second).abs() % (math.pi * 2);
    if (delta > math.pi) {
      delta = math.pi * 2 - delta;
    }
    return delta;
  }

  @override
  bool shouldRepaint(_RadarPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.gridColor != gridColor ||
        oldDelegate.sweepColor != sweepColor ||
        oldDelegate.blipCount != blipCount;
  }
}
