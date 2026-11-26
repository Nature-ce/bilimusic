import 'dart:async';

import 'package:media_kit/media_kit.dart' as media_kit;

class PlayerAudioEngine {
  PlayerAudioEngine() : _player = media_kit.Player() {
    _applyAudioTuning();
    _subscriptions.addAll(<StreamSubscription<dynamic>>[
      _player.stream.playing.listen((_) => _emitPlayerState()),
      _player.stream.buffering.listen((_) => _emitPlayerState()),
      _player.stream.completed.listen((_) => _emitPlayerState()),
    ]);
  }

  // 只调“解复用/缓冲”层面的参数，不碰采样率、位深、声道等音频格式，
  // 因此不影响音质：
  // - vid=no：本应用只放声音，不再解码从未显示的视频帧
  // - cache-secs / demuxer-readahead-secs：多缓冲一段时间，减少弱网下
  //   频繁小包请求带来的无线电唤醒
  // - audio-buffer：给音频输出多一点缓冲，减少欠载与重连
  Future<void> _applyAudioTuning() async {
    final Object? platform = _player.platform;
    if (platform == null) {
      return;
    }
    try {
      // ignore: avoid_dynamic_calls
      final dynamic player = platform;
      await player.setProperty('vid', 'no');
      await player.setProperty('cache', 'yes');
      await player.setProperty('cache-secs', '30');
      await player.setProperty('demuxer-readahead-secs', '30');
      await player.setProperty('audio-buffer', '1.0');
    } on Object {
      // Ignore tuning failures; playback still works with defaults.
    }
  }

  static const Duration _operationTimeout = Duration(seconds: 3);
  static const Duration _disposeDrainDelay = Duration(milliseconds: 280);

  final media_kit.Player _player;
  final StreamController<PlayerEngineState> _playerStateController =
      StreamController<PlayerEngineState>.broadcast();
  final List<StreamSubscription<dynamic>> _subscriptions =
      <StreamSubscription<dynamic>>[];
  bool _hasSource = false;
  bool _isOpening = false;
  bool _disposed = false;
  Future<void>? _disposeFuture;

  bool get isDisposed => _disposed;

  bool get playing => _player.state.playing;
  double get volume => _player.state.volume / 100.0;
  Duration get position => _player.state.position;
  PlayerEngineProcessingState get processingState => _processingState;

  Stream<Duration> get positionStream => _player.stream.position;
  Stream<Duration> get bufferedPositionStream => _player.stream.buffer;
  Stream<Duration?> get durationStream => _player.stream.duration.map(
    (Duration duration) => duration == Duration.zero ? null : duration,
  );
  Stream<PlayerEngineException> get errorStream =>
      _player.stream.error.map(PlayerEngineException.new);
  Stream<double> get volumeStream => _player.stream.volume.map(
    (double volume) => (volume / 100.0).clamp(0.0, 1.0).toDouble(),
  );
  Stream<PlayerEngineState> get playerStateStream =>
      _playerStateController.stream;

  Future<Duration?> setRemoteSource({
    required Uri uri,
    Map<String, String>? headers,
    Duration? initialPosition,
  }) async {
    await _openMedia(
      media_kit.Media(uri.toString(), httpHeaders: headers),
      initialPosition: initialPosition,
    );
    if (_disposed) {
      return null;
    }
    return _durationOrNull;
  }

  Future<Duration?> setFileSource({
    required String filePath,
    Duration? initialPosition,
  }) async {
    await _openMedia(
      media_kit.Media(Uri.file(filePath).toString()),
      initialPosition: initialPosition,
    );
    if (_disposed) {
      return null;
    }
    return _durationOrNull;
  }

  Future<void> play() {
    if (_disposed) {
      return Future<void>.value();
    }
    return _player.play();
  }

  Future<void> pause() {
    if (_disposed) {
      return Future<void>.value();
    }
    return _player.pause();
  }

  Future<void> stop() async {
    if (_disposed) {
      return;
    }
    await _player.stop();
    _hasSource = false;
    _isOpening = false;
    _emitPlayerState();
  }

  Future<void> seek(Duration position) {
    if (_disposed) {
      return Future<void>.value();
    }
    return _player.seek(position);
  }

  Future<void> setVolume(double volume) {
    if (_disposed) {
      return Future<void>.value();
    }
    return _player.setVolume(volume.clamp(0.0, 1.0) * 100.0);
  }

