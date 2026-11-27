import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/utils/player_state_selectors.dart';
import 'package:flutter_test/flutter_test.dart';

const PlayableItem _item = PlayableItem(
  aid: 1,
  bvid: 'BV1',
  title: '晴天',
  author: '周杰伦',
  coverUrl: '',
);

void main() {
  test('去掉播放进度，其它字段保持不变', () {
    const PlayerState state = PlayerState(
      currentItem: _item,
      queue: <PlayableItem>[_item],
      currentQueueIndex: 0,
      isPlaying: true,
      position: Duration(seconds: 42),
      bufferedPosition: Duration(seconds: 60),
      duration: Duration(minutes: 4),
    );

    final PlayerState selected = withoutPlaybackPosition(state);

    expect(selected.position, Duration.zero);
    expect(selected.bufferedPosition, Duration.zero);
    expect(selected.currentItem, _item);
    expect(selected.isPlaying, isTrue);
    expect(selected.duration, const Duration(minutes: 4));
    expect(selected.queue.length, 1);
  });

  test('只有进度变化时，选择结果相等（不会触发重建）', () {
    const PlayerState first = PlayerState(
      currentItem: _item,
      isPlaying: true,
      position: Duration(seconds: 1),
    );
    final PlayerState second = first.copyWith(
      position: const Duration(seconds: 2),
      bufferedPosition: const Duration(seconds: 3),
    );

    expect(withoutPlaybackPosition(first), withoutPlaybackPosition(second));
  });

  test('已经是零点时直接返回同一个实例', () {
    const PlayerState state = PlayerState(currentItem: _item);

    expect(identical(withoutPlaybackPosition(state), state), isTrue);
  });

  test('播放状态变化仍然会体现出来', () {
    const PlayerState playing = PlayerState(
      currentItem: _item,
      isPlaying: true,
      position: Duration(seconds: 30),
    );
    final PlayerState paused = playing.copyWith(isPlaying: false);

    expect(
      withoutPlaybackPosition(playing),
      isNot(withoutPlaybackPosition(paused)),
    );
  });
}
