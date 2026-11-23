import 'dart:convert';
import 'package:bilimusic/core/cache/app_cache_manager.dart';
import 'package:bilimusic/feature/metadata/data/metadata_cache_repository.dart';
import 'package:bilimusic/feature/metadata/domain/metadata.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:hive_ce/hive.dart';

class CacheUtil {
  CacheUtil._();

  static CacheManager get imageCacheManager => AppImageCacheManager.instance;
  static CacheManager get audioCacheManager => AppAudioCacheManager.instance;
  static CacheManager get lyricsCacheManager => AppLyricsCacheManager.instance;
  static Future<void> clearImageCache() async {
    await imageCacheManager.emptyCache();
  }

  static Future<void> clearAudioCache() async {
    await audioCacheManager.emptyCache();
  }

  static Future<void> clearLyricsCache() => lyricsCacheManager.emptyCache();

  static Future<void> clearMetadataCache() async {
    await Hive.lazyBox<Metadata>(metadataCacheBoxName).clear();
  }

  static Future<int> getImageCacheSizeBytes() async {
    return imageCacheManager.store.getCacheSize();
  }

  static Future<int> getAudioCacheSizeBytes() async {
    return audioCacheManager.store.getCacheSize();
  }

  static Future<int> getLyricsCacheSizeBytes() {
    return lyricsCacheManager.store.getCacheSize();
  }

  static Future<int> getMetadataCacheSizeBytes() async {
    final LazyBox<Metadata> box = Hive.lazyBox<Metadata>(metadataCacheBoxName);
    int total = 0;
    for (final Object key in box.keys) {
      final Metadata? metadata = await box.get(key);
      if (metadata == null) {
        continue;
      }
      total += utf8.encode(jsonEncode(metadata.toJson())).length;
    }
    return total;
  }

  static Future<int> getTotalCacheSizeBytes() async {
    final List<int> sizes = await Future.wait<int>(<Future<int>>[
      getImageCacheSizeBytes(),
      getAudioCacheSizeBytes(),
      getLyricsCacheSizeBytes(),
      getMetadataCacheSizeBytes(),
    ]);
    return sizes.fold<int>(0, (int total, int item) => total + item);
  }
}
