import 'dart:convert';

import 'package:bilimusic/common/util/display_text.dart';
import 'package:bilimusic/common/util/json_util.dart';
import 'package:bilimusic/feature/home/domain/hot_playlist.dart';
import 'package:bilimusic/feature/home/domain/hot_playlist_track.dart';
import 'package:bilimusic/feature/home/domain/music_chart_platform.dart';
import 'package:dio/dio.dart';

typedef HotPlaylistHttpGet =
    Future<Object?> Function(
      String url,
      Map<String, dynamic> query,
      Map<String, String> headers,
    );

class HotPlaylistException implements Exception {
  const HotPlaylistException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// 一页歌单曲目：`hasMore` 决定是否还能继续加载，`totalCount` 是歌单曲目总数。
typedef HotPlaylistTrackPage = ({
  List<HotPlaylistTrack> tracks,
  bool hasMore,
  int totalCount,
});

/// 拉取网易云 / QQ音乐 / 酷狗的热门歌单与歌单曲目。
class HotPlaylistRepository {
  HotPlaylistRepository({Dio? dio, HotPlaylistHttpGet? httpGet})
    : _dio = dio ?? Dio() {
    _httpGet = httpGet ?? _defaultHttpGet;
  }

  static const int maxPlaylistCount = 12;
  static const int defaultTrackPageSize = 30;
  static const Duration cacheTtl = Duration(minutes: 10);

  static const String _neteaseListUrl =
      'https://music.163.com/api/playlist/list';
  static const String _neteaseDetailUrl =
      'https://music.163.com/api/v6/playlist/detail';
  static const String _neteaseSongDetailUrl =
      'https://music.163.com/api/song/detail/';
  static const String _tencentListUrl =
      'https://c.y.qq.com/splcloud/fcgi-bin/fcg_get_diss_by_tag.fcg';
  static const String _tencentTracksUrl =
      'https://c.y.qq.com/v8/fcg-bin/fcg_v8_playlist_cp.fcg';
  static const String _kugouListUrl = 'https://m.kugou.com/plist/index';
  static const String _kugouTracksUrl =
      'https://mobiles.kugou.com/api/v3/special/song';

  static const Map<String, String> _neteaseHeaders = <String, String>{
    'Referer': 'https://music.163.com/',
    'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
        '(KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
  };

  static const Map<String, String> _tencentHeaders = <String, String>{
    'Referer': 'https://y.qq.com/',
    'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
        '(KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
  };

  static const Map<String, String> _kugouHeaders = <String, String>{
    'User-Agent':
        'Mozilla/5.0 (Linux; Android 12) AppleWebKit/537.36 '
        '(KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
  };

  final Dio _dio;
  late final HotPlaylistHttpGet _httpGet;
  final Map<MusicChartPlatform, _CachedPlaylists> _playlistCache =
      <MusicChartPlatform, _CachedPlaylists>{};
  final Map<String, _CachedTrackPage> _trackPageCache =
      <String, _CachedTrackPage>{};
  final Map<String, _CachedTrackIds> _trackIdCache =
      <String, _CachedTrackIds>{};

  Future<List<HotPlaylist>> fetchPlaylists(
    MusicChartPlatform platform, {
    bool forceRefresh = false,
  }) async {
    if (!platform.supportsPlaylists) {
      throw const HotPlaylistException('该平台暂无热门歌单');
    }
    final _CachedPlaylists? cached = _playlistCache[platform];
    if (!forceRefresh && cached != null && !cached.isExpired) {
      return cached.playlists;
    }
    final List<HotPlaylist> playlists = switch (platform) {
      MusicChartPlatform.netease => await _fetchNeteasePlaylists(),
      MusicChartPlatform.tencent => await _fetchTencentPlaylists(),
      MusicChartPlatform.kugou => await _fetchKugouPlaylists(),
      MusicChartPlatform.bilibili => throw const HotPlaylistException(
        '该平台暂无热门歌单',
      ),
    };
    _playlistCache[platform] = _CachedPlaylists(
      playlists: playlists,
      fetchedAt: DateTime.now(),
    );
    return playlists;
  }

