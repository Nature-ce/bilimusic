import 'package:bilimusic/feature/up/domain/favorite_up.dart';
import 'package:bilimusic/feature/up/domain/up_profile.dart';
import 'package:hive_ce/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'favorite_up_local_repository.g.dart';

const String favoriteUpsBoxName = 'favorite_ups';

@riverpod
FavoriteUpLocalRepository favoriteUpLocalRepository(Ref ref) {
  return FavoriteUpLocalRepository(Hive.box<FavoriteUp>(favoriteUpsBoxName));
}

/// 同一个 UP 主的身份键：名字 + 头像。用来清理「同一账号存了两份」的历史数据。
String favoriteUpIdentityKey({
  required String name,
  required String avatarUrl,
}) {
  return '${name.trim()}|${avatarUrl.trim()}';
}

/// 去重并剔除无效记录：mid<=0 的脏数据直接丢弃，同 mid / 同身份只留最新收藏的那条。
List<FavoriteUp> dedupeFavoriteUps(Iterable<FavoriteUp> ups) {
  final List<FavoriteUp> sorted =
      ups.where((FavoriteUp up) => up.mid > 0).toList(growable: false)..sort(
        (FavoriteUp a, FavoriteUp b) =>
            b.favoritedAtEpochMs.compareTo(a.favoritedAtEpochMs),
      );
  final Set<int> seenMids = <int>{};
  final Set<String> seenIdentities = <String>{};
  final List<FavoriteUp> result = <FavoriteUp>[];
  for (final FavoriteUp up in sorted) {
    if (!seenMids.add(up.mid)) {
      continue;
    }
    final String identity = favoriteUpIdentityKey(
      name: up.name,
      avatarUrl: up.avatarUrl,
    );
    if (!seenIdentities.add(identity)) {
      continue;
    }
    result.add(up);
  }
  return result;
}

class FavoriteUpLocalRepository {
  const FavoriteUpLocalRepository(this._box);

  final Box<FavoriteUp> _box;

  List<FavoriteUp> load() {
    return dedupeFavoriteUps(_box.values);
  }

  FavoriteUp? get(int mid) {
    return _box.get(mid);
  }

  /// 按 mid 找；找不到时依次用「名字 + 头像」「名字」兜底，
  /// 兼容历史脏数据里 mid 不同、头像 URL 参数不同的同一条收藏。
  FavoriteUp? find(int mid, {UpProfile? profile}) {
    final FavoriteUp? byKey = _box.get(mid);
    if (byKey != null) {
      return byKey;
    }
    // 历史版本可能用自增 key 写入（key != mid），这里再按记录里的 mid 找一次。
    for (final FavoriteUp up in _box.values) {
      if (up.mid == mid) {
        return up;
      }
    }
    if (profile == null) {
      return null;
    }
    final String identity = favoriteUpIdentityKey(
      name: profile.name,
      avatarUrl: profile.avatarUrl,
    );
    final String name = profile.name.trim();
    FavoriteUp? byName;
    for (final FavoriteUp up in _box.values) {
      if (favoriteUpIdentityKey(name: up.name, avatarUrl: up.avatarUrl) ==
          identity) {
        return up;
      }
      if (name.isNotEmpty && up.name.trim() == name) {
        byName ??= up;
      }
    }
    return byName;
  }

  /// 删除所有指向同一个 UP 的记录（同名或同 mid），返回删掉的数量。
  Future<int> deleteMatching({required int mid, required String name}) async {
    final String trimmed = name.trim();
    final List<dynamic> keys = <dynamic>[
      for (final MapEntry<dynamic, FavoriteUp> entry in _box.toMap().entries)
        if (entry.value.mid == mid ||
            (trimmed.isNotEmpty && entry.value.name.trim() == trimmed))
          entry.key,
    ];
    for (final dynamic key in keys) {
      await _box.delete(key);
    }
    return keys.length;
  }

  Future<List<FavoriteUp>> save(FavoriteUp up) async {
    // 先把同 mid / 同名的旧记录清掉（按真实 key 删，兼容自增 key 的旧数据）。
    await deleteMatching(mid: up.mid, name: up.name);
    await _box.put(up.mid, up);
    return load();
  }

  Future<List<FavoriteUp>> delete(int mid) async {
    await _box.delete(mid);
    // 旧数据可能用自增 key 存，这里再按记录里的 mid 删一遍。
    final List<dynamic> keys = <dynamic>[
      for (final MapEntry<dynamic, FavoriteUp> entry in _box.toMap().entries)
        if (entry.value.mid == mid) entry.key,
    ];
    for (final dynamic key in keys) {
      await _box.delete(key);
    }
    return load();
  }
}
