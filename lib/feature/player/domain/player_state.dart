import 'package:bilimusic/feature/player/domain/audio_stream_info.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/playback_chapter.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'player_state.freezed.dart';

enum PlayerQueueMode { sequence, singleRepeat, shuffle }

/// 点「切换播放模式」时的下一个模式。
///
/// [allowShuffle] 为 false 时跳过随机播放（刷歌这种自动补货队列不该随机播，
/// 否则播放顺序和补货逻辑对不上），其它情况保持原来的循环顺序。
PlayerQueueMode nextQueueMode(
  PlayerQueueMode current, {
  bool allowShuffle = true,
}) {
  return switch (current) {
    PlayerQueueMode.sequence => PlayerQueueMode.singleRepeat,
    PlayerQueueMode.singleRepeat =>
      allowShuffle ? PlayerQueueMode.shuffle : PlayerQueueMode.sequence,
    PlayerQueueMode.shuffle => PlayerQueueMode.sequence,
  };
}

enum PlayerStatusHint {
  resolvingAudio,
  connectingStream,
  loadingCache,
  buffering,
  error,
}

@freezed
abstract class PlayerState with _$PlayerState {
  const factory PlayerState({
    PlayableItem? currentItem,
    AudioStreamInfo? audioStream,
    @Default(<PlayableItem>[]) List<PlayableItem> availableParts,
    @Default(<PlaybackChapter>[]) List<PlaybackChapter> chapters,
    @Default(<PlayableItem>[]) List<PlayableItem> queue,
    int? currentQueueIndex,
    String? queueSourceLabel,
    @Default(PlayerQueueMode.sequence) PlayerQueueMode queueMode,
    @Default(false) bool isLoading,
    @Default(false) bool isReady,
    @Default(false) bool isPlaying,
    @Default(false) bool isBuffering,
    @Default(1.0) double volume,
    @Default(1.0) double speed,
    @Default(Duration.zero) Duration position,
    @Default(Duration.zero) Duration bufferedPosition,
    Duration? duration,
    PlayerStatusHint? statusHint,
    String? errorMessage,
  }) = _PlayerState;

  const PlayerState._();

  bool get hasItem => currentItem != null;
  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;
  bool get isSinglePart => availableParts.length <= 1 && chapters.isEmpty;
  bool get hasQueue => queue.isNotEmpty;
  bool get hasActiveQueueIndex =>
      currentQueueIndex != null &&
      currentQueueIndex! >= 0 &&
      currentQueueIndex! < queue.length;
  PlayableItem? get currentQueueItem =>
      hasActiveQueueIndex ? queue[currentQueueIndex!] : null;
  bool get hasPrevious => hasActiveQueueIndex && queue.length > 1;
  bool get hasNext => hasActiveQueueIndex && queue.length > 1;
}
