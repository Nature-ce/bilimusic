import 'dart:convert';

import 'package:bilimusic/common/domain/meta_lyrics.dart';
import 'package:bilimusic/common/logger.dart';
import 'package:bilimusic/core/net/bm_client.dart';
import 'package:bilimusic/feature/metadata/data/metadata_resolver.dart';
import 'package:bilimusic/feature/metadata/domain/metadata.dart';
import 'package:bilimusic/feature/meting/data/meting_repository.dart';
import 'package:bilimusic/feature/meting/domain/meting_search_item.dart';
import 'package:bilimusic/feature/meting/domain/meting_server.dart';
import 'package:bilimusic/feature/meting/logic/meting_source_preference_logic.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'metadata_lookup_service.g.dart';

@riverpod
MetadataLookupService metadataLookupService(Ref ref) {
  return MetadataLookupService(
    metingRepository: ref.read(metingRepositoryProvider),
    bmClient: ref.read(bmClientProvider.notifier),
    resolveServer: ref.read(metingSourcePreferenceLogicProvider).resolve,
  );
}

class MetadataLookupService {
  MetadataLookupService({
    required this.metingRepository,
    required this.resolveServer,
    this.bmClient,
  });

  final MetingRepository metingRepository;
  final MetingServer Function(String text) resolveServer;
  final BmClient? bmClient;

  final AppLogger _logger = AppLogger('MetadataLookup');

  Future<MetadataLookupResult> lookup({
    required PlayableItem item,
    required String title,
    bool normalizeKeyword = true,
    bool aggregate = true,
    bool Function()? isActive,
  }) async {
    void checkActive() {
      if (item.isSpoken || isActive?.call() == false) {
        throw StateError('Metadata lookup is no longer active');
      }
    }

    checkActive();
    final String keyword = normalizeKeyword
        ? (await resolveSearchKeyword(title)).trim()
        : extractSearchKeyword(title).trim();
    checkActive();
    final String? fallbackKeyword = keyword.isNotEmpty ? keyword : null;

    final MetingServer preferredServer = resolveServer(keyword);
    final List<MetingSearchItem> results = aggregate
        ? await metingRepository.searchAll(
            keyword: keyword,
            servers: <MetingServer>[
              preferredServer,
              ...MetingRepository.lyricSearchServers.where(
                (MetingServer server) => server != preferredServer,
              ),
            ],
          )
        : await metingRepository.search(
            keyword: keyword,
            server: preferredServer,
          );
    checkActive();
    MetingSearchItem? instrumentalItem;
    for (final MetingSearchItem result in results) {
      checkActive();
      final MetaLyrics? rawLyrics = await _fetchLyricsOrNull(result);
      final bool instrumental = isInstrumentalLyrics(rawLyrics?.lyric);
      final MetaLyrics? metaLyrics = instrumental
          ? null
          : normalizeMetaLyrics(rawLyrics);
      checkActive();
      if (metaLyrics != null && metaLyrics.hasRenderableMainLyric) {
        return MetadataLookupResult(
          metadata: await buildMetadata(
            item: item,
            searchItem: result,
            metaLyrics: metaLyrics,
            isActive: isActive,
          ),
          searchKeyword: fallbackKeyword,
          searchResults: results,
        );
      }
      if (instrumental) {
        instrumentalItem ??= result;
      }
    }

    if (instrumentalItem != null) {
      final Metadata metadata = await buildMetadata(
        item: item,
        searchItem: instrumentalItem,
        metaLyrics: null,
        isActive: isActive,
      );
      return MetadataLookupResult(
        metadata: metadata.copyWith(isInstrumental: true),
        searchKeyword: fallbackKeyword,
        searchResults: results,
      );
    }

    final MetadataLookupResult? fallback = await _fallbackLookup(
      item: item,
      primaryKeyword: keyword,
      isActive: isActive,
    );
    if (fallback != null) {
      return fallback;
    }

    return MetadataLookupResult(
      metadata: Metadata(stableId: item.stableId, updatedAt: DateTime.now()),
      searchKeyword: fallbackKeyword,
      searchResults: const <MetingSearchItem>[],
    );
  }

