// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hot_search_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(HotSearchController)
final hotSearchControllerProvider = HotSearchControllerProvider._();

final class HotSearchControllerProvider
    extends $AsyncNotifierProvider<HotSearchController, List<HotSearchItem>> {
  HotSearchControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hotSearchControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hotSearchControllerHash();

  @$internal
  @override
  HotSearchController create() => HotSearchController();
}

String _$hotSearchControllerHash() =>
    r'570c23810bc4d6af19b8aa0d51a3428316d7df90';

abstract class _$HotSearchController
    extends $AsyncNotifier<List<HotSearchItem>> {
  FutureOr<List<HotSearchItem>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<HotSearchItem>>, List<HotSearchItem>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<HotSearchItem>>, List<HotSearchItem>>,
              AsyncValue<List<HotSearchItem>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
