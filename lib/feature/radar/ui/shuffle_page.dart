import 'dart:async';

import 'package:bilimusic/core/theme/app_design.dart';
import 'package:bilimusic/feature/home/domain/hot_playlist_track.dart';
import 'package:bilimusic/feature/home/logic/music_chart_resolver.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:bilimusic/feature/radar/domain/music_radar_state.dart';
import 'package:bilimusic/feature/radar/logic/music_radar_controller.dart';
import 'package:bilimusic/feature/radar/ui/components/music_radar_visual.dart';
import 'package:bilimusic/feature/radar/ui/components/shuffle_card.dart';
import 'package:bilimusic/router/util/player_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 刷歌：沉浸式单曲流，上下滑换歌，滑到末尾自动补货。
class ShufflePage extends ConsumerStatefulWidget {
  const ShufflePage({super.key});

  @override
  ConsumerState<ShufflePage> createState() => _ShufflePageState();
}

class _ShufflePageState extends ConsumerState<ShufflePage> {
  static const Duration _autoPlayDelay = Duration(milliseconds: 420);

  final PageController _pageController = PageController();
  final Map<String, PlayableItem> _resolvedItems = <String, PlayableItem>{};

  Timer? _autoPlayTimer;
  int _index = 0;
  int _playGeneration = 0;
  bool _didScheduleInitialPlay = false;

  /// 当前已成功匹配并播放的歌单曲目 key（用于和 B 站条目 stableId 区分）。
  String? _playingKey;
  String? _resolvingKey;
  String? _failedKey;
  String? _failedMessage;

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _handlePageChanged(int index, int total) {
    setState(() => _index = index);
    ref.read(musicRadarControllerProvider.notifier).ensureFeedAt(index);
    _scheduleAutoPlay();
  }

