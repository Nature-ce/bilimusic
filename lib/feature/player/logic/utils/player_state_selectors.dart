import 'package:bilimusic/feature/player/domain/player_state.dart';

/// 去掉播放中高频变化的字段（`position` / `bufferedPosition`）。
///
/// 给「本身不显示进度、却会随 position 每秒变化多次重建」的 widget 用：
///
/// ```dart
/// ref.watch(playerControllerProvider.select(withoutPlaybackPosition));
/// ```
///
/// 除位置外返回的 state 与原状态完全一致，所以渲染结果不变；位置每变一次
/// 都会产生一个「其它字段相同」的 state，Riverpod 比较相等后就不会重建。
PlayerState withoutPlaybackPosition(PlayerState state) {
  if (state.position == Duration.zero &&
      state.bufferedPosition == Duration.zero) {
    return state;
  }
  return state.copyWith(
    position: Duration.zero,
    bufferedPosition: Duration.zero,
  );
}