  Future<HotPlaylistTrackPage> fetchTrackPage(
    HotPlaylist playlist, {
    int offset = 0,
    int limit = defaultTrackPageSize,
    bool forceRefresh = false,
  }) async {
    final String cacheKey = '${playlist.key}@$offset@$limit';
    final _CachedTrackPage? cached = _trackPageCache[cacheKey];
    if (!forceRefresh && cached != null && !cached.isExpired) {
      return cached.page;
    }
    final HotPlaylistTrackPage page = switch (playlist.platform) {
      MusicChartPlatform.netease => await _fetchNeteaseTrackPage(
        playlist,
        offset: offset,
        limit: limit,
      ),
      MusicChartPlatform.tencent => await _fetchTencentTrackPage(
        playlist,
        offset: offset,
        limit: limit,
      ),
      MusicChartPlatform.kugou => await _fetchKugouTrackPage(
        playlist,
        offset: offset,
        limit: limit,
      ),
      MusicChartPlatform.bilibili => throw const HotPlaylistException(
        '该平台暂无热门歌单',
      ),
    };
    _trackPageCache[cacheKey] = _CachedTrackPage(
      page: page,
      fetchedAt: DateTime.now(),
    );
    if (_trackPageCache.length > 80) {
      _trackPageCache.remove(_trackPageCache.keys.first);
    }
    return page;
  }

  Future<List<HotPlaylist>> _fetchNeteasePlaylists() async {
    final Object? payload = await _httpGet(_neteaseListUrl, <String, dynamic>{
      'cat': '全部',
      'order': 'hot',
      'limit': '$maxPlaylistCount',
      'offset': '0',
    }, _neteaseHeaders);
    return parseNeteasePlaylists(payload);
  }

  Future<List<HotPlaylist>> _fetchTencentPlaylists() async {
    final Object? payload = await _httpGet(_tencentListUrl, <String, dynamic>{
      'picmid': '1',
      'rnd': '0.1',
      'g_tk': '5381',
      'loginUin': '0',
      'hostUin': '0',
      'format': 'json',
      'inCharset': 'utf8',
      'outCharset': 'utf-8',
      'notice': '0',
      'platform': 'yqq.json',
      'needNewCode': '0',
      'categoryId': '10000000',
      'sortId': '5',
      'sin': '0',
      'ein': '${maxPlaylistCount - 1}',
    }, _tencentHeaders);
    return parseTencentPlaylists(payload);
  }

  Future<List<HotPlaylist>> _fetchKugouPlaylists() async {
    final Object? payload = await _httpGet(_kugouListUrl, <String, dynamic>{
      'page': '1',
      'json': 'true',
    }, _kugouHeaders);
    return parseKugouPlaylists(payload);
  }

  Future<HotPlaylistTrackPage> _fetchNeteaseTrackPage(
    HotPlaylist playlist, {
    required int offset,
    required int limit,
  }) async {
    final List<String> trackIds = await _neteaseTrackIds(playlist);
    if (trackIds.isEmpty) {
      throw const HotPlaylistException('网易云歌单暂无曲目');
    }
    final List<String> pageIds = trackIds
        .skip(offset)
        .take(limit)
        .toList(growable: false);
    if (pageIds.isEmpty) {
      return (
        tracks: const <HotPlaylistTrack>[],
        hasMore: false,
        totalCount: trackIds.length,
      );
    }
    final Object? songs = await _httpGet(
      _neteaseSongDetailUrl,
      <String, dynamic>{'ids': '[${pageIds.join(',')}]'},
      _neteaseHeaders,
    );
    final List<HotPlaylistTrack> tracks = parseNeteaseTracks(
      songs,
      playlist,
      startRank: offset + 1,
    );
    return (
      tracks: tracks,
      hasMore: offset + pageIds.length < trackIds.length,
      totalCount: trackIds.length,
    );
  }

  Future<List<String>> _neteaseTrackIds(
    HotPlaylist playlist, {
    bool forceRefresh = false,
  }) async {
    final _CachedTrackIds? cached = _trackIdCache[playlist.key];
    if (!forceRefresh && cached != null && !cached.isExpired) {
      return cached.trackIds;
    }
    final Object? detail = await _httpGet(_neteaseDetailUrl, <String, dynamic>{
      'id': playlist.id,
      'n': '1000',
    }, _neteaseHeaders);
    final List<String> trackIds = _parseNeteaseTrackIds(detail);
    _trackIdCache[playlist.key] = _CachedTrackIds(
      trackIds: trackIds,
      fetchedAt: DateTime.now(),
    );
    if (_trackIdCache.length > 40) {
      _trackIdCache.remove(_trackIdCache.keys.first);
    }
    return trackIds;
  }

