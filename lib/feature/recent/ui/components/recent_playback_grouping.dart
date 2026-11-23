import 'package:bilimusic/feature/recent/domain/recent_playback_entry.dart';

typedef RecentPlaybackDayGroup = ({
  DateTime day,
  String label,
  List<RecentPlaybackEntry> entries,
});

List<RecentPlaybackDayGroup> groupRecentPlaybackEntries(
  List<RecentPlaybackEntry> entries, {
  DateTime? now,
}) {
  final List<RecentPlaybackEntry> sorted = List<RecentPlaybackEntry>.of(entries)
    ..sort(
      (RecentPlaybackEntry a, RecentPlaybackEntry b) =>
          b.playedAtEpochMs.compareTo(a.playedAtEpochMs),
    );
  final Map<DateTime, List<RecentPlaybackEntry>> buckets =
      <DateTime, List<RecentPlaybackEntry>>{};

  for (final RecentPlaybackEntry entry in sorted) {
    final DateTime day = _dayOf(
      DateTime.fromMillisecondsSinceEpoch(entry.playedAtEpochMs),
    );
    buckets.putIfAbsent(day, () => <RecentPlaybackEntry>[]).add(entry);
  }

  final List<DateTime> days = buckets.keys.toList(growable: false)
    ..sort((DateTime a, DateTime b) => b.compareTo(a));
  final DateTime resolvedNow = now ?? DateTime.now();

  return days
      .map(
        (DateTime day) => (
          day: day,
          label: recentPlaybackDayLabel(day, now: resolvedNow),
          entries: List<RecentPlaybackEntry>.unmodifiable(buckets[day]!),
        ),
      )
      .toList(growable: false);
}

String recentPlaybackDayLabel(DateTime day, {DateTime? now}) {
  final DateTime today = _dayOf(now ?? DateTime.now());
  final DateTime target = _dayOf(day);
  final int offset = _dayIndex(today) - _dayIndex(target);

  if (offset == 0) {
    return '今天';
  }
  if (offset == 1) {
    return '昨天';
  }
  return '${target.month}月${target.day}日';
}

String recentPlaybackTimeLabel(int playedAtEpochMs) {
  final DateTime time = DateTime.fromMillisecondsSinceEpoch(playedAtEpochMs);
  final String hour = time.hour.toString().padLeft(2, '0');
  final String minute = time.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

DateTime _dayOf(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}

int _dayIndex(DateTime value) {
  return DateTime.utc(
    value.year,
    value.month,
    value.day,
  ).difference(DateTime.utc(1970)).inDays;
}
