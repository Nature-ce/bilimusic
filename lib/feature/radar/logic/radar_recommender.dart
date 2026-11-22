import 'dart:math';

import 'package:bilimusic/feature/home/domain/hot_playlist_track.dart';
import 'package:bilimusic/feature/radar/domain/radar_keys.dart';
import 'package:bilimusic/feature/radar/domain/radar_pick.dart';
import 'package:bilimusic/feature/radar/domain/radar_taste.dart';

/// 私人雷达选曲器。
///
/// 和「按热度取前 N 首」相反：先把候选按口味分成三档——常听歌手的歌、
/// 和常听歌手同歌单的歌、完全没听过的歌——再按比例混起来，并且限制同一歌手 /
/// 同一歌单的占比，所以榜首热门只占少数，能听到冷门一点的歌。
class RadarRecommender {
  const RadarRecommender();

  /// 一批里「常听歌手」的占比（其余是拓展口味用的）。
  static const double familiarShare = 0.45;
  static const double relatedShare = 0.3;

  /// 同一个歌手最多出现几次，避免整批都是同一个人。
  static const int maxPerArtist = 2;

  /// 同一张歌单的保底上限：候选只来自少数几张歌单时会自动放宽，见 [_playlistCap]。
  static const int minPlaylistCap = 4;

  /// 排名前几的热门只给一点点分，避免唯热度论。
  static const int hotRankCutoff = 3;
  static const int mildRankCutoff = 10;
  static const int tailRankCutoff = 30;

  List<RadarPick> pick({
    required List<HotPlaylistTrack> pool,
    required RadarTaste taste,
    required int limit,
    required Random random,
    Set<String> excludeKeys = const <String>{},
  }) {
    if (limit <= 0 || pool.isEmpty) {
      return const <RadarPick>[];
    }
    List<_Candidate> candidates = _prepare(
      pool: pool,
      taste: taste,
      excludeKeys: excludeKeys,
      dropRecent: true,
    );
    if (candidates.isEmpty) {
      candidates = _prepare(
        pool: pool,
        taste: taste,
        excludeKeys: excludeKeys,
        dropRecent: false,
      );
    }
    if (candidates.isEmpty) {
      return const <RadarPick>[];
    }
    final int playlistCap = _playlistCap(candidates, limit);
    final List<RadarPick> picks = taste.isColdStart
        ? _coldStart(
            candidates,
            limit: limit,
            random: random,
            playlistCap: playlistCap,
          )
        : _personalized(
            candidates,
            taste: taste,
            limit: limit,
            random: random,
            playlistCap: playlistCap,
          );
    return picks;
  }

  List<_Candidate> _prepare({
    required List<HotPlaylistTrack> pool,
    required RadarTaste taste,
    required Set<String> excludeKeys,
    required bool dropRecent,
  }) {
    final Map<String, _Candidate> unique = <String, _Candidate>{};
    for (final HotPlaylistTrack track in pool) {
      if (excludeKeys.contains(track.key)) {
        continue;
      }
      final String trackKey = radarTrackKey(
        title: track.title,
        artist: track.artist,
      );
      if (unique.containsKey(trackKey)) {
        continue;
      }
      if (taste.dislikeFor(title: track.title, artist: track.artist) >= 1) {
        continue;
      }
      if (dropRecent &&
          taste.playedRecently(title: track.title, artist: track.artist)) {
        continue;
      }
      unique[trackKey] = _Candidate(track: track, trackKey: trackKey);
    }
    return unique.values.toList(growable: false);
  }

  List<RadarPick> _personalized(
    List<_Candidate> candidates, {
    required RadarTaste taste,
    required int limit,
    required Random random,
    required int playlistCap,
  }) {
    // 哪些歌单里出现过你常听的歌手，用来做「同一个歌单」的推荐理由。
    final Map<String, Set<String>> likedArtistsByPlaylist =
        <String, Set<String>>{};
    for (final _Candidate candidate in candidates) {
      if (taste.artistAffinity(candidate.track.artist) > 0.05) {
        likedArtistsByPlaylist
            .putIfAbsent(candidate.playlistKey, () => <String>{})
            .add(candidate.track.artist);
      }
    }

    final List<_Scored> familiar = <_Scored>[];
    final List<_Scored> related = <_Scored>[];
    final List<_Scored> explore = <_Scored>[];
    for (final _Candidate candidate in candidates) {
      final HotPlaylistTrack track = candidate.track;
      final double affinity = taste.artistAffinity(track.artist);
      final bool likedTitle = taste.likesTitle(track.title);
      final bool likedArtist = affinity > 0.05 || likedTitle;
      final Set<String> likedInPlaylist =
          likedArtistsByPlaylist[candidate.playlistKey] ?? const <String>{};
      final bool relatedHere =
          !likedArtist &&
          likedInPlaylist.any((String artist) => artist != track.artist);
      final double dislikes = taste.dislikeFor(
        title: track.title,
        artist: track.artist,
      );
      final double score =
          affinity * 3 +
          (likedTitle ? 1.4 : 0) -
          dislikes * 2 -
          _heatPenalty(track.rank) +
          random.nextDouble() * 0.35;
      final _Scored scored = _Scored(
        candidate: candidate,
        score: score,
        reason: likedArtist
            ? RadarReason.familiarArtist
            : relatedHere
            ? RadarReason.relatedPlaylist
            : RadarReason.explorer,
        detail: likedArtist
            ? (likedTitle ? track.title : track.artist)
            : relatedHere
            ? track.playlist.name
            : null,
      );
      if (likedArtist) {
        familiar.add(scored);
      } else if (relatedHere) {
        related.add(scored);
      } else {
        explore.add(scored);
      }
    }
    _sortByScore(familiar);
    _sortByScore(related);
    _sortByScore(explore);

    final _Picker picker = _Picker(limit: limit, playlistCap: playlistCap);
    picker
      ..take(familiar, (limit * familiarShare).round())
      ..take(related, (limit * relatedShare).round())
      ..take(explore, limit);
    // 某一档不够就用其它档补齐，保证一批里的数量稳定。
    picker
      ..take(familiar, limit)
      ..take(related, limit)
      ..take(explore, limit);
    return _interleave(picker.picks);
  }

