import 'package:bilimusic/common/components/glass_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

Future<void> _pumpHost(WidgetTester tester, {required Widget child}) async {
  await tester.pumpWidget(MaterialApp(home: Scaffold(body: child)));
}

void main() {
  testWidgets('showAppHalfSheet 弹出白雾玻璃面板', (WidgetTester tester) async {
    late BuildContext hostContext;
    await _pumpHost(
      tester,
      child: Builder(
        builder: (BuildContext context) {
          hostContext = context;
          return const SizedBox.shrink();
        },
      ),
    );

    unawaitedShow(tester, hostContext);

    await tester.pumpAndSettle();

    expect(find.byType(AppGlassSheet), findsOneWidget);
    expect(find.byType(GlassPanel), findsWidgets);
    expect(find.text('弹层内容'), findsOneWidget);
    final GlassContainer glass = tester.widget<GlassContainer>(
      find.byType(GlassContainer).first,
    );
    expect(
      glass.settings?.glassColor,
      appFrostGlassSettings(hostContext).glassColor,
    );
  });

  testWidgets('内容很高时弹层不占满整页，改为内部滚动', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    late BuildContext hostContext;
    await _pumpHost(
      tester,
      child: Builder(
        builder: (BuildContext context) {
          hostContext = context;
          return const SizedBox.shrink();
        },
      ),
    );

    showAppHalfSheet<void>(
      context: hostContext,
      builder: (BuildContext sheetContext) => ListView.builder(
        shrinkWrap: true,
        itemCount: 40,
        itemBuilder: (BuildContext context, int index) =>
            ListTile(title: Text('条目 $index')),
      ),
    );
    await tester.pumpAndSettle();

    final double sheetHeight = tester
        .getSize(find.byType(AppGlassSheet))
        .height;
    expect(sheetHeight, lessThanOrEqualTo(844 * 0.66 + 1));
    expect(sheetHeight, greaterThan(300));
    expect(find.text('条目 0'), findsOneWidget);
  });
  testWidgets('AppGlassAlertDialog 确认返回 true、取消返回 false', (
    WidgetTester tester,
  ) async {
    bool? result;
    late BuildContext hostContext;
    await _pumpHost(
      tester,
      child: Builder(
        builder: (BuildContext context) {
          hostContext = context;
          return const SizedBox.shrink();
        },
      ),
    );

    Future<void> open() async {
      result = await showDialog<bool>(
        context: hostContext,
        builder: (BuildContext dialogContext) => const AppGlassAlertDialog(
          title: '删除下载',
          message: '确认删除？',
          cancelLabel: '取消',
          confirmLabel: '删除',
          danger: true,
        ),
      );
    }

    open();
    await tester.pumpAndSettle();
    expect(find.text('删除下载'), findsOneWidget);
    expect(find.byType(GlassPanel), findsWidgets);

    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();
    expect(result, isFalse);

    open();
    await tester.pumpAndSettle();
    await tester.tap(find.text('删除'));
    await tester.pumpAndSettle();
    expect(result, isTrue);
  });
}

void unawaitedShow(WidgetTester tester, BuildContext context) {
  showAppHalfSheet<void>(
    context: context,
    builder: (BuildContext sheetContext) =>
        const Padding(padding: EdgeInsets.all(24), child: Text('弹层内容')),
  );
}
