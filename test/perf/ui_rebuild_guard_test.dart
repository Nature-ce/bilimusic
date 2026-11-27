import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/utils/player_state_selectors.dart';
import 'package:flutter_test/flutter_test.dart';

/// 性能回归守卫：锁住「播放进度变化不应导致外壳 / 队列面板 / 刷歌页重建」
/// 这条约定。这里不测时间（CI 上会抖动），只测确定性行为。
PlayableItem _item(int index) {
  return PlayableItem(
    aid: index + 1,
    bvid: 'BV$index',
    title: 'song $index',
    author: 'artist $index',
    coverUrl: '',
  );
}

PlayerState _baseState({int queueLength = 200}) {
  final List<PlayableItem> queue = List<PlayableItem>.generate(
    queueLength,
    _item,
  );
  return PlayerState(
    queue: queue,
    currentQueueIndex: 0,
    currentItem: queue.first,
    isPlaying: true,
    duration: const Duration(minutes: 4),
  );
}

void main() {
  test('200 首队列连续 600 次进度 tick，选择结果始终相等（不重建）', () {
    final PlayerState base = _baseState();
    final PlayerState selected = withoutPlaybackPosition(base);

    for (int second = 1; second <= 600; second += 1) {
      final PlayerState tick = base.copyWith(
        position: Duration(seconds: second),
        bufferedPosition: Duration(seconds: second + 8),
      );

      expect(
        withoutPlaybackPosition(tick),
        selected,
        reason: 'position=${second}s 时选择结果发生了变化，外壳会被重建',
      );
    }
  });

  test('去掉进度不会深拷贝队列', () {
    final PlayerState base = _baseState();
    final PlayerState selected = withoutPlaybackPosition(
      base.copyWith(position: const Duration(seconds: 12)),
    );

    // 注意：Freezed 的 list getter 每次访问都会新建 EqualUnmodifiableListView，
    // 所以这里比较的是「元素是否是同一批对象」——这正是「有没有深拷贝」的证据。
    expect(identical(selected.queue.first, base.queue.first), isTrue);
    expect(identical(selected.queue.last, base.queue.last), isTrue);
    expect(identical(selected.currentItem, base.currentItem), isTrue);
    expect(selected.queue.length, base.queue.length);
  });

  test('进度已是零点时返回同一实例（无播放不产生额外分配）', () {
    final PlayerState base = _baseState();

    expect(identical(withoutPlaybackPosition(base), base), isTrue);
  });

  test('切歌与播放状态变化仍然会改变选择结果（不能过度收敛）', () {
    final PlayerState base = _baseState();
    final PlayerState next = base.copyWith(
      currentQueueIndex: 1,
      isPlaying: false,
    );

    expect(withoutPlaybackPosition(base), isNot(withoutPlaybackPosition(next)));
  });
}
