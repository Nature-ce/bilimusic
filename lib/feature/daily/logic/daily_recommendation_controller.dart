import 'dart:async';
import 'dart:math';

import 'package:bilimusic/core/hive/hive_keys.dart';
import 'package:bilimusic/feature/daily/data/daily_recommendation_store.dart';
import 'package:bilimusic/feature/daily/domain/daily_recommendation.dart';
import 'package:bilimusic/feature/daily/domain/daily_recommendation_state.dart';
import 'package:bilimusic/feature/home/domain/hot_playlist_track.dart';
import 'package:bilimusic/feature/home/logic/chart_track_matcher.dart';
import 'package:bilimusic/feature/home/logic/music_chart_resolver.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/radar/data/radar_pool_loader.dart';
import 'package:bilimusic/feature/radar/domain/radar_pick.dart';
import 'package:bilimusic/feature/radar/domain/radar_taste.dart';
import 'package:bilimusic/feature/radar/logic/radar_recommender.dart';
import 'package:bilimusic/feature/radar/logic/radar_taste_provider.dart';
import 'package:bilimusic/feature/search/data/bili_search_repository.dart';
import 'package:bilimusic/feature/search/domain/search_page_result.dart';
import 'package:bilimusic/feature/search/domain/search_result_item.dart';
import 'package:bilimusic/feature/search/logic/search_controller.dart';
import 'package:hive_ce/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'daily_recommendation_controller.g.dart';

@riverpod
DailyRecommendationStore dailyRecommendationStore(Ref ref) {
  return DailyRecommendationStore(Hive.box<String>(HiveBoxNames.prefs));
}

typedef DailyNow = DateTime Function();

/// 可替换的「今天」来源：生成与跨天判断都从这里取，测试里能固定 / 推进日期。
@riverpod
DailyNow dailyNow(Ref ref) => DateTime.now;

@riverpod
Random dailyRecommendationRandom(Ref ref) => Random();

@riverpod
RadarRecommender dailyRecommendationRecommender(Ref ref) {
  return const RadarRecommender();
}

/// 每日推荐：当天第一份生成后存进 prefs，之后重启、切页面都读同一份；
/// `dateKey` 不是今天就重新生成。
@Riverpod(keepAlive: true)
class DailyRecommendationController extends _$DailyRecommendationController {
  static const int pickCount = 30;
  static const int maxPoolWaves = 6;
  static const int _resolveConcurrency = 4;
  static const int _maxResolveAttempts = pickCount * 3;
  static const int _topUpWaves = 2;

  /// 小于这个秒数的时长基本不可信（片段/试听），回填时允许用 B 站匹配结果纠正。
  static const int _minimumPlausibleDuration = 60;

  bool _isGenerating = false;
  bool _isBackfillingCovers = false;

  @override
  DailyRecommendationState build() {
    unawaited(Future<void>.microtask(load));
    return const DailyRecommendationState();
  }

  /// 优先用本地当天那份；没有或已跨天就重新生成。
  Future<void> load() async {
    final String today = _todayKey();
    final DailyRecommendation? stored = _readStored();
    final bool storedHasGenericTitles =
        stored?.picks.any(
          (DailyPick pick) => ChartTrackMatcher.isGenericTitle(pick.title),
        ) ??
        false;
    // 老版本存下来的推荐没有预解析 B 站视频，交给 resolvePending() 补上，
    // 不必重新生成——当天这份内容保持不变。
    if (stored != null &&
        stored.dateKey == today &&
        stored.picks.isNotEmpty &&
        !storedHasGenericTitles) {
      state = DailyRecommendationState(
        picks: List<DailyPick>.unmodifiable(stored.picks),
        isLoading: false,
        dateKey: stored.dateKey,
        generatedAtEpochMs: stored.generatedAtEpochMs,
      );
      unawaited(backfillCovers());
      unawaited(resolvePending());
      return;
    }
    await generate();
  }

  /// 页面重新打开时兜底检查：跨天、出错、还没拿到数据都重新拉一次。
  Future<void> ensureUpToDate() async {
    if (_isGenerating) {
      return;
    }
    final String today = _todayKey();
    if (!state.hasError && state.picks.isNotEmpty && state.dateKey == today) {
      return;
    }
    await load();
  }

