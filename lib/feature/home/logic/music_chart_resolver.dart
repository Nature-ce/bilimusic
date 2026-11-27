import 'package:bilimusic/core/hive/hive_keys.dart';
import 'package:bilimusic/feature/home/data/track_match_cache.dart';
import 'package:bilimusic/feature/home/domain/matchable_track.dart';
import 'package:bilimusic/feature/home/logic/chart_track_matcher.dart';
import 'package:bilimusic/feature/player/data/bili_player_repository.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/search/data/bili_search_repository.dart';
import 'package:bilimusic/feature/search/domain/search_page_result.dart';
import 'package:bilimusic/feature/search/domain/search_result_item.dart';
import 'package:bilimusic/feature/search/logic/search_controller.dart';
import 'package:hive_ce/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'music_chart_resolver.g.dart';

@riverpod
MusicChartResolver musicChartResolver(Ref ref) {
  return MusicChartResolver(
    searchRepository: ref.read(biliSearchRepositoryProvider),
    playerRepository: ref.read(biliPlayerRepositoryProvider),
    cache: TrackMatchCache(Hive.box<String>(HiveBoxNames.prefs)),
  );
}

class MusicChartResolver {
  MusicChartResolver({
    required this.searchRepository,
    required this.playerRepository,
    this.cache,
    this.minSearchInterval = const Duration(milliseconds: 260),
  });

  final BiliSearchRepository searchRepository;
  final BiliPlayerRepository playerRepository;

  /// 匹配结果缓存：同一个歌单再点一次「播放全部」不用重新搜 B 站，
  /// 也不会因为连续搜索被风控打成「全部匹配不到」。
  final TrackMatchCache? cache;

  /// 两次搜索之间的最小间隔，避免瞬时并发把 B 站搜索接口触发限流。
  final Duration minSearchInterval;

  DateTime _lastSearchAt = DateTime.fromMillisecondsSinceEpoch(0);

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
    final SearchResultItem? match =
        await _searchBest(track.searchKeyword, track) ??
        await _searchBest(track.title, track) ??
        await _searchTitleFallback(track);
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

  /// 严格规则找不到时，只按歌名找完整版（平台歌手本身是翻唱/搬运时用）。
  Future<SearchResultItem?> _searchTitleFallback(MatchableTrack track) async {
    final String keyword = track.title.trim();
    if (keyword.isEmpty) {
      return null;
    }
    final SearchPageResult result = await _search(keyword);
    return ChartTrackMatcher.pickTitleFallback(
      track: track,
      candidates: result.items,
    );
  }

  Future<SearchResultItem?> _searchBest(
    String keyword,
    MatchableTrack track,
  ) async {
    final String trimmedKeyword = keyword.trim();
    if (trimmedKeyword.isEmpty) {
      return null;
    }
    final SearchPageResult result = await _search(trimmedKeyword);
    return ChartTrackMatcher.pickBest(track: track, candidates: result.items);
  }

  Future<SearchPageResult> _search(String keyword) async {
    await _throttle();
    return searchRepository.searchVideos(keyword);
  }

  Future<void> _throttle() async {
    final Duration elapsed = DateTime.now().difference(_lastSearchAt);
    final Duration wait = minSearchInterval - elapsed;
    if (wait > Duration.zero) {
      await Future<void>.delayed(wait);
    }
    _lastSearchAt = DateTime.now();
  }
}
