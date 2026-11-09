import 'package:bilimusic/feature/favorites/ui/components/favorite_collection_play_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('play button offers 顺序/随机/循环 and reports the choice', (
    WidgetTester tester,
  ) async {
    FavoriteCollectionPlayMode? selected;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: FavoriteCollectionPlayButton(
              onModeSelected: (FavoriteCollectionPlayMode mode) {
                selected = mode;
              },
            ),
          ),
        ),
      ),
    );

    expect(
      find.byIcon(Icons.keyboard_double_arrow_right_rounded),
      findsOneWidget,
    );

    await tester.tap(find.byTooltip('播放'));
    await tester.pumpAndSettle();

    expect(find.text('顺序播放'), findsOneWidget);
    expect(
      find.descendant(
        of: find.widgetWithText(ListTile, '顺序播放'),
        matching: find.byIcon(Icons.keyboard_double_arrow_right_rounded),
      ),
      findsOneWidget,
    );
    expect(find.text('随机播放'), findsOneWidget);
    expect(find.text('循环播放'), findsOneWidget);

    await tester.tap(find.text('随机播放'));
    await tester.pumpAndSettle();

    expect(selected, FavoriteCollectionPlayMode.shuffle);
  });

  testWidgets('disabled play button does not open the sheet', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: FavoriteCollectionPlayButton(
              enabled: false,
              onModeSelected: _noop,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('播放'));
    await tester.pumpAndSettle();

    expect(find.text('顺序播放'), findsNothing);
  });
}

void _noop(FavoriteCollectionPlayMode mode) {}
