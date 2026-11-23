import 'package:bilimusic/feature/statistics/domain/song_statistics.dart';
import 'package:hive_ce/hive.dart';

const String songStatisticsBoxName = 'song_statistics';

class StatisticsLocalRepository {
  const StatisticsLocalRepository(this._box);

  final Box<Map> _box;

  SongStatistics? read(String stableId) {
    final Map? value = _box.get(stableId);
    if (value == null) return null;
    return SongStatistics(
      stableId: stableId,
      title: value['title'] as String? ?? '',
      author: value['author'] as String? ?? '',
      coverUrl: value['coverUrl'] as String? ?? '',
      playCount: (value['playCount'] as num?)?.toInt() ?? 0,
      totalPlayedMs: (value['totalPlayedMs'] as num?)?.toInt() ?? 0,
      firstPlayedAtEpochMs: (value['firstPlayedAtEpochMs'] as num?)?.toInt(),
      lastPlayedAtEpochMs: (value['lastPlayedAtEpochMs'] as num?)?.toInt(),
    );
  }

  SongStatistics? readCompatible(String stableId) {
    final SongStatistics? exact = read(stableId);
    if (exact != null || stableId.contains(':cid:')) return exact;
    final List<String> matches = _box.keys
        .whereType<String>()
        .where((String key) => key.startsWith('$stableId:cid:'))
        .toList(growable: false);
    return matches.length == 1 ? read(matches.single) : null;
  }

  int countFirstPlayedBetween(int startEpochMs, int endEpochMs) {
    int count = 0;
    for (final Map value in _box.values) {
      final int? firstPlayedAt = (value['firstPlayedAtEpochMs'] as num?)
          ?.toInt();
      if (firstPlayedAt != null &&
          firstPlayedAt >= startEpochMs &&
          firstPlayedAt < endEpochMs) {
        count += 1;
      }
    }
    return count;
  }

  List<SongStatistics> songsLastPlayedBetween(
    int startEpochMs,
    int endEpochMs, {
    int limit = 5,
  }) {
    final List<SongStatistics> matches = <SongStatistics>[];
    for (final MapEntry<dynamic, Map> entry in _box.toMap().entries) {
      final Object? key = entry.key;
      final Map value = entry.value;
      final int? lastPlayedAt = (value['lastPlayedAtEpochMs'] as num?)?.toInt();
      if (key is! String ||
          lastPlayedAt == null ||
          lastPlayedAt < startEpochMs ||
          lastPlayedAt >= endEpochMs) {
        continue;
      }
      matches.add(
        SongStatistics(
          stableId: key,
          title: value['title'] as String? ?? '',
          author: value['author'] as String? ?? '',
          coverUrl: value['coverUrl'] as String? ?? '',
          playCount: (value['playCount'] as num?)?.toInt() ?? 0,
          totalPlayedMs: (value['totalPlayedMs'] as num?)?.toInt() ?? 0,
          firstPlayedAtEpochMs: (value['firstPlayedAtEpochMs'] as num?)
              ?.toInt(),
          lastPlayedAtEpochMs: lastPlayedAt,
        ),
      );
    }
    matches.sort(
      (SongStatistics left, SongStatistics right) =>
          right.totalPlayedMs.compareTo(left.totalPlayedMs),
    );
    return matches.take(limit).toList(growable: false);
  }

  Future<void> write(SongStatistics statistics) =>
      _box.put(statistics.stableId, <String, Object?>{
        'title': statistics.title,
        'author': statistics.author,
        'coverUrl': statistics.coverUrl,
        'playCount': statistics.playCount,
        'totalPlayedMs': statistics.totalPlayedMs,
        'firstPlayedAtEpochMs': statistics.firstPlayedAtEpochMs,
        'lastPlayedAtEpochMs': statistics.lastPlayedAtEpochMs,
      });

  Future<void> clear(String stableId) => _box.delete(stableId);

  Future<void> clearAll() => _box.clear();
}
