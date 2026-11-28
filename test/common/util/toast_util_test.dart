import 'package:bilimusic/common/util/toast_util.dart';
import 'package:bilimusic/myApp.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(ToastUtil.resetReadyForTest);

  test('未挂载 SmartDialog 时所有 toast 调用都是空操作', () async {
    // SmartDialog 的 context 由 FlutterSmartDialog.init 注入；没挂载前调用会抛
    // LateInitializationError，而且是在异步任务里抛，调用方 try/catch 抓不到。
    ToastUtil.show('普通提示');
    ToastUtil.showCenter('中心提示', icon: Icons.info_outline_rounded);
    ToastUtil.showProgress('下载中 50%');

    await expectLater(ToastUtil.dismissProgress(), completes);
  });

  test('挂载后调用不会抛异常', () async {
    ToastUtil.markReady();

    // 测试环境即便标记为就绪也不会真的弹 toast（没有 Navigator/Overlay），
    // 这里只断言「不会同步抛错」，真实渲染由各页面测试覆盖。
    expect(() => ToastUtil.show(''), returnsNormally);
  });

  testWidgets('应用根 builder 渲染时会把 ToastUtil 标记为就绪', (tester) async {
    // 锁住生产接线：markReady 必须由 appSmartDialogBuilder 触发，
    // 否则线上所有 toast 都会静默失效。
    ToastUtil.resetReadyForTest();
    expect(ToastUtil.readyForTest, isFalse);

    await tester.pumpWidget(
      MaterialApp(
        builder: appSmartDialogBuilder(),
        home: const Scaffold(body: Text('x')),
      ),
    );

    expect(ToastUtil.readyForTest, isTrue);
  });
}
