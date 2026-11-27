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

  /// 这些是 B 站上到处都有的「通用曲名」，单靠标题包含会把不相干的合集判成命中。
  static const List<String> _genericTitleKeywords = <String>[
    '催眠曲',
    '纯音乐',
    '白噪音',
    '白噪声',
    '轻音乐',
    '助眠曲',
    '助眠',
    '睡眠曲',
    '冥想',
    '疗愈音乐',
    '摇篮曲',
  ];

  /// 候选时长 / 原曲时长 的允许区间：短于此值算剪辑，长于此值算拼接。
  /// 原曲时长不可信时，用「一首完整歌的合理区间」兜底：太短是片段，太长是合集。
  static const int _minimumPlausibleSongSeconds = 90;
  static const int _maximumPlausibleSongSeconds = 420;

  /// 认为是完整歌的时长下限（低于它的候选在兜底模式下不加分）。
  static const int _fullSongSeconds = 150;

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

  /// 明显不是「这首歌本身」的内容：游戏实况、攻略解说、搞笑剪辑等。
  /// 命中这些词时，只有歌手也对上才认，否则直接判为不匹配。
  static const List<String> _nonMusicMarkers = <String>[
    '游戏',
    '实况',
    '攻略',
    '解说',
    '直播回放',
    '录播',
    '搞笑',
    '吐槽',
    '速通',
  ];

  /// 同一首歌的「非原唱版本」标记：命中时要求歌手也对上，避免把翻唱/伴奏
  /// 当成原唱推出去。
  static const List<String> _variantMarkers = <String>[
    '翻唱',
    '翻自',
    'cover',
    '女声',
    '男声',
    '童声',
    '钢琴版',
    '吉他版',
    '尤克里里',
    '伴奏',
    'dj',
    'remix',
    '加速',
    '减速',
    'ai',
    '虚拟歌手',
  ];

  /// 归一化后长度不超过这个值算「短标题」（如「你的」「Fly」），
  /// 单靠标题包含太容易误判，必须同时命中歌手。
  static const int _shortTitleMaxLength = 3;

  /// 兜底匹配（只按歌名找完整版）要求的最短歌名，太短的不兜底。
  static const int _fallbackMinimumTitleLength = 4;

  static final RegExp _ignoredCharacters = RegExp(
    r'''[\s\-_/\\.。，,、:：!！?？"'`~@#%&*+=|<>()\[\]{}（）【】「」『』《》]''',
  );

  /// 通用曲名（催眠曲 / 摇篮曲 / 纯音乐…）在 B 站很难匹配到「同一首歌」，
  /// 推荐链路应该直接跳过，避免推荐了却播不出来。
  static bool isGenericTitle(String title) {
    final String normalized = normalize(title);
    return normalized.isNotEmpty && _genericTitleKeywords.contains(normalized);
  }

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

  /// 宽松兜底：只按歌名挑一个「完整版」视频。
  ///
  /// 平台给的歌手本身是翻唱/搬运时，严格规则会因「歌手对不上」而找不到，
  /// 这时改用歌名找候选：必须是完整歌时长、标题含歌名、不是剪辑/非音乐内容，
  /// 优先标题里带官方/MV/无损等标记的，再按播放量挑——通常就落到原唱版本。
  static SearchResultItem? pickTitleFallback({
    required MatchableTrack track,
    required List<SearchResultItem> candidates,
  }) {
    final String title = normalize(track.title);
    if (title.length < _fallbackMinimumTitleLength) {
      return null;
    }
    final String artist = normalize(track.artist);
    SearchResultItem? best;
    _MatchScore? bestScore;
    for (final SearchResultItem item in candidates) {
      final int seconds = parseDurationSeconds(item.duration);
      if (seconds > 0 &&
          (seconds < _minimumPlausibleSongSeconds ||
              seconds > _maximumPlausibleSongSeconds)) {
        continue;
      }
      final String candidateTitle = normalize(item.title);
      if (!candidateTitle.contains(title)) {
        continue;
      }
      if (_nonMusicMarkers.any(
        (String marker) => candidateTitle.contains(marker),
      )) {
        continue;
      }
      final bool artistMatched =
          artist.isNotEmpty &&
          (candidateTitle.contains(artist) ||
              normalize(item.author).contains(artist));
      final bool variantMarked = _variantMarkers.any(
        (String marker) => candidateTitle.contains(marker),
      );
      if (variantMarked && !artistMatched) {
        continue;
      }
      final _MatchScore score = _MatchScore(
        total: _keywordScore(candidateTitle) + (artistMatched ? 1 : 0),
        isConfident: true,
        durationDiff: -1,
        playCount: _parsePlayCount(item.playCountText),
      );
      if (bestScore == null || score.isBetterThan(bestScore)) {
        best = item;
        bestScore = score;
      }
    }
    return best;
  }

  /// 推荐链路用：标题或歌手带翻唱/伴奏/AI 等标记的，不作为「原唱」推荐。
  static bool looksLikeVariant({
    required String title,
    required String artist,
  }) {
    final String normalizedTitle = normalize(title);
    final String normalizedArtist = normalize(artist);
    return _variantMarkers.any(
      (String marker) =>
          normalizedTitle.contains(marker) || normalizedArtist.contains(marker),
    );
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
    final String candidateTitle = normalize(item.title);
    final String candidateAuthor = normalize(item.author);
    final bool titleMatched =
        title.isNotEmpty && candidateTitle.contains(title);
    final bool artistInTitle =
        artist.isNotEmpty && candidateTitle.contains(artist);
    final bool artistIsUploader =
        artist.length >= 2 &&
        candidateAuthor.isNotEmpty &&
        (candidateAuthor == artist || candidateAuthor.contains(artist));
    final bool artistMatched = artistInTitle || artistIsUploader;
    final bool exactTitleMatched = title.isNotEmpty && candidateTitle == title;
    final bool shortTitle = title.length <= _shortTitleMaxLength;
    final bool variantMarked = _variantMarkers.any(
      (String marker) => candidateTitle.contains(marker),
    );
    final bool nonMusicMarked = _nonMusicMarkers.any(
      (String marker) => candidateTitle.contains(marker),
    );

    final bool trackDurationUnreliable =
        trackSeconds > 0 && trackSeconds < minimumClipSeconds;

    int durationScore = 0;
    int durationDiff = -1;
    bool durationClose = false;
    if (trackDurationUnreliable && candidateSeconds > 0) {
      // 原曲时长不可信：把像完整歌的候选顶上去，避免同名的翻唱片段/短版抢先。
      if (candidateSeconds >= _fullSongSeconds) {
        durationScore = _exactDurationScore;
        durationClose = true;
      } else if (candidateSeconds >= _minimumPlausibleSongSeconds) {
        durationScore = _nearDurationScore;
      }
    } else if (trackSeconds > 0 && candidateSeconds > 0) {
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

    final int keywordScore = _keywordScore(candidateTitle);
    final int total =
        (titleMatched ? _titleScore : 0) +
        (artistMatched ? _artistScore : 0) +
        durationScore +
        keywordScore;
    // 标题必须命中；再要求「歌手命中」或「时长接近」二选一。
    // 之前的规则允许「歌手命中 + 时长接近」单独成立，会把同一位 UP 主的
    // 另一首歌（如推荐《光年之外》却播成《雾里》）判成命中。
    // 短标题 / 通用曲名 / 翻唱版本 / 非音乐内容再额外要求歌手命中，
    // 但「候选标题 == 歌名」这种完全同名的情况可以直接放行。
    final bool genericShortTitle =
        title.isNotEmpty && _genericTitleKeywords.contains(title);
    final bool isConfident =
        titleMatched &&
        (artistMatched || durationClose || exactTitleMatched) &&
        (!shortTitle || artistMatched || exactTitleMatched) &&
        (!genericShortTitle || artistMatched || exactTitleMatched) &&
        (!variantMarked || artistMatched || exactTitleMatched) &&
        (!nonMusicMarked || artistMatched);
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
    // 原曲时长本身可疑（榜单接口偶尔返回 00:29 这种片段/试听时长）时，
    // 比例过滤会把真正的完整版判成「太长」，改用「完整歌合理区间」兜底：
    // 一分钟上下的翻唱片段、几十分钟的合集都挡掉。
    if (trackSeconds < minimumClipSeconds) {
      // 合集/串烧直接不要；片段保留作兜底（没有完整版时才它上场）。
      return candidateSeconds <= _maximumPlausibleSongSeconds;
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
