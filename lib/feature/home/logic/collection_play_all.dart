import 'package:bilimusic/core/bili/session/bili_session.dart';
import 'package:bilimusic/core/bili/session/bili_session_controller.dart';
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

/// 一键播放：先匹配到第一首就起播，剩下的边播边入队。
///
/// 列表超过 [initialQueueSize] 首时只补这么多，之后跟随播放进度按
/// [refillSize] 懒加载，避免对着几百首的歌单一次性打满搜索。
class CollectionPlayAllRunner {
  const CollectionPlayAllRunner({
    required this.context,
    required this.ref,
    required this.sourceLabel,
    this.onProgress,
    this.onInitialFilled,
    this.startPlayback,
    this.isActive,
    this.initialQueueSize = 30,
    this.refillSize = 5,
    this.refillWhenRemaining = 3,
  });

  /// 匹配到第一首就开播。
  static const int _startSize = 1;
  static const int _batchSize = 2;

  final BuildContext context;
  final WidgetRef ref;
  final String sourceLabel;
  final void Function(int resolved, int total)? onProgress;

  /// 首批队列已经补好（或提前失败）时回调一次：页面据此结束「匹配中」状态，
  /// 后续的懒加载补充在后台继续，不再占用按钮状态。
  final void Function()? onInitialFilled;

  final CollectionStartPlayback? startPlayback;
  final bool Function()? isActive;

  /// 一次先补进队列的曲目上限（超过这个数就等其他歌播完再补）。
  final int initialQueueSize;

  /// 每次懒加载补充多少首。
  final int refillSize;

  /// 队列里「当前曲目之后还剩几首」时触发补充。
  final int refillWhenRemaining;

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
    int duplicateCount = 0;
    int errorCount = 0;
    MatchRateLimitedException? rateLimit;
    bool started = false;
    int cursor = 0;

    final int initialLimit = tracks.length > initialQueueSize
        ? initialQueueSize
        : tracks.length;

