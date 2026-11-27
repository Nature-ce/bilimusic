import 'dart:convert';

import 'package:bilimusic/feature/home/domain/matchable_track.dart';
import 'package:bilimusic/feature/home/logic/chart_track_matcher.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:hive_ce/hive.dart';

/// 记录「这首平台歌曲匹配到了哪个 B 站视频」。
///
/// 同一个歌单反复点「播放全部」时不用重新搜 B 站：命中直接复用，
/// 上一次判定为「匹配不到」的也记一笔短 TTL 的负缓存，避免被风控。
class TrackMatchCache {
  const TrackMatchCache(
    this._box, {
    this.hitTtl = const Duration(days: 14),
    this.missTtl = const Duration(hours: 2),
    this.maxEntries = 2000,
  });

  final Box<String> _box;
  final Duration hitTtl;
  final Duration missTtl;
  final int maxEntries;

  /// 负缓存条目的格式版本。
  ///
  /// 只有带这个标记的条目才认：升级前写入的旧负缓存是「12 小时语义」，
  /// 里面混着软限流等误判，一律当作过期，让那些歌立刻重新尝试；
  /// 正缓存不受影响，不会引发全量重搜。
  static const int _missSchema = 2;

  static String _keyFor(MatchableTrack track) {
    final String title = ChartTrackMatcher.normalize(track.title);
    final String artist = ChartTrackMatcher.normalize(track.artist);
    return 'match.v4|$title|$artist';
  }

  PlayableItem? readHit(MatchableTrack track) {
    final Map<String, dynamic>? entry = _read(track);
    if (entry == null || entry['hit'] != true) {
      return null;
    }
    if (_expired(entry, hitTtl)) {
      return null;
    }
    final String bvid = entry['bvid'] as String? ?? '';
    final int aid = (entry['aid'] as num?)?.toInt() ?? 0;
    if (bvid.isEmpty && aid <= 0) {
      return null;
    }
    return PlayableItem(
      aid: aid,
      bvid: bvid,
      title: entry['title'] as String? ?? '',
      author: entry['author'] as String? ?? '',
      coverUrl: entry['coverUrl'] as String? ?? '',
      cid: (entry['cid'] as num?)?.toInt(),
      page: (entry['page'] as num?)?.toInt(),
      durationText: entry['durationText'] as String?,
    );
  }

  bool isFreshMiss(MatchableTrack track) {
    final Map<String, dynamic>? entry = _read(track);
    if (entry == null || entry['hit'] != false) {
      return false;
    }
    if ((entry['schema'] as num?)?.toInt() != _missSchema) {
      return false;
    }
    return !_expired(entry, missTtl);
  }

  Future<void> writeHit(MatchableTrack track, PlayableItem item) {
    return _write(track, <String, dynamic>{
      'hit': true,
      'aid': item.aid,
      'bvid': item.bvid,
      'cid': item.cid,
      'page': item.page,
      'title': item.title,
      'author': item.author,
      'coverUrl': item.coverUrl,
      'durationText': item.durationText,
      'at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// 记一笔「匹配不到」。
  ///
  /// [reason] 只用于事后排查：`no-match` 表示确实搜到了候选但都不合格，
  /// 其余可疑原因（空结果、时长全不合格、限流冷却）调用方不该写负缓存。
  Future<void> writeMiss(MatchableTrack track, {String reason = 'no-match'}) {
    return _write(track, <String, dynamic>{
      'hit': false,
      'schema': _missSchema,
      'reason': reason,
      'at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Map<String, dynamic>? _read(MatchableTrack track) {
    final String raw = _box.get(_keyFor(track)) ?? '';
    if (raw.isEmpty) {
      return null;
    }
    try {
      final Object? decoded = jsonDecode(raw);
      return decoded is Map<String, dynamic> ? decoded : null;
    } on Object {
      return null;
    }
  }

  bool _expired(Map<String, dynamic> entry, Duration ttl) {
    final int at = (entry['at'] as num?)?.toInt() ?? 0;
    if (at <= 0) {
      return true;
    }
    return DateTime.now().millisecondsSinceEpoch - at > ttl.inMilliseconds;
  }

  Future<void> _write(MatchableTrack track, Map<String, dynamic> entry) async {
    try {
      await _box.put(_keyFor(track), jsonEncode(entry));
      await _pruneIfNeeded();
    } on Object {
      // 缓存写失败不影响播放。
    }
  }

  Future<void> _pruneIfNeeded() async {
    final List<dynamic> keys = _box.keys
        .whereType<String>()
        .where((String key) => key.startsWith('match.v4|'))
        .toList(growable: false);
    if (keys.length <= maxEntries) {
      return;
    }
    final int removeCount = keys.length - maxEntries;
    for (int index = 0; index < removeCount; index += 1) {
      await _box.delete(keys[index]);
    }
  }
}
