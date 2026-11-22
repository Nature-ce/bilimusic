import 'package:bilimusic/feature/player/ui/player_page_pager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('拖动时两侧页面按手指位移一起平移，而不是叠着淡入', (tester) async {
    await tester.pumpWidget(const _PagerHarness());
    expect(find.byKey(const ValueKey<String>('page-1')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('page-2')), findsNothing);

    final TestGesture gesture = await tester.startGesture(
      tester.getCenter(find.byType(PlayerPagePager)),
    );
    await gesture.moveBy(const Offset(-120, 0));
    await tester.pump();

    final double pagerLeft = tester.getRect(
      find.byType(PlayerPagePager),
    ).left;
    final Rect current = tester.getRect(
      find.byKey(const ValueKey<String>('page-1')),
    );
    final Rect incoming = tester.getRect(
      find.byKey(const ValueKey<String>('page-2')),
    );
    expect(current.left - pagerLeft, lessThan(-20));
    expect(incoming.left - current.left, closeTo(400, 0.01));
    expect(current.width, 400);
    expect(
      find.descendant(
        of: find.byType(PlayerPagePager),
        matching: find.byType(IgnorePointer),
      ),
      findsNothing,
    );

    await gesture.up();
    await tester.pumpAndSettle();
  });

  testWidgets('拖过一半松手切到下一页', (tester) async {
    await tester.pumpWidget(const _PagerHarness());
    final TestGesture gesture = await tester.startGesture(
      tester.getCenter(find.byType(PlayerPagePager)),
    );
    await gesture.moveBy(const Offset(-260, 0));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    expect(_PagerHarnessState.index, 2);
    expect(find.byKey(const ValueKey<String>('page-1')), findsNothing);
    final double pagerLeft = tester.getRect(
      find.byType(PlayerPagePager),
    ).left;
    expect(
      tester.getRect(find.byKey(const ValueKey<String>('page-2'))).left -
          pagerLeft,
      closeTo(0, 0.01),
    );
  });

  testWidgets('拖动不足一半时回弹到原页', (tester) async {
    await tester.pumpWidget(const _PagerHarness());
    final TestGesture gesture = await tester.startGesture(
      tester.getCenter(find.byType(PlayerPagePager)),
    );
    await gesture.moveBy(const Offset(-90, 0));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    expect(_PagerHarnessState.index, 1);
    final double pagerLeft = tester.getRect(
      find.byType(PlayerPagePager),
    ).left;
    expect(
      tester.getRect(find.byKey(const ValueKey<String>('page-1'))).left -
          pagerLeft,
      closeTo(0, 0.01),
    );
    expect(find.byKey(const ValueKey<String>('page-2')), findsNothing);
  });

  testWidgets('快速轻扫即使位移很小也能切页', (tester) async {
    await tester.pumpWidget(const _PagerHarness());
    final TestGesture gesture = await tester.startGesture(
      tester.getCenter(find.byType(PlayerPagePager)),
    );
    for (int step = 1; step <= 4; step += 1) {
      await gesture.moveBy(
        const Offset(-30, 0),
        timeStamp: Duration(milliseconds: 16 * step),
      );
    }
    await gesture.up(timeStamp: const Duration(milliseconds: 80));
    await tester.pumpAndSettle();

    expect(_PagerHarnessState.index, 2);
    expect(find.byKey(const ValueKey<String>('page-2')), findsOneWidget);
  });

  testWidgets('首尾页继续往外拖不会越界', (tester) async {
    await tester.pumpWidget(const _PagerHarness());
    final TestGesture gesture = await tester.startGesture(
      tester.getCenter(find.byType(PlayerPagePager)),
    );
    await gesture.moveBy(const Offset(-400, 0));
    await tester.pump();
    await gesture.moveBy(const Offset(-400, 0));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();
    expect(_PagerHarnessState.index, 2);

    final TestGesture back = await tester.startGesture(
      tester.getCenter(find.byType(PlayerPagePager)),
    );
    await back.moveBy(const Offset(700, 0));
    await tester.pump();
    await back.up();
    await tester.pumpAndSettle();
    expect(_PagerHarnessState.index, 0);
  });
}

class _PagerHarness extends StatefulWidget {
  const _PagerHarness();

  @override
  State<_PagerHarness> createState() => _PagerHarnessState();
}

class _PagerHarnessState extends State<_PagerHarness> {
  static int index = 1;

  @override
  void initState() {
    super.initState();
    index = 1;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 400,
            height: 600,
            child: PlayerPagePager(
              index: index,
              pageCount: 3,
              onIndexChanged: (int page) => setState(() => index = page),
              buildPage: (BuildContext context, int page) => DecoratedBox(
                key: ValueKey<String>('page-$page'),
                decoration: BoxDecoration(
                  color: Color(0xFF000000 + page * 0x101010),
                ),
                child: Center(child: Text('page $page')),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
