import 'package:bilimusic/feature/statistics/domain/listening_report.dart';
import 'package:hive_ce/hive.dart';

const String songListeningBoxName = 'listening_songs';

class SongListeningDailyRepository {
  const SongListeningDailyRepository(this._box);

  final Box<Map> _box;

  Future<void> record(
    DateTime day, {
    required String stableId,
    required String title,
    required String author,
    required String coverUrl,
    required int listenedMs,
    required int plays,
  }) async {
    if (stableId.isEmpty || (listenedMs <= 0 && plays <= 0)) {
      return;
    }
    final String key = '${dayKey(day)}::$stableId';
    final Map? current = _box.get(key);
    final int currentMs = (current?['listenedMs'] as num?)?.toInt() ?? 0;
    final int currentPlays = (current?['plays'] as num?)?.toInt() ?? 0;
    await _box.put(key, <String, Object?>{
      'stableId': stableId,
      'title': title.isNotEmpty ? title : (current?['title'] as String? ?? ''),
      'author': author.isNotEmpty
          ? author
          : (current?['author'] as String? ?? ''),
      'coverUrl': coverUrl.isNotEmpty
          ? coverUrl
          : (current?['coverUrl'] as String? ?? ''),
      'listenedMs': currentMs + (listenedMs > 0 ? listenedMs : 0),
      'plays': currentPlays + (plays > 0 ? plays : 0),
    });
  }

  List<ListeningReportSong> topSongs(DateTime weekStart, {int limit = 5}) {
    final Set<String> dayKeys = <String>{
      for (int index = 0; index < 7; index += 1)
        dayKey(weekStart.add(Duration(days: index))),
    };
    final Map<String, ListeningReportSong> byStableId =
        <String, ListeningReportSong>{};
    for (final Object? key in _box.keys) {
      if (key is! String) {
        continue;
      }
      final int separator = key.indexOf('::');
      if (separator <= 0 || !dayKeys.contains(key.substring(0, separator))) {
        continue;
      }
      final Map? value = _box.get(key);
      if (value == null) {
        continue;
      }
      final String stableId = key.substring(separator + 2);
      final int listenedMs = (value['listenedMs'] as num?)?.toInt() ?? 0;
      final int plays = (value['plays'] as num?)?.toInt() ?? 0;
      if (listenedMs <= 0 && plays <= 0) {
        continue;
      }
      final ListeningReportSong? existing = byStableId[stableId];
      byStableId[stableId] = ListeningReportSong(
        stableId: stableId,
        title: value['title'] as String? ?? existing?.title ?? '',
        author: value['author'] as String? ?? existing?.author ?? '',
        coverUrl: value['coverUrl'] as String? ?? existing?.coverUrl ?? '',
        listenedMs: listenedMs + (existing?.listenedMs ?? 0),
        plays: plays + (existing?.plays ?? 0),
      );
    }
    final List<ListeningReportSong> songs =
        byStableId.values.toList(growable: false)..sort(
          (ListeningReportSong left, ListeningReportSong right) =>
              right.listenedMs.compareTo(left.listenedMs),
        );
    return songs.take(limit).toList(growable: false);
  }

  String dayKey(DateTime day) {
    final String month = day.month.toString().padLeft(2, '0');
    final String date = day.day.toString().padLeft(2, '0');
    return '${day.year}-$month-$date';
  }
}
