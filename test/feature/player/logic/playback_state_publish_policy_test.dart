import 'package:bilimusic/feature/player/logic/utils/playback_state_publish_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('暂停时不因位置变化补推', () {
    expect(
      PlaybackStatePublishPolicy.shouldPublishPositionChange(
        position: const Duration(minutes: 1),
        lastPublishedPosition: Duration.zero,
        isPlaying: false,
      ),
      isFalse,
    );
  });

  test('播放中同一位置不补推', () {
    expect(
      PlaybackStatePublishPolicy.shouldPublishPositionChange(
        position: const Duration(seconds: 30),
        lastPublishedPosition: const Duration(seconds: 30),
        isPlaying: true,
      ),
      isFalse,
    );
  });

  test('播放中未到补推间隔不补推', () {
    for (final Duration position in <Duration>[
      const Duration(seconds: 1),
      const Duration(seconds: 3),
      const Duration(milliseconds: 4999),
    ]) {
      expect(
        PlaybackStatePublishPolicy.shouldPublishPositionChange(
          position: position,
          lastPublishedPosition: Duration.zero,
          isPlaying: true,
        ),
        isFalse,
        reason: 'position=$position',
      );
    }
  });

  test('播放中跨过补推间隔才补推一次', () {
    expect(
      PlaybackStatePublishPolicy.shouldPublishPositionChange(
        position: PlaybackStatePublishPolicy.resyncInterval,
        lastPublishedPosition: Duration.zero,
        isPlaying: true,
      ),
      isTrue,
    );
    expect(
      PlaybackStatePublishPolicy.shouldPublishPositionChange(
        position: const Duration(seconds: 40),
        lastPublishedPosition: const Duration(seconds: 32),
        isPlaying: true,
      ),
      isTrue,
    );
  });

  test('往回 seek 超过间隔也要补推（锁屏进度需要立刻纠正）', () {
    expect(
      PlaybackStatePublishPolicy.shouldPublishPositionChange(
        position: const Duration(seconds: 5),
        lastPublishedPosition: const Duration(seconds: 30),
        isPlaying: true,
      ),
      isTrue,
    );
  });
}
