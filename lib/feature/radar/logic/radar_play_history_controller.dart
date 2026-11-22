import 'dart:async';
import 'dart:math';

import 'package:bilimusic/core/settings/app_settings_store.dart';
import 'package:bilimusic/feature/metadata/domain/metadata.dart';
import 'package:bilimusic/feature/metadata/domain/metadata_state.dart';
import 'package:bilimusic/feature/metadata/logic/metadata_controller.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_event.dart';
import 'package:bilimusic/feature/player/logic/player_event_hub.dart';
import 'package:bilimusic/feature/radar/data/radar_play_history_store.dart';
import 'package:bilimusic/feature/radar/domain/radar_play_record.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'radar_play_history_controller.g.dart';

@riverpod
RadarPlayHistoryStore radarPlayHistoryStore(Ref ref) {
  return RadarPlayHistoryStore(ref.read(appSettingsStoreProvider));
}

/// 记录「你听了什么、听了多久」，供私人雷达算口味。
///
/// 和「最近播放进度」不同，这边保留的是历史记录（歌名 / 歌手 / 听了多久 /
/// 听了几遍），重启后还在，雷达靠它学习口味。
@Riverpod(keepAlive: true)
class RadarPlayHistoryController extends _$RadarPlayHistoryController {
  static const Duration _persistInterval = Duration(seconds: 5);
  static const Duration _minimumPlayed = Duration(seconds: 3);

  late final RadarPlayHistoryStore _store = ref.read(
    radarPlayHistoryStoreProvider,
  );

  StreamSubscription<PlayerEvent>? _subscription;
  PlayableItem? _activeItem;
  int _playedMs = 0;
  int _durationMs = 0;
  int _playCount = 1;
  DateTime _lastPersistAt = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  List<RadarPlayRecord> build() {
    _subscription = ref.read(playerEventHubProvider).events.listen(_onEvent);
    ref.onDispose(() {
      _subscription?.cancel();
    });
    return _store.load();
  }

  Future<void> clear() async {
    if (state.isEmpty) {
      return;
    }
    state = const <RadarPlayRecord>[];
    await _store.save(state);
  }

  void _onEvent(PlayerEvent event) {
    switch (event.type) {
      case PlayerEventType.trackChanged:
        _flush(force: true);
        _begin(event.item, event.duration);
      case PlayerEventType.position:
        if (_activeItem == null) {
          return;
        }
        _playedMs = max(_playedMs, event.position.inMilliseconds);
        _updateDuration(event.duration);
        _flush();
      case PlayerEventType.duration:
        _updateDuration(event.duration);
      case PlayerEventType.seek:
        _playedMs = max(_playedMs, event.position.inMilliseconds);
      case PlayerEventType.completed:
        _updateDuration(event.duration);
        if (_durationMs > 0) {
          _playedMs = max(_playedMs, _durationMs);
        }
        _flush(force: true);
        _activeItem = null;
      case PlayerEventType.playbackState:
        if (!event.isPlaying) {
          _flush(force: true);
        }
      case PlayerEventType.stop:
        _flush(force: true);
    }
  }

  void _updateDuration(Duration? duration) {
    final int durationMs = duration?.inMilliseconds ?? 0;
    if (durationMs > 0) {
      _durationMs = durationMs;
    }
  }

  void _begin(PlayableItem? item, Duration? duration) {
    _activeItem = item;
    _playedMs = 0;
    _durationMs = duration?.inMilliseconds ?? 0;
    if (item == null) {
      return;
    }
    _playCount = (_recordFor(item.stableId)?.playCount ?? 0) + 1;
  }

  void _flush({bool force = false}) {
    final PlayableItem? item = _activeItem;
    if (item == null) {
      return;
    }
    if (!force &&
        DateTime.now().difference(_lastPersistAt) < _persistInterval) {
      return;
    }
    if (_playedMs < _minimumPlayed.inMilliseconds) {
      return;
    }
    _lastPersistAt = DateTime.now();
    final ({String title, String artist}) labels = _labels(item);
    final RadarPlayRecord record = RadarPlayRecord(
      stableId: item.stableId,
      title: labels.title,
      artist: labels.artist,
      playedMs: _playedMs,
      durationMs: _durationMs,
      playCount: _playCount,
      updatedAtMs: DateTime.now().millisecondsSinceEpoch,
    );
    final List<RadarPlayRecord> next = List<RadarPlayRecord>.of(state)
      ..removeWhere(
        (RadarPlayRecord existing) =>
            existing.stableId == record.stableId ||
            existing.trackKey == record.trackKey,
      )
      ..add(record);
    final List<RadarPlayRecord> trimmed = RadarPlayHistoryStore.trim(next);
    state = List<RadarPlayRecord>.unmodifiable(trimmed);
    unawaited(_store.save(trimmed));
  }

  RadarPlayRecord? _recordFor(String stableId) {
    for (final RadarPlayRecord record in state) {
      if (record.stableId == stableId) {
        return record;
      }
    }
    return null;
  }

  /// 歌名 / 歌手优先用匹配到的元信息（真歌手），拿不到才退回 B 站视频信息。
  ({String title, String artist}) _labels(PlayableItem item) {
    final MetadataState metadataState = ref.read(metadataControllerProvider);
    final Metadata? metadata = metadataState.metadata;
    if (metadata != null && metadataState.stableId == item.stableId) {
      final String title = metadata.title?.trim() ?? '';
      final String artist = metadata.artist?.trim() ?? '';
      if (artist.isNotEmpty) {
        return (title: title.isNotEmpty ? title : item.title, artist: artist);
      }
    }
    return (title: item.title, artist: item.author);
  }
}
