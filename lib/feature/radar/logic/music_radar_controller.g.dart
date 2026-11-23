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

/// 刷歌流：把各平台热门歌单汇成候选池，再按「私人雷达」的口味画像挑选。
///
/// 不再是「随机挑一张歌单的前几首」——那样整条流都是各平台榜首，很单调。
/// 现在会按常听歌手 / 同歌单 / 换口味三档混合，并限制同一歌手、同一歌单的占比。

@ProviderFor(MusicRadarController)
final musicRadarControllerProvider = MusicRadarControllerProvider._();

/// 刷歌流：把各平台热门歌单汇成候选池，再按「私人雷达」的口味画像挑选。
///
/// 不再是「随机挑一张歌单的前几首」——那样整条流都是各平台榜首，很单调。
/// 现在会按常听歌手 / 同歌单 / 换口味三档混合，并限制同一歌手、同一歌单的占比。
final class MusicRadarControllerProvider
    extends $NotifierProvider<MusicRadarController, MusicRadarState> {
  /// 刷歌流：把各平台热门歌单汇成候选池，再按「私人雷达」的口味画像挑选。
  ///
  /// 不再是「随机挑一张歌单的前几首」——那样整条流都是各平台榜首，很单调。
  /// 现在会按常听歌手 / 同歌单 / 换口味三档混合，并限制同一歌手、同一歌单的占比。
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
    r'f94e27e450c008ce0455554012cf00d3da5548cf';

/// 刷歌流：把各平台热门歌单汇成候选池，再按「私人雷达」的口味画像挑选。
///
/// 不再是「随机挑一张歌单的前几首」——那样整条流都是各平台榜首，很单调。
/// 现在会按常听歌手 / 同歌单 / 换口味三档混合，并限制同一歌手、同一歌单的占比。

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
