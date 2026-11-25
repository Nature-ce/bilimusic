import 'package:bilimusic/feature/up/domain/favorite_up.dart';
import 'package:bilimusic/feature/up/domain/up_profile.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_ce/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'favorite_up_local_repository.g.dart';

const String favoriteUpsBoxName = 'favorite_ups';

@riverpod
FavoriteUpLocalRepository favoriteUpLocalRepository(Ref ref) {
  return FavoriteUpLocalRepository(Hive.box<FavoriteUp>(favoriteUpsBoxName));
}

/// 同一个 UP 主的身份键：名字 + 头像。用来清理「同一账号存了两份」的历史数据。
@visibleForTesting
String favoriteUpIdentityKey({
  required String name,
  required String avatarUrl,
}) {
  return '${name.trim()}|${avatarUrl.trim()}';
}

/// 去重并剔除无效记录：mid<=0 的脏数据直接丢弃，同 mid / 同身份只留最新收藏的那条。
@visibleForTesting
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

  /// 按 mid 找；找不到时用「名字 + 头像」兜底，兼容历史脏数据里的不同 mid。
  FavoriteUp? find(int mid, {UpProfile? profile}) {
    final FavoriteUp? byMid = _box.get(mid);
    if (byMid != null || profile == null) {
      return byMid;
    }
    final String identity = favoriteUpIdentityKey(
      name: profile.name,
      avatarUrl: profile.avatarUrl,
    );
    for (final FavoriteUp up in _box.values) {
      if (favoriteUpIdentityKey(name: up.name, avatarUrl: up.avatarUrl) ==
          identity) {
        return up;
      }
    }
    return null;
  }

  Future<List<FavoriteUp>> save(FavoriteUp up) async {
    final String identity = favoriteUpIdentityKey(
      name: up.name,
      avatarUrl: up.avatarUrl,
    );
    final List<FavoriteUp> duplicates = _box.values
        .where(
          (FavoriteUp existing) =>
              existing.mid != up.mid &&
              favoriteUpIdentityKey(
                    name: existing.name,
                    avatarUrl: existing.avatarUrl,
                  ) ==
                  identity,
        )
        .toList(growable: false);
    for (final FavoriteUp duplicate in duplicates) {
      await _box.delete(duplicate.mid);
    }
    await _box.put(up.mid, up);
    return load();
  }

  Future<List<FavoriteUp>> delete(int mid) async {
    await _box.delete(mid);
    return load();
  }
}
