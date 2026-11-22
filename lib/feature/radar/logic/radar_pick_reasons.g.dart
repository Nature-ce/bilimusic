// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'radar_pick_reasons.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 记住「这首推荐曲为什么被推过来」，播放页可以显示成一句推荐理由。

@ProviderFor(RadarPickReasons)
final radarPickReasonsProvider = RadarPickReasonsProvider._();

/// 记住「这首推荐曲为什么被推过来」，播放页可以显示成一句推荐理由。
final class RadarPickReasonsProvider
    extends $NotifierProvider<RadarPickReasons, Map<String, RadarPick>> {
  /// 记住「这首推荐曲为什么被推过来」，播放页可以显示成一句推荐理由。
  RadarPickReasonsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'radarPickReasonsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$radarPickReasonsHash();

  @$internal
  @override
  RadarPickReasons create() => RadarPickReasons();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, RadarPick> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, RadarPick>>(value),
    );
  }
}

String _$radarPickReasonsHash() => r'97ddf1fc4adce06d3fa5410026055ec3da8c5d05';

/// 记住「这首推荐曲为什么被推过来」，播放页可以显示成一句推荐理由。

abstract class _$RadarPickReasons extends $Notifier<Map<String, RadarPick>> {
  Map<String, RadarPick> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<Map<String, RadarPick>, Map<String, RadarPick>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Map<String, RadarPick>, Map<String, RadarPick>>,
              Map<String, RadarPick>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
