import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/domain/queue_source.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('nextQueueMode', () {
    test('普通队列按 列表循环 → 单曲循环 → 随机 → 列表循环 轮转', () {
      expect(
        nextQueueMode(PlayerQueueMode.sequence),
        PlayerQueueMode.singleRepeat,
      );
      expect(
        nextQueueMode(PlayerQueueMode.singleRepeat),
        PlayerQueueMode.shuffle,
      );
      expect(nextQueueMode(PlayerQueueMode.shuffle), PlayerQueueMode.sequence);
    });

    test('不允许随机时跳过随机播放', () {
      expect(
        nextQueueMode(PlayerQueueMode.sequence, allowShuffle: false),
        PlayerQueueMode.singleRepeat,
      );
      expect(
        nextQueueMode(PlayerQueueMode.singleRepeat, allowShuffle: false),
        PlayerQueueMode.sequence,
      );
    });

    test('连点也不会切到随机播放', () {
      PlayerQueueMode mode = PlayerQueueMode.sequence;
      for (int index = 0; index < 12; index += 1) {
        mode = nextQueueMode(mode, allowShuffle: false);
        expect(mode, isNot(PlayerQueueMode.shuffle));
      }
    });
  });

  group('isAutoFeedQueue', () {
    test('刷歌来源（含平台后缀）都算自动补货队列', () {
      expect(isAutoFeedQueue('刷歌'), isTrue);
      expect(isAutoFeedQueue('刷歌 · 网易云'), isTrue);
    });

    test('其它来源不算自动补货队列', () {
      expect(isAutoFeedQueue('我喜欢'), isFalse);
      expect(isAutoFeedQueue('热门歌单'), isFalse);
      expect(isAutoFeedQueue(null), isFalse);
      expect(isAutoFeedQueue(''), isFalse);
    });
  });
}
