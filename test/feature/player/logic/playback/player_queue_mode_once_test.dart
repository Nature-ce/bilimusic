import 'dart:math';

import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/playback/player_queue_manager.dart';
import 'package:flutter_test/flutter_test.dart';

List<PlayableItem> _queue(int length) {
  return List<PlayableItem>.generate(
    length,
    (int index) => PlayableItem(
      aid: index + 1,
      bvid: 'BV$index',
      title: '歌曲 $index',
      author: 'UP',
      coverUrl: '',
    ),
  );
}

void main() {
  test('sequence-once advances in order and stops at the last track', () {
    final PlayerQueueManager manager = PlayerQueueManager(random: Random(1));
    final List<PlayableItem> queue = _queue(3);

    expect(
      manager.resolveNextIndex(
        queue: queue,
        currentIndex: 0,
        mode: PlayerQueueMode.sequenceOnce,
      ),
      1,
    );
    expect(
      manager.resolveNextIndex(
        queue: queue,
        currentIndex: 1,
        mode: PlayerQueueMode.sequenceOnce,
      ),
      2,
    );
    expect(
      manager.resolveNextIndex(
        queue: queue,
        currentIndex: 2,
        mode: PlayerQueueMode.sequenceOnce,
      ),
      isNull,
    );
  });

  test('sequence-once goes back without wrapping around', () {
    final PlayerQueueManager manager = PlayerQueueManager(random: Random(1));
    final List<PlayableItem> queue = _queue(3);

    expect(
      manager.resolvePreviousIndex(
        queue: queue,
        currentIndex: 0,
        mode: PlayerQueueMode.sequenceOnce,
      ),
      isNull,
    );
    expect(
      manager.resolvePreviousIndex(
        queue: queue,
        currentIndex: 2,
        mode: PlayerQueueMode.sequenceOnce,
      ),
      1,
    );
  });
}
