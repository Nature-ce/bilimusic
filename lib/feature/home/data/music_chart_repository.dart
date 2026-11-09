import 'dart:convert';

import 'package:bilimusic/common/util/display_text.dart';
import 'package:bilimusic/common/util/json_util.dart';
import 'package:bilimusic/feature/home/domain/music_chart.dart';
import 'package:bilimusic/feature/home/domain/music_chart_platform.dart';
import 'package:bilimusic/feature/home/domain/music_chart_track.dart';
import 'package:bilimusic/feature/meting/domain/meting_server.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:dio/dio.dart';
import 'package:meting_dart/meting_dart.dart';

typedef MusicChartPlaylistRequest =
    Future<Object?> Function(MetingServer server, String chartId);
typedef MusicChartCoverRequest =
    Future<String> Function(MetingServer server, String pictureId);
typedef MusicChartToplistRequest = Future<Object?> Function(String topId);
typedef MusicChartRankSongRequest = Future<Object?> Function(String rankId);
typedef MusicChartBiliRecommendRequest = Future<Object?> Function(int count);
typedef MusicChartBiliRankingRequest = Future<Object?> Function(int count);

class MusicChartException implements Exception {
  const MusicChartException(this.message);

  final String message;

  @override
  String toString() => message;
}

class MusicChartRepository {
  MusicChartRepository({
    Dio? dio,
    MusicChartPlaylistRequest? playlistRequest,
    MusicChartCoverRequest? coverRequest,
    MusicChartToplistRequest? toplistRequest,
    MusicChartRankSongRequest? rankSongRequest,
    MusicChartBiliRecommendRequest? biliRecommendRequest,
    MusicChartBiliRankingRequest? biliRankingRequest,
  }) : _dio = dio ?? Dio() {
    _playlistRequest = playlistRequest ?? _defaultPlaylistRequest;
    _coverRequest = coverRequest ?? _defaultCoverRequest;
    _toplistRequest = toplistRequest ?? _defaultToplistRequest;
    _rankSongRequest = rankSongRequest ?? _defaultRankSongRequest;
    _biliRecommendRequest = biliRecommendRequest;
    _biliRankingRequest = biliRankingRequest;
  }

  static const int maxTrackCount = 30;
  static const Duration cacheTtl = Duration(minutes: 10);
  static const String _toplistUrl =
      'https://c.y.qq.com/v8/fcg-bin/fcg_v8_toplist_cp.fcg';
  static const String _kugouRankUrl =
      'https://mobiles.kugou.com/api/v3/rank/song';

  final Dio _dio;
  late final MusicChartPlaylistRequest _playlistRequest;
  late final MusicChartCoverRequest _coverRequest;
  late final MusicChartToplistRequest _toplistRequest;
  late final MusicChartRankSongRequest _rankSongRequest;
  late final MusicChartBiliRecommendRequest? _biliRecommendRequest;
  late final MusicChartBiliRankingRequest? _biliRankingRequest;
  final Map<String, _CachedChart> _cache = <String, _CachedChart>{};

  Future<List<MusicChartTrack>> fetchTracks(MusicChart chart) async {
    final _CachedChart? cached = _cache[chart.key];
    if (cached != null && !cached.isExpired) {
      return cached.tracks;
    }

    final List<MusicChartTrack> tracks = switch (chart.platform) {
      MusicChartPlatform.netease => await _fetchMetingPlaylist(chart),
      MusicChartPlatform.tencent => await _fetchTencentToplist(chart),
      MusicChartPlatform.kugou => await _fetchKugouRank(chart),
      MusicChartPlatform.bilibili => await _fetchBilibili(chart),
    };
    _cache[chart.key] = _CachedChart(tracks: tracks, fetchedAt: DateTime.now());
    return tracks;
  }