    try {
      while (cursor < tracks.length && resolved.length < initialLimit) {
        // 只判断业务活性；页面被关掉不影响继续补队列（UI 相关的调用各自判断）。
        if (!_alive) {
          break;
        }
        final MatchableTrack track = tracks[cursor];
        cursor += 1;
        PlayableItem? item;
        try {
          item = track.directItem ?? await resolver.resolve(track);
        } on MatchRateLimitedException catch (error) {
          rateLimit = error;
          break;
        } on Object {
          item = null;
          errorCount += 1;
        }
        if (item != null) {
          if (seen.add(item.stableId)) {
            resolved.add(item);
          } else {
            duplicateCount += 1;
          }
        }
        onProgress?.call(resolved.length, tracks.length);
        if (!started && resolved.length >= _startSize) {
          if (!await _start(resolved)) {
            return;
          }
          started = true;
          player.setQueueMode(PlayerQueueMode.sequence);
          queued = resolved.length;
        } else if (started && resolved.length - queued >= _batchSize) {
          await player.enqueue(resolved.sublist(queued));
          queued = resolved.length;
        }
      }

      if (started && resolved.length > queued) {
        await player.enqueue(resolved.sublist(queued));
        queued = resolved.length;
      }
      if (!started) {
        onInitialFilled?.call();
        final MatchRateLimitedException? limited = rateLimit;
        if (limited != null) {
          ToastUtil.show(_rateLimitMessage(limited.retryAfter));
        } else {
          final bool looksLikeThrottled =
              errorCount > 0 && errorCount >= resolved.length + 1;
          ToastUtil.show(
            looksLikeThrottled ? '搜索太频繁被限流了，稍等一会再试' : '没有匹配到可播放的 B 站视频',
          );
        }
        return;
      }
      if (rateLimit != null) {
        ToastUtil.show('已开始播放，但搜索被限流，队列暂时补到 ${resolved.length} 首');
      }

      // 首批已经补进队列：页面可以收起「匹配中」，剩下的后台慢慢补。
      onInitialFilled?.call();

      // 首批已经补进队列：页面可以收起「匹配中」，剩下的后台慢慢补。
      onInitialFilled?.call();

      final bool hasMore = rateLimit == null && cursor < tracks.length;
      if (hasMore) {
        await _refillAlongPlayback(
          tracks: tracks,
          cursor: cursor,
          resolver: resolver,
          player: player,
          resolved: resolved,
          seen: seen,
          queued: queued,
        );
      }

      final int unmatched = tracks.length - resolved.length;
      if (!hasMore && unmatched > 0 && context.mounted) {
        final String reason = duplicateCount > 0
            ? '其中 $duplicateCount 首匹配到了同一个视频'
            : '没有找到可信的 B 站视频';
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          SnackBar(
            content: Text('已加入 ${resolved.length} 首，$unmatched 首未匹配（$reason）'),
          ),
        );
      }
    } on Object {
      ToastUtil.show('一键播放失败，请稍后再试');
    }
  }

  /// 跟随播放进度懒加载：队列里当前曲目之后不足 [refillWhenRemaining] 首时，
  /// 再匹配 [refillSize] 首补进队列，直到整张歌单都补完。
  Future<void> _refillAlongPlayback({
    required List<MatchableTrack> tracks,
    required int cursor,
    required MusicChartResolver resolver,
    required PlayerController player,
    required List<PlayableItem> resolved,
    required Set<String> seen,
    required int queued,
  }) async {
    int next = cursor;
    int queuedCount = queued;
    while (next < tracks.length) {
      final bool needsRefill = await _waitForRefillWindow(
        player,
        expectedQueue: queuedCount,
      );
      if (!needsRefill) {
        return;
      }
      final int target = resolved.length + refillSize;
      while (next < tracks.length && resolved.length < target) {
        final MatchableTrack track = tracks[next];
        next += 1;
        PlayableItem? item;
        try {
          item = track.directItem ?? await resolver.resolve(track);
        } on MatchRateLimitedException {
          return;
        } on Object {
          item = null;
        }
        if (item == null) {
          continue;
        }
        if (!seen.add(item.stableId)) {
          continue;
        }
        resolved.add(item);
        onProgress?.call(resolved.length, tracks.length);
      }
      if (resolved.length > queuedCount) {
        await player.enqueue(resolved.sublist(queuedCount));
        queuedCount = resolved.length;
      }
    }
  }

  /// 等到「当前曲目之后剩余不多于 [refillWhenRemaining] 首」才补歌。
  ///
  /// [expectedQueue] 是本地认为已经入队的数量：播放器状态可能还没反映最新
  /// 队列长度，这种情况下先等一会儿再判断，否则一次跳转会连补两批。
  Future<bool> _waitForRefillWindow(
    PlayerController player, {
    required int expectedQueue,
  }) async {
    int lagTicks = 0;
    while (_alive) {
      PlayerState state;
      try {
        state = player.sessionState;
      } on Object {
        return false;
      }
      if (!state.hasQueue) {
        return false;
      }
      if (state.queue.length < expectedQueue && lagTicks < 6) {
        lagTicks += 1;
        await Future<void>.delayed(const Duration(milliseconds: 400));
        continue;
      }
      lagTicks = 0;
      final int index = state.currentQueueIndex ?? 0;
      final int remaining = state.queue.length - 1 - index;
      if (remaining <= refillWhenRemaining) {
        return true;
      }
      await Future<void>.delayed(const Duration(seconds: 2));
    }
    return false;
  }

  /// 限流提示带上登录建议：登录后搜索配额更高，更不容易被拦。
  String _rateLimitMessage(Duration retryAfter) {
    bool loggedIn = false;
    try {
      final BiliSession? session = ref.read(biliSessionControllerProvider);
      loggedIn = session?.isLoggedIn ?? false;
    } on Object {
      // 页面已经销毁时 ref 不可用，按游客文案处理即可。
    }
    final String base = '搜索被限流了，约 ${retryAfter.inSeconds} 秒后再试';
    return loggedIn ? '$base（已匹配的不会重复搜）' : '$base；登录 B 站账号可减少限流';
  }

  Future<bool> _start(List<PlayableItem> items) async {
    if (!context.mounted) {
      return false;
    }
    final CollectionStartPlayback? custom = startPlayback;
    final List<PlayableItem> snapshot = List<PlayableItem>.of(items);
    if (custom != null) {
      await custom(context, ref, snapshot, sourceLabel);
      return true;
    }
    await PlayerUtil.playQueueAndOpenPlayer(
      context,
      ref,
      items: snapshot,
      sourceLabel: sourceLabel,
    );
    return true;
  }
}
