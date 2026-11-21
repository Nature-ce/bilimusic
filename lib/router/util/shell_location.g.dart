// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shell_location.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 当前 shell 所在的一级路由。
///
/// `StatefulShellRoute.indexedStack` 会把各个 tab 的页面一直挂在树上，
/// 来回切 tab 不会重跑 `initState`，所以需要这个信号让页面知道
/// 「自己被重新切回来了」。

@ProviderFor(ShellLocation)
final shellLocationProvider = ShellLocationProvider._();

/// 当前 shell 所在的一级路由。
///
/// `StatefulShellRoute.indexedStack` 会把各个 tab 的页面一直挂在树上，
/// 来回切 tab 不会重跑 `initState`，所以需要这个信号让页面知道
/// 「自己被重新切回来了」。
final class ShellLocationProvider
    extends $NotifierProvider<ShellLocation, String> {
  /// 当前 shell 所在的一级路由。
  ///
  /// `StatefulShellRoute.indexedStack` 会把各个 tab 的页面一直挂在树上，
  /// 来回切 tab 不会重跑 `initState`，所以需要这个信号让页面知道
  /// 「自己被重新切回来了」。
  ShellLocationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'shellLocationProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$shellLocationHash();

  @$internal
  @override
  ShellLocation create() => ShellLocation();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$shellLocationHash() => r'7eb5b309997d45903c91b30ceeb8bc0053cd64e3';

/// 当前 shell 所在的一级路由。
///
/// `StatefulShellRoute.indexedStack` 会把各个 tab 的页面一直挂在树上，
/// 来回切 tab 不会重跑 `initState`，所以需要这个信号让页面知道
/// 「自己被重新切回来了」。

abstract class _$ShellLocation extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
