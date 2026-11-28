import 'package:audio_service/audio_service.dart';
import 'package:bilimusic/feature/player/logic/media_session/app_audio_handler.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  AppAudioHandler buildHandler({
    required bool isPlaying,
    required bool hasPrevious,
    required bool hasNext,
  }) {
    final AppAudioHandler handler = AppAudioHandler();
    handler.updatePlaybackSnapshot(
      isPlaying: isPlaying,
      isBuffering: false,
      hasPrevious: hasPrevious,
      hasNext: hasNext,
      position: const Duration(seconds: 10),
      bufferedPosition: const Duration(seconds: 20),
      queueIndex: 0,
      speed: 1,
      processingState: AudioProcessingState.ready,
    );
    return handler;
  }

  List<MediaAction> actionsOf(AppAudioHandler handler) {
    return handler.playbackState.value.controls
        .map((MediaControl control) => control.action)
        .toList(growable: false);
  }

  test('通知控制项不再包含 stop（真机上会渲染成空白方块）', () {
    final AppAudioHandler handler = buildHandler(
      isPlaying: true,
      hasPrevious: true,
      hasNext: true,
    );

    expect(actionsOf(handler), <MediaAction>[
      MediaAction.skipToPrevious,
      MediaAction.pause,
      MediaAction.skipToNext,
    ]);
  });

  test('第一首 / 最后一首时仍然只显示可用的按钮', () {
    final AppAudioHandler first = buildHandler(
      isPlaying: true,
      hasPrevious: false,
      hasNext: true,
    );
    expect(actionsOf(first), <MediaAction>[
      MediaAction.pause,
      MediaAction.skipToNext,
    ]);

    final AppAudioHandler last = buildHandler(
      isPlaying: false,
      hasPrevious: true,
      hasNext: false,
    );
    expect(actionsOf(last), <MediaAction>[
      MediaAction.skipToPrevious,
      MediaAction.play,
    ]);
  });

  test('系统动作里也不再声明 stop（MIUI 会据此画出空白方块按钮）', () {
    final AppAudioHandler handler = buildHandler(
      isPlaying: true,
      hasPrevious: true,
      hasNext: true,
    );

    expect(
      handler.playbackState.value.systemActions,
      isNot(contains(MediaAction.stop)),
    );
    expect(
      handler.playbackState.value.systemActions,
      containsAll(<MediaAction>[
        MediaAction.play,
        MediaAction.pause,
        MediaAction.skipToNext,
        MediaAction.skipToPrevious,
        MediaAction.seek,
      ]),
    );
  });

  test('通知小图标指向自带的单色音符，而不是 Flutter 模板图标', () {
    expect(
      PlayerAudioService.androidNotificationIcon,
      'drawable/ic_stat_music',
    );
    expect(
      PlayerAudioService.androidNotificationIcon,
      isNot(contains('ic_launcher')),
    );
  });
}
