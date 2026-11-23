// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorite_up_update_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(FavoriteUpUpdateController)
final favoriteUpUpdateControllerProvider =
    FavoriteUpUpdateControllerProvider._();

final class FavoriteUpUpdateControllerProvider
    extends
        $NotifierProvider<
          FavoriteUpUpdateController,
          Map<int, FavoriteUpUpdate>
        > {
  FavoriteUpUpdateControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'favoriteUpUpdateControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$favoriteUpUpdateControllerHash();

  @$internal
  @override
  FavoriteUpUpdateController create() => FavoriteUpUpdateController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<int, FavoriteUpUpdate> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<int, FavoriteUpUpdate>>(value),
    );
  }
}

String _$favoriteUpUpdateControllerHash() =>
    r'677de58bd9771940c8150de6df303c1b69a69515';

abstract class _$FavoriteUpUpdateController
    extends $Notifier<Map<int, FavoriteUpUpdate>> {
  Map<int, FavoriteUpUpdate> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<Map<int, FavoriteUpUpdate>, Map<int, FavoriteUpUpdate>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                Map<int, FavoriteUpUpdate>,
                Map<int, FavoriteUpUpdate>
              >,
              Map<int, FavoriteUpUpdate>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
