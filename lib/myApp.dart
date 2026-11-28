import 'dart:ui';

import 'package:bilimusic/common/util/toast_util.dart';
import 'package:bilimusic/core/devtools/dev_overlay.dart';
import 'package:bilimusic/core/theme/app_theme.dart';
import 'package:bilimusic/core/theme/theme_logic.dart';
import 'package:bilimusic/core/theme/theme_ui_model.dart';
import 'package:bilimusic/router/routers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:go_router/go_router.dart';

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  Widget build(BuildContext context) {
    final GoRouter router = ref.watch(routerProvider);
    final ThemeUiModel currentTheme = ref.watch(themeLogicProvider);

    return MaterialApp.router(
      routerConfig: router,
      themeMode: currentTheme.themeMode,
      theme: AppTheme.lightTheme(currentTheme.themeVariantId),
      darkTheme: AppTheme.darkTheme(currentTheme.themeVariantId),
      scrollBehavior: MyBehavior(),
      builder: FlutterSmartDialog.init(
        builder: (BuildContext context, Widget? child) {
          // SmartDialog 的 context 已经就绪，toast 从这里开始可用。
          ToastUtil.markReady();
          return Stack(
            children: <Widget>[
              child ?? const SizedBox.shrink(),
              if (kDebugMode) const DevOverlay(),
            ],
          );
        },
      ),
    );
  }
}

class MyBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
  };
}

/// 应用根部的 SmartDialog 包装。
///
/// 顺便把 [ToastUtil] 标记为「SmartDialog 已挂载」：toast 依赖
/// `FlutterSmartDialog.init()` 注入的 context，未挂载时调用会抛
/// `LateInitializationError`（且发生在异步任务里，调用方抓不到）。
/// 抽成函数是为了让测试能验证这段生产接线。
TransitionBuilder appSmartDialogBuilder() {
  return FlutterSmartDialog.init(
    builder: (BuildContext context, Widget? child) {
      ToastUtil.markReady();
      return Stack(
        children: <Widget>[
          child ?? const SizedBox.shrink(),
          if (kDebugMode) const DevOverlay(),
        ],
      );
    },
  );
}
