import 'package:bilimusic/feature/search/ui/components/search_input_area.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const List<String> _keywords = <String>[
  '腿多多',
  '据多多',
  '影视飓风',
  '周杰伦歌曲全集',
  'tim',
  '慌啥子嘛 (赵本山版)',
  '晴天',
  '稻香',
  '七里香',
  '夜曲',
  '告白气球',
  '兰亭序',
  '菊花台',
  '青花瓷',
  '东风破',
  '发如雪',
  '千里之外',
  '大城小爱',
  '唯一',
  '吻别',
];

Future<void> _pumpSection(
  WidgetTester tester, {
  required List<String> keywords,
  ValueChanged<String>? onSelectKeyword,
  VoidCallback? onClearHistory,
}) async {
  tester.view.physicalSize = const Size(360, 780);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 332,
            child: SearchHistorySection(
              recentKeywords: keywords,
              onClearHistory: onClearHistory ?? () {},
              onSelectKeyword: onSelectKeyword ?? (String _) {},
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

int _visibleCount(WidgetTester tester, List<String> keywords) {
  int count = 0;
  for (final String keyword in keywords) {
    if (find.text(keyword).evaluate().isNotEmpty) {
      count += 1;
    }
  }
  return count;
}

void main() {
  testWidgets('limits the history chips to three lines', (
    WidgetTester tester,
  ) async {
    await _pumpSection(tester, keywords: _keywords);

    expect(find.text('搜索历史'), findsOneWidget);
    expect(find.text('清空'), findsOneWidget);
    expect(find.text('展开全部 ${_keywords.length} 条'), findsOneWidget);

    final int visible = _visibleCount(tester, _keywords);
    expect(visible, greaterThan(0));
    expect(visible, lessThan(_keywords.length));
    expect(tester.getSize(find.byType(Wrap)).height, lessThan(120));
  });

  testWidgets('expands every keyword and collapses again', (
    WidgetTester tester,
  ) async {
    await _pumpSection(tester, keywords: _keywords);
    final int collapsedCount = _visibleCount(tester, _keywords);

    await tester.tap(find.text('展开全部 ${_keywords.length} 条'));
    await tester.pumpAndSettle();

    expect(find.text('收起'), findsOneWidget);
    expect(_visibleCount(tester, _keywords), _keywords.length);

    await tester.tap(find.text('收起'));
    await tester.pumpAndSettle();

    expect(find.text('展开全部 ${_keywords.length} 条'), findsOneWidget);
    expect(_visibleCount(tester, _keywords), collapsedCount);
  });

  testWidgets('shows a short history without an expand chip', (
    WidgetTester tester,
  ) async {
    await _pumpSection(tester, keywords: _keywords.take(3).toList());

    expect(find.text('展开全部 3 条'), findsNothing);
    expect(find.text('收起'), findsNothing);
    expect(_visibleCount(tester, _keywords.take(3).toList()), 3);
  });

  testWidgets('forwards taps on a keyword and on clear', (
    WidgetTester tester,
  ) async {
    final List<String> tapped = <String>[];
    int cleared = 0;
    await _pumpSection(
      tester,
      keywords: _keywords.take(3).toList(),
      onSelectKeyword: tapped.add,
      onClearHistory: () => cleared += 1,
    );

    await tester.tap(find.text('腿多多'));
    await tester.tap(find.text('清空'));
    await tester.pumpAndSettle();

    expect(tapped, <String>['腿多多']);
    expect(cleared, 1);
  });
}
