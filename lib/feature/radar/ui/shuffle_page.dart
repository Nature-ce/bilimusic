import 'dart:async';
import 'dart:math';

import 'package:bilimusic/core/theme/app_design.dart';
import 'package:bilimusic/feature/home/domain/hot_playlist_track.dart';
import 'package:bilimusic/feature/home/logic/music_chart_resolver.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/domain/queue_source.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:bilimusic/feature/player/logic/utils/player_state_selectors.dart';
import 'package:bilimusic/feature/player/ui/player_page.dart';
import 'package:bilimusic/feature/radar/domain/music_radar_state.dart';
import 'package:bilimusic/feature/radar/domain/radar_pick.dart';
import 'package:bilimusic/feature/radar/logic/music_radar_controller.dart';
import 'package:bilimusic/feature/radar/logic/radar_pick_reasons.dart';
import 'package:bilimusic/feature/radar/logic/radar_refresh_requests.dart';
import 'package:bilimusic/feature/radar/ui/components/music_radar_visual.dart';
import 'package:bilimusic/router/util/shell_location.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 进入刷歌时一次先装几首（越少启动越快）。
@visibleForTesting
const int kShuffleInitialBatchSize = 3;

/// 之后每次补货的曲目数区间。
@visibleForTesting
const int kShuffleMinRefill = 5;
@visibleForTesting
const int kShuffleMaxRefill = 8;

/// 每次补货在 [kShuffleMinRefill] ~ [kShuffleMaxRefill] 之间随机。
@visibleForTesting
int shuffleRefillCount(Random random) =>
    kShuffleMinRefill +
    random.nextInt(kShuffleMaxRefill - kShuffleMinRefill + 1);

/// 是否该给刷歌队列补货。
///
/// 只有当队列确实属于刷歌、并且「当前已是最后一首」（剩余 < [lead]）时才补，
/// 这样既能一直续上，又不会一次塞太多歌。
@visibleForTesting
bool shouldTopUpShuffleQueue({
  required String? sourceLabel,
  required int queueLength,
  required int? currentIndex,
  required int lead,
  String queueLabel = autoFeedQueueSourceLabel,
}) {
  if (!(sourceLabel ?? '').startsWith(queueLabel)) {
    return false;
  }
  final int index = currentIndex ?? 0;
  final int remaining = queueLength - index - 1;
  return remaining < lead;
}

/// 刷歌：本质上就是播放页，只是把队列换成「跨平台推荐歌曲」。
///
/// 一次只装 [_batchSize] 首进队列；播到最后一首时自动再补一批，
/// 这样既能一直刷下去，又不会一次性把播放列表塞满。
class ShufflePage extends ConsumerStatefulWidget {
  const ShufflePage({super.key});

  @override
  ConsumerState<ShufflePage> createState() => _ShufflePageState();
}

class _ShufflePageState extends ConsumerState<ShufflePage> {
  /// 队列前方剩余不足这么多首时补货（等于「播到最后一首」附近）。
  static const int _bufferAhead = 2;

  final Random _random = Random();

  /// 本次补货要补几首（5~8 随机）。
  int get _refillCount => shuffleRefillCount(_random);

  /// 预取缓存的目标长度，够一次最大补货量，补货时能瞬间入队。
  static const int _pendingTarget = kShuffleMaxRefill;

  /// 同时并发解析几首（每首都要搜一次 B 站，串行太慢）。
  static const int _resolveConcurrency = 3;

  /// 已经尝试匹配过的推荐曲目，避免重复搜索同一首失败歌。
  final Set<String> _attemptedTrackKeys = <String>{};

  /// 已经解析好、还没入队的条目，用来让补货瞬间完成。
  final List<PlayableItem> _pending = <PlayableItem>[];

