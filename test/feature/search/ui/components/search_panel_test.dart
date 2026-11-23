import 'package:bilimusic/feature/search/domain/hot_search_item.dart';
import 'package:bilimusic/feature/search/logic/hot_search_controller.dart';
import 'package:bilimusic/feature/search/ui/components/search_input_area.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const List<HotSearchItem> _hotItems = <HotSearchItem>[
  HotSearchItem(keyword: '海屿你', showName: '马也_Crabbit'),
  HotSearchItem(keyword: '慌啥子嘛', showName: '赵本山'),
];

Future<void> _pumpPanel(
  WidgetTester tester, {
  List<String> recentKeywords = const <String>['腿多多', 'tim'],
  List<HotSearchItem> hotItems = _hotItems,
}) async {
  tester.view.physicalSize = const Size(360, 780);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [hotSearchProvider.overrideWithValue(hotItems)],
      child: MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 328,
              child: SearchPanel(
                recentKeywords: recentKeywords,
                onClearHistory: () {},
                onSelectKeyword: (String _) {},
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('puts history and hot search in a single card', (
    WidgetTester tester,
  ) async {
    await _pumpPanel(tester);

    expect(find.text('搜索历史'), findsOneWidget);
    expect(find.text('清空'), findsOneWidget);
    expect(find.text('热搜'), findsOneWidget);
    expect(find.text('海屿你'), findsOneWidget);
    expect(find.text('马也_Crabbit'), findsOneWidget);
    expect(find.text('慌啥子嘛'), findsOneWidget);
    expect(find.byType(Divider), findsOneWidget);

    final Rect historyRect = tester.getRect(find.text('搜索历史'));
    final Rect hotRect = tester.getRect(find.text('热搜'));
    expect(hotRect.top, greaterThan(historyRect.top));
    expect(hotRect.bottom, lessThanOrEqualTo(780));
  });

  testWidgets('keeps only the hot search section without history', (
    WidgetTester tester,
  ) async {
    await _pumpPanel(tester, recentKeywords: const <String>[]);

    expect(find.text('搜索历史'), findsNothing);
    expect(find.text('清空'), findsNothing);
    expect(find.byType(Divider), findsNothing);
    expect(find.text('热搜'), findsOneWidget);
    expect(find.text('海屿你'), findsOneWidget);
  });

  testWidgets('renders nothing when history and hot search are empty', (
    WidgetTester tester,
  ) async {
    await _pumpPanel(
      tester,
      recentKeywords: const <String>[],
      hotItems: const <HotSearchItem>[],
    );

    expect(find.byType(Divider), findsNothing);
    expect(find.text('热搜'), findsNothing);
    expect(find.text('搜索历史'), findsNothing);
  });
}
