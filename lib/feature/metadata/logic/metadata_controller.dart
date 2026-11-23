import 'dart:async';

import 'package:bilimusic/common/logger.dart';
import 'package:bilimusic/common/domain/meta_lyrics.dart';
import 'package:bilimusic/feature/favorites/logic/favorites_controller.dart';
import 'package:bilimusic/feature/metadata/data/metadata_cache_repository.dart';
import 'package:bilimusic/feature/metadata/data/metadata_resolver.dart';
import 'package:bilimusic/feature/metadata/domain/metadata.dart';
import 'package:bilimusic/feature/metadata/domain/metadata_state.dart';
import 'package:bilimusic/feature/metadata/logic/metadata_lookup_service.dart';
import 'package:bilimusic/feature/metadata/logic/metadata_query_context.dart';
import 'package:bilimusic/feature/meting/data/meting_repository.dart';
import 'package:bilimusic/feature/meting/domain/meting_search_item.dart';
import 'package:bilimusic/feature/meting/domain/meting_search_response.dart';
import 'package:bilimusic/feature/meting/domain/meting_server.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'metadata_controller.g.dart';

@Riverpod(keepAlive: true)
class MetadataController extends _$MetadataController {
  final AppLogger _logger = AppLogger('MetadataController');

  late final MetadataLookupService _lookupService = ref.read(
    metadataLookupServiceProvider,
  );

  int _generation = 0;

  @override
  MetadataState build() {
    ref.listen<PlayerState>(playerControllerProvider, (
      PlayerState? previous,
      PlayerState next,
    ) {
      final MetadataQueryContext? previousContext = _queryContextOf(previous);
      final MetadataQueryContext? nextContext = _queryContextOf(next);
      if (previousContext == null || nextContext == null) {
        if (previousContext == null && nextContext == null) {
          return;
        }
        unawaited(_loadCurrentItemMetadata());
        return;
      }
      if (previousContext.matches(nextContext)) {
        return;
      }
      unawaited(_loadCurrentItemMetadata());
    });
    final PlayerState playerState = ref.read(playerControllerProvider);
    final PlayableItem? item = playerState.currentItem;
    if (item != null) {
      final int generation = _generation;
      unawaited(
        Future<void>.microtask(() async {
          if (ref.mounted && generation == _generation) {
            await _loadCurrentItemMetadata();
          }
        }),
      );
    }
    return MetadataState(stableId: item?.stableId, isLoading: item != null);
  }

  Future<void> retryCurrent() async {
    final PlayerState playerState = ref.read(playerControllerProvider);
    await _loadForItem(playerState.currentItem, ignoreCache: true);
  }

  Future<void> adjustOffset(int deltaMs) async {
    final PlayerState playerState = ref.read(playerControllerProvider);
    final PlayableItem? item = playerState.currentItem;
    final String? stableId = item?.stableId;
    final Metadata? metadata = state.metadata;
    if (item == null || state.stableId != stableId) {
      return;
    }
    if (metadata == null || metadata.stableId != stableId) {
      return;
    }

    final Metadata updatedMetadata = metadata.copyWith(
      lyricOffsetMs: metadata.lyricOffsetMs + deltaMs,
      updatedAt: DateTime.now(),
    );
    state = state.copyWith(metadata: updatedMetadata);
    await _saveCacheIfEligible(
      item: item,
      metadata: updatedMetadata,
      context: _activeContext,
    );
  }

  Future<void> searchManual(String keyword, {MetingServer? server}) async {
    final PlayerState playerState = ref.read(playerControllerProvider);
    final PlayableItem? item = playerState.currentItem;
    final String? stableId = item?.stableId;
    if (item == null || state.stableId != stableId) {
      return;
    }

    final int requestGeneration = _generation;
    final String trimmedKeyword = keyword.trim();
    state = state.copyWith(
      searchKeyword: trimmedKeyword,
      manualSearchError: null,
      isSearching: true,
    );

    try {
      final MetingSearchResponse response = await _searchManually(
        keyword: trimmedKeyword,
        server: server,
      );
      if (!_isActiveRequest(requestGeneration, item, _contextFor(item))) {
        return;
      }
      state = state.copyWith(
        searchKeyword: response.keyword,
        searchResults: response.results,
        manualSearchError: null,
        isSearching: false,
      );
    } on MetingException catch (error) {
      if (!_isActiveRequest(requestGeneration, item, _contextFor(item))) {
        return;
      }
      state = state.copyWith(
        searchKeyword: trimmedKeyword,
        searchResults: const <MetingSearchItem>[],
        manualSearchError: error.message,
        isSearching: false,
      );
    } on Object catch (error) {
      if (!_isActiveRequest(requestGeneration, item, _contextFor(item))) {
        return;
      }
      _logger.e('manual metadata search failed', error);
      state = state.copyWith(
        searchKeyword: trimmedKeyword,
        searchResults: const <MetingSearchItem>[],
        manualSearchError: '搜索失败：$error',
        isSearching: false,
      );
    }
  }

