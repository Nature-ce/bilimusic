// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hot_playlist_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 仓库要活到整个会话：它内部记住“当前翻到第几页”，被回收后下拉刷新就永远停在第一批。

@ProviderFor(hotPlaylistRepository)
final hotPlaylistRepositoryProvider = HotPlaylistRepositoryProvider._();

/// 仓库要活到整个会话：它内部记住“当前翻到第几页”，被回收后下拉刷新就永远停在第一批。

final class HotPlaylistRepositoryProvider
    extends
        $FunctionalProvider<
          HotPlaylistRepository,
          HotPlaylistRepository,
          HotPlaylistRepository
        >
    with $Provider<HotPlaylistRepository> {
  /// 仓库要活到整个会话：它内部记住“当前翻到第几页”，被回收后下拉刷新就永远停在第一批。
  HotPlaylistRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hotPlaylistRepositoryProvider',
        isAutoDispose: false,
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
    r'cacca59f7f80322b55249bc343f8865b1a33536f';

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
    r'9d36f042836c377843b7e87e224591b66c6564f9';

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
