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

/// 刷歌：本质上就是播放页，只是把队列换成「跨平台推荐歌曲」。
///
/// 进入时取样推荐曲目 → 匹配 B 站条目 → 装进播放队列 → 直接展示完整播放页；
/// 上下滑切换上一首 / 下一首，队列快放完时自动补货。
class ShufflePage extends ConsumerStatefulWidget {
  const ShufflePage({super.key});

  @override
  ConsumerState<ShufflePage> createState() => _ShufflePageState();
}

class _ShufflePageState extends ConsumerState<ShufflePage> {
  static const int _initialBatch = 8;
  static const int _topUpBatch = 4;
  static const int _topUpThreshold = 2;
  static const String _queueLabel = '刷歌';

  bool _isBootstrapping = false;
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
      return;
    }
    setState(() {
      _isBootstrapping = true;
      _errorMessage = null;
    });
    try {
      final MusicRadarController radarController = ref.read(
        musicRadarControllerProvider.notifier,
      );
      MusicRadarState radar = ref.read(musicRadarControllerProvider);
      if (radar.tracks.isEmpty) {
        await radarController.scan();
        radar = ref.read(musicRadarControllerProvider);
      }
      if (radar.tracks.isEmpty) {
        if (mounted) {
          setState(() => _errorMessage = radar.errorMessage ?? '暂时没有推荐歌曲');
        }
        return;
      }
      final List<PlayableItem> items = await _resolveTracks(
        radar.tracks,
        _initialBatch,
      );
      if (!mounted) {
        return;
      }
      if (items.isEmpty) {
        setState(() => _errorMessage = '推荐歌曲都还没匹配到 B 站视频，换个批次再试');
        return;
      }
      await ref
          .read(playerControllerProvider.notifier)
          .setQueue(items, startIndex: 0, sourceLabel: _queueLabel);
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

  Future<List<PlayableItem>> _resolveTracks(
    List<HotPlaylistTrack> tracks,
    int limit,
  ) async {
    final MusicChartResolver resolver = ref.read(musicChartResolverProvider);
    final List<PlayableItem> items = <PlayableItem>[];
    final Set<String> seen = <String>{};
    for (final HotPlaylistTrack track in tracks) {
      if (items.length >= limit) {
        break;
      }
      try {
        final PlayableItem? item = await resolver.resolve(track);
        if (item == null || !seen.add(item.stableId)) {
          continue;
        }
        items.add(item);
      } on Object {
        continue;
      }
    }
    return items;
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
      await controller.skipToNext();
      unawaited(_topUpQueue());
    } else {
      await controller.skipToPrevious();
    }
  }

  /// 队列快放完时补充推荐曲目，让刷歌可以一直往下滑。
  Future<void> _topUpQueue() async {
    final PlayerState player = ref.read(playerControllerProvider);
    final int index = player.currentQueueIndex ?? 0;
    if (player.queue.length - index > _topUpThreshold) {
      return;
    }
    final MusicRadarState radar = ref.read(musicRadarControllerProvider);
    final List<PlayableItem> items = await _resolveTracks(
      radar.tracks,
      _topUpBatch,
    );
    if (!mounted || items.isEmpty) {
      return;
    }
    final Set<String> queued = ref
        .read(playerControllerProvider)
        .queue
        .map((PlayableItem item) => item.stableId)
        .toSet();
    final List<PlayableItem> fresh = items
        .where((PlayableItem item) => !queued.contains(item.stableId))
        .toList(growable: false);
    if (fresh.isEmpty) {
      unawaited(ref.read(musicRadarControllerProvider.notifier).extendFeed());
      return;
    }
    await ref.read(playerControllerProvider.notifier).enqueue(fresh);
    unawaited(ref.read(musicRadarControllerProvider.notifier).extendFeed());
  }

  @override
  Widget build(BuildContext context) {
    final PlayerState player = ref.watch(playerControllerProvider);
    if (player.currentItem == null) {
      if (_isBootstrapping) {
        return const _ShuffleStatus(
          title: '正在为你挑歌',
          message: '从网易云 / QQ音乐 / 酷狗的热门歌单里随机发现…',
          isLoading: true,
        );
      }
      return _ShuffleStatus(
        title: _errorMessage == null ? '暂无歌曲' : '刷歌暂时没有发现',
        message: _errorMessage ?? '点下面的按钮重新取样',
        actionLabel: '重新取样',
        onAction: () => unawaited(_ensureShuffleQueue(force: true)),
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onVerticalDragEnd: _handleVerticalSwipe,
      child: PlayerPage(
        embedded: true,
        bottomInset: MediaQuery.viewPaddingOf(context).bottom + 72,
      ),
    );
  }
}

class _ShuffleStatus extends StatelessWidget {
  const _ShuffleStatus({
    required this.title,
    required this.message,
    this.isLoading = false,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String message;
  final bool isLoading;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF15100E),
      child: Center(
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
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl),
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
    );
  }
}
