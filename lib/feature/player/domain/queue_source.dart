/// 自动补货队列（刷歌）的来源标签。
///
/// 这类队列由上游持续补充曲目，播放顺序必须保持顺序，不接受随机播放。
const String autoFeedQueueSourceLabel = '刷歌';

/// 判断一个队列是否来自自动补货（刷歌）。
bool isAutoFeedQueue(String? sourceLabel) {
  return (sourceLabel ?? '').startsWith(autoFeedQueueSourceLabel);
}
