import 'package:bilimusic/common/components/video_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('blank tags render nothing', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: VideoCardTag(label: '   ')),
        ),
      ),
    );

    expect(find.byType(Text), findsNothing);
    expect(find.byType(Container), findsNothing);
  });

  testWidgets('a non-blank tag is trimmed and rendered', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: VideoCardTag(label: ' 电台 ')),
        ),
      ),
    );

    expect(find.text('电台'), findsOneWidget);
  });
}
