// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorite_hot_playlist_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(favoriteHotPlaylistRepository)
final favoriteHotPlaylistRepositoryProvider =
    FavoriteHotPlaylistRepositoryProvider._();

final class FavoriteHotPlaylistRepositoryProvider
    extends
        $FunctionalProvider<
          FavoriteHotPlaylistRepository,
          FavoriteHotPlaylistRepository,
          FavoriteHotPlaylistRepository
        >
    with $Provider<FavoriteHotPlaylistRepository> {
  FavoriteHotPlaylistRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'favoriteHotPlaylistRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$favoriteHotPlaylistRepositoryHash();

  @$internal
  @override
  $ProviderElement<FavoriteHotPlaylistRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FavoriteHotPlaylistRepository create(Ref ref) {
    return favoriteHotPlaylistRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FavoriteHotPlaylistRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FavoriteHotPlaylistRepository>(
        value,
      ),
    );
  }
}

String _$favoriteHotPlaylistRepositoryHash() =>
    r'fba867ceab96a8aea86d58c95e3bc7652247a526';

/// 收藏的热门歌单（本地保存，新收藏的排前面）。

@ProviderFor(FavoriteHotPlaylists)
final favoriteHotPlaylistsProvider = FavoriteHotPlaylistsProvider._();

/// 收藏的热门歌单（本地保存，新收藏的排前面）。
final class FavoriteHotPlaylistsProvider
    extends $NotifierProvider<FavoriteHotPlaylists, List<HotPlaylist>> {
  /// 收藏的热门歌单（本地保存，新收藏的排前面）。
  FavoriteHotPlaylistsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'favoriteHotPlaylistsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$favoriteHotPlaylistsHash();

  @$internal
  @override
  FavoriteHotPlaylists create() => FavoriteHotPlaylists();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<HotPlaylist> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<HotPlaylist>>(value),
    );
  }
}

String _$favoriteHotPlaylistsHash() =>
    r'976a04c7b90c7537aea305662a43513653129f5f';

/// 收藏的热门歌单（本地保存，新收藏的排前面）。

abstract class _$FavoriteHotPlaylists extends $Notifier<List<HotPlaylist>> {
  List<HotPlaylist> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<HotPlaylist>, List<HotPlaylist>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<HotPlaylist>, List<HotPlaylist>>,
              List<HotPlaylist>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
