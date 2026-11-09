// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bili_music_chart_source.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(biliMusicChartSource)
final biliMusicChartSourceProvider = BiliMusicChartSourceProvider._();

final class BiliMusicChartSourceProvider
    extends
        $FunctionalProvider<
          BiliMusicChartSource,
          BiliMusicChartSource,
          BiliMusicChartSource
        >
    with $Provider<BiliMusicChartSource> {
  BiliMusicChartSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'biliMusicChartSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$biliMusicChartSourceHash();

  @$internal
  @override
  $ProviderElement<BiliMusicChartSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BiliMusicChartSource create(Ref ref) {
    return biliMusicChartSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BiliMusicChartSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BiliMusicChartSource>(value),
    );
  }
}

String _$biliMusicChartSourceHash() =>
    r'bbfb5040c9101d2dd47e37933d1e17cede471e1e';
