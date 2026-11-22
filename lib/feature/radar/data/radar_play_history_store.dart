import 'dart:convert';

import 'package:bilimusic/core/hive/hive_keys.dart';
import 'package:bilimusic/core/settings/app_settings_store.dart';
import 'package:bilimusic/feature/radar/domain/radar_play_record.dart';

/// 收听记录的本地存储（就放在 prefs 里，一条 JSON 数组）。
class RadarPlayHistoryStore {
  const RadarPlayHistoryStore(this._settings);

  static const int maxRecords = 240;

  final AppSettingsStore _settings;

  List<RadarPlayRecord> load() {
    final String raw = _settings.readString(
      HiveKeys.radarPlayHistory,
      defaultValue: '[]',
    );
    if (raw.trim().isEmpty) {
      return const <RadarPlayRecord>[];
    }
    List<RadarPlayRecord> records = <RadarPlayRecord>[];
    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is! List<dynamic>) {
        return const <RadarPlayRecord>[];
      }
      for (final Object? value in decoded) {
        if (value is! Map<String, dynamic>) {
          continue;
        }
        try {
          records.add(RadarPlayRecord.fromJson(value));
        } on Object {
          continue;
        }
      }
    } on FormatException {
      return const <RadarPlayRecord>[];
    }
    records = trim(records);
    records.sort(
      (RadarPlayRecord a, RadarPlayRecord b) =>
          b.updatedAtMs.compareTo(a.updatedAtMs),
    );
    return records;
  }

  Future<void> save(List<RadarPlayRecord> records) {
    final List<RadarPlayRecord> trimmed = trim(records);
    return _settings.writeString(
      HiveKeys.radarPlayHistory,
      jsonEncode(<Map<String, dynamic>>[
        for (final RadarPlayRecord record in trimmed) record.toJson(),
      ]),
    );
  }

  /// 只留最近更新的若干条，避免无限增长。
  static List<RadarPlayRecord> trim(List<RadarPlayRecord> records) {
    if (records.length <= maxRecords) {
      return List<RadarPlayRecord>.of(records);
    }
    final List<RadarPlayRecord> sorted = List<RadarPlayRecord>.of(records)
      ..sort(
        (RadarPlayRecord a, RadarPlayRecord b) =>
            b.updatedAtMs.compareTo(a.updatedAtMs),
      );
    return sorted.sublist(0, maxRecords);
  }
}
