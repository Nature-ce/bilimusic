import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/recent/domain/recent_playback_entry.dart';
import 'package:bilimusic/feature/recent/ui/components/recent_playback_filter_bar.dart';
import 'package:bilimusic/feature/recent/ui/components/recent_playback_grouping.dart';
import 'package:bilimusic/feature/recent/ui/components/recent_playback_list.dart';
import 'package:bilimusic/core/theme/app_design.dart';
import 'package:flutter/material.dart';

typedef RecentPlaybackPlayCallback =
    void Function(List<PlayableItem> queue, int index, int? progressMs);

class RecentPlaybackBody extends StatefulWidget {
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
  State<RecentPlaybackBody> createState() => _RecentPlaybackBodyState();
}

class _RecentPlaybackBodyState extends State<RecentPlaybackBody> {
  RecentPlaybackFilter _filter = RecentPlaybackFilter.all;

  @override
  Widget build(BuildContext context) {
    final List<RecentPlaybackEntry> visibleEntries = widget.entries
        .where(_filter.matches)
        .toList(growable: false);
    final List<RecentPlaybackDayGroup> groups = groupRecentPlaybackEntries(
      visibleEntries,
    );
    final List<RecentPlaybackEntry> orderedEntries = groups
        .expand((RecentPlaybackDayGroup group) => group.entries)
        .toList(growable: false);
    final List<PlayableItem> queue = orderedEntries
        .map((RecentPlaybackEntry entry) => entry.toPlayableItem())
        .toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        RecentPlaybackFilterBar(
          filter: _filter,
          onSelected: (RecentPlaybackFilter filter) {
            if (filter == _filter) {
              return;
            }
            setState(() {
              _filter = filter;
            });
          },
        ),
        Expanded(
          child: visibleEntries.isEmpty
              ? const _FilteredEmptyView()
              : RecentPlaybackList(
                  groups: groups,
                  progress: widget.progress,
                  onPlay: (int index) => widget.onPlay(
                    queue,
                    index,
                    widget.progress[orderedEntries[index].stableId],
                  ),
                  onLongPressEntry: widget.onDeleteEntry == null
                      ? null
                      : (int index) => _showEntryActions(
                          orderedEntries[index],
                          queue,
                          index,
                        ),
                ),
        ),
      ],
    );
  }

  Future<void> _showEntryActions(
    RecentPlaybackEntry entry,
    List<PlayableItem> queue,
    int index,
  ) async {
    final String? action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) {
        final ColorScheme colorScheme = Theme.of(context).colorScheme;
        return SafeArea(
          child: Column(
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
                leading: Icon(
                  Icons.delete_outline_rounded,
                  color: colorScheme.error,
                ),
                title: Text(
                  '从最近播放移除',
                  style: TextStyle(color: colorScheme.error),
                ),
                onTap: () => Navigator.of(context).pop('remove'),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        );
      },
    );
    if (action == null || !mounted) {
      return;
    }
    if (action == 'play') {
      widget.onPlay(queue, index, widget.progress[entry.stableId]);
      return;
    }
    final Future<void> Function(RecentPlaybackEntry entry)? delete =
        widget.onDeleteEntry;
    if (delete != null) {
      await delete(entry);
    }
  }
}

class _FilteredEmptyView extends StatelessWidget {
  const _FilteredEmptyView();

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Text(
        '这里还没有内容',
        style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
      ),
    );
  }
}
