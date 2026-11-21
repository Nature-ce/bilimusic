import 'package:bilimusic/feature/home/domain/matchable_track.dart';
import 'package:bilimusic/feature/search/domain/search_result_item.dart';

/// 把其它平台的歌匹配到 B 站视频的评分规则。
///
/// 同一首歌在 B 站往往有几十个投稿，质量参差不齐（剪辑片段、拼接合集、
/// 翻唱、加长版都有），所以策略是：
///
/// 1. 先用**时长**做硬门槛：原曲时长已知时，候选必须落在原曲的
///    [minimumDurationRatio, maximumDurationRatio] 区间内，太短（剪辑）
///    或太长（拼接）直接淘汰；
/// 2. 再按标题、歌手、时长接近程度、完整版 / 剪辑关键词打分；
/// 3. 同分时按「时长更接近」「播放量更高」挑，播放量高的通常画质音质更好。
class ChartTrackMatcher {
  const ChartTrackMatcher._();

  static const int minimumConfidentScore = 2;
  static const int _titleScore = 3;
  static const int _artistScore = 2;
  static const int _exactDurationScore = 4;
  static const int _closeDurationScore = 3;
  static const int _nearDurationScore = 1;
  static const int _completeBonus = 1;
  static const int _clipPenalty = -2;
  static const int _exactDurationWindowSeconds = 5;
  static const int _closeDurationWindowSeconds = 15;
  static const int _nearDurationWindowSeconds = 30;

  /// 短于这个时长的视频基本都是「剪辑片段」，不参与匹配。
  static const int minimumClipSeconds = 60;

  /// 候选时长 / 原曲时长 的允许区间：短于此值算剪辑，长于此值算拼接。
  static const double minimumDurationRatio = 0.85;
  static const double maximumDurationRatio = 1.25;

  /// 标题里出现这些词通常是完整版，加分。
  static const List<String> _completeMarkers = <String>[
    '完整版',
    '完整',
    'mv',
    '官方',
    '无损',
    'hires',
    'hi-res',
    '高音质',
    '高清',
    '原曲',
    '纯享',
    '动画版',
  ];

  /// 标题里出现这些词通常是剪辑 / 拼接 / 非原曲，扣分。
  static const List<String> _clipMarkers = <String>[
    '剪辑',
    '片段',
    '试听',
    '一分钟',
    'cut',
    '合集',
    '串烧',
    'remix',
    'dj',
    '鬼畜',
    '伴奏',
    '加速',
    '减速',
    '翻唱',
    '改编',
  ];

  static final RegExp _ignoredCharacters = RegExp(
    r'''[\s\-_/\\.。，,、:：!！?？"'`~@#%&*+=|<>()\[\]{}（）【】「」『』《》]''',
  );

  static SearchResultItem? pickBest({
    required MatchableTrack track,
    required List<SearchResultItem> candidates,
  }) {
    SearchResultItem? best;
    _MatchScore? bestScore;
    for (final SearchResultItem candidate in candidates) {
      final _MatchScore score = _score(track: track, item: candidate);
      if (!score.isConfident) {
        continue;
      }
      if (bestScore == null || score.isBetterThan(bestScore)) {
        best = candidate;
        bestScore = score;
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
    final int trackSeconds = track.durationSeconds;
    if (!_isUsableDuration(trackSeconds, candidateSeconds)) {
      return const _MatchScore.rejected();
    }

    final String title = normalize(track.title);
    final String artist = normalize(track.artist);
    final String candidate = normalize(item.title);
    final bool titleMatched = title.isNotEmpty && candidate.contains(title);
    final bool artistMatched = artist.isNotEmpty && candidate.contains(artist);

    int durationScore = 0;
    int durationDiff = -1;
    bool durationClose = false;
    if (trackSeconds > 0 && candidateSeconds > 0) {
      durationDiff = (trackSeconds - candidateSeconds).abs();
      if (durationDiff <= _exactDurationWindowSeconds) {
        durationScore = _exactDurationScore;
        durationClose = true;
      } else if (durationDiff <= _closeDurationWindowSeconds) {
        durationScore = _closeDurationScore;
        durationClose = true;
      } else if (durationDiff <= _nearDurationWindowSeconds) {
        durationScore = _nearDurationScore;
        durationClose = true;
      }
    }

    final int keywordScore = _keywordScore(candidate);
    final int total =
        (titleMatched ? _titleScore : 0) +
        (artistMatched ? _artistScore : 0) +
        durationScore +
        keywordScore;
    final bool isConfident = titleMatched || (artistMatched && durationClose);
    return _MatchScore(
      total: total,
      isConfident: isConfident,
      durationDiff: durationDiff,
      playCount: _parsePlayCount(item.playCountText),
    );
  }

  /// 时长门槛：太短（剪辑）或比原曲长太多（拼接）都不收。
  ///
  /// [candidateSeconds] 为 0 表示解析不出时长，这时不做判断，保持宽容。
  static bool _isUsableDuration(int trackSeconds, int candidateSeconds) {
    if (candidateSeconds <= 0) {
      return true;
    }
    if (candidateSeconds < minimumClipSeconds) {
      return false;
    }
    if (trackSeconds <= 0) {
      return true;
    }
    final double ratio = candidateSeconds / trackSeconds;
    return ratio >= minimumDurationRatio && ratio <= maximumDurationRatio;
  }

  /// 标题关键词加减分：完整版 / MV 加分，剪辑 / 翻唱扣分。
  static int _keywordScore(String normalizedTitle) {
    int score = 0;
    for (final String marker in _completeMarkers) {
      if (normalizedTitle.contains(marker)) {
        score += _completeBonus;
        break;
      }
    }
    for (final String marker in _clipMarkers) {
      if (normalizedTitle.contains(marker)) {
        score += _clipPenalty;
        break;
      }
    }
    return score;
  }

  /// 播放量文案（如 `4.1万`、`5097`）换算成数字，用来做同分时的质量偏好。
  static int _parsePlayCount(String text) {
    final String value = text.trim();
    if (value.isEmpty) {
      return 0;
    }
    if (value.endsWith('亿')) {
      final double? number = double.tryParse(
        value.substring(0, value.length - 1),
      );
      return number == null ? 0 : (number * 100000000).round();
    }
    if (value.endsWith('万')) {
      final double? number = double.tryParse(
        value.substring(0, value.length - 1),
      );
      return number == null ? 0 : (number * 10000).round();
    }
    return int.tryParse(value) ?? 0;
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
  const _MatchScore({
    required this.total,
    required this.isConfident,
    required this.durationDiff,
    required this.playCount,
  });

  const _MatchScore.rejected()
    : total = 0,
      isConfident = false,
      durationDiff = -1,
      playCount = 0;

  final int total;
  final bool isConfident;

  /// 与原曲的时长差（秒），未知时是 -1。
  final int durationDiff;
  final int playCount;

  /// 分数高的优先；同分时选时长更接近的，再选播放量更高的。
  bool isBetterThan(_MatchScore other) {
    if (total != other.total) {
      return total > other.total;
    }
    if (durationDiff >= 0 && other.durationDiff >= 0) {
      if (durationDiff != other.durationDiff) {
        return durationDiff < other.durationDiff;
      }
    } else if (durationDiff >= 0 != (other.durationDiff >= 0)) {
      return durationDiff >= 0;
    }
    return playCount > other.playCount;
  }
}
