import 'package:bilimusic/feature/home/domain/matchable_track.dart';
import 'package:bilimusic/feature/search/domain/search_result_item.dart';

class ChartTrackMatcher {
  const ChartTrackMatcher._();

  static const int minimumConfidentScore = 2;
  static const int _titleScore = 3;
  static const int _artistScore = 2;
  static const int _closeDurationScore = 2;
  static const int _nearDurationScore = 1;
  static const int _closeDurationWindowSeconds = 8;
  static const int _nearDurationWindowSeconds = 20;

  /// 短于这个时长的视频基本都是「剪辑片段」，不参与匹配。
  static const int minimumClipSeconds = 60;

  /// 比原曲短到这个比例以下，也算片段（例如 4 分钟的歌只搜到 1 分钟视频）。
  static const double minimumDurationRatio = 0.6;

  static final RegExp _ignoredCharacters = RegExp(
    r'''[\s\-_/\\.。，,、:：!！?？"'`~@#%&*+=|<>()\[\]{}（）【】「」『』《》]''',
  );

  static SearchResultItem? pickBest({
    required MatchableTrack track,
    required List<SearchResultItem> candidates,
  }) {
    SearchResultItem? best;
    int bestScore = -1;
    for (final SearchResultItem candidate in candidates) {
      final _MatchScore score = _score(track: track, item: candidate);
      if (!score.isConfident) {
        continue;
      }
      if (score.total > bestScore) {
        best = candidate;
        bestScore = score.total;
      }
    }
    return best;
  }

  static int scoreOf({
    required MatchableTrack track,
    required SearchResultItem item,
  }) {
    return _score(track: track, item: item).total;
  }

  static _MatchScore _score({
    required MatchableTrack track,
    required SearchResultItem item,
  }) {
    final int candidateSeconds = parseDurationSeconds(item.duration);
    // 剪辑片段（只有几十秒的副歌 / 试听版）即使标题歌手都对也不要。
    if (_isShortClip(track: track, candidateSeconds: candidateSeconds)) {
      return const _MatchScore(total: 0, isConfident: false);
    }

    final String title = normalize(track.title);
    final String artist = normalize(track.artist);
    final String candidate = normalize(item.title);
    final bool titleMatched = title.isNotEmpty && candidate.contains(title);
    final bool artistMatched = artist.isNotEmpty && candidate.contains(artist);
    int durationScore = 0;
    bool durationClose = false;
    if (track.durationSeconds > 0 && candidateSeconds > 0) {
      final int diff = (track.durationSeconds - candidateSeconds).abs();
      if (diff <= _closeDurationWindowSeconds) {
        durationScore = _closeDurationScore;
        durationClose = true;
      } else if (diff <= _nearDurationWindowSeconds) {
        durationScore = _nearDurationScore;
        durationClose = true;
      }
    }

    final int total =
        (titleMatched ? _titleScore : 0) +
        (artistMatched ? _artistScore : 0) +
        durationScore;
    final bool isConfident = titleMatched || (artistMatched && durationClose);
    return _MatchScore(total: total, isConfident: isConfident);
  }

  /// 候选视频是不是被剪过的片段：时长太短，或者比原曲短一大截。
  ///
  /// 时长解析不出来（0）时不做判断，保持原来的行为。
  static bool _isShortClip({
    required MatchableTrack track,
    required int candidateSeconds,
  }) {
    if (candidateSeconds <= 0) {
      return false;
    }
    if (candidateSeconds < minimumClipSeconds) {
      return true;
    }
    final int trackSeconds = track.durationSeconds;
    return trackSeconds > 0 &&
        candidateSeconds < trackSeconds * minimumDurationRatio;
  }

  static String normalize(String value) {
    return value.toLowerCase().replaceAll(_ignoredCharacters, '');
  }

  static int parseDurationSeconds(String value) {
    final List<String> parts = value
        .trim()
        .split(':')
        .map((String part) => part.trim())
        .toList(growable: false);
    if (parts.length < 2 || parts.length > 3) {
      return 0;
    }
    int seconds = 0;
    for (final String part in parts) {
      final int? value = int.tryParse(part);
      if (value == null || value < 0) {
        return 0;
      }
      seconds = seconds * 60 + value;
    }
    return seconds;
  }
}

class _MatchScore {
  const _MatchScore({required this.total, required this.isConfident});

  final int total;
  final bool isConfident;
}