  Future<List<MusicChartTrack>> _fetchMetingPlaylist(MusicChart chart) async {
    final MetingServer? server = chart.platform.server;
    if (server == null) {
      throw const MusicChartException('该榜单不支持 meting 数据源');
    }
    final Object? response = await _playlistRequest(server, chart.chartId);
    final List<dynamic> rawItems = _decodeList(response);
    final List<MusicChartTrack> tracks = <MusicChartTrack>[];
    for (final dynamic rawItem in rawItems) {
      final Map<String, dynamic>? json = _asMap(rawItem);
      if (json == null) {
        continue;
      }
      final String title = _readString(json['name'] ?? json['title']);
      final String artist = _readArtist(json['artist'] ?? json['author']);
      if (title.isEmpty) {
        continue;
      }
      final String pictureId = _readString(json['pic_id']);
      String coverUrl = '';
      if (pictureId.isNotEmpty) {
        try {
          coverUrl = await _coverRequest(server, pictureId);
        } on Object {
          coverUrl = '';
        }
      }
      tracks.add(
        MusicChartTrack(
          chart: chart,
          rank: 0,
          title: normalizeDisplayText(title),
          artist: normalizeDisplayText(artist),
          coverUrl: coverUrl,
          durationSeconds: _readDurationSeconds(json['duration']),
        ),
      );
    }

    return _finalizeTracks(tracks);
  }

  Future<List<MusicChartTrack>> _fetchTencentToplist(MusicChart chart) async {
    final Object? response = await _toplistRequest(chart.chartId);
    return parseTencentToplist(response, chart);
  }

  static List<MusicChartTrack> parseTencentToplist(
    Object? payload,
    MusicChart chart,
  ) {
    final Object? decoded = payload is String ? _tryDecode(payload) : payload;
    final Map<String, dynamic>? root = _asMap(decoded);
    if (root == null) {
      throw const MusicChartException('QQ音乐榜单数据异常');
    }
    final Object? code = root['code'];
    if (code is num && code.toInt() != 0) {
      throw const MusicChartException('QQ音乐榜单加载失败');
    }
    final List<MusicChartTrack> tracks = <MusicChartTrack>[];
    for (final Map<String, dynamic> item in _asListOfMaps(root['songlist'])) {
      final Map<String, dynamic> data =
          _asMap(item['data']) ?? <String, dynamic>{};
      final String title = _readString(data['songname'] ?? data['title']);
      if (title.isEmpty) {
        continue;
      }
      tracks.add(
        MusicChartTrack(
          chart: chart,
          rank: 0,
          title: normalizeDisplayText(title),
          artist: normalizeDisplayText(_readTencentSingers(data['singer'])),
          coverUrl: _tencentCoverUrl(data['albummid']),
          durationSeconds: _readDurationSeconds(data['interval']),
        ),
      );
    }
    return _finalizeTracks(tracks);
  }

  Future<List<MusicChartTrack>> _fetchKugouRank(MusicChart chart) async {
    final Object? response = await _rankSongRequest(chart.chartId);
    return parseKugouRank(response, chart);
  }

  static List<MusicChartTrack> parseKugouRank(
    Object? payload,
    MusicChart chart,
  ) {
    final Object? decoded = payload is String ? _tryDecode(payload) : payload;
    final Map<String, dynamic>? root = _asMap(decoded);
    if (root == null) {
      throw const MusicChartException('酷狗榜单数据异常');
    }
    final Object? status = root['status'];
    if (status is num && status.toInt() != 1) {
      throw const MusicChartException('酷狗榜单加载失败');
    }
    final Map<String, dynamic> data =
        _asMap(root['data']) ?? <String, dynamic>{};
    final List<MusicChartTrack> tracks = <MusicChartTrack>[];
    for (final dynamic rawItem in _asListOfMaps(data['info'])) {
      final Map<String, dynamic> json = rawItem;
      final String rawName = _readString(json['songname']);
      String artist = '';
      final List<Map<String, dynamic>> authors = asListOfMaps(json['authors']);
      if (authors.isNotEmpty) {
        artist = authors
            .map(
              (Map<String, dynamic> author) =>
                  _readString(author['author_name']),
            )
            .where((String value) => value.isNotEmpty)
            .join(' / ');
      }
      if (artist.isEmpty) {
        final String filename = _readString(json['filename']);
        final int splitIndex = filename.indexOf(' - ');
        if (splitIndex > 0) {
          artist = filename.substring(0, splitIndex).trim();
        }
      }
      if (rawName.isEmpty) {
        continue;
      }
      tracks.add(
        MusicChartTrack(
          chart: chart,
          rank: 0,
          title: normalizeDisplayText(rawName),
          artist: normalizeDisplayText(artist),
          coverUrl: _kugouCoverUrl(json),
          durationSeconds: _readKugouDuration(json['duration']),
        ),
      );
    }
    return _finalizeTracks(tracks);
  }

