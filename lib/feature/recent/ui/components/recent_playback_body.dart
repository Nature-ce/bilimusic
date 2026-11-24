import 'package:bilimusic/common/components/glass_panel.dart';
import 'package:bilimusic/core/theme/app_design.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/recent/domain/recent_playback_entry.dart';
import 'package:bilimusic/feature/recent/ui/components/recent_playback_grouping.dart';
import 'package:bilimusic/feature/recent/ui/components/recent_playback_list.dart';
import 'package:bilimusic/feature/setting/logic/appearance_setting_logic.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef RecentPlaybackPlayCallback =
    void Function(List<PlayableItem> queue, int index, int? progressMs);

class RecentPlaybackBody extends ConsumerWidget {
  const RecentPlaybackBody({
    super.key,
    required this.entries,
    required this.progress,
    required this.onPlay,
    this.onDeleteEntry,
  });

  final List<RecentPlaybackEntry> entries;
  final Map<String, int> progress;
  final RecentPlaybackPlayCallback onPlay;
  final Future<void> Function(RecentPlaybackEntry entry)? onDeleteEntry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool useGlass = ref.watch(appearanceSettingLogicProvider);
    final List<RecentPlaybackDayGroup> groups = groupRecentPlaybackEntries(
      entries,
    );
    final List<RecentPlaybackEntry> orderedEntries = groups
        .expand((RecentPlaybackDayGroup group) => group.entries)
        .toList(growable: false);
    final List<PlayableItem> queue = orderedEntries
        .map((RecentPlaybackEntry entry) => entry.toPlayableItem())
        .toList(growable: false);

    return RecentPlaybackList(
      groups: groups,
      progress: progress,
      onPlay: (int index) =>
          onPlay(queue, index, progress[orderedEntries[index].stableId]),
      onLongPressEntry: onDeleteEntry == null
          ? null
          : (int index) => _showEntryActions(
              context,
              orderedEntries[index],
              queue,
              index,
              useGlass,
            ),
    );
  }

  Widget _entryActions(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ListTile(
          leading: Icon(
            Icons.play_circle_outline_rounded,
            color: colorScheme.primary,
          ),
          title: const Text('播放'),
          onTap: () => Navigator.of(context).pop('play'),
        ),
        ListTile(
          leading: Icon(Icons.delete_outline_rounded, color: colorScheme.error),
          title: Text('从最近播放移除', style: TextStyle(color: colorScheme.error)),
          onTap: () => Navigator.of(context).pop('remove'),
        ),
        const SizedBox(height: AppSpacing.sm),
      ],
    );
  }

  Future<void> _showEntryActions(
    BuildContext context,
    RecentPlaybackEntry entry,
    List<PlayableItem> queue,
    int index,
    bool useGlass,
  ) async {
    final String? action = useGlass
        ? await showAppHalfSheet<String>(
            context: context,
            builder: (BuildContext sheetContext) => _entryActions(sheetContext),
          )
        : await showModalBottomSheet<String>(
            context: context,
            showDragHandle: true,
            builder: (BuildContext sheetContext) =>
                SafeArea(child: _entryActions(sheetContext)),
          );
    if (action == null) {
      return;
    }
    if (action == 'play') {
      onPlay(queue, index, progress[entry.stableId]);
      return;
    }
    final Future<void> Function(RecentPlaybackEntry entry)? delete =
        onDeleteEntry;
    if (delete != null) {
      await delete(entry);
    }
  }
}
