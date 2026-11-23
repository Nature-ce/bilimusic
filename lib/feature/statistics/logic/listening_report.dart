import 'package:bilimusic/feature/statistics/data/daily_listening_repository.dart';
import 'package:bilimusic/feature/statistics/data/statistics_local_repository.dart';
import 'package:bilimusic/feature/statistics/domain/daily_listening.dart';
import 'package:bilimusic/feature/statistics/domain/listening_report.dart';
import 'package:bilimusic/feature/statistics/domain/song_statistics.dart';
import 'package:bilimusic/feature/statistics/logic/statistics_tracker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'listening_report.g.dart';

@riverpod
ListeningReport listeningReport(Ref ref) {
  final DateTime now = DateTime.now();
  final DailyListeningRepository daily = ref.watch(
    dailyListeningRepositoryProvider,
  );
  final DateTime weekStart = daily.weekStartOf(now);
  final List<DailyListening> days = daily.readDays(weekStart);
  final List<DailyListening> lastWeekDays = daily.readDays(
    weekStart.subtract(const Duration(days: 7)),
  );
  final DateTime weekEnd = weekStart.add(const Duration(days: 7));
  final List<ListeningReportSong> dailyTopSongs = ref
      .watch(songListeningDailyRepositoryProvider)
      .topSongs(weekStart);
  final StatisticsLocalRepository statistics = ref.watch(
    statisticsLocalRepositoryProvider,
  );
  final bool topSongsAreCumulative = dailyTopSongs.isEmpty;
  final List<ListeningReportSong> topSongs = topSongsAreCumulative
      ? statistics
            .songsLastPlayedBetween(
              weekStart.millisecondsSinceEpoch,
              weekEnd.millisecondsSinceEpoch,
            )
            .map(_toReportSong)
            .toList(growable: false)
      : dailyTopSongs;

  return ListeningReport(
    days: days,
    lastWeekDays: lastWeekDays,
    topSongs: topSongs,
    topSongsAreCumulative: topSongsAreCumulative,
    weekListenedMs: _sumListenedMs(days),
    lastWeekListenedMs: _sumListenedMs(lastWeekDays),
    weekSongs: _sumSongs(days),
    lastWeekSongs: _sumSongs(lastWeekDays),
    newSongCount: statistics.countFirstPlayedBetween(
      weekStart.millisecondsSinceEpoch,
      weekEnd.millisecondsSinceEpoch,
    ),
    streakDays: daily.listenedDaysInRow(now),
    elapsedDays: now.weekday,
    weekStart: weekStart,
  );
}

int _sumListenedMs(List<DailyListening> days) {
  int total = 0;
  for (final DailyListening day in days) {
    total += day.listenedMs;
  }
  return total;
}

int _sumSongs(List<DailyListening> days) {
  int total = 0;
  for (final DailyListening day in days) {
    total += day.songs;
  }
  return total;
}

ListeningReportSong _toReportSong(SongStatistics statistics) {
  return ListeningReportSong(
    stableId: statistics.stableId,
    title: statistics.title,
    author: statistics.author,
    coverUrl: statistics.coverUrl,
    listenedMs: statistics.totalPlayedMs,
    plays: statistics.playCount,
  );
}
