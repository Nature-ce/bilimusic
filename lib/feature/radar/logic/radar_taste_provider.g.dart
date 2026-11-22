// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'radar_taste_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 你的口味画像：收听历史为主，收藏（歌名 + 元信息里的真歌手）为辅。

@ProviderFor(radarTaste)
final radarTasteProvider = RadarTasteProvider._();

/// 你的口味画像：收听历史为主，收藏（歌名 + 元信息里的真歌手）为辅。

final class RadarTasteProvider
    extends
        $FunctionalProvider<
          AsyncValue<RadarTaste>,
          RadarTaste,
          FutureOr<RadarTaste>
        >
    with $FutureModifier<RadarTaste>, $FutureProvider<RadarTaste> {
  /// 你的口味画像：收听历史为主，收藏（歌名 + 元信息里的真歌手）为辅。
  RadarTasteProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'radarTasteProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$radarTasteHash();

  @$internal
  @override
  $FutureProviderElement<RadarTaste> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<RadarTaste> create(Ref ref) {
    return radarTaste(ref);
  }
}

String _$radarTasteHash() => r'55b9a22bbdce9d8644452809667e1bef7b9563df';
