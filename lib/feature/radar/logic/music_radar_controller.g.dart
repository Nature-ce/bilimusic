// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'music_radar_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(musicRadarRandom)
final musicRadarRandomProvider = MusicRadarRandomProvider._();

final class MusicRadarRandomProvider
    extends $FunctionalProvider<Random, Random, Random>
    with $Provider<Random> {
  MusicRadarRandomProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'musicRadarRandomProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$musicRadarRandomHash();

  @$internal
  @override
  $ProviderElement<Random> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Random create(Ref ref) {
    return musicRadarRandom(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Random value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Random>(value),
    );
  }
}

String _$musicRadarRandomHash() => r'7ef00326402536208036f8f47518c4c06f5d035c';

/// 刷歌流：扫描各平台热榜歌单，随机抽取曲目组成可持续下滑的发现流。

@ProviderFor(MusicRadarController)
final musicRadarControllerProvider = MusicRadarControllerProvider._();

/// 刷歌流：扫描各平台热榜歌单，随机抽取曲目组成可持续下滑的发现流。
final class MusicRadarControllerProvider
    extends $NotifierProvider<MusicRadarController, MusicRadarState> {
  /// 刷歌流：扫描各平台热榜歌单，随机抽取曲目组成可持续下滑的发现流。
  MusicRadarControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'musicRadarControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$musicRadarControllerHash();

  @$internal
  @override
  MusicRadarController create() => MusicRadarController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MusicRadarState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MusicRadarState>(value),
    );
  }
}

String _$musicRadarControllerHash() =>
    r'42f92e53c2484f8b40d487aa477b892e2589759e';

/// 刷歌流：扫描各平台热榜歌单，随机抽取曲目组成可持续下滑的发现流。

abstract class _$MusicRadarController extends $Notifier<MusicRadarState> {
  MusicRadarState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<MusicRadarState, MusicRadarState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<MusicRadarState, MusicRadarState>,
              MusicRadarState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