  Future<void> applyManualResult(MetingSearchItem item) async {
    final PlayerState playerState = ref.read(playerControllerProvider);
    final PlayableItem? currentItem = playerState.currentItem;
    final String? stableId = currentItem?.stableId;
    if (currentItem == null || state.stableId != stableId) {
      return;
    }
    final MetadataQueryContext context = _contextFor(currentItem);

    final int requestGeneration = ++_generation;
    state = state.copyWith(
      manualSearchError: null,
      isSearching: true,
      isLoading: false,
    );

    try {
      final Metadata metadata = await _lookupService
          .buildMetadataFromSearchItem(
            item: currentItem,
            searchItem: item,
            isActive: () =>
                _isActiveRequest(requestGeneration, currentItem, context),
          );
      if (!_isActiveRequest(requestGeneration, currentItem, context)) {
        return;
      }
      final Metadata withOffset = _withChapterOffset(
        metadata.copyWith(isManualMatch: true),
        context,
      );
      state = state.copyWith(
        metadata: withOffset,
        errorMessage: null,
        manualSearchError: null,
        isSearching: false,
        hasSearched: true,
      );
      await _saveCacheIfEligible(
        item: currentItem,
        metadata: withOffset,
        context: context,
      );
    } on MetingException catch (error) {
      if (!_isActiveRequest(requestGeneration, currentItem, context)) {
        return;
      }
      state = state.copyWith(
        manualSearchError: error.message,
        isSearching: false,
      );
    } on Object catch (error) {
      if (!_isActiveRequest(requestGeneration, currentItem, context)) {
        return;
      }
      _logger.e('apply manual metadata result failed', error);
      state = state.copyWith(
        manualSearchError: '歌词加载失败：$error',
        isSearching: false,
      );
    }
  }

  Future<void> _loadCurrentItemMetadata() async {
    final PlayerState playerState = ref.read(playerControllerProvider);
    await _loadForItem(playerState.currentItem);
  }

  Future<void> _loadForItem(
    PlayableItem? item, {
    bool ignoreCache = false,
  }) async {
    final int requestGeneration = ++_generation;
    if (item == null) {
      state = MetadataState(stableId: item?.stableId);
      return;
    }

    final String stableId = item.stableId;
    final MetadataQueryContext context = _contextFor(item);
    _activeContext = context;
    state = MetadataState(stableId: stableId, isLoading: true);

    if (!ignoreCache) {
      final Metadata? cached = await ref
          .read(metadataCacheRepositoryProvider)
          .getCachedMetadata(
            item: item,
            chapterStartMs: context.chapterStartMs,
          );
      if (!_isActiveRequest(requestGeneration, item, context)) {
        return;
      }
      if (cached != null &&
          _isCacheRelevant(cached, item) &&
          _isCacheLyricsUsable(cached)) {
        state = MetadataState(
          stableId: stableId,
          metadata: _withChapterOffset(cached, context),
          hasSearched: true,
        );
        return;
      }
    }

    try {
      final MetadataLookupResult lookupResult = await _resolve(
        item,
        context,
        requestGeneration,
      );
      if (!_isActiveRequest(requestGeneration, item, context)) {
        return;
      }

      final Metadata metadata = _withChapterOffset(
        lookupResult.metadata,
        context,
      );
      state = MetadataState(
        stableId: stableId,
        metadata: metadata,
        searchKeyword: lookupResult.searchKeyword,
        searchResults: lookupResult.searchResults,
        hasSearched: true,
      );
      await _saveCacheIfEligible(
        item: item,
        metadata: metadata,
        context: context,
      );
    } on MetingException catch (error) {
      if (!_isActiveRequest(requestGeneration, item, context)) {
        return;
      }
      state = MetadataState(
        stableId: stableId,
        errorMessage: error.message,
        searchKeyword: context.defaultKeyword,
        hasSearched: true,
      );
    } on Object catch (error) {
      if (!_isActiveRequest(requestGeneration, item, context)) {
        return;
      }
      _logger.e('load metadata failed', error);
      state = MetadataState(
        stableId: stableId,
        errorMessage: '元信息查询失败：$error',
        searchKeyword: context.defaultKeyword,
        hasSearched: true,
      );
    }
  }

  MetadataQueryContext? _activeContext;

  MetadataQueryContext _contextFor(PlayableItem item) {
    final PlayerState playerState = ref.read(playerControllerProvider);
    if (playerState.currentItem?.stableId != item.stableId) {
      return MetadataQueryContext(
        stableId: item.stableId,
        titles: <String>[
          if (item.pageTitle?.trim().isNotEmpty ?? false)
            item.pageTitle!.trim(),
          if (item.title.trim().isNotEmpty) item.title.trim(),
        ],
        chapterStartMs: null,
      );
    }
    return MetadataQueryContext.fromState(item: item, state: playerState);
  }