  Future<HotPlaylistTrackPage> _fetchTencentTrackPage(
    HotPlaylist playlist, {
    required int offset,
    required int limit,
  }) async {
    final Object? payload = await _httpGet(_tencentTracksUrl, <String, dynamic>{
      'id': playlist.id,
      'format': 'json',
      'newsong': '1',
      'song_begin': '$offset',
      'song_num': '$limit',
    }, _tencentHeaders);
    final List<HotPlaylistTrack> tracks = parseTencentTracks(
      payload,
      playlist,
      startRank: offset + 1,
    );
    final int totalCount = _tencentTotal(payload);
    return (
      tracks: tracks,
      hasMore: _hasMore(
        totalCount: totalCount,
        offset: offset,
        limit: limit,
        fetched: tracks.length,
      ),
      totalCount: totalCount,
    );
  }

  Future<HotPlaylistTrackPage> _fetchKugouTrackPage(
    HotPlaylist playlist, {
    required int offset,
    required int limit,
  }) async {
    final int page = offset ~/ limit + 1;
    final Object? payload = await _httpGet(_kugouTracksUrl, <String, dynamic>{
      'specialid': playlist.id,
      'page': '$page',
      'pagesize': '$limit',
      'plat': '0',
      'version': '8000',
    }, _kugouHeaders);
    final List<HotPlaylistTrack> tracks = parseKugouTracks(
      payload,
      playlist,
      startRank: offset + 1,
    );
    final int totalCount = _kugouTotal(payload);
    return (
      tracks: tracks,
      hasMore: _hasMore(
        totalCount: totalCount,
        offset: offset,
        limit: limit,
        fetched: tracks.length,
      ),
      totalCount: totalCount,
    );
  }

  static bool _hasMore({
    required int totalCount,
    required int offset,
    required int limit,
    required int fetched,
  }) {
    if (totalCount > 0) {
      return offset + limit < totalCount;
    }
    return fetched >= limit;
  }

  static int _tencentTotal(Object? payload) {
    final Map<String, dynamic>? root = _asMap(_decode(payload));
    final Map<String, dynamic> data =
        _asMap(root?['data']) ?? <String, dynamic>{};
    final List<Map<String, dynamic>> cdlist = _asListOfMaps(data['cdlist']);
    if (cdlist.isEmpty) {
      return 0;
    }
    final Map<String, dynamic> cd = cdlist.first;
    return _readInt(cd['total_song_num'] ?? cd['songnum']);
  }

  static int _kugouTotal(Object? payload) {
    final Map<String, dynamic>? root = _asMap(_decode(payload));
    final Map<String, dynamic>? data = _asMap(root?['data']);
    return _readInt(data?['total']);
  }

  static List<HotPlaylist> parseNeteasePlaylists(Object? payload) {
    final Map<String, dynamic>? root = _asMap(_decode(payload));
    if (root == null) {
      throw const HotPlaylistException('网易云歌单数据异常');
    }
    if (root['playlists'] is! List) {
      throw const HotPlaylistException('网易云歌单数据异常');
    }
    final List<HotPlaylist> playlists = <HotPlaylist>[];
    for (final Map<String, dynamic> json in _asListOfMaps(root['playlists'])) {
      final String id = _readString(json['id']);
      final String name = normalizeDisplayTextOrEmpty(
        _readString(json['name']),
      );
      if (id.isEmpty || name.isEmpty) {
        continue;
      }
      final Map<String, dynamic>? creator = _asMap(json['creator']);
      playlists.add(
        HotPlaylist(
          platform: MusicChartPlatform.netease,
          id: id,
          name: name,
          coverUrl: _httpsImageUrl(_readString(json['coverImgUrl'])),
          playCount: _readInt(json['playCount']),
          trackCount: _readInt(json['trackCount']),
          creator: normalizeDisplayTextOrEmpty(
            _readString(creator?['nickname']),
          ),
        ),
      );
    }
    return _finalizePlaylists(playlists);
  }

