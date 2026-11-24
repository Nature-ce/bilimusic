import 'package:bilimusic/common/components/status_view.dart';
import 'package:bilimusic/common/util/player_util.dart';
import 'package:bilimusic/core/theme/app_design.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/recent/domain/recent_playback_entry.dart';
import 'package:bilimusic/feature/recent/logic/recent_playback_controller.dart';
import 'package:bilimusic/feature/recent/logic/recent_playback_progress_controller.dart';
import 'package:bilimusic/feature/recent/ui/components/recent_playback_body.dart';
import 'package:bilimusic/common/components/glass_panel.dart';
import 'package:flutter/material.dart';
import 'package:bilimusic/feature/setting/logic/appearance_setting_logic.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DesktopRecentPlaybackPage extends ConsumerWidget {
  const DesktopRecentPlaybackPage({super.key});

  static const String _sourceLabel = '最近播放';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final List<RecentPlaybackEntry> entries = ref.watch(
      recentPlaybackControllerProvider,
    );
    final Map<String, int> progress = ref.watch(
      recentPlaybackProgressControllerProvider,
    );

    if (entries.isEmpty) {
      return Scaffold(
        body: StatusView(
          icon: Icons.history_rounded,
          iconColor: colorScheme.primary,
          title: '还没有最近播放',
          description: '播放过的内容会按时间出现在这里。',
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.sm,
              AppSpacing.xs,
            ),
            child: Row(
              children: <Widget>[
                Text(
                  _sourceLabel,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => _clearAll(context, ref),
                  style: TextButton.styleFrom(
                    foregroundColor: colorScheme.primary,
                  ),
                  child: const Text('清空'),
                ),
              ],
            ),
          ),
          Expanded(
            child: RecentPlaybackBody(
              entries: entries,
              progress: progress,
              onDeleteEntry: (RecentPlaybackEntry entry) => ref
                  .read(recentPlaybackControllerProvider.notifier)
                  .removeEntry(entry.stableId),
              onPlay: (List<PlayableItem> queue, int index, int? progressMs) =>
                  _play(context, ref, queue, index, progressMs),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _play(
    BuildContext context,
    WidgetRef ref,
    List<PlayableItem> queue,
    int index,
    int? progressMs,
  ) {
    return PlayerUtil.playQueueAndOpenPlayer(
      context,
      ref,
      items: queue,
      startIndex: index,
      sourceLabel: _sourceLabel,
      initialPosition: progressMs == null
          ? Duration.zero
          : Duration(milliseconds: progressMs),
    );
  }

  Future<void> _clearAll(BuildContext context, WidgetRef ref) async {
    final bool useGlass = ref.read(appearanceSettingLogicProvider);
    final bool? confirmed = useGlass
        ? await showAppGlassDialog<bool>(
            context: context,
            builder: (BuildContext dialogContext) => const AppGlassAlertDialog(
              title: '清空最近播放？',
              message: '将删除全部最近播放记录与收听进度，且无法恢复。',
              cancelLabel: '取消',
              confirmLabel: '清空',
            ),
          )
        : await showDialog<bool>(
            context: context,
            builder: (BuildContext dialogContext) => AlertDialog(
              title: const Text('清空最近播放？'),
              content: const Text('将删除全部最近播放记录与收听进度，且无法恢复。'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('取消'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text('清空'),
                ),
              ],
            ),
          );
    if (confirmed != true) {
      return;
    }
    await ref.read(recentPlaybackControllerProvider.notifier).clear();
    await ref
        .read(recentPlaybackProgressControllerProvider.notifier)
        .clearAll();
  }
}
