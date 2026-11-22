import 'package:bilimusic/feature/favorites/domain/favorite_entry.dart';
import 'package:bilimusic/feature/favorites/logic/favorites_controller.dart';
import 'package:bilimusic/feature/metadata/data/metadata_cache_repository.dart';
import 'package:bilimusic/feature/metadata/domain/metadata.dart';
import 'package:bilimusic/feature/radar/domain/radar_play_record.dart';
import 'package:bilimusic/feature/radar/domain/radar_taste.dart';
import 'package:bilimusic/feature/radar/logic/radar_play_history_controller.dart';
import 'package:bilimusic/feature/radar/logic/radar_taste_builder.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'radar_taste_provider.g.dart';

const int _favoriteArtistSample = 40;
const int _likedTitleSample = 80;

/// 你的口味画像：收听历史为主，收藏（歌名 + 元信息里的真歌手）为辅。
@riverpod
Future<RadarTaste> radarTaste(Ref ref) async {
  final List<RadarPlayRecord> history = ref.watch(
    radarPlayHistoryControllerProvider,
  );
  final List<FavoriteEntry> entries = ref
      .watch(favoritesControllerProvider)
      .entries;
  final List<String> likedTitles = <String>[
    for (final FavoriteEntry entry in entries.take(_likedTitleSample))
      if (entry.title.trim().isNotEmpty) entry.title,
  ];
  final List<String> likedArtists = <String>[];
  if (entries.isNotEmpty) {
    final MetadataCacheRepository cache = ref.read(
      metadataCacheRepositoryProvider,
    );
    for (final FavoriteEntry entry in entries.take(_favoriteArtistSample)) {
      try {
        final Metadata? cached = await cache.getCachedMetadata(
          item: entry.toPlayableItem(),
        );
        final String artist = cached?.artist?.trim() ?? '';
        if (artist.isNotEmpty) {
          likedArtists.add(artist);
        }
      } on Object {
        continue;
      }
    }
  }
  return buildRadarTaste(
    history: history,
    now: DateTime.now(),
    likedArtists: likedArtists,
    likedTitles: likedTitles,
  );
}
