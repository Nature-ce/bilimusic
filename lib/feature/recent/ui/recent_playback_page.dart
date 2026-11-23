import 'package:bilimusic/common/components/status_view.dart';
import 'package:bilimusic/common/util/player_util.dart';
import 'package:bilimusic/core/theme/app_design.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/recent/domain/recent_playback_entry.dart';
import 'package:bilimusic/feature/recent/logic/recent_playback_controller.dart';
import 'package:bilimusic/feature/recent/logic/recent_playback_progress_controller.dart';
import 'package:bilimusic/feature/recent/ui/components/recent_playback_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RecentPlaybackPage extends ConsumerWidget {
  const RecentPlaybackPage({super.key});

  static const String _sourceLabel = '最近播放';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final List<RecentPlaybackEntry> entries = ref.watch(
      recentPlaybackControllerProvider,
    );
    final Map<String, int> progress = ref.watch(
      recentPlaybackProgressControllerProvider,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(_sourceLabel),
        actions: entries.isEmpty
            ? null
            : <Widget>[
                TextButton(
                  onPressed: () => _clearAll(context, ref),
                  style: TextButton.styleFrom(
                    foregroundColor: colorScheme.primary,
                  ),
                  child: const Text('清空'),
                ),
                const SizedBox(width: AppSpacing.xs),
              ],
      ),
      body: entries.isEmpty
          ? StatusView(
              icon: Icons.history_rounded,
              iconColor: colorScheme.primary,
              title: '还没有最近播放',
              description: '播放过的内容会按时间出现在这里。',
            )
          : RecentPlaybackBody(
              entries: entries,
              progress: progress,
              onDeleteEntry: (RecentPlaybackEntry entry) => ref
                  .read(recentPlaybackControllerProvider.notifier)
                  .removeEntry(entry.stableId),
              onPlay: (List<PlayableItem> queue, int index, int? progressMs) =>
                  _play(context, ref, queue, index, progressMs),
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
    final bool? confirmed = await showDialog<bool>(
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
