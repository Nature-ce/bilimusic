import 'dart:async';

import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/recent/domain/recent_playback_entry.dart';
import 'package:bilimusic/feature/recent/ui/components/recent_playback_grouping.dart';
import 'package:bilimusic/feature/recent/ui/components/recent_playback_list.dart';
import 'package:flutter/material.dart';

typedef RecentPlaybackPlayCallback =
    void Function(List<PlayableItem> queue, int index, int? progressMs);

class RecentPlaybackBody extends StatelessWidget {
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
  Widget build(BuildContext context) {
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
      onDeleteEntry: onDeleteEntry == null
          ? null
          : (int index) => unawaited(onDeleteEntry!(orderedEntries[index])),
    );
  }
}
