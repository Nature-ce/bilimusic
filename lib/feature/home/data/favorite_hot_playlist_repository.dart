import 'dart:convert';

import 'package:bilimusic/core/hive/hive_keys.dart';
import 'package:bilimusic/feature/home/domain/hot_playlist.dart';
import 'package:bilimusic/feature/home/domain/music_chart_platform.dart';
import 'package:hive_ce/hive.dart';

/// 「收藏的热门歌单」本地存储。
///
/// 热门歌单来自网易云 / QQ音乐 / 酷狗，不是 B 站收藏夹，没法走收藏夹那套，
/// 所以单独存一份 JSON 列表在 prefs 里。
class FavoriteHotPlaylistRepository {
  FavoriteHotPlaylistRepository() : _box = null;

  /// 测试可注入内存 box。
  FavoriteHotPlaylistRepository.withBox(Box<String> box) : _box = box;

  final Box<String>? _box;

  Box<String> get _storage => _box ?? Hive.box<String>(HiveBoxNames.prefs);

  List<HotPlaylist> load() {
    try {
      final String raw = _storage.get(HiveKeys.favoriteHotPlaylists) ?? '';
      if (raw.trim().isEmpty) {
        return const <HotPlaylist>[];
      }
      final Object? decoded = jsonDecode(raw);
      if (decoded is! List) {
        return const <HotPlaylist>[];
      }
      final List<HotPlaylist> playlists = <HotPlaylist>[];
      for (final Object? item in decoded) {
        final HotPlaylist? playlist = _fromJson(item);
        if (playlist != null) {
          playlists.add(playlist);
        }
      }
      return playlists;
    } on Object {
      // 本地缓存读不到（没初始化 Hive、数据损坏）就当没收藏过。
      return const <HotPlaylist>[];
    }
  }

  Future<void> save(List<HotPlaylist> playlists) async {
    try {
      await _storage.put(
        HiveKeys.favoriteHotPlaylists,
        jsonEncode(playlists.map(_toJson).toList(growable: false)),
      );
    } on Object {
      // 存不进去不影响当前会话的收藏状态。
    }
  }

  static Map<String, dynamic> _toJson(HotPlaylist playlist) {
    return <String, dynamic>{
      'platform': playlist.platform.name,
      'id': playlist.id,
      'name': playlist.name,
      'coverUrl': playlist.coverUrl,
      'playCount': playlist.playCount,
      'trackCount': playlist.trackCount,
      'favoriteCount': playlist.favoriteCount,
      'creator': playlist.creator,
      'description': playlist.description,
    };
  }

  static HotPlaylist? _fromJson(Object? value) {
    if (value is! Map) {
      return null;
    }
    final String platformName = '${value['platform'] ?? ''}'.trim();
    final String id = '${value['id'] ?? ''}'.trim();
    final String name = '${value['name'] ?? ''}'.trim();
    if (id.isEmpty || name.isEmpty) {
      return null;
    }
    MusicChartPlatform? platform;
    for (final MusicChartPlatform candidate in MusicChartPlatform.values) {
      if (candidate.name == platformName) {
        platform = candidate;
        break;
      }
    }
    if (platform == null) {
      return null;
    }
    return HotPlaylist(
      platform: platform,
      id: id,
      name: name,
      coverUrl: '${value['coverUrl'] ?? ''}'.trim(),
      playCount: _readInt(value['playCount']),
      trackCount: _readInt(value['trackCount']),
      favoriteCount: _readInt(value['favoriteCount']),
      creator: '${value['creator'] ?? ''}'.trim(),
      description: '${value['description'] ?? ''}'.trim(),
    );
  }

  static int _readInt(Object? value) {
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse('${value ?? ''}') ?? 0;
  }
}
