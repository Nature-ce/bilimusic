import 'package:audio_service/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final Provider<AppAudioHandler> appAudioHandlerProvider =
    Provider<AppAudioHandler>((Ref ref) {
      return PlayerAudioService.handler;
    });

abstract interface class PlayerCommandTarget {
  Future<void> play();
  Future<void> pause();
  Future<void> stop();
  Future<void> seek(Duration position);
  Future<void> skipToNext();
  Future<void> skipToPrevious();
}

class PlayerAudioService {
  PlayerAudioService._();

  /// 通知栏小图标。
  ///
  /// 不设置的话 audio_service 默认取 `mipmap/ic_launcher`，而项目里那个文件还是
  /// Flutter 模板图标（真正的应用图标是 `mipmap/launcher_icon`），通知上会显示
  /// 一个 Flutter 图标。这里改用单色的音符图标，和系统状态栏风格一致。
  static const String androidNotificationIcon = 'drawable/ic_stat_music';

  static AppAudioHandler? _handler;

  static AppAudioHandler get handler {
    final AppAudioHandler? handler = _handler;
    if (handler == null) {
      throw StateError('PlayerAudioService has not been initialized.');
    }
    return handler;
  }

  static Future<void> initialize() async {
    if (_handler != null) {
      return;
    }

    final AudioHandler audioHandler = await AudioService.init(
      builder: AppAudioHandler.new,
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.example.bilimusic.channel.audio',
        androidNotificationChannelName: 'Bilimusic Playback',
        androidNotificationIcon: androidNotificationIcon,
        // 暂停时不要停掉前台服务：否则通知会消失、进程降级成缓存进程，
        // 后台被系统回收后就只能重新打开 App 才能继续播。
        androidStopForegroundOnPause: false,
        androidNotificationOngoing: false,
      ),
    );

    _handler = audioHandler as AppAudioHandler;
  }
}

class AppAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  PlayerCommandTarget? _target;

  void attachTarget(PlayerCommandTarget target) {
    _target = target;
  }

  void detachTarget(PlayerCommandTarget target) {
    if (identical(_target, target)) {
      _target = null;
    }
  }

  @override
  Future<void> updateQueue(List<MediaItem> queue) async {
    this.queue.add(List<MediaItem>.unmodifiable(queue));
  }

  void updateCurrentMediaItem(MediaItem? item) {
    mediaItem.add(item);
  }

  void updatePlaybackSnapshot({
    required bool isPlaying,
    required bool isBuffering,
    required bool hasPrevious,
    required bool hasNext,
    required Duration position,
    required Duration bufferedPosition,
    required int? queueIndex,
    required double speed,
    required AudioProcessingState processingState,
  }) {
    // 不再放 MediaControl.stop：系统通知上它的图标解析不出来（真机渲染成空白
    // 方块，点一下就结束播放），而通知滑走 / 系统控件已经能停止播放。
    // systemActions 里保留 MediaAction.stop，外部控制器仍可停止。
    final List<MediaControl> controls = <MediaControl>[
      if (hasPrevious) MediaControl.skipToPrevious,
      isPlaying ? MediaControl.pause : MediaControl.play,
      if (hasNext) MediaControl.skipToNext,
    ];

    playbackState.add(
      PlaybackState(
        controls: controls,
        systemActions: const <MediaAction>{
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
          MediaAction.play,
          MediaAction.pause,
          MediaAction.skipToNext,
          MediaAction.skipToPrevious,
        },
        androidCompactActionIndices: _compactActionIndices(controls),
        processingState: processingState,
        playing: isPlaying,
        updatePosition: position,
        bufferedPosition: bufferedPosition,
        speed: speed,
        queueIndex: queueIndex,
      ),
    );
  }

  List<int> _compactActionIndices(List<MediaControl> controls) {
    final List<int> indices = <int>[];
    for (int index = 0; index < controls.length; index++) {
      final MediaAction action = controls[index].action;
      if (action == MediaAction.skipToPrevious ||
          action == MediaAction.play ||
          action == MediaAction.pause ||
          action == MediaAction.skipToNext) {
        indices.add(index);
      }
    }
    return indices.take(3).toList(growable: false);
  }

  @override
  Future<void> play() async {
    final PlayerCommandTarget? target = _target;
    if (target == null) {
      return;
    }
    await target.play();
  }

  @override
  Future<void> pause() async {
    final PlayerCommandTarget? target = _target;
    if (target == null) {
      return;
    }
    await target.pause();
  }

  @override
  Future<void> stop() async {
    final PlayerCommandTarget? target = _target;
    if (target == null) {
      return;
    }
    await target.stop();
  }

  @override
  Future<void> seek(Duration position) async {
    final PlayerCommandTarget? target = _target;
    if (target == null) {
      return;
    }
    await target.seek(position);
  }

  @override
  Future<void> skipToNext() async {
    final PlayerCommandTarget? target = _target;
    if (target == null) {
      return;
    }
    await target.skipToNext();
  }

  @override
  Future<void> skipToPrevious() async {
    final PlayerCommandTarget? target = _target;
    if (target == null) {
      return;
    }
    await target.skipToPrevious();
  }
}

AudioProcessingState mapAudioProcessingState(String processingStateName) {
  return switch (processingStateName) {
    'idle' => AudioProcessingState.idle,
    'loading' => AudioProcessingState.loading,
    'buffering' => AudioProcessingState.buffering,
    'ready' => AudioProcessingState.ready,
    'completed' => AudioProcessingState.completed,
    _ => AudioProcessingState.idle,
  };
}
