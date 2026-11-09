import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:bilimusic/common/components/sequence_play_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('inherits size and color from the ambient icon theme', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: IconTheme(
          data: IconThemeData(size: 18, color: Color(0xFF123456)),
          child: Center(child: SequencePlayIcon()),
        ),
      ),
    );

    expect(
      tester.getSize(find.byType(SequencePlayIcon)),
      const Size.square(18),
    );
    final CustomPaint customPaint = tester.widget<CustomPaint>(
      find.descendant(
        of: find.byType(SequencePlayIcon),
        matching: find.byType(CustomPaint),
      ),
    );
    expect(customPaint.painter, isNotNull);
  });

  testWidgets('explicit size wins over the ambient icon theme', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: IconTheme(
          data: IconThemeData(size: 18, color: Color(0xFF123456)),
          child: Center(child: SequencePlayIcon(size: 30)),
        ),
      ),
    );

    expect(
      tester.getSize(find.byType(SequencePlayIcon)),
      const Size.square(30),
    );
  });

  testWidgets('paints two parallel arrows with a gap between them', (
    WidgetTester tester,
  ) async {
    final GlobalKey boundaryKey = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: RepaintBoundary(
            key: boundaryKey,
            child: const IconTheme(
              data: IconThemeData(size: 24, color: Color(0xFF000000)),
              child: SequencePlayIcon(),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final RenderRepaintBoundary boundary =
        boundaryKey.currentContext!.findRenderObject()!
            as RenderRepaintBoundary;
    final ui.Image? image = await tester.runAsync(() => boundary.toImage());
    expect(image, isNotNull);
    final ByteData? bytes = await tester.runAsync<ByteData?>(
      () => image!.toByteData(format: ui.ImageByteFormat.rawRgba),
    );
    expect(bytes, isNotNull);
    final Uint8List pixels = bytes!.buffer.asUint8List();
    final int width = image!.width;

    int alphaAt(int x, int y) {
      final int pixel = (y * width + x) * 4;
      return pixels[pixel + 3];
    }

    expect(alphaAt(1, 1), lessThan(10));
    expect(alphaAt(5, 11), greaterThan(100));
    expect(alphaAt(16, 11), greaterThan(100));
    expect(alphaAt(12, 12), lessThan(40));
    expect(alphaAt(8, 10), greaterThan(60));
    expect(alphaAt(8, 13), greaterThan(60));
  });
}
