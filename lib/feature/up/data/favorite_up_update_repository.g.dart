// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorite_up_update_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(favoriteUpUpdateRepository)
final favoriteUpUpdateRepositoryProvider =
    FavoriteUpUpdateRepositoryProvider._();

final class FavoriteUpUpdateRepositoryProvider
    extends
        $FunctionalProvider<
          FavoriteUpUpdateRepository,
          FavoriteUpUpdateRepository,
          FavoriteUpUpdateRepository
        >
    with $Provider<FavoriteUpUpdateRepository> {
  FavoriteUpUpdateRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'favoriteUpUpdateRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$favoriteUpUpdateRepositoryHash();

  @$internal
  @override
  $ProviderElement<FavoriteUpUpdateRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FavoriteUpUpdateRepository create(Ref ref) {
    return favoriteUpUpdateRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FavoriteUpUpdateRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FavoriteUpUpdateRepository>(value),
    );
  }
}

String _$favoriteUpUpdateRepositoryHash() =>
    r'e51a3ce0abfd2eda534b812009ab37a601033dd1';