  // 依赖 mpv 的 speed 是 player 级属性（换源不重置），故 open 后不重放速率。
  // ponytail: 若某平台实测换源后回到 1.0x，在 _openMedia 里补一次 setRate。
  Future<void> setRate(double rate) {
    if (_disposed) {
      return Future<void>.value();
    }
    return _player.setRate(rate);
  }

  Future<void> dispose() {
    return _disposeFuture ??= _performDispose();
  }

  Future<void> _performDispose() async {
    if (_disposed) {
      return;
    }
    _disposed = true;
    for (final StreamSubscription<dynamic> subscription in _subscriptions) {
      await subscription.cancel();
    }
    _subscriptions.clear();
    if (!_playerStateController.isClosed) {
      await _playerStateController.close();
    }
    await _waitForOpenToSettle();
    try {
      await _player.setVolume(0).timeout(_operationTimeout);
    } on Object {
      // Ignore volume failures while tearing down.
    }
    try {
      await _player.stop().timeout(_operationTimeout);
    } on Object {
      // Ignore stop failures while tearing down.
    }
    // media_kit 释放 Player 时会立刻 close 掉注册给 mpv 的 Dart 回调，但
    // mpv_terminate_destroy 要 5 秒后才执行；此时 mpv 仍可能从解复用线程回调，
    // 触发 Dart VM 的 “Callback invoked after it has been deleted” 直接 abort。
    // 留一段静默期再释放，让待处理的 wakeup 事件先排空。
    await Future<void>.delayed(_disposeDrainDelay);
    try {
      await _player.dispose().timeout(_operationTimeout);
    } on Object {
      // Ignore player dispose failures.
    }
  }

  Future<void> _waitForOpenToSettle() async {
    final Stopwatch stopwatch = Stopwatch()..start();
    while (_isOpening && stopwatch.elapsed < _operationTimeout) {
      await Future<void>.delayed(const Duration(milliseconds: 20));
    }
  }

  Future<void> _openMedia(
    media_kit.Media media, {
    Duration? initialPosition,
  }) async {
    if (_disposed) {
      return;
    }
    _hasSource = false;
    _isOpening = true;
    _emitPlayerState();
    try {
      await _player.open(media, play: false);
      if (_disposed) {
        return;
      }
      _hasSource = true;
      final Duration? position = initialPosition;
      if (position != null && position > Duration.zero) {
        // 等待音频就绪
        if (_player.state.duration <= Duration.zero) {
          await _player.stream.duration
              .firstWhere((Duration value) => value > Duration.zero)
              .timeout(
                const Duration(seconds: 5),
                onTimeout: () => Duration.zero,
              );
        }
        if (_disposed) {
          return;
        }
        await _player.seek(position);
      }
    } finally {
      _isOpening = false;
      _emitPlayerState();
    }
  }

  Duration? get _durationOrNull {
    final Duration duration = _player.state.duration;
    return duration == Duration.zero ? null : duration;
  }

  PlayerEngineProcessingState get _processingState {
    final media_kit.PlayerState state = _player.state;
    if (_isOpening) {
      return PlayerEngineProcessingState.loading;
    }
    if (state.completed) {
      return PlayerEngineProcessingState.completed;
    }
    if (state.buffering) {
      return PlayerEngineProcessingState.buffering;
    }
    if (!_hasSource) {
      return PlayerEngineProcessingState.idle;
    }
    return PlayerEngineProcessingState.ready;
  }

  void _emitPlayerState() {
    if (_playerStateController.isClosed) {
      return;
    }
    _playerStateController.add(
      PlayerEngineState(
        playing: _player.state.playing,
        processingState: _processingState,
      ),
    );
  }
}

class PlayerEngineState {
  const PlayerEngineState({
    required this.playing,
    required this.processingState,
  });

  final bool playing;
  final PlayerEngineProcessingState processingState;
}

class PlayerEngineException implements Exception {
  const PlayerEngineException(this.message, {this.code});

  final String message;
  final Object? code;

  @override
  String toString() {
    if (code == null) {
      return message;
    }
    return '$message (code: $code)';
  }
}

enum PlayerEngineProcessingState { idle, loading, buffering, ready, completed }

extension PlayerEngineProcessingStateX on PlayerEngineProcessingState {
  bool get isBuffering {
    return this == PlayerEngineProcessingState.loading ||
        this == PlayerEngineProcessingState.buffering;
  }

  bool get isReady {
    return this != PlayerEngineProcessingState.idle &&
        this != PlayerEngineProcessingState.loading;
  }
}
