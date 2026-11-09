import 'package:bilimusic/feature/player/ui/player_gestures.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('swiping up on the mini player opens the player page', () {
    expect(
      PlayerGestureMath.miniPlayerSwipe(const Offset(0, -120)),
      MiniPlayerSwipeAction.openPlayer,
    );
    expect(
      PlayerGestureMath.miniPlayerSwipe(
        const Offset(10, -PlayerGestureMath.minSwipeDistance),
      ),
      MiniPlayerSwipeAction.openPlayer,
    );
    expect(
      PlayerGestureMath.miniPlayerSwipe(const Offset(0, -20)),
      MiniPlayerSwipeAction.none,
    );
    expect(
      PlayerGestureMath.miniPlayerSwipe(const Offset(0, 120)),
      MiniPlayerSwipeAction.none,
    );
  });

  test('swiping sideways on the mini player changes tracks', () {
    expect(
      PlayerGestureMath.miniPlayerSwipe(const Offset(-120, 8)),
      MiniPlayerSwipeAction.nextTrack,
    );
    expect(
      PlayerGestureMath.miniPlayerSwipe(const Offset(120, -8)),
      MiniPlayerSwipeAction.previousTrack,
    );
    expect(
      PlayerGestureMath.miniPlayerSwipe(const Offset(-10, 0)),
      MiniPlayerSwipeAction.none,
    );
    expect(
      PlayerGestureMath.miniPlayerSwipe(Offset.zero),
      MiniPlayerSwipeAction.none,
    );
  });

  test('a long diagonal drag follows the dominant axis', () {
    expect(
      PlayerGestureMath.miniPlayerSwipe(const Offset(-30, -90)),
      MiniPlayerSwipeAction.openPlayer,
    );
    expect(
      PlayerGestureMath.miniPlayerSwipe(const Offset(-90, -30)),
      MiniPlayerSwipeAction.nextTrack,
    );
  });

  test('swiping down on the player page top bar dismisses it', () {
    expect(PlayerGestureMath.pageShouldDismiss(const Offset(0, 200)), isTrue);
    expect(PlayerGestureMath.pageShouldDismiss(const Offset(12, 90)), isTrue);
    expect(PlayerGestureMath.pageShouldDismiss(const Offset(0, 40)), isFalse);
    expect(PlayerGestureMath.pageShouldDismiss(const Offset(0, -200)), isFalse);
    expect(PlayerGestureMath.pageShouldDismiss(const Offset(200, 60)), isFalse);
    expect(PlayerGestureMath.pageShouldDismiss(Offset.zero), isFalse);
  });
}
