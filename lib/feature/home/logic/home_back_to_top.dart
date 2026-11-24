import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_back_to_top.g.dart';

/// 首页当前 section 的滚动控制器（「回到顶部」按钮据此滚动）。
///
/// 首页改成分页滑动后，两个 section 各有一份滚动控制器，
/// 这里只持有当前可见那一份。
@Riverpod(keepAlive: true)
class HomeActiveScrollController extends _$HomeActiveScrollController {
  @override
  ScrollController? build() => null;

  void bind(ScrollController? controller) {
    if (!ref.mounted || identical(state, controller)) {
      return;
    }
    state = controller;
  }
}

/// 首页列表是否已经滚过阈值，用来决定是否显示「回到顶部」按钮。
@Riverpod(keepAlive: true)
class HomeBackToTopVisibility extends _$HomeBackToTopVisibility {
  @override
  bool build() => false;

  void setVisible(bool value) {
    if (!ref.mounted || state == value) {
      return;
    }
    state = value;
  }
}
