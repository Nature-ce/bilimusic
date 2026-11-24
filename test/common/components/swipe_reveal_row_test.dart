import 'package:bilimusic/common/components/swipe_reveal_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pump(
  WidgetTester tester, {
  required VoidCallback onAction,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: ListView(
          children: <Widget>[
            SwipeRevealRow(
              actionLabel: '删除',
              onAction: onAction,
              child: const SizedBox(
                height: 72,
                child: Center(child: Text('列表条目')),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('未滑动时删除按钮被内容盖住，点不到', (WidgetTester tester) async {
    int actions = 0;
    await _pump(tester, onAction: () => actions += 1);

    await tester.tap(find.text('删除'), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(actions, 0);
  });

  testWidgets('向左滑动露出删除按钮，点击后触发回调', (WidgetTester tester) async {
    int actions = 0;
    await _pump(tester, onAction: () => actions += 1);

    await tester.drag(find.text('列表条目'), const Offset(-110, 0));
    await tester.pumpAndSettle();

    await tester.tap(find.text('删除'));
    await tester.pumpAndSettle();

    expect(actions, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('向右滑回原处后删除按钮重新被盖住', (WidgetTester tester) async {
    int actions = 0;
    await _pump(tester, onAction: () => actions += 1);

    await tester.drag(find.text('列表条目'), const Offset(-110, 0));
    await tester.pumpAndSettle();
    await tester.drag(find.text('列表条目'), const Offset(110, 0));
    await tester.pumpAndSettle();

    await tester.tap(find.text('删除'), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(actions, 0);
  });
}
