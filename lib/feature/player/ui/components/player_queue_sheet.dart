import 'package:bilimusic/common/components/desktop/desktop_side_panel.dart';
import 'package:bilimusic/common/components/glass_panel.dart';
import 'package:bilimusic/common/components/queue_mode_icon.dart';
import 'package:bilimusic/common/util/display_text.dart';
import 'package:bilimusic/core/theme/app_design.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:bilimusic/feature/player/ui/components/player_playback_waveform.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

Future<void> showPlayerQueueSheet({
  required BuildContext context,
  required PlayerState state,
  bool glass = true,
}) async {
  if (!state.hasQueue) {
    return;
  }

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: glass ? Colors.transparent : null,
    elevation: 0,
    barrierColor: glass
        ? Colors.transparent
        : Colors.black.withValues(alpha: 0.3),
    clipBehavior: glass ? Clip.none : Clip.antiAlias,
    shape: glass
        ? null
        : const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppRadius.xl),
            ),
          ),
    builder: (BuildContext context) {
      if (!glass) {
        return SafeArea(
          top: false,
          child: const _PlayerQueueSheet(glass: false),
        );
      }
      return GlassPanel(
        settings: playerQueueSheetGlassSettings,
        shape: const LiquidVerticalRoundedSuperellipse(
          topRadius: AppRadius.xl,
          bottomRadius: 0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const GlassDragHandle(tone: GlassTone.smoke),
            Flexible(
              child: SafeArea(top: false, child: const _PlayerQueueSheet()),
            ),
          ],
        ),
      );
    },
  );
}

/// 播放队列弹层的玻璃：比播放页的 smoke 更厚背衬、更少折射，
/// 避免背后的彩色卡片（例如「我的」页顶部绿卡）透出来糊住第一行。
const LiquidGlassSettings playerQueueSheetGlassSettings = LiquidGlassSettings(
  bodyMode: GlassBodyMode.clear,
  glassColor: Color(0x33FFFFFF),
  backerColor: Color(0x94000000),
  thickness: 12,
  blur: 28,
  chromaticAberration: 0,
  saturation: 1.1,
  lightIntensity: 0.5,
  refractiveIndex: 1.06,
);

Future<void> showDesktopPlayerQueuePanel({
  required BuildContext context,
  required PlayerState state,
}) async {
  if (!state.hasQueue) {
    return;
  }

  await showDesktopSidePanel(
    tag: 'player_queue_panel',
    context: context,
    width: 420,
    builder: (BuildContext context) {
      return const SafeArea(
        child: _PlayerQueueContent(closeTarget: _QueueCloseTarget.sidePanel),
      );
    },
  );
}

enum _QueueCloseTarget { navigator, sidePanel }

class _PlayerQueueSheet extends ConsumerWidget {
  const _PlayerQueueSheet({this.glass = true});

  final bool glass;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.72,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (BuildContext context, ScrollController _) {
        final Widget content = _PlayerQueueContent(
          closeTarget: _QueueCloseTarget.navigator,
          tone: glass ? GlassTone.smoke : null,
        );
        if (glass) {
          return content;
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const GlassDragHandle(tone: GlassTone.frost),
            Flexible(child: content),
          ],
        );
      },
    );
  }
}

class _PlayerQueueContent extends ConsumerStatefulWidget {
  const _PlayerQueueContent({required this.closeTarget, this.tone});

  final _QueueCloseTarget closeTarget;

  /// 玻璃弹层里用 [GlassTone] 定的文字色；桌面侧栏为 null，沿用主题色。
  final GlassTone? tone;

  @override
  ConsumerState<_PlayerQueueContent> createState() =>
      _PlayerQueueContentState();
}

class _PlayerQueueContentState extends ConsumerState<_PlayerQueueContent> {
  static const double _estimatedQueueItemExtent = 56;

  late final AutoScrollController _scrollController;
  bool _didFocusInitialItem = false;

