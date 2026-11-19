// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hot_playlist_detail_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(HotPlaylistDetailController)
final hotPlaylistDetailControllerProvider =
    HotPlaylistDetailControllerFamily._();

final class HotPlaylistDetailControllerProvider
    extends
        $NotifierProvider<HotPlaylistDetailController, HotPlaylistDetailState> {
  HotPlaylistDetailControllerProvider._({
    required HotPlaylistDetailControllerFamily super.from,
    required HotPlaylist super.argument,
  }) : super(
         retry: null,
         name: r'hotPlaylistDetailControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$hotPlaylistDetailControllerHash();

  @override
  String toString() {
    return r'hotPlaylistDetailControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  HotPlaylistDetailController create() => HotPlaylistDetailController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HotPlaylistDetailState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HotPlaylistDetailState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is HotPlaylistDetailControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$hotPlaylistDetailControllerHash() =>
    r'7f9b40308553b5f73fb2c4afffe08422aedec6a1';

final class HotPlaylistDetailControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          HotPlaylistDetailController,
          HotPlaylistDetailState,
          HotPlaylistDetailState,
          HotPlaylistDetailState,
          HotPlaylist
        > {
  HotPlaylistDetailControllerFamily._()
    : super(
        retry: null,
        name: r'hotPlaylistDetailControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  HotPlaylistDetailControllerProvider call(HotPlaylist playlist) =>
      HotPlaylistDetailControllerProvider._(argument: playlist, from: this);

  @override
  String toString() => r'hotPlaylistDetailControllerProvider';
}

abstract class _$HotPlaylistDetailController
    extends $Notifier<HotPlaylistDetailState> {
  late final _$args = ref.$arg as HotPlaylist;
  HotPlaylist get playlist => _$args;

  HotPlaylistDetailState build(HotPlaylist playlist);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<HotPlaylistDetailState, HotPlaylistDetailState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<HotPlaylistDetailState, HotPlaylistDetailState>,
              HotPlaylistDetailState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
