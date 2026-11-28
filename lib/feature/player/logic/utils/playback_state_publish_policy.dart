/// 什么时候该把播放状态推给系统（MediaSession / 通知栏 / 锁屏）。
///
/// 位置（`position`）在播放中每秒会变好几次，如果每次都推，系统会收到每秒
/// 5~10 次 `setPlaybackState`；而我们的 session 上挂着十几个 controller
/// （SystemUI、MIUI misound、通知监听、蓝牙…），于是变成每秒上百次跨进程回调，
/// 足以把系统音量面板这种短动画拖到掉帧（Redmi K50 实测）。
///
/// 正常做法是：状态变化（播放 / 暂停 / 切歌 / seek）时推一次，位置交给
/// `PlaybackState(position + speed + updateTime)` 让系统自己推算；这里额外每
/// [resyncInterval] 补推一次，兜住不插值的系统，避免通知栏进度冻结。
class PlaybackStatePublishPolicy {
  const PlaybackStatePublishPolicy._();

  /// 播放中补推位置的最小间隔。
  static const Duration resyncInterval = Duration(seconds: 5);

  /// 只是一次位置变化时，是否需要顺带推送一次状态。
  static bool shouldPublishPositionChange({
    required Duration position,
    required Duration lastPublishedPosition,
    required bool isPlaying,
  }) {
    if (!isPlaying) {
      return false;
    }
    final Duration delta = position - lastPublishedPosition;
    return delta.abs() >= resyncInterval;
  }
}