  static List<HotPlaylist> parseTencentPlaylists(Object? payload) {
    final Object? decoded = _decode(payload);
    final Map<String, dynamic>? root = _asMap(decoded);
    if (root == null) {
      throw const HotPlaylistException('QQ音乐歌单数据异常');
    }
    final Object? code = root['code'];
    if (code is num && code.toInt() != 0) {
      throw const HotPlaylistException('QQ音乐歌单加载失败');
    }
    final Map<String, dynamic>? data = _asMap(root['data']);
    if (data == null) {
      throw const HotPlaylistException('QQ音乐歌单数据异常');
    }
    final List<HotPlaylist> playlists = <HotPlaylist>[];
    for (final Map<String, dynamic> json in _asListOfMaps(data['list'])) {
      final String id = _readString(json['dissid']);
      final String name = normalizeDisplayTextOrEmpty(
        _readString(json['dissname']),
      );
      if (id.isEmpty || name.isEmpty) {
        continue;
      }
      final Map<String, dynamic>? creator = _asMap(json['creator']);
      playlists.add(
        HotPlaylist(
          platform: MusicChartPlatform.tencent,
          id: id,
          name: name,
          coverUrl: _httpsImageUrl(_readString(json['imgurl'])),
          playCount: _readInt(json['listennum']),
          creator: normalizeDisplayTextOrEmpty(_readString(creator?['name'])),
          description: normalizeDisplayTextOrEmpty(
            _readString(json['introduction']),
          ),
        ),
      );
    }
    return _finalizePlaylists(playlists);
  }

  static List<HotPlaylist> parseKugouPlaylists(Object? payload) {
    final Map<String, dynamic>? root = _asMap(_decode(payload));
    if (root == null) {
      throw const HotPlaylistException('酷狗歌单数据异常');
    }
    final Map<String, dynamic>? plist = _asMap(root['plist']);
    if (plist == null) {
      throw const HotPlaylistException('酷狗歌单数据异常');
    }
    final Map<String, dynamic>? list = _asMap(plist['list']);
    if (list == null) {
      throw const HotPlaylistException('酷狗歌单数据异常');
    }
    final List<HotPlaylist> playlists = <HotPlaylist>[];
    for (final Map<String, dynamic> json in _asListOfMaps(list['info'])) {
      final String id = _readString(json['specialid']);
      final String name = normalizeDisplayTextOrEmpty(
        _readString(json['specialname']),
      );
      if (id.isEmpty || name.isEmpty) {
        continue;
      }
      playlists.add(
        HotPlaylist(
          platform: MusicChartPlatform.kugou,
          id: id,
          name: name,
          coverUrl: _kugouCoverUrl(json['imgurl']),
          playCount: _readInt(json['playcount']),
          trackCount: _readInt(json['songcount']),
          creator: normalizeDisplayTextOrEmpty(_readString(json['username'])),
          description: normalizeDisplayTextOrEmpty(_readString(json['intro'])),
        ),
      );
    }
    return _finalizePlaylists(playlists);
  }

  static List<HotPlaylistTrack> parseNeteaseTracks(
    Object? payload,
    HotPlaylist playlist, {
    int startRank = 1,
  }) {
    final Map<String, dynamic>? root = _asMap(_decode(payload));
    if (root == null) {
      throw const HotPlaylistException('网易云歌单曲目数据异常');
    }
    final List<HotPlaylistTrack> tracks = <HotPlaylistTrack>[];
    for (final Map<String, dynamic> json in _asListOfMaps(root['songs'])) {
      final String title = normalizeDisplayTextOrEmpty(
        _readString(json['name']),
      );
      if (title.isEmpty) {
        continue;
      }
      final List<Map<String, dynamic>> artists = _asListOfMaps(json['artists']);
      final String artist = normalizeDisplayTextOrEmpty(
        artists
            .map((Map<String, dynamic> item) => _readString(item['name']))
            .where((String value) => value.isNotEmpty)
            .join(' / '),
      );
      final Map<String, dynamic>? album =
          _asMap(json['al']) ?? _asMap(json['album']);
      tracks.add(
        HotPlaylistTrack(
          playlist: playlist,
          rank: 0,
          title: title,
          artist: artist,
          coverUrl: _httpsImageUrl(_readString(album?['picUrl'])),
          durationSeconds: _readDurationSeconds(json['dt'] ?? json['duration']),
        ),
      );
    }
    return _finalizeTracks(tracks, startRank: startRank);
  }