  Future<void> retry() => generate();

  Future<void> generate() async {
    if (_isGenerating) {
      return;
    }
    _isGenerating = true;
    state = state.copyWith(isLoading: true, errorMessage: null);
    final DateTime now = ref.read(dailyNowProvider)();
    final String today = dailyDateKey(now);
    try {
      final Random random = ref.read(dailyRecommendationRandomProvider);
      final RadarPoolLoader loader = ref.read(radarPoolLoaderProvider);
      final RadarRecommender recommender = ref.read(
        dailyRecommendationRecommenderProvider,
      );
      final RadarTaste taste = await ref.read(radarTasteProvider.future);
      final List<DailyPick> picks = <DailyPick>[];
      final Set<String> seenTrackKeys = <String>{};
      final Set<String> seenKeys = <String>{};
      for (
        int wave = 0;
        wave < maxPoolWaves && picks.length < pickCount;
        wave += 1
      ) {
        final RadarPoolResult pool = await loader.load(random: random);
        final List<HotPlaylistTrack> usableTracks = pool.tracks
            .where(
              (HotPlaylistTrack track) =>
                  !ChartTrackMatcher.isGenericTitle(track.title) &&
                  !ChartTrackMatcher.looksLikeVariant(
                    title: track.title,
                    artist: track.artist,
                  ),
            )
            .toList(growable: false);
        if (usableTracks.isEmpty) {
          continue;
        }
        final List<RadarPick> wavePicks = recommender.pick(
          pool: usableTracks,
          taste: taste,
          limit: pickCount - picks.length,
          random: random,
          excludeKeys: seenTrackKeys,
        );
        for (final RadarPick pick in wavePicks) {
          seenTrackKeys.add(pick.track.key);
          final DailyPick dailyPick = _toDailyPick(pick);
          if (seenKeys.add(dailyPick.key)) {
            picks.add(dailyPick);
          }
        }
      }
      if (!ref.mounted) {
        return;
      }
      if (picks.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: '每日推荐生成失败，请稍后重试',
        );
        return;
      }
      final DailyRecommendation recommendation = DailyRecommendation(
        dateKey: today,
        generatedAtEpochMs: now.millisecondsSinceEpoch,
        picks: picks,
      );
      try {
        await ref.read(dailyRecommendationStoreProvider).save(recommendation);
      } on Object {
        // 存不进去也不影响今天先听这一份。
      }
      if (!ref.mounted) {
        return;
      }
      state = DailyRecommendationState(
        picks: List<DailyPick>.unmodifiable(picks),
        isLoading: false,
        dateKey: today,
        generatedAtEpochMs: recommendation.generatedAtEpochMs,
      );
      unawaited(backfillCovers());
      unawaited(resolvePending());
    } on Object {
      if (!ref.mounted) {
        return;
      }
      state = state.copyWith(isLoading: false, errorMessage: '每日推荐生成失败，请稍后重试');
    } finally {
      _isGenerating = false;
    }
  }

  DailyRecommendation? _readStored() {
    try {
      return ref.read(dailyRecommendationStoreProvider).load();
    } on Object {
      return null;
    }
  }

  /// 源接口偶尔不给封面（coverUrl 为空），用 B 站匹配到的视频封面回填并落盘。
  Future<void> backfillCovers({int maxTracks = 8}) async {
    if (_isBackfillingCovers) {
      return;
    }
    final List<DailyPick> missing = state.picks
        .where(
          (DailyPick pick) =>
              pick.coverUrl.trim().isEmpty ||
              pick.durationSeconds < _minimumPlausibleDuration,
        )
        .take(maxTracks)
        .toList(growable: false);
    if (missing.isEmpty) {
      return;
    }
    _isBackfillingCovers = true;
    try {
      final BiliSearchRepository repository = ref.read(
        biliSearchRepositoryProvider,
      );
      final Map<String, SearchResultItem> matches =
          <String, SearchResultItem>{};
      for (final DailyPick pick in missing) {
        if (!ref.mounted) {
          return;
        }
        try {
          final SearchPageResult result = await repository.searchVideos(
            pick.searchKeyword,
          );
          final SearchResultItem? match = ChartTrackMatcher.pickBest(
            track: pick,
            candidates: result.items,
          );
          if (match != null) {
            matches[pick.key] = match;
          }
        } on Object {
          // 单首失败不影响其它曲目。
        }
      }
      if (!ref.mounted || matches.isEmpty) {
        return;
      }
      final List<DailyPick> updated = <DailyPick>[
        for (final DailyPick pick in state.picks)
          _backfilled(pick, matches[pick.key]),
      ];
      state = state.copyWith(picks: List<DailyPick>.unmodifiable(updated));
      await _persistPicks(updated);
    } on Object {
      // 回填只是锦上添花，失败不影响已展示的推荐。
    } finally {
      _isBackfillingCovers = false;
    }
  }

  /// 用 B 站匹配结果补封面/纠正离谱时长（源接口偶尔给 00:29 这种片段时长）。
  DailyPick _backfilled(DailyPick pick, SearchResultItem? match) {
    if (match == null) {
      return pick;
    }
    final bool needCover = pick.coverUrl.trim().isEmpty;
    final bool needDuration = pick.durationSeconds < _minimumPlausibleDuration;
    if (!needCover && !needDuration) {
      return pick;
    }
    final int matchSeconds = ChartTrackMatcher.parseDurationSeconds(
      match.duration,
    );
    return pick.copyWith(
      coverUrl: needCover && match.coverUrl.trim().isNotEmpty
          ? match.coverUrl.trim()
          : pick.coverUrl,
      durationSeconds: needDuration && matchSeconds > 0
          ? matchSeconds
          : pick.durationSeconds,
    );
  }

  Future<void> _persistPicks(List<DailyPick> picks) async {
    try {
      await ref
          .read(dailyRecommendationStoreProvider)
          .save(
            DailyRecommendation(
              dateKey: state.dateKey,
              generatedAtEpochMs: state.generatedAtEpochMs,
              picks: picks,
            ),
          );
    } on Object {
      // 落盘失败不影响当前展示。
    }
  }

  String _todayKey() => dailyDateKey(ref.read(dailyNowProvider)());

  DailyPick _toDailyPick(RadarPick pick) {
    final HotPlaylistTrack track = pick.track;
    return DailyPick(
      title: track.title,
      artist: track.artist,
      reason: pick.reason,
      coverUrl: track.coverUrl,
      durationSeconds: track.durationSeconds,
      platform: track.playlist.platform.name,
      reasonDetail: pick.reasonDetail,
    );
  }

  /// 生成阶段解析 B 站视频；解析不出来（或没拿到有效视频）返回 null，
  /// 由调用方丢弃并用下一批候选补齐。
  Future<DailyPick?> _resolveDailyPick(
    DailyPick pick,
    MusicChartResolver resolver,
  ) async {
    try {
      final PlayableItem? item = await resolver.resolve(pick);
      if (item == null || !item.hasIdentity) {
        return null;
      }
      return pick.copyWith(
        bvid: item.bvid,
        aid: item.aid,
        cid: item.cid,
        page: item.page,
        videoTitle: item.title,
        videoAuthor: item.author,
        videoCoverUrl: item.coverUrl,
        videoDurationText: item.durationText ?? '',
      );
    } on Object {
      return null;
    }
  }

  Future<void>? _resolveTask;

  /// 把还没解析出 B 站视频的推荐补齐并落盘。
  ///
  /// 每日推荐当天不再变化，所以匹配一次就够：页面打开时后台跑一遍，
  /// 「播放全部」前 await 一次，之后都直接用缓存，不再每次播放都重新搜。
  Future<void> resolvePending() {
    return _resolveTask ??= _runResolvePending().whenComplete(
      () => _resolveTask = null,
    );
  }

  Future<void> _runResolvePending() async {
    if (state.picks.isEmpty) {
      return;
    }
    final List<DailyPick> unresolved = state.picks
        .where((DailyPick pick) => !pick.isResolved)
        .toList(growable: false);
    if (unresolved.isEmpty) {
      return;
    }
    final MusicChartResolver resolver = ref.read(musicChartResolverProvider);
    for (
      int start = 0;
      start < unresolved.length;
      start += _resolveConcurrency
    ) {
      if (!ref.mounted) {
        return;
      }
      final int end = min(start + _resolveConcurrency, unresolved.length);
      final List<DailyPick?> results = await Future.wait(
        unresolved
            .sublist(start, end)
            .map((DailyPick pick) => _resolveDailyPick(pick, resolver)),
      );
      final List<DailyPick> resolved = <DailyPick>[
        for (final DailyPick? pick in results) ?pick,
      ];
      if (resolved.isNotEmpty) {
        await _applyResolvedPicks(resolved);
      }
      await Future<void>.delayed(const Duration(milliseconds: 120));
    }
    await _topUpUnresolvedPicks();
  }

  Future<void> _applyResolvedPicks(List<DailyPick> resolved) async {
    if (!ref.mounted) {
      return;
    }
    final Map<String, DailyPick> byKey = <String, DailyPick>{
      for (final DailyPick pick in resolved) pick.key: pick,
    };
    final List<DailyPick> next = state.picks
        .map((DailyPick pick) => byKey[pick.key] ?? pick)
        .toList(growable: false);
    state = state.copyWith(picks: List<DailyPick>.unmodifiable(next));
    await _persistPicks(next);
  }

  /// 匹配不上的推荐用新候选替换掉：只多拉一两波池子，避免无限重试。
  Future<void> _topUpUnresolvedPicks() async {
    if (!ref.mounted) {
      return;
    }
    final int missing = state.picks
        .where((DailyPick pick) => !pick.isResolved)
        .length;
    if (missing == 0) {
      return;
    }
    final Random random = ref.read(dailyRecommendationRandomProvider);
    final RadarPoolLoader loader = ref.read(radarPoolLoaderProvider);
    final RadarRecommender recommender = ref.read(
      dailyRecommendationRecommenderProvider,
    );
    final RadarTaste taste = await ref.read(radarTasteProvider.future);
    final MusicChartResolver resolver = ref.read(musicChartResolverProvider);
    final Set<String> existingKeys = state.picks
        .map((DailyPick pick) => pick.key)
        .toSet();
    final Set<String> excludedTrackKeys = <String>{};
    final List<DailyPick> replacements = <DailyPick>[];
    int attempts = 0;
    for (
      int wave = 0;
      wave < _topUpWaves &&
          replacements.length < missing &&
          attempts < _maxResolveAttempts;
      wave += 1
    ) {
      if (!ref.mounted) {
        return;
      }
      final RadarPoolResult pool = await loader.load(random: random);
      final List<HotPlaylistTrack> usable = pool.tracks
          .where(
            (HotPlaylistTrack track) =>
                !ChartTrackMatcher.isGenericTitle(track.title) &&
                !ChartTrackMatcher.looksLikeVariant(
                  title: track.title,
                  artist: track.artist,
                ),
          )
          .toList(growable: false);
      if (usable.isEmpty) {
        continue;
      }
      final List<RadarPick> candidates = recommender.pick(
        pool: usable,
        taste: taste,
        limit: missing - replacements.length,
        random: random,
        excludeKeys: excludedTrackKeys,
      );
      for (final RadarPick pick in candidates) {
        excludedTrackKeys.add(pick.track.key);
        final DailyPick candidate = _toDailyPick(pick);
        if (!existingKeys.add(candidate.key)) {
          continue;
        }
        attempts += 1;
        if (attempts > _maxResolveAttempts) {
          break;
        }
        final DailyPick? resolved = await _resolveDailyPick(
          candidate,
          resolver,
        );
        if (resolved != null) {
          replacements.add(resolved);
        }
        if (replacements.length >= missing) {
          break;
        }
      }
    }
    if (replacements.isEmpty || !ref.mounted) {
      return;
    }
    final List<DailyPick> unresolvedReplacements = List<DailyPick>.of(
      replacements,
    );
    final List<DailyPick> next = <DailyPick>[];
    for (final DailyPick pick in state.picks) {
      if (pick.isResolved) {
        next.add(pick);
        continue;
      }
      next.add(
        unresolvedReplacements.isNotEmpty
            ? unresolvedReplacements.removeAt(0)
            : pick,
      );
    }
    state = state.copyWith(picks: List<DailyPick>.unmodifiable(next));
    await _persistPicks(next);
  }
}
