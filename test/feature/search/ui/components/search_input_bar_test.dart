import 'package:bilimusic/feature/search/ui/components/search_input_area.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pumpBar(
  WidgetTester tester, {
  String query = '',
  ValueChanged<String>? onChanged,
  VoidCallback? onSubmitted,
  VoidCallback? onClear,
}) async {
  final TextEditingController controller = TextEditingController(text: query);
  final FocusNode focusNode = FocusNode();
  addTearDown(controller.dispose);
  addTearDown(focusNode.dispose);

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SearchInputBar(
          controller: controller,
          focusNode: focusNode,
          query: query,
          onChanged: onChanged ?? (String _) {},
          onSubmitted: onSubmitted ?? () {},
          onClear: onClear ?? () {},
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows the hint and no cancel action', (
    WidgetTester tester,
  ) async {
    await _pumpBar(tester);

    expect(find.text('搜索歌曲、歌手或视频'), findsOneWidget);
    expect(find.text('取消'), findsNothing);
    expect(find.byIcon(Icons.cancel_rounded), findsNothing);
  });

  testWidgets('disables the text magnifier', (WidgetTester tester) async {
    await _pumpBar(tester);

    final TextField field = tester.widget<TextField>(find.byType(TextField));
    expect(field.magnifierConfiguration, TextMagnifierConfiguration.disabled);
  });

  testWidgets('clears the query from the trailing button', (
    WidgetTester tester,
  ) async {
    int cleared = 0;
    await _pumpBar(tester, query: '晴天', onClear: () => cleared += 1);

    await tester.tap(find.byIcon(Icons.cancel_rounded));
    await tester.pumpAndSettle();

    expect(cleared, 1);
  });

  testWidgets('submits from the keyboard action', (WidgetTester tester) async {
    int submitted = 0;
    await _pumpBar(tester, onSubmitted: () => submitted += 1);

    await tester.showKeyboard(find.byType(TextField));
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    expect(submitted, 1);
  });
}
