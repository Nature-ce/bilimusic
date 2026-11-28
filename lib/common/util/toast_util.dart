import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

class ToastUtil {
  ToastUtil._();

  /// SmartDialog 是否已经挂载。
  ///
  /// 所有 toast 都依赖 `FlutterSmartDialog.init()` 注入的 context；没初始化就调用
  /// 会抛 `LateInitializationError: Field 'contextToast'`，而且是在异步任务里抛，
  /// 外层 try/catch 抓不到（桌面 / 测试环境都会踩到）。这里显式记录状态，
  /// 未挂载时静默跳过，避免只为一条进度提示把调用方炸掉。
  static bool _ready = false;

  static void markReady() {
    _ready = true;
  }

  @visibleForTesting
  static bool get readyForTest => _ready;

  @visibleForTesting
  static void resetReadyForTest() {
    _ready = false;
  }

  static void show(String message) {
    message = message.trim();
    if (message.isEmpty || !_ready) {
      return;
    }
    SmartDialog.showToast(message);
  }

  static void showCenter(String message, {required IconData icon}) {
    message = message.trim();
    if (message.isEmpty || !_ready) {
      return;
    }
    SmartDialog.showToast(
      message,
      alignment: Alignment.center,
      displayType: SmartToastType.onlyRefresh,
      builder: (BuildContext context) {
        final ColorScheme colors = Theme.of(context).colorScheme;
        return Semantics(
          liveRegion: true,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            constraints: const BoxConstraints(minWidth: 160, maxWidth: 280),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            decoration: BoxDecoration(
              color: colors.inverseSurface.withValues(alpha: 0.94),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(icon, size: 40, color: colors.onInverseSurface),
                const SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: colors.onInverseSurface,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 进度类提示：复用同一条 toast 原地刷新，避免高频调用排队堆积。
  static void showProgress(String message) {
    message = message.trim();
    if (message.isEmpty || !_ready) {
      return;
    }
    SmartDialog.showToast(
      message,
      displayType: SmartToastType.onlyRefresh,
      displayTime: const Duration(seconds: 4),
    );
  }

  /// 关掉进度 toast
  static Future<void> dismissProgress() {
    if (!_ready) {
      return Future<void>.value();
    }
    return SmartDialog.dismiss(status: SmartStatus.toast);
  }
}