  Future<void>? _prefetchFuture;
  bool _isBootstrapping = false;
  bool _isToppingUp = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_ensureShuffleQueue().then((_) => _startPlaybackIfNeeded()));
    });
  }

  bool get _queueIsShuffle {
    final PlayerState player = ref.read(playerControllerProvider);
    return isAutoFeedQueue(player.queueSourceLabel) &&
        player.currentItem != null;
  }

  /// 刷歌是顺序补货的队列，随机播放会让播放顺序和补货逻辑对不上。
  void _ensureSequentialQueueMode({bool always = false}) {
    final PlayerQueueMode mode = ref.read(playerControllerProvider).queueMode;
    if (mode == PlayerQueueMode.sequence) {
      return;
    }
    if (!always && mode != PlayerQueueMode.shuffle) {
      return;
    }
    ref
        .read(playerControllerProvider.notifier)
        .setQueueMode(PlayerQueueMode.sequence);
  }

  /// 进入刷歌时确保真的开始播：队列有了但停在 0:00 / 暂停时补一次 play。
  Future<void> _startPlaybackIfNeeded() async {
    final PlayerState player = ref.read(playerControllerProvider);
    if (!isAutoFeedQueue(player.queueSourceLabel) ||
        player.currentItem == null ||
        player.isPlaying ||
        player.position > Duration.zero) {
      return;
    }
    await ref.read(playerControllerProvider.notifier).play();
  }

  Future<void> _ensureShuffleQueue({bool force = false}) async {
    if (_isBootstrapping) {
      return;
    }
    if (!force && _queueIsShuffle) {
      // 已有刷歌队列，只需保证后面还有歌可播。
      _ensureSequentialQueueMode();
      unawaited(_topUpIfNeeded());
      return;
    }
    setState(() {
      _isBootstrapping = true;
      _errorMessage = null;
    });
    if (force) {
      _attemptedTrackKeys.clear();
      _pending.clear();
    }
    try {
      final List<PlayableItem> items = await _fillBatchWithRetry(
        kShuffleInitialBatchSize,
      );
      if (!mounted) {
        return;
      }
      if (items.isEmpty) {
        setState(() => _errorMessage = '推荐歌曲暂时都没匹配到 B 站视频，换个批次再试');
        return;
      }
      await ref
          .read(playerControllerProvider.notifier)
          .setQueue(
            items,
            startIndex: 0,
            sourceLabel: autoFeedQueueSourceLabel,
          );
      _ensureSequentialQueueMode(always: true);
      // setQueue 默认会起播；但页面可能还没可见导致起播被拦，这里补一脚。
      await _startPlaybackIfNeeded();
      // 队列建好后立刻在后台预取下一批，快速切歌时补货可以瞬间完成。
      unawaited(_ensurePrefetched());
    } on Object {
      if (mounted) {
        setState(() => _errorMessage = '刷歌启动失败，请重试');
      }
    } finally {
      if (mounted) {
        setState(() => _isBootstrapping = false);
      }
    }
  }

  /// 换一批：重新扫一遍候选池按最新口味挑，再把队列换掉。
  Future<void> _refreshRadarFeed() async {
    if (_isBootstrapping) {
      return;
    }
    await ref.read(musicRadarControllerProvider.notifier).scan();
    if (!mounted) {
      return;
    }
    await _ensureShuffleQueue(force: true);
  }

  /// 解析一批；候选都被过滤掉时清空已试集合 + 重新扫一批再试一次。
  Future<List<PlayableItem>> _fillBatchWithRetry(int want) async {
    List<PlayableItem> items = await _fillBatch(want);
    if (items.isNotEmpty || _attemptedTrackKeys.isEmpty || !mounted) {
      return items;
    }
    _attemptedTrackKeys.clear();
    await ref.read(musicRadarControllerProvider.notifier).scan();
    if (!mounted) {
      return const <PlayableItem>[];
    }
    items = await _fillBatch(want);
    return items;
  }

  /// 从推荐流里持续解析出 [want] 首可播放条目。
  ///
  /// 匹配失败的曲目会计入 [_attemptedTrackKeys] 不再重试；候选不够时向
  /// 推荐控制器要更多曲目，必要时整批重扫。解析是并发跑的（每首都要搜一次
  /// B 站，串行太慢）。
  Future<List<PlayableItem>> _fillBatch(int want) async {
    final MusicChartResolver resolver = ref.read(musicChartResolverProvider);
    final List<PlayableItem> items = <PlayableItem>[];
    final Set<String> pickedIds = <String>{
      ...ref
          .read(playerControllerProvider)
          .queue
          .map((PlayableItem item) => item.stableId),
      ..._pending.map((PlayableItem item) => item.stableId),
    };
    bool rescanned = false;

    for (
      int round = 0;
      round < 6 && items.length < want && mounted;
      round += 1
    ) {
      final MusicRadarController radarController = ref.read(
        musicRadarControllerProvider.notifier,
      );
      final MusicRadarState radar = ref.read(musicRadarControllerProvider);
      List<HotPlaylistTrack> candidates = _freshCandidates(radar);
      if (candidates.isEmpty) {
        if (radar.tracks.isEmpty && !rescanned) {
          rescanned = true;
          await radarController.scan();
        } else {
          await radarController.extendFeed();
        }
        if (!mounted) {
          return items;
        }
        candidates = _freshCandidates(ref.read(musicRadarControllerProvider));
        if (candidates.isEmpty) {
          break;
        }
      }
      await _resolveCandidates(
        resolver,
        candidates,
        reasons: _reasonsByTrackKey(ref.read(musicRadarControllerProvider)),
        want: want - items.length,
        pickedIds: pickedIds,
        sink: items,
      );
    }
    return items;
  }

  Map<String, RadarPick> _reasonsByTrackKey(MusicRadarState radar) {
    return <String, RadarPick>{
      for (final RadarPick pick in radar.picks) pick.key: pick,
    };
  }

  /// 并发解析候选（最多 [_resolveConcurrency] 路），成功且不重复的收进 [sink]。
  Future<void> _resolveCandidates(
    MusicChartResolver resolver,
    List<HotPlaylistTrack> candidates, {
    required Map<String, RadarPick> reasons,
    required int want,
    required Set<String> pickedIds,
    required List<PlayableItem> sink,
  }) async {
    if (want <= 0 || candidates.isEmpty) {
      return;
    }
    int next = 0;

    Future<void> worker() async {
      while (mounted && sink.length < want && next < candidates.length) {
        final HotPlaylistTrack track = candidates[next];
        next += 1;
        if (!_attemptedTrackKeys.add(track.key)) {
          continue;
        }
        PlayableItem? item;
        try {
          item = await resolver.resolve(track);
        } on Object {
          item = null;
        }
        if (item == null || sink.length >= want) {
          continue;
        }
        if (!pickedIds.add(item.stableId)) {
          continue;
        }
        final RadarPick? pick = reasons[track.key];
        sink.add(item);
        if (pick == null) {
          continue;
        }
        ref.read(radarPickReasonsProvider.notifier).record(item, pick);
      }
    }

    final int workerCount = _resolveConcurrency < candidates.length
        ? _resolveConcurrency
        : candidates.length;
    await Future.wait(<Future<void>>[
      for (int index = 0; index < workerCount; index += 1) worker(),
    ]);
  }

  List<HotPlaylistTrack> _freshCandidates(MusicRadarState radar) {
    return radar.tracks
        .where(
          (HotPlaylistTrack track) => !_attemptedTrackKeys.contains(track.key),
        )
        .toList(growable: false);
  }

  /// 队列前方剩余不足 [_bufferAhead] 首时补货，保证「下一首」永远有歌。
  ///
  /// 先拿预取缓存（立刻入队），不够再现场解析；不管这次要不要补，都会顺手把
  /// 预取缓存补满，这样快速连点下一首也不会绕回第一首。
  Future<void> _topUpIfNeeded({bool force = false}) async {
    final PlayerState player = ref.read(playerControllerProvider);
    if (!isAutoFeedQueue(player.queueSourceLabel)) {
      return;
    }
    final bool isShort =
        force ||
        shouldTopUpShuffleQueue(
          sourceLabel: player.queueSourceLabel,
          queueLength: player.queue.length,
          currentIndex: player.currentQueueIndex,
          lead: _bufferAhead,
        );
    if (isShort) {
      final int want = _refillCount;
      final int fromPending = await _appendFromPending(limit: want);
      final int missing = want - fromPending;
      if (missing > 0 && !_isToppingUp) {
        _isToppingUp = true;
        try {
          final List<PlayableItem> items = await _fillBatchWithRetry(missing);
          if (mounted && items.isNotEmpty) {
            await ref.read(playerControllerProvider.notifier).enqueue(items);
          }
        } on Object {
          // 补货失败不打断当前播放，等下次切歌再试。
        } finally {
          _isToppingUp = false;
        }
      }
    }
    unawaited(_ensurePrefetched());
  }

  /// 把预取缓存补进队列，最多 [limit] 首；缓存空的话先等一次预取。
  Future<int> _appendFromPending({required int limit}) async {
    if (_pending.isEmpty) {
      await _ensurePrefetched();
    }
    if (_pending.isEmpty || !mounted) {
      return 0;
    }
    final PlayerState player = ref.read(playerControllerProvider);
    if (!isAutoFeedQueue(player.queueSourceLabel)) {
      return 0;
    }
    final int take = limit < _pending.length ? limit : _pending.length;
    final List<PlayableItem> items = List<PlayableItem>.of(_pending.take(take));
    _pending.removeRange(0, take);
    await ref.read(playerControllerProvider.notifier).enqueue(items);
    return items.length;
  }

  /// 保证后台预取在跑（已在跑就复用它）。
  Future<void> _ensurePrefetched() {
    final Future<void>? running = _prefetchFuture;
    if (running != null) {
      return running;
    }
    final Future<void> future = _prefetchOnce();
    _prefetchFuture = future;
    return future.whenComplete(() {
      if (identical(_prefetchFuture, future)) {
        _prefetchFuture = null;
      }
    });
  }

  Future<void> _prefetchOnce() async {
    if (!mounted || _pending.length >= _pendingTarget) {
      return;
    }
    try {
      final List<PlayableItem> items = await _fillBatch(
        _pendingTarget - _pending.length,
      );
      if (!mounted || items.isEmpty) {
        return;
      }
      _pending.addAll(items);
    } on Object {
      // 预取失败无所谓，下次切歌再试。
    }
  }

  @override
  Widget build(BuildContext context) {
    // 刷歌页只看队列来源和当前曲目，不需要播放进度：去掉 position 后
    // 不会随着进度每秒重建。
    final PlayerState player = ref.watch(
      playerControllerProvider.select(withoutPlaybackPosition),
    );

    ref.listen<PlayerState>(playerControllerProvider, (
      PlayerState? previous,
      PlayerState next,
    ) {
      final bool indexChanged =
          next.currentQueueIndex != previous?.currentQueueIndex;
      final bool queueChanged = next.queue.length != previous?.queue.length;
      if (indexChanged || queueChanged) {
        unawaited(_topUpIfNeeded());
      }
    });

    // 从别的 tab 重新切回刷歌：如果期间播放队列已经被别的歌单占掉，
    // 就重新拉一批推荐并开播（indexedStack 下 initState 不会重跑）。
    ref.listen<int>(radarRefreshRequestsProvider, (int? previous, int next) {
      if (previous == null || previous == next) {
        return;
      }
      unawaited(_refreshRadarFeed());
    });

    ref.listen<String>(shellLocationProvider, (String? previous, String next) {
      if (previous == next || next != shuffleTabLocation) {
        return;
      }
      unawaited(_ensureShuffleQueue().then((_) => _startPlaybackIfNeeded()));
    });

    // 已经装好刷歌队列才显示播放页；否则（包括队列还是别的歌单、或启动失败）
    // 都显示「正在挑歌 / 重新取样」，避免把上一首别的队列的歌当成刷歌。
    final bool onShuffleQueue = isAutoFeedQueue(player.queueSourceLabel);
    if (!onShuffleQueue || player.currentItem == null) {
      if (_isBootstrapping) {
        return _ShuffleStatus(
          title: '正在为你挑歌',
          message: '从网易云 / QQ音乐 / 酷狗的热门歌单里随机发现…',
          isLoading: true,
          onExit: _exitToHome,
        );
      }
      return _ShuffleStatus(
        title: _errorMessage == null ? '暂无歌曲' : '刷歌暂时没有发现',
        message: _errorMessage ?? '点下面的按钮重新取样',
        actionLabel: '重新取样',
        onAction: () => unawaited(_ensureShuffleQueue(force: true)),
        onExit: _exitToHome,
      );
    }

    return PlayerPage(
      embedded: true,
      onExit: _exitToHome,
      bottomInset: AppSpacing.xl,
    );
  }

  void _exitToHome() {
    GoRouter.maybeOf(context)?.go(_homeRoutePath);
  }
}

const String _homeRoutePath = '/home';

class _ShuffleStatus extends StatelessWidget {
  const _ShuffleStatus({
    required this.title,
    required this.message,
    required this.onExit,
    this.isLoading = false,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String message;
  final VoidCallback onExit;
  final bool isLoading;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF15100E),
      child: Stack(
        children: <Widget>[
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (isLoading) ...<Widget>[
                  const MusicRadarVisual(scanning: true, size: 148),
                  const SizedBox(height: AppSpacing.xl),
                ],
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xxxl,
                  ),
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: Color(0xB3FFFFFF),
                    ),
                  ),
                ),
                if (actionLabel != null) ...<Widget>[
                  const SizedBox(height: AppSpacing.xl),
                  FilledButton(onPressed: onAction, child: Text(actionLabel!)),
                ],
              ],
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                tooltip: '返回首页',
                onPressed: onExit,
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
