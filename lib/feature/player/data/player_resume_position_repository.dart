import 'package:bilimusic/core/hive/hive_keys.dart';
import 'package:hive_ce/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'player_resume_position_repository.g.dart';

@riverpod
PlayerResumePositionRepository playerResumePositionRepository(Ref ref) {
  return PlayerResumePositionRepository(Hive.box<String>(HiveBoxNames.prefs));
}

/// 续播位置单独持久化。
///
/// 以前「每 10 秒记一次进度」走的是整条队列快照，大歌单（100 首 ≈ 200KB）
/// 一小时要重写约 72MB。这里只记「当前曲目 stableId + 毫秒数」一个很小的值；
/// 读取时 stableId 对不上就丢弃，避免把上一首的进度套到新曲目上。
class PlayerResumePositionRepository {
  const PlayerResumePositionRepository(this._box);

  final Box<String> _box;

  ({String stableId, Duration position})? read() {
    final String raw = _box.get(HiveKeys.playerResumePosition) ?? '';
    if (raw.isEmpty) {
      return null;
    }
    final int separator = raw.indexOf('|');
    if (separator <= 0 || separator == raw.length - 1) {
      return null;
    }
    final String stableId = raw.substring(0, separator);
    final int? millis = int.tryParse(raw.substring(separator + 1));
    if (stableId.isEmpty || millis == null || millis < 0) {
      return null;
    }
    return (stableId: stableId, position: Duration(milliseconds: millis));
  }

  Future<void> write({required String stableId, required Duration position}) {
    if (stableId.isEmpty || position.isNegative) {
      return Future<void>.value();
    }
    return _box.put(
      HiveKeys.playerResumePosition,
      '$stableId|${position.inMilliseconds}',
    );
  }

  Future<void> clear() {
    return _box.delete(HiveKeys.playerResumePosition);
  }
}
