import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/radar/domain/radar_pick.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'radar_pick_reasons.g.dart';

/// 推荐理由按「视频」归档：stableId 会随着 cid 补全而变化，
/// 用 bvid / aid 才能把解析时记下的理由对上播放中的这一条。
String radarReasonKey(PlayableItem item) {
  if (item.bvid.isNotEmpty) {
    return 'bvid:${item.bvid}';
  }
  return 'aid:${item.aid}';
}

/// 记住「这首推荐曲为什么被推过来」，播放页可以显示成一句推荐理由。
@Riverpod(keepAlive: true)
class RadarPickReasons extends _$RadarPickReasons {
  static const int maxEntries = 80;

  @override
  Map<String, RadarPick> build() => const <String, RadarPick>{};

  void record(PlayableItem item, RadarPick pick) {
    final String key = radarReasonKey(item);
    if (key.isEmpty) {
      return;
    }
    final Map<String, RadarPick> next = Map<String, RadarPick>.of(state)
      ..[key] = pick;
    if (next.length > maxEntries) {
      final List<String> keys = next.keys.toList(growable: false);
      for (final String stale in keys.take(next.length - maxEntries)) {
        next.remove(stale);
      }
    }
    state = next;
  }

  RadarPick? pickFor(PlayableItem? item) {
    if (item == null) {
      return null;
    }
    return state[radarReasonKey(item)];
  }
}
