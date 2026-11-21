import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'shell_location.g.dart';

/// 刷歌标签的路由（一级 tab）。
const String shuffleTabLocation = '/radar';

/// 当前 shell 所在的一级路由。
///
/// `StatefulShellRoute.indexedStack` 会把各个 tab 的页面一直挂在树上，
/// 来回切 tab 不会重跑 `initState`，所以需要这个信号让页面知道
/// 「自己被重新切回来了」。
@Riverpod(keepAlive: true)
class ShellLocation extends _$ShellLocation {
  @override
  String build() => '/home';

  void update(String location) {
    if (state == location) {
      return;
    }
    state = location;
  }
}
