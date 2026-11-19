// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hot_playlist_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(hotPlaylistRepository)
final hotPlaylistRepositoryProvider = HotPlaylistRepositoryProvider._();

final class HotPlaylistRepositoryProvider
    extends
        $FunctionalProvider<
          HotPlaylistRepository,
          HotPlaylistRepository,
          HotPlaylistRepository
        >
    with $Provider<HotPlaylistRepository> {
  HotPlaylistRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hotPlaylistRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hotPlaylistRepositoryHash();

  @$internal
  @override
  $ProviderElement<HotPlaylistRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  HotPlaylistRepository create(Ref ref) {
    return hotPlaylistRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HotPlaylistRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HotPlaylistRepository>(value),
    );
  }
}

String _$hotPlaylistRepositoryHash() =>
    r'fbf74a0c0ba68baf25b6036cbc39f374e7f825be';

@ProviderFor(HotPlaylistController)
final hotPlaylistControllerProvider = HotPlaylistControllerProvider._();

final class HotPlaylistControllerProvider
    extends $NotifierProvider<HotPlaylistController, HotPlaylistState> {
  HotPlaylistControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hotPlaylistControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hotPlaylistControllerHash();

  @$internal
  @override
  HotPlaylistController create() => HotPlaylistController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HotPlaylistState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HotPlaylistState>(value),
    );
  }
}

String _$hotPlaylistControllerHash() =>
    r'a72453f4f28bad6c2eca7742c8eb84444c22aa8a';

abstract class _$HotPlaylistController extends $Notifier<HotPlaylistState> {
  HotPlaylistState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<HotPlaylistState, HotPlaylistState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<HotPlaylistState, HotPlaylistState>,
              HotPlaylistState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
