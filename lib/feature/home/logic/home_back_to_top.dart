import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_back_to_top.g.dart';

/// 首页热榜列表与「回到顶部」按钮共用的滚动控制器。
@Riverpod(keepAlive: true)
ScrollController homeScrollController(Ref ref) {
  final ScrollController controller = ScrollController();
  ref.onDispose(controller.dispose);
  return controller;
}

/// 首页列表是否已经滚过阈值，用来决定是否显示「回到顶部」按钮。
@Riverpod(keepAlive: true)
class HomeBackToTopVisibility extends _$HomeBackToTopVisibility {
  @override
  bool build() => false;

  void setVisible(bool value) {
    if (state == value) {
      return;
    }
    state = value;
  }
}
