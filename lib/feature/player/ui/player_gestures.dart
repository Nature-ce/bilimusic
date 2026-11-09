import 'dart:ui' show Offset;

enum MiniPlayerSwipeAction { none, openPlayer, nextTrack, previousTrack }

abstract final class PlayerGestureMath {
  static const double minSwipeDistance = 40;

  /// 迷你播放器与播放页顶部栏都用原始指针位移判定，
  /// 避免被玻璃按钮的拉伸手势、PageView 的横滑抢走。
  static MiniPlayerSwipeAction miniPlayerSwipe(
    Offset delta, {
    double minDistance = minSwipeDistance,
  }) {
    final bool mostlyVertical = delta.dy.abs() >= delta.dx.abs();
    if (mostlyVertical) {
      if (delta.dy <= -minDistance) {
        return MiniPlayerSwipeAction.openPlayer;
      }
      return MiniPlayerSwipeAction.none;
    }
    if (delta.dx.abs() < minDistance) {
      return MiniPlayerSwipeAction.none;
    }
    return delta.dx < 0
        ? MiniPlayerSwipeAction.nextTrack
        : MiniPlayerSwipeAction.previousTrack;
  }

  static bool pageShouldDismiss(
    Offset delta, {
    double minDistance = minSwipeDistance * 2,
  }) {
    final bool mostlyVertical = delta.dy.abs() >= delta.dx.abs();
    return mostlyVertical && delta.dy >= minDistance;
  }
}
