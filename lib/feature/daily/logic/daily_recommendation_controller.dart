import 'dart:async';
import 'dart:math';

import 'package:bilimusic/core/hive/hive_keys.dart';
import 'package:bilimusic/feature/daily/data/daily_recommendation_store.dart';
import 'package:bilimusic/feature/daily/domain/daily_recommendation.dart';
import 'package:bilimusic/feature/daily/domain/daily_recommendation_state.dart';
import 'package:bilimusic/feature/home/domain/hot_playlist_track.dart';
import 'package:bilimusic/feature/home/logic/chart_track_matcher.dart';
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
  static const int maxPoolWaves = 3;

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
    if (stored != null && stored.dateKey == today && stored.picks.isNotEmpty) {
      state = DailyRecommendationState(
        picks: List<DailyPick>.unmodifiable(stored.picks),
        isLoading: false,
        dateKey: stored.dateKey,
        generatedAtEpochMs: stored.generatedAtEpochMs,
      );
      unawaited(backfillCovers());
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
        if (pool.tracks.isEmpty) {
          continue;
        }
        final List<RadarPick> wavePicks = recommender.pick(
          pool: pool.tracks,
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
}