  static const String bilibiliRecommendChartId = 'recommend';

  Future<List<MusicChartTrack>> _fetchBilibili(MusicChart chart) async {
    final bool isRecommend = chart.chartId == bilibiliRecommendChartId;
    final Object? payload;
    if (isRecommend) {
      final MusicChartBiliRecommendRequest? request = _biliRecommendRequest;
      if (request == null) {
        throw const MusicChartException('B站推荐暂不可用');
      }
      payload = await request(maxTrackCount);
    } else {
      final MusicChartBiliRankingRequest? request = _biliRankingRequest;
      if (request == null) {
        throw const MusicChartException('B站音乐区榜单暂不可用');
      }
      payload = await request(maxTrackCount);
    }
    return isRecommend
        ? parseBilibiliRecommend(payload, chart)
        : parseBilibiliRanking(payload, chart);
  }

  static List<MusicChartTrack> parseBilibiliRecommend(
    Object? payload,
    MusicChart chart,
  ) {
    return _parseBilibiliTracks(payload, chart, dataKey: 'item');
  }

  static List<MusicChartTrack> parseBilibiliRanking(
    Object? payload,
    MusicChart chart,
  ) {
    return _parseBilibiliTracks(payload, chart, dataKey: 'list');
  }

  static List<MusicChartTrack> _parseBilibiliTracks(
    Object? payload,
    MusicChart chart, {
    required String dataKey,
  }) {
    final Object? decoded = payload is String ? _tryDecode(payload) : payload;
    final Map<String, dynamic>? root = _asMap(decoded);
    if (root == null) {
      throw const MusicChartException('B站榜单数据异常');
    }
    final Object? code = root['code'];
    if (code is num && code.toInt() != 0) {
      throw const MusicChartException('B站榜单加载失败');
    }
    final Map<String, dynamic>? data = _asMap(root['data']);
    final List<MusicChartTrack> tracks = <MusicChartTrack>[];
    for (final Map<String, dynamic> json in _asListOfMaps(data?[dataKey])) {
      final MusicChartTrack? track = _bilibiliTrack(json, chart);
      if (track != null) {
        tracks.add(track);
      }
    }
    return _finalizeTracks(tracks);
  }

  static MusicChartTrack? _bilibiliTrack(
    Map<String, dynamic> json,
    MusicChart chart,
  ) {
    final String bvid = _readString(json['bvid']);
    final int aid = _readInt(json['id'] ?? json['aid']);
    final int cid = _readInt(json['cid']);
    final String title = normalizeDisplayText(_readString(json['title']));
    if (bvid.isEmpty || cid <= 0 || title.isEmpty) {
      return null;
    }

    final Map<String, dynamic>? owner = _asMap(json['owner']);
    final String author = normalizeDisplayText(_readString(owner?['name']));
    final int ownerMid = _readInt(owner?['mid']);
    final String coverUrl = _httpsImageUrl(_readString(json['pic']));
    final int durationSeconds = _readDurationSeconds(json['duration']);

    return MusicChartTrack(
      chart: chart,
      rank: 0,
      title: title,
      artist: author,
      coverUrl: coverUrl,
      durationSeconds: durationSeconds,
      directItem: PlayableItem(
        aid: aid > 0 ? aid : 0,
        bvid: bvid,
        cid: cid,
        page: 1,
        title: title,
        author: author,
        coverUrl: coverUrl,
        ownerMid: ownerMid > 0 ? ownerMid : null,
      ),
    );
  }