  static List<HotPlaylistTrack> parseTencentTracks(
    Object? payload,
    HotPlaylist playlist, {
    int startRank = 1,
  }) {
    final Map<String, dynamic>? root = _asMap(_decode(payload));
    if (root == null) {
      throw const HotPlaylistException('QQ音乐歌单曲目数据异常');
    }
    final Map<String, dynamic> data =
        _asMap(root['data']) ?? <String, dynamic>{};
    final List<Map<String, dynamic>> cdlist = _asListOfMaps(data['cdlist']);
    final Map<String, dynamic> cd = cdlist.isEmpty
        ? <String, dynamic>{}
        : cdlist.first;
    final List<HotPlaylistTrack> tracks = <HotPlaylistTrack>[];
    for (final Map<String, dynamic> json in _asListOfMaps(cd['songlist'])) {
      final String title = normalizeDisplayTextOrEmpty(
        _readString(json['name'] ?? json['title']),
      );
      if (title.isEmpty) {
        continue;
      }
      final Map<String, dynamic>? album = _asMap(json['album']);
      tracks.add(
        HotPlaylistTrack(
          playlist: playlist,
          rank: 0,
          title: title,
          artist: normalizeDisplayTextOrEmpty(
            _joinTencentSingers(json['singer']),
          ),
          coverUrl: _tencentCoverUrl(json['albummid'] ?? album?['mid']),
          durationSeconds: _readDurationSeconds(json['interval']),
        ),
      );
    }
    return _finalizeTracks(tracks, startRank: startRank);
  }

  static List<HotPlaylistTrack> parseKugouTracks(
    Object? payload,
    HotPlaylist playlist, {
    int startRank = 1,
  }) {
    final Map<String, dynamic>? root = _asMap(_decode(payload));
    if (root == null) {
      throw const HotPlaylistException('酷狗歌单曲目数据异常');
    }
    final Object? status = root['status'];
    if (status is num && status.toInt() != 1) {
      throw const HotPlaylistException('酷狗歌单加载失败');
    }
    final Map<String, dynamic> data =
        _asMap(root['data']) ?? <String, dynamic>{};
    final List<HotPlaylistTrack> tracks = <HotPlaylistTrack>[];
    for (final Map<String, dynamic> json in _asListOfMaps(data['info'])) {
      String title = _readString(json['songname']).trim();
      String artist = _asListOfMaps(json['authors'])
          .map(
            (Map<String, dynamic> author) => _readString(author['author_name']),
          )
          .where((String value) => value.isNotEmpty)
          .join(' / ');
      if (title.isEmpty) {
        final String filename = _readString(json['filename']);
        final int splitIndex = filename.indexOf(' - ');
        if (splitIndex > 0) {
          artist = artist.isEmpty
              ? filename.substring(0, splitIndex).trim()
              : artist;
          title = filename.substring(splitIndex + 3).trim();
        } else {
          title = filename.trim();
        }
      }
      if (title.isEmpty) {
        continue;
      }
      tracks.add(
        HotPlaylistTrack(
          playlist: playlist,
          rank: 0,
          title: normalizeDisplayTextOrEmpty(title),
          artist: normalizeDisplayTextOrEmpty(artist),
          coverUrl: _kugouCoverUrl(_kugouTrackCover(json)),
          durationSeconds: _readDurationSeconds(json['duration']),
        ),
      );
    }
    return _finalizeTracks(tracks, startRank: startRank);
  }

  static List<String> _parseNeteaseTrackIds(Object? payload) {
    final Map<String, dynamic>? root = _asMap(_decode(payload));
    final Map<String, dynamic>? playlist = _asMap(root?['playlist']);
    final Object? trackIds = playlist?['trackIds'];
    if (trackIds is! List) {
      return const <String>[];
    }
    return trackIds
        .map((Object? item) {
          if (item is Map) {
            return _readString(_asMap(item)?['id']);
          }
          return _readString(item);
        })
        .where((String value) => value.isNotEmpty)
        .toList(growable: false);
  }

  static List<HotPlaylist> _finalizePlaylists(List<HotPlaylist> playlists) {
    final List<HotPlaylist> unique = <HotPlaylist>[];
    final Set<String> seen = <String>{};
    for (final HotPlaylist playlist in playlists) {
      if (!seen.add(playlist.id)) {
        continue;
      }
      unique.add(playlist);
      if (unique.length >= maxPlaylistCount) {
        break;
      }
    }
    return List<HotPlaylist>.unmodifiable(unique);
  }