  List<RadarPick> _coldStart(
    List<_Candidate> candidates, {
    required int limit,
    required Random random,
    required int playlistCap,
  }) {
    final List<_Scored> hot = <_Scored>[];
    final List<_Scored> steady = <_Scored>[];
    final List<_Scored> tail = <_Scored>[];
    for (final _Candidate candidate in candidates) {
      final int rank = candidate.track.rank;
      final _Scored scored = _Scored(
        candidate: candidate,
        score: random.nextDouble(),
        reason: RadarReason.coldStart,
      );
      if (rank <= mildRankCutoff) {
        hot.add(scored);
      } else if (rank <= tailRankCutoff) {
        steady.add(scored);
      } else {
        tail.add(scored);
      }
    }
    _sortByScore(hot);
    _sortByScore(steady);
    _sortByScore(tail);
    final _Picker picker = _Picker(limit: limit, playlistCap: playlistCap);
    picker
      ..take(hot, (limit * 0.45).round())
      ..take(steady, (limit * 0.35).round())
      ..take(tail, limit);
    picker
      ..take(steady, limit)
      ..take(tail, limit)
      ..take(hot, limit);
    return _interleave(picker.picks);
  }

  /// 同一张歌单能贡献几首：候选池只有一两张歌单时放宽，否则按份额分。
  static int _playlistCap(List<_Candidate> candidates, int limit) {
    final int playlists = <String>{
      for (final _Candidate candidate in candidates) candidate.playlistKey,
    }.length;
    if (playlists <= 1) {
      return limit;
    }
    return max(minPlaylistCap, (limit / playlists).ceil());
  }

  /// 排名越靠前扣分越多：榜首只比第 30 名多 0.18 分，避免整个流都是热榜前几。
  double _heatPenalty(int rank) {
    if (rank <= 0) {
      return 0.12;
    }
    if (rank <= hotRankCutoff) {
      return 0.18;
    }
    if (rank <= mildRankCutoff) {
      return 0.09;
    }
    return 0;
  }

  static void _sortByScore(List<_Scored> items) {
    items.sort((_Scored a, _Scored b) => b.score.compareTo(a.score));
  }

  /// 交错排列：熟悉 / 拓展 / 相关轮流出场，不会连着好几首同一种理由。
  static List<RadarPick> _interleave(List<RadarPick> picks) {
    if (picks.length <= 2) {
      return picks;
    }
    const List<RadarReason> order = <RadarReason>[
      RadarReason.familiarArtist,
      RadarReason.explorer,
      RadarReason.relatedPlaylist,
      RadarReason.coldStart,
    ];
    final Map<RadarReason, List<RadarPick>> byReason =
        <RadarReason, List<RadarPick>>{};
    for (final RadarPick pick in picks) {
      byReason.putIfAbsent(pick.reason, () => <RadarPick>[]).add(pick);
    }
    final List<RadarPick> result = <RadarPick>[];
    int round = 0;
    while (result.length < picks.length) {
      for (final RadarReason reason in order) {
        final List<RadarPick>? bucket = byReason[reason];
        if (bucket == null || round >= bucket.length) {
          continue;
        }
        result.add(bucket[round]);
      }
      round += 1;
    }
    return result;
  }
}

class _Candidate {
  const _Candidate({required this.track, required this.trackKey});

  final HotPlaylistTrack track;
  final String trackKey;

  String get artistKey => normalizeRadarKey(track.artist);

  String get playlistKey => track.playlist.key;
}

class _Scored {
  const _Scored({
    required this.candidate,
    required this.score,
    required this.reason,
    this.detail,
  });

  final _Candidate candidate;
  final double score;
  final RadarReason reason;
  final String? detail;
}

/// 按配额取歌，同时守住「同一个歌手 / 同一张歌单」的上限。
class _Picker {
  _Picker({required this.limit, required this.playlistCap});

  final int limit;
  final int playlistCap;
  final List<RadarPick> picks = <RadarPick>[];
  final Map<String, int> _artistCount = <String, int>{};
  final Map<String, int> _playlistCount = <String, int>{};
  final Set<String> _pickedKeys = <String>{};

  void take(List<_Scored> source, int want) {
    for (final _Scored scored in source) {
      if (want <= 0 || picks.length >= limit) {
        return;
      }
      final String trackKey = scored.candidate.trackKey;
      if (_pickedKeys.contains(trackKey)) {
        continue;
      }
      final String artistKey = scored.candidate.artistKey;
      if ((_artistCount[artistKey] ?? 0) >= RadarRecommender.maxPerArtist) {
        continue;
      }
      final String playlistKey = scored.candidate.playlistKey;
      if ((_playlistCount[playlistKey] ?? 0) >= playlistCap) {
        continue;
      }
      _pickedKeys.add(trackKey);
      _artistCount[artistKey] = (_artistCount[artistKey] ?? 0) + 1;
      _playlistCount[playlistKey] = (_playlistCount[playlistKey] ?? 0) + 1;
      picks.add(
        RadarPick(
          track: scored.candidate.track,
          reason: scored.reason,
          score: scored.score,
          reasonDetail: scored.detail,
        ),
      );
      want -= 1;
    }
  }
}