  bool isInstrumentalLyrics(String? lyric) {
    final String text = lyric?.trim() ?? '';
    if (text.isEmpty || text.contains('[')) {
      return false;
    }
    return text.contains('纯音乐');
  }

  Future<Metadata> buildMetadataFromSearchItem({
    required PlayableItem item,
    required MetingSearchItem searchItem,
    bool Function()? isActive,
  }) async {
    if (item.isSpoken || isActive?.call() == false) {
      throw StateError('Metadata lookup is no longer active');
    }
    return buildMetadata(
      item: item,
      searchItem: searchItem,
      metaLyrics: normalizeMetaLyrics(await _fetchLyricsOrNull(searchItem)),
      isActive: isActive,
    );
  }

  Future<Metadata> buildMetadata({
    required PlayableItem item,
    required MetingSearchItem searchItem,
    required MetaLyrics? metaLyrics,
    bool Function()? isActive,
  }) async {
    if (item.isSpoken || isActive?.call() == false) {
      throw StateError('Metadata lookup is no longer active');
    }
    String? albumArtUrl;
    try {
      albumArtUrl = _normalizeText(
        await metingRepository.fetchPicture(searchItem),
      );
    } on Object {
      albumArtUrl = null;
    }

    return MetadataResolver.fromCacheLikeValues(
      stableId: item.stableId,
      artist: searchItem.author,
      title: searchItem.title,
      lyrics: metaLyrics?.preferredMainLyric,
      metaLyrics: metaLyrics,
      albumArtUrl: albumArtUrl,
      updatedAt: DateTime.now(),
    );
  }

  /// 主关键词搜不到歌词时的兜底：换用视频标题等关键词、跨平台聚合，
  /// 再按「标题像不像」挑候选，避免随手拿第一条（例如把 《直到永远》匹配成
  /// 吴奇隆的《我爱你到永远》）。
  Future<MetadataLookupResult?> _fallbackLookup({
    required PlayableItem item,
    required String primaryKeyword,
    bool Function()? isActive,
  }) async {
    final List<String> keywords = <String>[
      primaryKeyword,
      extractSearchKeyword(item.title).trim(),
      item.title.trim(),
      '${item.title.trim()} ${item.author.trim()}'.trim(),
    ].where((String keyword) => keyword.isNotEmpty).toSet().toList();
    for (final String keyword in keywords) {
      if (isActive?.call() == false) {
        return null;
      }
      List<MetingSearchItem> results;
      try {
        results = await metingRepository.searchAll(keyword: keyword);
      } on Object {
        continue;
      }
      final List<MetingSearchItem> ranked = _rankCandidates(results, item);
      for (final MetingSearchItem candidate in ranked) {
        if (isActive?.call() == false) {
          return null;
        }
        final MetaLyrics? rawLyrics = await _fetchLyricsOrNull(candidate);
        if (isInstrumentalLyrics(rawLyrics?.lyric)) {
          continue;
        }
        final MetaLyrics? metaLyrics = normalizeMetaLyrics(rawLyrics);
        if (metaLyrics == null || !metaLyrics.hasRenderableMainLyric) {
          continue;
        }
        return MetadataLookupResult(
          metadata: await buildMetadata(
            item: item,
            searchItem: candidate,
            metaLyrics: metaLyrics,
            isActive: isActive,
          ),
          searchKeyword: keyword,
          searchResults: results,
        );
      }
    }
    return null;
  }

