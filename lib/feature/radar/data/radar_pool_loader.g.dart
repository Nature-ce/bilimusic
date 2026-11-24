// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'radar_pool_loader.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(radarPoolLoader)
final radarPoolLoaderProvider = RadarPoolLoaderProvider._();

final class RadarPoolLoaderProvider
    extends
        $FunctionalProvider<RadarPoolLoader, RadarPoolLoader, RadarPoolLoader>
    with $Provider<RadarPoolLoader> {
  RadarPoolLoaderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'radarPoolLoaderProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$radarPoolLoaderHash();

  @$internal
  @override
  $ProviderElement<RadarPoolLoader> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  RadarPoolLoader create(Ref ref) {
    return radarPoolLoader(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RadarPoolLoader value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RadarPoolLoader>(value),
    );
  }
}

String _$radarPoolLoaderHash() => r'6c85d3f7fd351fb589e7f73ddaa4d4df5f10961b';
