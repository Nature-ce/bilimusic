// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_back_to_top.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 首页热榜列表与「回到顶部」按钮共用的滚动控制器。

@ProviderFor(homeScrollController)
final homeScrollControllerProvider = HomeScrollControllerProvider._();

/// 首页热榜列表与「回到顶部」按钮共用的滚动控制器。

final class HomeScrollControllerProvider
    extends
        $FunctionalProvider<
          ScrollController,
          ScrollController,
          ScrollController
        >
    with $Provider<ScrollController> {
  /// 首页热榜列表与「回到顶部」按钮共用的滚动控制器。
  HomeScrollControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeScrollControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeScrollControllerHash();

  @$internal
  @override
  $ProviderElement<ScrollController> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ScrollController create(Ref ref) {
    return homeScrollController(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ScrollController value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ScrollController>(value),
    );
  }
}

String _$homeScrollControllerHash() =>
    r'9d09bab4eb39c68e474e7c1e955c256f33927dd5';

/// 首页列表是否已经滚过阈值，用来决定是否显示「回到顶部」按钮。

@ProviderFor(HomeBackToTopVisibility)
final homeBackToTopVisibilityProvider = HomeBackToTopVisibilityProvider._();

/// 首页列表是否已经滚过阈值，用来决定是否显示「回到顶部」按钮。
final class HomeBackToTopVisibilityProvider
    extends $NotifierProvider<HomeBackToTopVisibility, bool> {
  /// 首页列表是否已经滚过阈值，用来决定是否显示「回到顶部」按钮。
  HomeBackToTopVisibilityProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeBackToTopVisibilityProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeBackToTopVisibilityHash();

  @$internal
  @override
  HomeBackToTopVisibility create() => HomeBackToTopVisibility();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$homeBackToTopVisibilityHash() =>
    r'4204cebd83641b748e64188cb2f0c6d7cea7a1f8';

/// 首页列表是否已经滚过阈值，用来决定是否显示「回到顶部」按钮。

abstract class _$HomeBackToTopVisibility extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
