import 'package:bilimusic/feature/home/data/favorite_hot_playlist_repository.dart';
import 'package:bilimusic/feature/home/domain/hot_playlist.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'favorite_hot_playlist_controller.g.dart';

@Riverpod(keepAlive: true)
FavoriteHotPlaylistRepository favoriteHotPlaylistRepository(Ref ref) {
  return FavoriteHotPlaylistRepository();
}

/// 收藏的热门歌单（本地保存，新收藏的排前面）。
@Riverpod(keepAlive: true)
class FavoriteHotPlaylists extends _$FavoriteHotPlaylists {
  late final FavoriteHotPlaylistRepository _repository = ref.read(
    favoriteHotPlaylistRepositoryProvider,
  );

  @override
  List<HotPlaylist> build() => _repository.load();

  bool contains(HotPlaylist playlist) {
    return state.any((HotPlaylist item) => item.key == playlist.key);
  }

  /// 切换收藏状态，返回切换后是否已收藏。
  Future<bool> toggle(HotPlaylist playlist) async {
    final bool willFavorite = !contains(playlist);
    final List<HotPlaylist> next = willFavorite
        ? <HotPlaylist>[
            playlist,
            ...state.where((HotPlaylist item) => item.key != playlist.key),
          ]
        : state
              .where((HotPlaylist item) => item.key != playlist.key)
              .toList(growable: false);
    state = next;
    await _repository.save(next);
    return willFavorite;
  }
}
