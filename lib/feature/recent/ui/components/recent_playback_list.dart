import 'package:bilimusic/common/components/bottom_page_spacer.dart';
import 'package:bilimusic/common/components/swipe_reveal_row.dart';
import 'package:bilimusic/core/theme/app_design.dart';
import 'package:bilimusic/feature/recent/domain/recent_playback_entry.dart';
import 'package:bilimusic/feature/recent/ui/components/recent_playback_entry_tile.dart';
import 'package:bilimusic/feature/recent/ui/components/recent_playback_grouping.dart';
import 'package:flutter/material.dart';

typedef _RecentListRow = ({
  String? dayLabel,
  RecentPlaybackEntry? entry,
  int index,
});

class RecentPlaybackList extends StatefulWidget {
  const RecentPlaybackList({
    super.key,
    required this.groups,
    required this.progress,
    required this.onPlay,
    this.onDeleteEntry,
  });

  final List<RecentPlaybackDayGroup> groups;
  final Map<String, int> progress;
  final ValueChanged<int> onPlay;
  final ValueChanged<int>? onDeleteEntry;

  @override
  State<RecentPlaybackList> createState() => _RecentPlaybackListState();
}

class _RecentPlaybackListState extends State<RecentPlaybackList> {
  final SwipeRevealController _swipeController = SwipeRevealController();

  @override
  void dispose() {
    _swipeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<_RecentListRow> rows = <_RecentListRow>[];
    int index = 0;

    for (final RecentPlaybackDayGroup group in widget.groups) {
      rows.add((dayLabel: group.label, entry: null, index: -1));
      for (final RecentPlaybackEntry entry in group.entries) {
        rows.add((dayLabel: null, entry: entry, index: index));
        index += 1;
      }
    }

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _swipeController.close,
      child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification notification) {
          if (notification is ScrollStartNotification) {
            _swipeController.close();
          }
          return false;
        },
        child: ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: rows.length + 1,
          itemBuilder: (BuildContext context, int position) {
            if (position == rows.length) {
              return const BottomPageSpacer();
            }

            final _RecentListRow row = rows[position];
            final String? dayLabel = row.dayLabel;
            if (dayLabel != null) {
              return _RecentDayHeader(label: dayLabel);
            }

            final RecentPlaybackEntry? entry = row.entry;
            if (entry == null) {
              return const SizedBox.shrink();
            }

            final Widget tile = RecentPlaybackEntryTile(
              entry: entry,
              progressMs: widget.progress[entry.stableId],
              onTap: () {
                _swipeController.close();
                widget.onPlay(row.index);
              },
            );
            final ValueChanged<int>? delete = widget.onDeleteEntry;
            if (delete == null) {
              return KeyedSubtree(
                key: ValueKey<String>(entry.stableId),
                child: tile,
              );
            }
            return SwipeRevealRow(
              key: ValueKey<String>('swipe:${entry.stableId}'),
              actionLabel: '删除',
              revealId: entry.stableId,
              controller: _swipeController,
              onAction: () => delete(row.index),
              child: tile,
            );
          },
        ),
      ),
    );
  }
}

class _RecentDayHeader extends StatelessWidget {
  const _RecentDayHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.xs,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          height: 1.2,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