  MetadataQueryContext? _queryContextOf(PlayerState? playerState) {
    if (playerState == null) {
      return null;
    }
    final PlayableItem? item = playerState.currentItem;
    if (item == null) {
      return null;
    }
    return MetadataQueryContext.fromState(item: item, state: playerState);
  }

  Metadata _withChapterOffset(Metadata metadata, MetadataQueryContext context) {
    if (!context.hasChapter) {
      return metadata;
    }
    return metadata.copyWith(lyricBaseOffsetMs: context.lyricBaseOffsetMs);
  }

  /// 缓存里没有可用歌词时不要直接采用：早期自动匹配失败（或匹配到错的歌）
  /// 会把「无歌词」的结果缓存下来，导致后续再也不会自动去搜。
  ///
  /// 纯音乐和用户手动匹配过的记录保持有效；其它情况只信任 10 分钟内的记录，
  /// 超过就重新走一遍「聚合搜索 + 兜底」流程。
  bool _isCacheLyricsUsable(Metadata cached) {
    if (cached.isInstrumental || cached.isManualMatch) {
      return true;
    }
    final MetaLyrics? lyrics = cached.metaLyrics;
    // 没有歌词的缓存一律不信任：否则匹配失败一次后就再也不会自动去搜了。
    return lyrics != null && lyrics.hasRenderableMainLyric;
  }

  /// 缓存里的歌名和视频标题完全对不上时视为无效。
  ///
  /// 早期匹配会直接把第一条搜索结果配上歌词（例如《直到永远》被配成
  /// 吴奇隆的《我爱你到永远》），这类脏数据缓存下来后要能被重新识别。
  bool _isCacheRelevant(Metadata cached, PlayableItem item) {
    final String title = _normalizeTitle(item.title);
    final String cachedTitle = _normalizeTitle(cached.title ?? '');
    if (title.isEmpty || cachedTitle.isEmpty) {
      return true;
    }
    return title.contains(cachedTitle) || cachedTitle.contains(title);
  }

  static String _normalizeTitle(String value) {
    return value.toLowerCase().replaceAll(
      RegExp(r'''[\s\-_/\\.，,、:：!！?？"'`~@#%&*+=|<>()\[\]{}（）【】「」『』《》]'''),
      '',
    );
  }

  bool _isActiveRequest(
    int requestGeneration,
    PlayableItem item,
    MetadataQueryContext context,
  ) {
    if (!ref.mounted || requestGeneration != _generation) {
      return false;
    }
    final PlayerState playerState = ref.read(playerControllerProvider);
    final PlayableItem? currentItem = playerState.currentItem;
    if (currentItem == null) {
      return false;
    }
    if (currentItem.stableId != item.stableId ||
        currentItem.collectionId != item.collectionId ||
        state.stableId != item.stableId) {
      return false;
    }
    return MetadataQueryContext.fromState(
      item: currentItem,
      state: playerState,
    ).matches(context);
  }

  Future<void> _saveCacheIfEligible({
    required PlayableItem item,
    required Metadata metadata,
    MetadataQueryContext? context,
  }) async {
    if (!_shouldCacheMetadata(item)) {
      return;
    }

    await ref
        .read(metadataCacheRepositoryProvider)
        .putCachedMetadata(
          item: item,
          metadata: metadata,
          chapterStartMs: context?.chapterStartMs,
        );
  }

  bool _shouldCacheMetadata(PlayableItem item) {
    return ref
        .read(favoritesControllerProvider)
        .collectionsForItem(item)
        .isNotEmpty;
  }

  Future<MetingSearchResponse> _searchManually({
    required String keyword,
    MetingServer? server,
  }) async {
    final MetingRepository metingRepository = ref.read(
      metingRepositoryProvider,
    );
    final String trimmedKeyword = keyword.trim();
    return MetingSearchResponse(
      keyword: trimmedKeyword,
      results: server == null
          ? await metingRepository.searchAll(keyword: trimmedKeyword)
          : await metingRepository.search(
              keyword: trimmedKeyword,
              server: server,
            ),
    );
  }

  Future<MetadataLookupResult> _resolve(
    PlayableItem item,
    MetadataQueryContext context,
    int requestGeneration,
  ) async {
    final List<String> titles = context.titles.isEmpty
        ? <String>[item.title.trim()]
        : context.titles;
    MetadataLookupResult? best;
    for (final String title in titles) {
      if (title.trim().isEmpty) {
        continue;
      }
      final MetadataLookupResult result = await _lookupService.lookup(
        item: item,
        title: title,
        normalizeKeyword: !context.hasChapter,
        isActive: () => _isActiveRequest(requestGeneration, item, context),
      );
      if (result.metadata.hasLyrics) {
        return result;
      }
      if (best == null ||
          (result.metadata.albumArtUrl?.trim().isNotEmpty ?? false)) {
        best = result;
      }
    }
    return best ??
        MetadataLookupResult(
          metadata: Metadata(
            stableId: item.stableId,
            updatedAt: DateTime.now(),
          ),
          searchKeyword: context.defaultKeyword,
          searchResults: const <MetingSearchItem>[],
        );
  }
}
