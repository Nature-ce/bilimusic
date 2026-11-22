import 'dart:math';

import 'package:bilimusic/feature/radar/domain/radar_keys.dart';
import 'package:bilimusic/feature/radar/domain/radar_play_record.dart';
import 'package:bilimusic/feature/radar/domain/radar_taste.dart';

/// 从收听记录 + 收藏算出「你的口味」。
///
/// 三个信号：听完程度（听了多少）、重复次数（听了几遍）、时间衰减（多久以前）。
/// 听两下就切走的会拉低对应歌手的分，喜欢的歌手分越高，雷达就越会往那个方向推。
RadarTaste buildRadarTaste({
  required Iterable<RadarPlayRecord> history,
  required DateTime now,
  Iterable<String> likedArtists = const <String>[],
  Iterable<String> likedTitles = const <String>[],
  Duration maxAge = const Duration(days: 150),
  double recencyHalfLifeDays = 18,
}) {
  final Map<String, double> artists = <String, double>{};
  final Map<String, double> dislikedTracks = <String, double>{};
  final Set<String> recentTrackKeys = <String>{};
  int sampleCount = 0;

  for (final RadarPlayRecord record in history) {
    final Duration age = now.difference(record.updatedAt);
    if (age.isNegative || age > maxAge) {
      continue;
    }
    final double recency = pow(
      0.5,
      age.inHours / (recencyHalfLifeDays * 24),
    ).toDouble();
    final String artistKey = record.artistKey;
    final String trackKey = record.trackKey;
    if (record.isSkip) {
      if (artistKey.isNotEmpty) {
        _add(artists, artistKey, -recency * 0.8);
      }
      if (trackKey.isNotEmpty) {
        _add(dislikedTracks, trackKey, recency * 0.9);
      }
      continue;
    }
    sampleCount += 1;
    final double completion = record.completionRatio;
    final double repeatWeight = 1 + log(1 + record.playCount) * 0.4;
    final double weight = recency * (0.35 + 0.65 * completion) * repeatWeight;
    if (artistKey.isNotEmpty) {
      _add(artists, artistKey, weight);
    }
    if (age.inHours <= 72) {
      recentTrackKeys.add(trackKey);
    }
  }

  for (final String artist in likedArtists) {
    final String key = normalizeRadarKey(artist);
    if (key.isNotEmpty) {
      _add(artists, key, 1.8);
    }
  }

  final List<String> likedTitleBlobs = <String>[];
  for (final String title in likedTitles) {
    final String blob = normalizeRadarKey(title);
    if (blob.isNotEmpty && !likedTitleBlobs.contains(blob)) {
      likedTitleBlobs.add(blob);
    }
  }

  return RadarTaste(
    artists: artists,
    dislikedTracks: dislikedTracks,
    recentTrackKeys: recentTrackKeys,
    likedTitleBlobs: likedTitleBlobs,
    sampleCount: sampleCount,
  );
}

void _add(Map<String, double> sink, String key, double delta) {
  sink[key] = (sink[key] ?? 0) + delta;
}
