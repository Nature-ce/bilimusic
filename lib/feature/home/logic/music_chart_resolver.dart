import 'dart:async';
import 'dart:math';

import 'package:bilimusic/core/hive/hive_keys.dart';
import 'package:bilimusic/core/net/bili_client.dart';
import 'package:bilimusic/feature/home/data/track_match_cache.dart';
import 'package:bilimusic/feature/home/domain/matchable_track.dart';
import 'package:bilimusic/feature/home/logic/chart_track_matcher.dart';
import 'package:bilimusic/feature/player/data/bili_player_repository.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/search/data/bili_search_repository.dart';
import 'package:bilimusic/feature/search/domain/search_page_result.dart';
import 'package:bilimusic/feature/search/domain/search_result_item.dart';
import 'package:bilimusic/feature/search/logic/search_controller.dart';
import 'package:bilimusic/feature/search/logic/search_guard.dart';
import 'package:dio/dio.dart';
import 'package:hive_ce/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'music_chart_resolver.g.dart';

/// 搜索被 B 站限流时抛出：调用方据此提示用户，而不是继续硬搜。
class MatchRateLimitedException implements Exception {
  const MatchRateLimitedException(this.retryAfter);

  final Duration retryAfter;

  @override
  String toString() => '搜索被限流，约 ${retryAfter.inSeconds} 秒后可重试';
}

@Riverpod(keepAlive: true)
MusicChartResolver musicChartResolver(Ref ref) {
  return MusicChartResolver(
    searchRepository: ref.read(biliSearchRepositoryProvider),
    playerRepository: ref.read(biliPlayerRepositoryProvider),
    cache: TrackMatchCache(Hive.box<String>(HiveBoxNames.prefs)),
    guard: ref.read(searchGuardProvider.notifier),
  );
}

class MusicChartResolver {
  MusicChartResolver({
    required this.searchRepository,
    required this.playerRepository,
    this.cache,
    this.guard,
    this.baseSearchInterval = const Duration(milliseconds: 1000),
    this.maxSearchInterval = const Duration(seconds: 3),
    this.cooldown = const Duration(seconds: 45),
    this.maxCooldown = const Duration(minutes: 3),
  }) : _interval = baseSearchInterval;

  final BiliSearchRepository searchRepository;
  final BiliPlayerRepository playerRepository;

  /// 匹配结果缓存：同一个歌单再点一次「播放全部」不用重新搜 B 站。
  final TrackMatchCache? cache;

  /// 与搜索页共用的限流熔断状态。
  final SearchGuard? guard;

  final Duration baseSearchInterval;
  final Duration maxSearchInterval;

  /// 被限流后暂停搜索的初始时长，连续被限会翻倍（上限 [maxCooldown]）。
  final Duration cooldown;
  final Duration maxCooldown;

  static const Duration _searchCacheTtl = Duration(minutes: 10);
  static const int _searchCacheMax = 60;
  static const int _successesBeforeSpeedUp = 8;

  final Random _random = Random();
  final Map<String, _CachedSearch> _searchCache = <String, _CachedSearch>{};

  Duration _interval;
  Future<void> _gate = Future<void>.value();
  DateTime _nextAllowedAt = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime? _cooldownUntil;
  Duration _currentCooldown = Duration.zero;
  int _healthySearches = 0;

  Future<PlayableItem?> resolve(MatchableTrack track) async {
    final PlayableItem? directItem = track.directItem;
    if (directItem != null) {
      return directItem;
    }
    final TrackMatchCache? matchCache = cache;
    if (matchCache != null) {
      final PlayableItem? cached = matchCache.readHit(track);
      if (cached != null) {
        return cached;
      }
      if (matchCache.isFreshMiss(track)) {
        return null;
      }
    }
    SearchResultItem? match = await _searchBest(track.searchKeyword, track);
    if (match == null) {
      final SearchPageResult? result = await _searchCached(track.title);
      if (result != null) {
        match =
            ChartTrackMatcher.pickBest(
              track: track,
              candidates: result.items,
            ) ??
            ChartTrackMatcher.pickTitleFallback(
              track: track,
              candidates: result.items,
            );
      }
    }
    if (match == null) {
      await matchCache?.writeMiss(track);
      return null;
    }
    final PlayableItem item = await playerRepository.resolvePreferredPart(
      match.toPlayableItem(),
      preferredPage: 1,
      expectedTitle: track.title,
      expectedArtist: track.artist,
    );
    await matchCache?.writeHit(track, item);
    return item;
  }

  Future<SearchResultItem?> _searchBest(
    String keyword,
    MatchableTrack track,
  ) async {
    final SearchPageResult? result = await _searchCached(keyword);
    if (result == null) {
      return null;
    }
    return ChartTrackMatcher.pickBest(track: track, candidates: result.items);
  }

