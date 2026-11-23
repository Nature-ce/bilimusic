import 'dart:convert';

import 'package:bilimusic/feature/up/domain/favorite_up_update.dart';
import 'package:hive_ce/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'favorite_up_update_repository.g.dart';

const String favoriteUpUpdatesBoxName = 'favorite_up_updates';

@riverpod
FavoriteUpUpdateRepository favoriteUpUpdateRepository(Ref ref) {
  return FavoriteUpUpdateRepository(Hive.box<String>(favoriteUpUpdatesBoxName));
}

class FavoriteUpUpdateRepository {
  const FavoriteUpUpdateRepository(this._box);

  final Box<String> _box;

  Map<int, FavoriteUpUpdate> load() {
    final Map<int, FavoriteUpUpdate> updates = <int, FavoriteUpUpdate>{};
    for (final String value in _box.values) {
      final FavoriteUpUpdate? update = _decode(value);
      if (update != null) {
        updates[update.mid] = update;
      }
    }
    return updates;
  }

  Future<void> save(FavoriteUpUpdate update) {
    return _box.put(update.mid, jsonEncode(update.toJson()));
  }

  Future<void> clear() {
    return _box.clear();
  }

  FavoriteUpUpdate? _decode(String value) {
    try {
      final Object? decoded = jsonDecode(value);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }
      return FavoriteUpUpdate.fromJson(decoded);
    } on Object {
      return null;
    }
  }
}
