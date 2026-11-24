import 'dart:convert';

import 'package:bilimusic/core/hive/hive_keys.dart';
import 'package:bilimusic/feature/daily/domain/daily_recommendation.dart';
import 'package:hive_ce/hive.dart';

/// 每日推荐的本地存储：prefs 里一条 JSON，按 `dateKey` 判断是不是今天那份。
class DailyRecommendationStore {
  const DailyRecommendationStore(this._prefsBox);

  final Box<String> _prefsBox;

  DailyRecommendation? load() {
    final String raw = _prefsBox.get(HiveKeys.dailyRecommendation) ?? '';
    if (raw.trim().isEmpty) {
      return null;
    }
    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }
      final DailyRecommendation recommendation = DailyRecommendation.fromJson(
        decoded,
      );
      if (recommendation.dateKey.trim().isEmpty) {
        return null;
      }
      return recommendation;
    } on Object {
      return null;
    }
  }

  Future<void> save(DailyRecommendation recommendation) {
    return _prefsBox.put(
      HiveKeys.dailyRecommendation,
      jsonEncode(recommendation.toJson()),
    );
  }

  Future<void> clear() {
    return _prefsBox.delete(HiveKeys.dailyRecommendation);
  }
}
