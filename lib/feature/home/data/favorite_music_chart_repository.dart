import 'dart:convert';

import 'package:bilimusic/core/hive/hive_keys.dart';
import 'package:bilimusic/feature/home/domain/music_chart.dart';
import 'package:bilimusic/feature/home/domain/music_chart_platform.dart';
import 'package:hive_ce/hive.dart';

class FavoriteMusicChartRepository {
  FavoriteMusicChartRepository() : _box = null;

  FavoriteMusicChartRepository.withBox(Box<String> box) : _box = box;

  final Box<String>? _box;

  Box<String> get _storage => _box ?? Hive.box<String>(HiveBoxNames.prefs);

  List<MusicChart> load() {
    try {
      final String raw = _storage.get(HiveKeys.favoriteMusicCharts) ?? '';
      if (raw.trim().isEmpty) {
        return const <MusicChart>[];
      }
      final Object? decoded = jsonDecode(raw);
      if (decoded is! List) {
        return const <MusicChart>[];
      }
      final List<MusicChart> charts = <MusicChart>[];
      for (final Object? item in decoded) {
        final MusicChart? chart = _fromJson(item);
        if (chart != null) {
          charts.add(chart);
        }
      }
      return charts;
    } on Object {
      return const <MusicChart>[];
    }
  }

  Future<void> save(List<MusicChart> charts) async {
    try {
      await _storage.put(
        HiveKeys.favoriteMusicCharts,
        jsonEncode(charts.map(_toJson).toList(growable: false)),
      );
    } on Object {
      return;
    }
  }

  static Map<String, dynamic> _toJson(MusicChart chart) {
    return <String, dynamic>{
      'platform': chart.platform.name,
      'chartId': chart.chartId,
      'name': chart.name,
    };
  }

  static MusicChart? _fromJson(Object? raw) {
    if (raw is! Map) {
      return null;
    }
    final String chartId = (raw['chartId'] as Object?)?.toString() ?? '';
    final String name = (raw['name'] as Object?)?.toString() ?? '';
    if (chartId.isEmpty || name.isEmpty) {
      return null;
    }
    return MusicChart(
      platform:
          MusicChartPlatform.tryFromName(
            (raw['platform'] as Object?)?.toString() ?? '',
          ) ??
          MusicChartPlatform.netease,
      chartId: chartId,
      name: name,
    );
  }
}
