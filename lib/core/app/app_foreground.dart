import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_foreground.g.dart';

/// 应用是否处于前台。后台播放时用它停掉只服务于 UI 的定时器与轮询，
/// 避免息屏后仍在每秒唤醒主线程。
@Riverpod(keepAlive: true)
class AppForeground extends _$AppForeground {
  @override
  bool build() => true;

  void update(bool value) {
    if (state == value) {
      return;
    }
    state = value;
  }
}
