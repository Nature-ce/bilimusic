// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_back_to_top.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 首页当前 section 的滚动控制器（「回到顶部」按钮据此滚动）。
///
/// 首页改成分页滑动后，两个 section 各有一份滚动控制器，
/// 这里只持有当前可见那一份。

@ProviderFor(HomeActiveScrollController)
final homeActiveScrollControllerProvider =
    HomeActiveScrollControllerProvider._();

/// 首页当前 section 的滚动控制器（「回到顶部」按钮据此滚动）。
///
/// 首页改成分页滑动后，两个 section 各有一份滚动控制器，
/// 这里只持有当前可见那一份。
final class HomeActiveScrollControllerProvider
    extends $NotifierProvider<HomeActiveScrollController, ScrollController?> {
  /// 首页当前 section 的滚动控制器（「回到顶部」按钮据此滚动）。
  ///
  /// 首页改成分页滑动后，两个 section 各有一份滚动控制器，
  /// 这里只持有当前可见那一份。
  HomeActiveScrollControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeActiveScrollControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeActiveScrollControllerHash();

  @$internal
  @override
  HomeActiveScrollController create() => HomeActiveScrollController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ScrollController? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ScrollController?>(value),
    );
  }
}

String _$homeActiveScrollControllerHash() =>
    r'790c020797c1c29c94da3cda3f33633159b868c2';

/// 首页当前 section 的滚动控制器（「回到顶部」按钮据此滚动）。
///
/// 首页改成分页滑动后，两个 section 各有一份滚动控制器，
/// 这里只持有当前可见那一份。

abstract class _$HomeActiveScrollController
    extends $Notifier<ScrollController?> {
  ScrollController? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ScrollController?, ScrollController?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ScrollController?, ScrollController?>,
              ScrollController?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

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
    r'5a4a454f934d8d45d1bc981237c9884a3543e818';

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