  Future<SearchPageResult?> _searchCached(String rawKeyword) async {
    final String keyword = rawKeyword.trim();
    if (keyword.isEmpty) {
      return null;
    }
    final _CachedSearch? cached = _searchCache[keyword];
    if (cached != null && !cached.isExpired(_searchCacheTtl)) {
      return cached.result;
    }
    return _runSerialized(() async {
      await _waitForTurn();
      try {
        final SearchPageResult result = await searchRepository.searchVideos(
          keyword,
        );
        _onSearchSucceeded();
        _searchCache[keyword] = _CachedSearch(
          result: result,
          at: DateTime.now(),
        );
        _pruneSearchCache();
        return result;
      } on Object catch (error) {
        if (_looksRateLimited(error)) {
          _onRateLimited();
        } else {
          _onSearchFailed();
        }
        rethrow;
      }
    });
  }

  /// 所有搜索串行执行：并发调用会排队等前一次结束，不会被识别成扫库。
  Future<T> _runSerialized<T>(Future<T> Function() action) {
    final Completer<T> completer = Completer<T>();
    _gate = _gate.then((_) async {
      try {
        completer.complete(await action());
      } on Object catch (error, stackTrace) {
        completer.completeError(error, stackTrace);
      }
    });
    return completer.future;
  }

  Future<void> _waitForTurn() async {
    final SearchGuard? sharedGuard = guard;
    if (sharedGuard != null && sharedGuard.isBlocked) {
      throw MatchRateLimitedException(sharedGuard.remaining);
    }
    final DateTime now = DateTime.now();
    final DateTime? until = _cooldownUntil;
    if (until != null && now.isBefore(until)) {
      throw MatchRateLimitedException(until.difference(now));
    }
    if (now.isBefore(_nextAllowedAt)) {
      await Future<void>.delayed(_nextAllowedAt.difference(now));
    }
    final int jitterMs = 120 + _random.nextInt(180);
    _nextAllowedAt = DateTime.now()
        .add(_interval)
        .add(Duration(milliseconds: jitterMs));
  }

  void _onSearchSucceeded() {
    guard?.markHealthy();
    _healthySearches += 1;
    if (_healthySearches < _successesBeforeSpeedUp) {
      return;
    }
    _healthySearches = 0;
    final int next = (_interval.inMilliseconds * 0.85).round().clamp(
      baseSearchInterval.inMilliseconds,
      maxSearchInterval.inMilliseconds,
    );
    _interval = Duration(milliseconds: next);
  }

  void _onSearchFailed() {
    _healthySearches = 0;
  }

  void _onRateLimited() {
    _healthySearches = 0;
    final int doubled = _interval.inMilliseconds * 2;
    _interval = Duration(
      milliseconds: doubled.clamp(
        baseSearchInterval.inMilliseconds,
        maxSearchInterval.inMilliseconds,
      ),
    );
    final Duration previous = _currentCooldown;
    final Duration next = previous == Duration.zero
        ? cooldown
        : Duration(
            milliseconds: (previous.inMilliseconds * 2).clamp(
              cooldown.inMilliseconds,
              maxCooldown.inMilliseconds,
            ),
          );
    _currentCooldown = next;
    _cooldownUntil = DateTime.now().add(next);
    _nextAllowedAt = _cooldownUntil!;
    guard?.markLimited(next);
  }

  bool _looksRateLimited(Object error) {
    if (error is MatchRateLimitedException) {
      return true;
    }
    if (error is BiliApiException) {
      final int? code = error.code;
      return code == -412 ||
          code == -509 ||
          code == -351 ||
          code == -352 ||
          code == -429;
    }
    if (error is DioException) {
      final int status = error.response?.statusCode ?? 0;
      return status == 412 || status == 429 || status == 503;
    }
    final String text = error.toString();
    return text.contains('-412') ||
        text.contains('-509') ||
        text.contains('412') ||
        text.contains('429');
  }

  void _pruneSearchCache() {
    if (_searchCache.length <= _searchCacheMax) {
      return;
    }
    final List<String> expired = <String>[
      for (final MapEntry<String, _CachedSearch> entry in _searchCache.entries)
        if (entry.value.isExpired(_searchCacheTtl)) entry.key,
    ];
    for (final String key in expired) {
      _searchCache.remove(key);
    }
    while (_searchCache.length > _searchCacheMax) {
      _searchCache.remove(_searchCache.keys.first);
    }
  }
}

class _CachedSearch {
  const _CachedSearch({required this.result, required this.at});

  final SearchPageResult result;
  final DateTime at;

  bool isExpired(Duration ttl) => DateTime.now().difference(at) > ttl;
}
