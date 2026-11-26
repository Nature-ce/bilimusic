import 'dart:async';

import 'package:bilimusic/core/app/app_foreground.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'player_progress_provider.g.dart';

typedef PlayerProgressSnapshot = ({
  Duration position,
  Duration? duration,
  bool isReady,
});

@Riverpod(keepAlive: true)
Stream<PlayerProgressSnapshot> playerProgress(Ref ref) {
  final StreamController<PlayerProgressSnapshot> controller =
      StreamController<PlayerProgressSnapshot>.broadcast(sync: true);
  Timer? timer;
  void emitCurrentSnapshot() {
    if (controller.isClosed) {
      return;
    }

    final PlayerState state = ref.read(playerControllerProvider);
    controller.add((
      position: state.position,
      duration: state.duration,
      isReady: state.isReady,
    ));
  }

  void syncTimer() {
    final bool foreground = ref.read(appForegroundProvider);
    if (!foreground) {
      timer?.cancel();
      timer = null;
      return;
    }
    if (timer != null) {
      return;
    }
    emitCurrentSnapshot();
    timer = Timer.periodic(const Duration(milliseconds: 250), (_) {
      emitCurrentSnapshot();
    });
  }

  syncTimer();
  ref.listen<bool>(appForegroundProvider, (_, _) => syncTimer());

  ref.onDispose(() {
    timer?.cancel();
    unawaited(controller.close());
  });

  return controller.stream;
}
