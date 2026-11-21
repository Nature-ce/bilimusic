import 'package:bilimusic/common/logger.dart';
import 'package:bilimusic/common/util/platform_util.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// 播放期间握住 Android 的 PARTIAL_WAKE_LOCK。
///
/// media_kit / libmpv 不替我们管休眠：息屏后 CPU 一 suspend，音频就会卡在
/// 半路上，媒体通知也可能跟着消失。所以播放时开锁、暂停/停止时释放。
class PlaybackWakeLock {
  PlaybackWakeLock._();

  static const MethodChannel _channel = MethodChannel('bilimusic/keep_awake');
  static final AppLogger _logger = AppLogger('PlaybackWakeLock');

  static bool _held = false;

  /// 测试用：强制走通道调用（测试环境不是 Android）。
  @visibleForTesting
  static bool debugForceEnabled = false;

  static bool get isHeld => _held;

  static Future<void> setHeld(bool held) async {
    if (!_shouldUseChannel || _held == held) {
      return;
    }
    _held = held;
    try {
      await _channel.invokeMethod<void>(held ? 'acquire' : 'release');
    } on Object catch (error) {
      // 拿不到锁不影响播放，只是息屏后可能被系统挂起。
      _held = !held;
      _logger.w('keep_awake ${held ? 'acquire' : 'release'} failed: $error');
    }
  }

  static bool get _shouldUseChannel =>
      debugForceEnabled || PlatformUtil.isMobile;

  @visibleForTesting
  static void resetForTest() {
    _held = false;
    debugForceEnabled = false;
  }
}