  @override
  void initState() {
    super.initState();
    _scrollController = AutoScrollController(
      suggestedRowHeight: _estimatedQueueItemExtent,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final PlayerState liveState = ref.watch(playerControllerProvider);
    final PlayerController liveController = ref.read(
      playerControllerProvider.notifier,
    );
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final GlassTone? tone = widget.tone;
    final Color primaryText = tone?.primaryText ?? colorScheme.onSurface;
    final Color secondaryText =
        tone?.secondaryText ?? colorScheme.onSurfaceVariant;
    final String modeLabel = switch (liveState.queueMode) {
      PlayerQueueMode.sequence => '列表循环',
      PlayerQueueMode.singleRepeat => '单曲循环',
      PlayerQueueMode.shuffle => '随机播放',
    };
    _focusInitialItem(liveState.currentQueueIndex);

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '播放队列',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: primaryText,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${liveState.queue.length} 项 · $modeLabel',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              if (liveState.hasQueue)
                TextButton(
                  style: TextButton.styleFrom(foregroundColor: secondaryText),
                  onPressed: () async {
                    await liveController.clearQueue();
                    if (!context.mounted) {
                      return;
                    }
                    await _close(context);
                  },
                  child: const Text('清空'),
                ),
              if (tone == null)
                IconButton.filledTonal(
                  onPressed: liveState.hasQueue
                      ? liveController.toggleQueueMode
                      : null,
                  icon: queueModeIcon(liveState.queueMode),
                )
              else
                IconButton(
                  onPressed: liveState.hasQueue
                      ? liveController.toggleQueueMode
                      : null,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.14),
                    foregroundColor: primaryText,
                    disabledBackgroundColor: Colors.white.withValues(
                      alpha: 0.06,
                    ),
                  ),
                  icon: queueModeIcon(liveState.queueMode),
                ),
            ],
          ),
        ),
        Expanded(
          child: ReorderableListView.builder(
            scrollController: _scrollController,
            padding: const EdgeInsets.only(bottom: 24),
            itemCount: liveState.queue.length,
            onReorderItem: (int oldIndex, int newIndex) async {
              if (newIndex == oldIndex) {
                return;
              }
              await liveController.reorderQueueItem(oldIndex, newIndex);
            },
            itemBuilder: (BuildContext context, int index) {
              final PlayableItem queuedItem = liveState.queue[index];
              final bool isCurrent = liveState.currentQueueIndex == index;
              final String partTitle = normalizeDisplayTextOrEmpty(
                queuedItem.pageTitle,
              );
              final String itemTitle = normalizeDisplayTextOrEmpty(
                queuedItem.title,
              );
              final String title = partTitle.isEmpty ? itemTitle : partTitle;
              final String subtitle =
                  partTitle.isEmpty || partTitle == itemTitle
                  ? normalizeDisplayTextOrEmpty(queuedItem.author)
                  : itemTitle;

              return AutoScrollTag(
                key: ValueKey<String>('queue-${queuedItem.stableId}'),
                controller: _scrollController,
                index: index,
                child: Semantics(
                  selected: isCurrent,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () async {
                        await _close(context);
                        await liveController.skipToQueueIndex(index);
                      },
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 4, 8, 4),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Text.rich(
                                TextSpan(
                                  text: title,
                                  children: <InlineSpan>[
                                    if (subtitle.isNotEmpty)
                                      TextSpan(
                                        text: ' - $subtitle',
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              color: isCurrent
                                                  ? colorScheme.primary
                                                  : secondaryText,
                                              fontWeight: FontWeight.normal,
                                            ),
                                      ),
                                  ],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: isCurrent
                                      ? colorScheme.primary
                                      : primaryText,
                                  fontWeight: isCurrent
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                            if (isCurrent) ...<Widget>[
                              const SizedBox(width: 8),
                              PlayerPlaybackWaveform(
                                isPlaying:
                                    liveState.isPlaying &&
                                    !liveState.isBuffering &&
                                    !liveState.isLoading,
                              ),
                            ],
                            IconButton(
                              constraints: const BoxConstraints.tightFor(
                                width: 48,
                                height: 48,
                              ),
                              tooltip: '移出队列',
                              onPressed: () async {
                                await liveController.removeQueueItemAt(index);
                                if (!context.mounted) {
                                  return;
                                }
                                final PlayerState refreshedState = ref.read(
                                  playerControllerProvider,
                                );
                                if (!refreshedState.hasQueue) {
                                  await _close(context);
                                }
                              },
                              icon: HugeIcon(
                                icon: HugeIcons.strokeRoundedCancel01,
                                color: secondaryText,
                                size: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _focusInitialItem(int? currentQueueIndex) {
    if (_didFocusInitialItem || currentQueueIndex == null) {
      return;
    }

    _didFocusInitialItem = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || !_scrollController.hasClients) {
        return;
      }

      await _scrollController.scrollToIndex(
        currentQueueIndex,
        preferPosition: AutoScrollPosition.middle,
      );
    });
  }

  Future<void> _close(BuildContext context) async {
    switch (widget.closeTarget) {
      case _QueueCloseTarget.navigator:
        Navigator.of(context).pop();
      case _QueueCloseTarget.sidePanel:
        await SmartDialog.dismiss<void>(tag: desktopSidePanelTag);
    }
  }
}