  void _scheduleAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = Timer(_autoPlayDelay, () => unawaited(_playActiveCard()));
  }

  Future<void> _playActiveCard({bool force = false}) async {
    final List<HotPlaylistTrack> tracks = ref
        .read(musicRadarControllerProvider)
        .tracks;
    if (_index < 0 || _index >= tracks.length) {
      return;
    }
    final HotPlaylistTrack track = tracks[_index];
    if (!force && _playingKey == track.key) {
      return;
    }
    final int generation = ++_playGeneration;
    setState(() {
      _resolvingKey = track.key;
      _failedKey = null;
      _failedMessage = null;
    });
    try {
      PlayableItem? item = _resolvedItems[track.key];
      item ??= await ref.read(musicChartResolverProvider).resolve(track);
      if (!mounted || generation != _playGeneration) {
        return;
      }
      if (item == null) {
        setState(() {
          _failedKey = track.key;
          _failedMessage = '没找到匹配的 B 站视频';
        });
        return;
      }
      _resolvedItems[track.key] = item;
      await ref
          .read(playerControllerProvider.notifier)
          .setQueue(
            <PlayableItem>[item],
            startIndex: 0,
            sourceLabel: '刷歌 · ${track.playlist.platform.label}',
          );
      if (mounted && generation == _playGeneration) {
        setState(() => _playingKey = track.key);
      }
    } on Object {
      if (mounted && generation == _playGeneration) {
        setState(() {
          _failedKey = track.key;
          _failedMessage = '匹配失败，请稍后再试';
        });
      }
    } finally {
      if (mounted && generation == _playGeneration) {
        setState(() => _resolvingKey = null);
      }
    }
  }

  Future<void> _handleShuffle() async {
    _autoPlayTimer?.cancel();
    ++_playGeneration;
    _resolvedItems.clear();
    setState(() {
      _index = 0;
      _playingKey = null;
      _resolvingKey = null;
      _failedKey = null;
      _failedMessage = null;
    });
    if (_pageController.hasClients) {
      _pageController.jumpToPage(0);
    }
    await ref.read(musicRadarControllerProvider.notifier).scan();
    if (mounted) {
      _scheduleAutoPlay();
    }
  }

  void _handleTogglePlayback() {
    final List<HotPlaylistTrack> tracks = ref
        .read(musicRadarControllerProvider)
        .tracks;
    final bool onActiveCard =
        _index < tracks.length && _playingKey == tracks[_index].key;
    if (!onActiveCard) {
      unawaited(_playActiveCard(force: true));
      return;
    }
    unawaited(ref.read(playerControllerProvider.notifier).togglePlayback());
  }

  @override
  Widget build(BuildContext context) {
    final MusicRadarState state = ref.watch(musicRadarControllerProvider);
    final PlayerState player = ref.watch(playerControllerProvider);
    final MusicRadarController controller = ref.read(
      musicRadarControllerProvider.notifier,
    );

    ref.listen<MusicRadarState>(musicRadarControllerProvider, (
      MusicRadarState? previous,
      MusicRadarState next,
    ) {
      if (previous?.tracks.isEmpty ?? false) {
        if (next.tracks.isNotEmpty) {
          _scheduleAutoPlay();
        }
      }
    });

    if (state.isScanning && !state.hasResult) {
      return const _ShuffleStatus(
        title: '正在为你挑歌',
        message: '从网易云 / QQ音乐 / 酷狗的热门歌单里随机发现…',
        isLoading: true,
      );
    }
    if (state.hasError && !state.hasResult) {
      return _ShuffleStatus(
        title: '刷歌暂时没有发现',
        message: state.errorMessage,
        actionLabel: '重新扫描',
        onAction: () => unawaited(controller.scan()),
      );
    }
    if (state.isEmpty) {
      return _ShuffleStatus(
        title: '暂无歌曲',
        message: '下拉或点击重新扫描，开始刷歌',
        actionLabel: '重新扫描',
        onAction: () => unawaited(controller.scan()),
      );
    }

    final List<HotPlaylistTrack> tracks = state.tracks;
    final int safeIndex = _index.clamp(0, tracks.length - 1);
    if (!_didScheduleInitialPlay) {
      _didScheduleInitialPlay = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _scheduleAutoPlay();
        }
      });
    }
    final HotPlaylistTrack activeTrack = tracks[safeIndex];
    final bool cardIsPlaying = _playingKey == activeTrack.key;
    final bool activeIsPlaying = cardIsPlaying && player.isPlaying;
    final Duration position = cardIsPlaying ? player.position : Duration.zero;
    final Duration? duration = cardIsPlaying ? player.duration : null;
    final double progress = duration == null || duration <= Duration.zero
        ? 0
        : (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);

    return PageView.builder(
      controller: _pageController,
      scrollDirection: Axis.vertical,
      itemCount: tracks.length,
      onPageChanged: (int index) => _handlePageChanged(index, tracks.length),
      itemBuilder: (BuildContext context, int index) {
        final HotPlaylistTrack track = tracks[index];
        final bool isActive = index == safeIndex;
        return ShuffleCard(
          track: track,
          index: index,
          total: tracks.length,
          isActive: isActive,
          isPlaying: isActive && activeIsPlaying,
          isResolving: isActive && _resolvingKey == track.key,
          progress: isActive ? progress : 0,
          positionText: _formatDuration(position),
          durationText: duration == null ? '' : _formatDuration(duration),
          bottomInset: _bottomInset(context),
          errorMessage: isActive && _failedKey == track.key
              ? _failedMessage
              : null,
          onRetry: () => unawaited(_playActiveCard(force: true)),
          onTogglePlayback: _handleTogglePlayback,
          onOpenPlayer: () => unawaited(openPlayerPage(context)),
          onShuffle: () => unawaited(_handleShuffle()),
        );
      },
    );
  }

  double _bottomInset(BuildContext context) {
    // 底部导航悬浮在内容之上（extendBody），要留出导航高度 + 底部提示的空间。
    return MediaQuery.viewPaddingOf(context).bottom + 104;
  }

  static String _formatDuration(Duration duration) {
    final int minutes = duration.inMinutes.remainder(60);
    final int seconds = duration.inSeconds.remainder(60);
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
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
  final String? message;
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
            if (message != null) ...<Widget>[
              const SizedBox(height: AppSpacing.sm),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xxxl,
                ),
                child: Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: Color(0xB3FFFFFF),
                  ),
                ),
              ),
            ],
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
