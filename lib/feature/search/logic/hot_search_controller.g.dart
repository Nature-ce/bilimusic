// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hot_search_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(hotSearch)
final hotSearchProvider = HotSearchProvider._();

final class HotSearchProvider
    extends
        $FunctionalProvider<
          List<HotSearchItem>,
          List<HotSearchItem>,
          List<HotSearchItem>
        >
    with $Provider<List<HotSearchItem>> {
  HotSearchProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hotSearchProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hotSearchHash();

  @$internal
  @override
  $ProviderElement<List<HotSearchItem>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<HotSearchItem> create(Ref ref) {
    return hotSearch(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<HotSearchItem> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<HotSearchItem>>(value),
    );
  }
}

String _$hotSearchHash() => r'2de7d1e421bcff32cd50c8b66995426d710a082f';
