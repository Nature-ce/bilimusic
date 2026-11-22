import 'package:bilimusic/feature/radar/domain/radar_keys.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'radar_taste.freezed.dart';

/// 从收听记录 + 收藏里算出来的口味画像。
@freezed
abstract class RadarTaste with _$RadarTaste {
  const RadarTaste._();

  const factory RadarTaste({
    @Default(<String, double>{}) Map<String, double> artists,
    @Default(<String, double>{}) Map<String, double> dislikedTracks,
    @Default(<String>{}) Set<String> recentTrackKeys,
    @Default(<String>[]) List<String> likedTitleBlobs,
    @Default(0) int sampleCount,
  }) = _RadarTaste;

  bool get isColdStart => sampleCount == 0 && artists.isEmpty;

  double get maxArtistScore {
    double maxScore = 0;
    for (final double score in artists.values) {
      if (score > maxScore) {
        maxScore = score;
      }
    }
    return maxScore;
  }

  /// 歌手的口味分归一化到 0..1。
  double artistAffinity(String artist) {
    final double maxScore = maxArtistScore;
    if (maxScore <= 0) {
      return 0;
    }
    final double score = artists[normalizeRadarKey(artist)] ?? 0;
    return score <= 0 ? 0 : (score / maxScore).clamp(0.0, 1.0);
  }

  double dislikeFor({required String title, required String artist}) {
    return dislikedTracks[radarTrackKey(title: title, artist: artist)] ?? 0;
  }

  bool likesTitle(String title) {
    final String key = normalizeRadarKey(title);
    if (key.length < 2) {
      return false;
    }
    for (final String blob in likedTitleBlobs) {
      if (blob.contains(key)) {
        return true;
      }
    }
    return false;
  }

  bool playedRecently({required String title, required String artist}) {
    return recentTrackKeys.contains(
      radarTrackKey(title: title, artist: artist),
    );
  }
}