  static int _readInt(Object? value) {
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(_readString(value)) ?? 0;
  }

  static String _httpsImageUrl(String url) {
    final String trimmed = url.trim();
    if (trimmed.startsWith('http://')) {
      return 'https://${trimmed.substring('http://'.length)}';
    }
    return trimmed;
  }

  static String _readTencentSingers(Object? value) {
    final List<Map<String, dynamic>> singers = _asListOfMaps(value);
    return singers
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

  static String _kugouCoverUrl(Map<String, dynamic> json) {
    final Map<String, dynamic>? params = _asMap(json['trans_param']);
    final String raw = _readString(params?['union_cover']).isNotEmpty
        ? _readString(params?['union_cover'])
        : _readString(json['album_sizable_cover']);
    return raw.isEmpty ? '' : raw.replaceAll('{size}', '300');
  }

  static int _readKugouDuration(Object? value) {
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(_readString(value)) ?? 0;
  }

  static List<MusicChartTrack> _finalizeTracks(List<MusicChartTrack> tracks) {
    final List<MusicChartTrack> unique = <MusicChartTrack>[];
    final Set<String> seen = <String>{};
    for (final MusicChartTrack track in tracks) {
      final String uniqueKey =
          '${track.title.toLowerCase()}|${track.artist.toLowerCase()}';
      if (!seen.add(uniqueKey)) {
        continue;
      }
      unique.add(track);
      if (unique.length >= maxTrackCount) {
        break;
      }
    }
    return List<MusicChartTrack>.unmodifiable(<MusicChartTrack>[
      for (int index = 0; index < unique.length; index += 1)
        unique[index].copyWith(rank: index + 1),
    ]);
  }

  static Future<Object?> _defaultPlaylistRequest(
    MetingServer server,
    String chartId,
  ) {
    final Meting meting = Meting(server: server.apiValue)..format(true);
    return meting.playlist(chartId);
  }

  static Future<String> _defaultCoverRequest(
    MetingServer server,
    String pictureId,
  ) {
    final Meting meting = Meting(server: server.apiValue)..format(false);
    return meting.pic(pictureId, size: 300);
  }

  Future<Object?> _defaultToplistRequest(String topId) async {
    final Response<dynamic> response = await _dio.get<dynamic>(
      _toplistUrl,
      queryParameters: <String, dynamic>{
        'topid': topId,
        'page': 'detail',
        'type': 'top',
        'song_begin': 0,
        'song_num': maxTrackCount,
        'format': 'json',
      },
      options: Options(
        responseType: ResponseType.json,
        headers: <String, String>{'Referer': 'https://y.qq.com/'},
      ),
    );
    return response.data;
  }

  Future<Object?> _defaultRankSongRequest(String rankId) async {
    final Response<dynamic> response = await _dio.get<dynamic>(
      _kugouRankUrl,
      queryParameters: <String, dynamic>{
        'rankid': rankId,
        'page': 1,
        'pagesize': maxTrackCount,
        'plat': 2,
        'version': 8990,
      },
      options: Options(responseType: ResponseType.json),
    );
    return response.data;
  }

  static Object? _tryDecode(String value) {
    try {
      return jsonDecode(value);
    } on FormatException {
      return null;
    }
  }

  static List<dynamic> _decodeList(Object? response) {
    final Object? decoded = response is String
        ? _tryDecode(response)
        : response;
    return decoded is List ? decoded : const <dynamic>[];
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

  static String _readArtist(Object? value) {
    if (value is List) {
      return value
          .where((Object? item) => item != null)
          .map((Object? item) => item.toString().trim())
          .where((String item) => item.isNotEmpty)
          .join(' / ');
    }
    return _readString(value);
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

class _CachedChart {
  const _CachedChart({required this.tracks, required this.fetchedAt});

  final List<MusicChartTrack> tracks;
  final DateTime fetchedAt;

  bool get isExpired =>
      DateTime.now().difference(fetchedAt) > MusicChartRepository.cacheTtl;
}
