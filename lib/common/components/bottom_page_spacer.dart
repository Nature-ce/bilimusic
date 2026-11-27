import 'package:bilimusic/common/util/screen_util.dart';
import 'package:flutter/material.dart';

/// 底部播放栏 / 导航栏需要让出的高度（桌面 shell 下为 0）。
///
/// 移动端 shell 用 `extendBody` 把页面画到底栏后面，[MediaQuery] 的
/// bottom padding 已经是底栏高度；再加 16 留一点呼吸空间。
double bottomPageInset(BuildContext context) {
  if (ScreenUtil.shouldUseDesktopShell(context)) {
    return 0;
  }
  return MediaQuery.paddingOf(context).bottom + 16;
}

class BottomPageSpacer extends StatelessWidget {
  const BottomPageSpacer({super.key});

  @override
  Widget build(BuildContext context) {
    final double inset = bottomPageInset(context);
    if (inset <= 0) {
      return const SizedBox.shrink();
    }
    return SizedBox(height: inset);
  }
}