  static List<HotPlaylistTrack> _finalizeTracks(
    List<HotPlaylistTrack> tracks, {
    int startRank = 1,
  }) {
    final List<HotPlaylistTrack> unique = <HotPlaylistTrack>[];
    final Set<String> seen = <String>{};
    for (final HotPlaylistTrack track in tracks) {
      final String dedupeKey =
          '${track.title.toLowerCase()}|${track.artist.toLowerCase()}';
      if (!seen.add(dedupeKey)) {
        continue;
      }
      unique.add(track);
    }
    return List<HotPlaylistTrack>.unmodifiable(<HotPlaylistTrack>[
      for (int index = 0; index < unique.length; index += 1)
        unique[index].copyWith(rank: startRank + index),
    ]);
  }

  Future<Object?> _defaultHttpGet(
    String url,
    Map<String, dynamic> query,
    Map<String, String> headers,
  ) async {
    final Response<dynamic> response = await _dio.get<dynamic>(
      url,
      queryParameters: query,
      options: Options(responseType: ResponseType.json, headers: headers),
    );
    return response.data;
  }

  static String _joinTencentSingers(Object? value) {
    return _asListOfMaps(value)
        .map((Map<String, dynamic> singer) => _readString(singer['name']))
        .where((String name) => name.isNotEmpty)
        .join(' / ');
  }

  static String _tencentCoverUrl(Object? albumMid) {
    final String mid = _readString(albumMid);
    if (mid.isEmpty) {
      return '';
    }
    return 'https://y.gtimg.cn/music/photo_new/T002R300x300M000$mid.jpg';
  }

  static String _kugouTrackCover(Map<String, dynamic> json) {
    final Map<String, dynamic>? params = _asMap(json['trans_param']);
    final String unionCover = _readString(params?['union_cover']);
    if (unionCover.isNotEmpty) {
      return unionCover;
    }
    return _readString(json['album_sizable_cover']);
  }

  static String _kugouCoverUrl(Object? value) {
    final String raw = _readString(value);
    if (raw.isEmpty) {
      return '';
    }
    final String sized = raw.contains('{size}')
        ? raw.replaceAll('{size}', '300')
        : raw;
    return _httpsImageUrl(sized);
  }

  static String _httpsImageUrl(String url) {
    final String trimmed = url.trim();
    if (trimmed.startsWith('http://')) {
      return 'https://${trimmed.substring('http://'.length)}';
    }
    return trimmed;
  }

  static Object? _decode(Object? payload) {
    if (payload is String) {
      try {
        return jsonDecode(payload);
      } on FormatException {
        return null;
      }
    }
    return payload;
  }

  static Map<String, dynamic>? _asMap(Object? value) {
    return asNullableStringKeyedMap(value);
  }

  static List<Map<String, dynamic>> _asListOfMaps(Object? value) {
    if (value is! List) {
      return const <Map<String, dynamic>>[];
    }
    return asListOfMaps(value);
  }

  static String _readString(Object? value) {
    return value?.toString().trim() ?? '';
  }

  static int _readInt(Object? value) {
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(_readString(value)) ?? 0;
  }

  static int _readDurationSeconds(Object? value) {
    final int raw = value is num
        ? value.toInt()
        : int.tryParse(_readString(value)) ?? 0;
    if (raw <= 0) {
      return 0;
    }
    if (raw >= 10000) {
      return (raw / 1000).round();
    }
    return raw;
  }
}

class _CachedPlaylists {
  const _CachedPlaylists({required this.playlists, required this.fetchedAt});

  final List<HotPlaylist> playlists;
  final DateTime fetchedAt;

  bool get isExpired =>
      DateTime.now().difference(fetchedAt) > HotPlaylistRepository.cacheTtl;
}

class _CachedTrackPage {
  const _CachedTrackPage({required this.page, required this.fetchedAt});

  final HotPlaylistTrackPage page;
  final DateTime fetchedAt;

  bool get isExpired =>
      DateTime.now().difference(fetchedAt) > HotPlaylistRepository.cacheTtl;
}

class _CachedTrackIds {
  const _CachedTrackIds({required this.trackIds, required this.fetchedAt});

  final List<String> trackIds;
  final DateTime fetchedAt;

  bool get isExpired =>
      DateTime.now().difference(fetchedAt) > HotPlaylistRepository.cacheTtl;
}
