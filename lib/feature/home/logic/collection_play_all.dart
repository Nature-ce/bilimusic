import 'package:bilimusic/feature/home/domain/matchable_track.dart';
import 'package:bilimusic/feature/home/logic/music_chart_resolver.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:bilimusic/common/util/player_util.dart';
import 'package:bilimusic/common/util/toast_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef CollectionStartPlayback =
    Future<void> Function(
      BuildContext context,
      WidgetRef ref,
      List<PlayableItem> items,
      String sourceLabel,
    );

/// 一键播放：先把前几首解析成 B 站视频就开播，剩下边解析边补队列。
///
/// 榜单与热门歌单的曲目都要先搜 B 站，共用这一套节奏；
/// [onProgress] 用于把「匹配中 x/y」回传给按钮。
class CollectionPlayAllRunner {
  const CollectionPlayAllRunner({
    required this.context,
    required this.ref,
    required this.sourceLabel,
    this.onProgress,
    this.startPlayback,
    this.isActive,
  });

  static const int _startSize = 5;
  static const int _batchSize = 5;

  final BuildContext context;
  final WidgetRef ref;
  final String sourceLabel;
  final void Function(int resolved, int total)? onProgress;
  final CollectionStartPlayback? startPlayback;
  final bool Function()? isActive;

  bool get _alive => isActive?.call() ?? true;

  Future<void> run(List<MatchableTrack> tracks) async {
    if (tracks.isEmpty) {
      return;
    }
    final MusicChartResolver resolver = ref.read(musicChartResolverProvider);
    final PlayerController player = ref.read(playerControllerProvider.notifier);
    final List<PlayableItem> resolved = <PlayableItem>[];
    final Set<String> seen = <String>{};
    int queued = 0;
    bool started = false;

    try {
      for (final MatchableTrack track in tracks) {
        if (!_alive) {
          break;
        }
        PlayableItem? item;
        try {
          item = await resolver.resolve(track);
        } on Object {
          item = null;
        }
        if (item != null && seen.add(item.stableId)) {
          resolved.add(item);
        }
        onProgress?.call(resolved.length, tracks.length);
        if (!started && resolved.length >= _startSize) {
          started = true;
          await _start(resolved);
          player.setQueueMode(PlayerQueueMode.sequence);
          queued = resolved.length;
        } else if (started && resolved.length - queued >= _batchSize) {
          await player.enqueue(resolved.sublist(queued));
          queued = resolved.length;
        }
      }

      if (!started && resolved.isNotEmpty) {
        started = true;
        await _start(resolved);
        player.setQueueMode(PlayerQueueMode.sequence);
        queued = resolved.length;
      }
      if (started && resolved.length > queued) {
        await player.enqueue(resolved.sublist(queued));
      } else if (!started) {
        ToastUtil.show('没有匹配到可播放的 B 站视频');
      }
    } on Object {
      ToastUtil.show('一键播放失败，请稍后再试');
    }
  }

  Future<void> _start(List<PlayableItem> items) async {
    if (!_alive) {
      return;
    }
    final CollectionStartPlayback? custom = startPlayback;
    final List<PlayableItem> snapshot = List<PlayableItem>.of(items);
    if (custom != null) {
      await custom(context, ref, snapshot, sourceLabel);
      return;
    }
    await PlayerUtil.playQueueAndOpenPlayer(
      context,
      ref,
      items: snapshot,
      sourceLabel: sourceLabel,
    );
  }
}
