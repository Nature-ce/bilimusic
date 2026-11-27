import 'dart:io';

import 'package:bilimusic/common/util/platform_util.dart';
import 'package:bilimusic/core/hive/hive_adapters.dart';
import 'package:bilimusic/core/hive/hive_keys.dart';
import 'package:bilimusic/feature/download/data/download_repository.dart';
import 'package:bilimusic/feature/favorites/data/favorites_local_repository.dart';
import 'package:bilimusic/feature/favorites/data/favorites_remote_cache_repository.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_collection.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_entry.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_membership.dart';
import 'package:bilimusic/feature/metadata/data/metadata_cache_repository.dart';
import 'package:bilimusic/feature/metadata/domain/metadata.dart';
import 'package:bilimusic/feature/player/data/player_queue_local_repository.dart';
import 'package:bilimusic/feature/player/domain/persisted_playback_queue.dart';
import 'package:bilimusic/feature/recent/data/recent_playback_local_repository.dart';
import 'package:bilimusic/feature/recent/domain/recent_playback_entry.dart';
import 'package:bilimusic/feature/statistics/data/daily_listening_repository.dart';
import 'package:bilimusic/feature/statistics/data/song_listening_repository.dart';
import 'package:bilimusic/feature/statistics/data/statistics_local_repository.dart';
import 'package:bilimusic/feature/up/data/favorite_up_local_repository.dart';
import 'package:bilimusic/feature/up/data/favorite_up_update_repository.dart';
import 'package:bilimusic/feature/favorites/data/favorited_season_local_repository.dart';
import 'package:bilimusic/feature/up/domain/favorite_up.dart';
import 'package:bilimusic/feature/favorites/domain/favorited_season.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_ce/hive.dart';
import 'package:path_provider/path_provider.dart';

Future<void> initHive() async {
  if (!kIsWeb) {
    final Directory directory = PlatformUtil.isDesktop
        ? await getApplicationSupportDirectory()
        : await getApplicationDocumentsDirectory();
    Hive
      ..init(directory.path)
      ..registerAdapter(FavoriteCollectionAdapter())
      ..registerAdapter(FavoriteCollectionSourceAdapter())
      ..registerAdapter(FavoriteEntryAdapter())
      ..registerAdapter(FavoriteMembershipAdapter())
      ..registerAdapter(PlayerQueueModeAdapter())
      ..registerAdapter(PersistedPlayableItemAdapter())
      ..registerAdapter(PersistedPlaybackQueueAdapter())
      ..registerAdapter(RecentPlaybackEntryAdapter())
      ..registerAdapter(FavoriteUpAdapter())
      ..registerAdapter(FavoritedSeasonAdapter())
      ..registerAdapter(MetaLyricsAdapter())
      ..registerAdapter(MetadataAdapter())
      ..registerAdapter(CollectionKindAdapter());
  }
  // 并行打开：每个 box 是独立文件，open 之间没有依赖，串行 await 只会把
  // 冷启动时间叠加起来。打开的集合和顺序都和以前一致，只是更快。
  await Future.wait<Object?>(<Future<Object?>>[
    Hive.openBox<String>(HiveBoxNames.prefs),
    Hive.openBox<FavoriteCollection>(favoriteCollectionsBoxName),
    Hive.openBox<FavoriteEntry>(favoriteEntriesBoxName),
    Hive.openBox<FavoriteMembership>(favoriteMembershipsBoxName),
    Hive.openBox<FavoriteCollection>(remoteFavoriteCollectionsBoxName),
    Hive.openBox<FavoriteEntry>(remoteFavoriteEntriesBoxName),
    Hive.openBox<FavoriteMembership>(remoteFavoriteMembershipsBoxName),
    Hive.openBox<String>(HiveBoxNames.remoteFavoriteWastedResourceIds),
    Hive.openBox<PersistedPlaybackQueue>(playerQueueSnapshotBoxName),
    Hive.openBox<RecentPlaybackEntry>(recentPlaybackBoxName),
    Hive.openBox<Map>(songStatisticsBoxName),
    Hive.openBox<Map>(dailyListeningBoxName),
    Hive.openBox<Map>(songListeningBoxName),
    Hive.openBox<FavoriteUp>(favoriteUpsBoxName),
    Hive.openBox<String>(favoriteUpUpdatesBoxName),
    Hive.openBox<FavoritedSeason>(favoritedSeasonsBoxName),
    Hive.openLazyBox<Metadata>(metadataCacheBoxName),
    Hive.openBox<String>(downloadedTracksBoxName),
  ]);
}
