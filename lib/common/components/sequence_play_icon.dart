import 'package:flutter/material.dart';

class SequencePlayIcon extends StatelessWidget {
  const SequencePlayIcon({super.key, this.size, this.color});

  final double? size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final IconThemeData iconTheme = IconTheme.of(context);
    final Color resolvedColor =
        color ??
        iconTheme.color ??
        Theme.of(context).colorScheme.onSurfaceVariant;
    final double side = size ?? iconTheme.size ?? 24;
    return SizedBox(
      width: side,
      height: side,
      child: CustomPaint(
        painter: _SequencePlayPainter(color: resolvedColor),
        size: Size.square(side),
      ),
    );
  }
}

class _SequencePlayPainter extends CustomPainter {
  const _SequencePlayPainter({required this.color});

  final Color color;

  static const double _arrowStep = 11.8;

  @override
  void paint(Canvas canvas, Size size) {
    final double scale = size.shortestSide / 24;
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8 * scale
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    for (int index = 0; index < 2; index += 1) {
      final double offset = index * _arrowStep;
      canvas.drawLine(
        Offset((2.2 + offset) * scale, 12 * scale),
        Offset((7.0 + offset) * scale, 12 * scale),
        paint,
      );
      final Path head = Path()
        ..moveTo((6.0 + offset) * scale, 7.9 * scale)
        ..lineTo((10.0 + offset) * scale, 12 * scale)
        ..lineTo((6.0 + offset) * scale, 16.1 * scale);
      canvas.drawPath(head, paint);
    }
  }

  @override
  bool shouldRepaint(_SequencePlayPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
