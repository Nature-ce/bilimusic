import 'dart:async';

import 'package:bilimusic/core/theme/app_design.dart';
import 'package:bilimusic/feature/home/domain/hot_playlist_track.dart';
import 'package:bilimusic/feature/home/logic/music_chart_resolver.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:bilimusic/feature/player/ui/player_page.dart';
import 'package:bilimusic/feature/radar/domain/music_radar_state.dart';
import 'package:bilimusic/feature/radar/logic/music_radar_controller.dart';
import 'package:bilimusic/feature/radar/ui/components/music_radar_visual.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
  String queueLabel = _shuffleQueueLabel,
}) {
  if (!(sourceLabel ?? '').startsWith(queueLabel)) {
    return false;
  }
  final int index = currentIndex ?? 0;
  final int remaining = queueLength - index - 1;
  return remaining < lead;
}

const String _shuffleQueueLabel = '刷歌';

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
  /// 每次补货的曲目数。
  static const int _batchSize = 5;

  /// 剩余未播曲目不足这个数就补货（1 表示正在播最后一首时补）。
  static const int _topUpLead = 1;

  static const String _queueLabel = '刷歌';

  /// 已经尝试匹配过的推荐曲目，避免重复搜索同一首失败歌。
  final Set<String> _attemptedTrackKeys = <String>{};

  bool _isBootstrapping = false;
  bool _isToppingUp = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_ensureShuffleQueue());
    });
  }

  bool get _queueIsShuffle {
    final PlayerState player = ref.read(playerControllerProvider);
    return (player.queueSourceLabel ?? '').startsWith(_queueLabel) &&
        player.currentItem != null;
  }

  Future<void> _ensureShuffleQueue({bool force = false}) async {
    if (_isBootstrapping) {
      return;
    }
    if (!force && _queueIsShuffle) {
      // 已有刷歌队列，只需保证后面还有歌可播。
      unawaited(_topUpIfNeeded());
      return;
    }
    setState(() {
      _isBootstrapping = true;
      _errorMessage = null;
    });
    if (force) {
      _attemptedTrackKeys.clear();
    }
    try {
      final List<PlayableItem> items = await _fillBatch(_batchSize);
      if (!mounted) {
        return;
      }
      if (items.isEmpty) {
        setState(() => _errorMessage = '推荐歌曲暂时都没匹配到 B 站视频，换个批次再试');
        return;
      }
      await ref
          .read(playerControllerProvider.notifier)
          .setQueue(items, startIndex: 0, sourceLabel: _queueLabel);
      // 队列不足一批时（例如只匹配到 1 首），立刻把后面补齐。
      unawaited(_topUpIfNeeded());
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

  /// 从推荐流里持续解析出 [want] 首可播放条目。
  ///
  /// 匹配失败的曲目会计入 [_attemptedTrackKeys] 不再重试；候选不够时向
  /// 推荐控制器要更多曲目，必要时整批重扫。
  Future<List<PlayableItem>> _fillBatch(int want) async {
    final MusicChartResolver resolver = ref.read(musicChartResolverProvider);
    final List<PlayableItem> items = <PlayableItem>[];
    final Set<String> pickedIds = ref
        .read(playerControllerProvider)
        .queue
        .map((PlayableItem item) => item.stableId)
        .toSet();
    bool rescanned = false;

    for (
      int round = 0;
      round < 6 && items.length < want && mounted;
      round += 1
    ) {
      final MusicRadarController radarController = ref.read(
        musicRadarControllerProvider.notifier,
      );
      MusicRadarState radar = ref.read(musicRadarControllerProvider);
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
      for (final HotPlaylistTrack track in candidates) {
        if (items.length >= want || !mounted) {
          break;
        }
        if (!_attemptedTrackKeys.add(track.key)) {
          continue;
        }
        try {
          final PlayableItem? item = await resolver.resolve(track);
          if (item == null || !pickedIds.add(item.stableId)) {
            continue;
          }
          items.add(item);
        } on Object {
          continue;
        }
      }
    }
    return items;
  }

  List<HotPlaylistTrack> _freshCandidates(MusicRadarState radar) {
    return radar.tracks
        .where(
          (HotPlaylistTrack track) => !_attemptedTrackKeys.contains(track.key),
        )
        .toList(growable: false);
  }

  /// 播到最后一首时补货，保证「下一首」永远有歌。
  Future<void> _topUpIfNeeded({bool force = false}) async {
    if (_isToppingUp) {
      return;
    }
    final PlayerState player = ref.read(playerControllerProvider);
    if (!force &&
        !shouldTopUpShuffleQueue(
          sourceLabel: player.queueSourceLabel,
          queueLength: player.queue.length,
          currentIndex: player.currentQueueIndex,
          lead: _topUpLead,
        )) {
      return;
    }
    if (!(player.queueSourceLabel ?? '').startsWith(_queueLabel)) {
      return;
    }
    _isToppingUp = true;
    try {
      final List<PlayableItem> items = await _fillBatch(_batchSize);
      if (!mounted || items.isEmpty) {
        return;
      }
      await ref.read(playerControllerProvider.notifier).enqueue(items);
    } on Object {
      // 补货失败不打断当前播放，等下次切歌再试。
    } finally {
      _isToppingUp = false;
    }
  }

  Future<void> _handleVerticalSwipe(DragEndDetails details) async {
    final double velocity = details.primaryVelocity ?? 0;
    if (velocity.abs() < 220) {
      return;
    }
    final PlayerController controller = ref.read(
      playerControllerProvider.notifier,
    );
    if (velocity < 0) {
      await _skipToNextWithTopUp(controller);
    } else {
      await controller.skipToPrevious();
    }
  }

  /// 点「下一首」前先确认队列里还有下一首，没有就先把货补上。
  Future<void> _skipToNextWithTopUp(PlayerController controller) async {
    final PlayerState player = ref.read(playerControllerProvider);
    final int index = player.currentQueueIndex ?? 0;
    final bool hasNext = index + 1 < player.queue.length;
    if (!hasNext) {
      await _topUpIfNeeded(force: true);
    }
    await controller.skipToNext();
  }

  @override
  Widget build(BuildContext context) {
    final PlayerState player = ref.watch(playerControllerProvider);

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

    if (player.currentItem == null) {
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

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onVerticalDragEnd: _handleVerticalSwipe,
      child: PlayerPage(
        embedded: true,
        onExit: _exitToHome,
        bottomInset: AppSpacing.xl,
      ),
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
