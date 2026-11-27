import 'package:bilimusic/feature/home/domain/matchable_track.dart';
import 'package:bilimusic/feature/home/logic/chart_track_matcher.dart';
import 'package:bilimusic/feature/player/data/bili_player_repository.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/search/data/bili_search_repository.dart';
import 'package:bilimusic/feature/search/domain/search_page_result.dart';
import 'package:bilimusic/feature/search/domain/search_result_item.dart';
import 'package:bilimusic/feature/search/logic/search_controller.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'music_chart_resolver.g.dart';

@riverpod
MusicChartResolver musicChartResolver(Ref ref) {
  return MusicChartResolver(
    searchRepository: ref.read(biliSearchRepositoryProvider),
    playerRepository: ref.read(biliPlayerRepositoryProvider),
  );
}

class MusicChartResolver {
  const MusicChartResolver({
    required this.searchRepository,
    required this.playerRepository,
  });

  final BiliSearchRepository searchRepository;
  final BiliPlayerRepository playerRepository;

  Future<PlayableItem?> resolve(MatchableTrack track) async {
    final PlayableItem? directItem = track.directItem;
    if (directItem != null) {
      return directItem;
    }
    final SearchResultItem? match =
        await _searchBest(track.searchKeyword, track) ??
        await _searchBest(track.title, track) ??
        await _searchTitleFallback(track);
    if (match == null) {
      return null;
    }
    return playerRepository.resolvePreferredPart(
      match.toPlayableItem(),
      preferredPage: 1,
      expectedTitle: track.title,
      expectedArtist: track.artist,
    );
  }

  /// 严格规则找不到时，只按歌名找完整版（平台歌手本身是翻唱/搬运时用）。
  Future<SearchResultItem?> _searchTitleFallback(MatchableTrack track) async {
    final String keyword = track.title.trim();
    if (keyword.isEmpty) {
      return null;
    }
    final SearchPageResult result = await searchRepository.searchVideos(
      keyword,
    );
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
    final SearchPageResult result = await searchRepository.searchVideos(
      trimmedKeyword,
    );
    return ChartTrackMatcher.pickBest(track: track, candidates: result.items);
  }
}