  /// 按「候选标题/歌手是否出现在视频标题里」排序，分数太低的不参与匹配。
  List<MetingSearchItem> _rankCandidates(
    List<MetingSearchItem> results,
    PlayableItem item,
  ) {
    final String title = _normalizeForMatch(item.title);
    int scoreOf(MetingSearchItem candidate) {
      final String candidateTitle = _normalizeForMatch(candidate.title);
      final String candidateAuthor = _normalizeForMatch(candidate.author);
      int score = 0;
      if (candidateTitle.isNotEmpty && title.isNotEmpty) {
        if (title.contains(candidateTitle)) {
          score += 3;
        } else if (candidateTitle.contains(title)) {
          score += 2;
        }
      }
      if (candidateAuthor.isNotEmpty &&
          title.isNotEmpty &&
          title.contains(candidateAuthor)) {
        score += 2;
      }
      return score;
    }

    final List<MetingSearchItem> ranked = List<MetingSearchItem>.of(results)
      ..sort(
        (MetingSearchItem a, MetingSearchItem b) =>
            scoreOf(b).compareTo(scoreOf(a)),
      );
    return ranked
        .where((MetingSearchItem candidate) => scoreOf(candidate) > 0)
        .take(6)
        .toList(growable: false);
  }

  static String _normalizeForMatch(String value) {
    return value.toLowerCase().replaceAll(
      RegExp(r'''[\s\-_/\\.，,、:：!！?？"'`~@#%&*+=|<>()\[\]{}（）【】「」『』《》]'''),
      '',
    );
  }

  String? defaultSearchKeyword(PlayableItem item) {
    for (final String title in item.lyricSearchTitles) {
      final String keyword = title.trim();
      if (keyword.isNotEmpty) {
        return keyword;
      }
    }
    return null;
  }

  Future<String> resolveSearchKeyword(String value) async {
    final String rawTitle = value.trim();
    if (rawTitle.isEmpty) {
      return '';
    }

    final String fallbackKeyword = extractSearchKeyword(rawTitle).trim();
    final BmClient? client = bmClient;
    if (client == null) {
      return fallbackKeyword;
    }
    try {
      final Response<String> response = await client.post<String>(
        '/ai',
        data: <String, dynamic>{'message': rawTitle},
        options: Options(responseType: ResponseType.plain),
      );
      final Object? decoded = jsonDecode(response.data ?? '{}');
      if (decoded is String && decoded.isNotEmpty) {
        return decoded;
      }
    } on Object catch (error) {
      _logger.d('BM 识别失败，回退正则：$error');
    }

    return fallbackKeyword;
  }

  String extractSearchKeyword(String value) {
    String result = value.trim();
    final RegExp priorityRegex = RegExp(r'《(.+?)》|「(.+?)」');
    final RegExpMatch? priorityMatch = priorityRegex.firstMatch(result);

    if (priorityMatch != null) {
      final String? group1 = priorityMatch.group(1);
      final String? group2 = priorityMatch.group(2);
      return group1 ?? group2 ?? '';
    }

    final String replacedKeyword = result
        .replaceAll(RegExp(r'【.*?】|“.*?”'), '')
        .trim();

    result = replacedKeyword.isNotEmpty ? replacedKeyword : result;
    return result;
  }

  MetaLyrics? normalizeMetaLyrics(MetaLyrics? value) {
    if (value == null) {
      return null;
    }

    final MetaLyrics normalized = MetaLyrics(
      lyric: _normalizeLyrics(value.lyric),
      translatedLyric: _normalizeLyrics(value.translatedLyric),
      romanizedLyric: _normalizeLyrics(value.romanizedLyric),
      karaokeLyric: _normalizeLyrics(value.karaokeLyric),
      karaokeTranslatedLyric: _normalizeLyrics(value.karaokeTranslatedLyric),
    );
    return normalized.hasAnyLyrics ? normalized : null;
  }

  Future<MetaLyrics?> _fetchLyricsOrNull(MetingSearchItem searchItem) async {
    try {
      return await metingRepository.fetchLyrics(searchItem);
    } on Object {
      return null;
    }
  }

  String? _normalizeLyrics(String? value) {
    final String trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? null : trimmed;
  }

  String? _normalizeText(String? value) {
    final String trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? null : trimmed;
  }
}
