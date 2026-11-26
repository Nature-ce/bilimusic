// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_foreground.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 应用是否处于前台。后台播放时用它停掉只服务于 UI 的定时器与轮询，
/// 避免息屏后仍在每秒唤醒主线程。

@ProviderFor(AppForeground)
final appForegroundProvider = AppForegroundProvider._();

/// 应用是否处于前台。后台播放时用它停掉只服务于 UI 的定时器与轮询，
/// 避免息屏后仍在每秒唤醒主线程。
final class AppForegroundProvider
    extends $NotifierProvider<AppForeground, bool> {
  /// 应用是否处于前台。后台播放时用它停掉只服务于 UI 的定时器与轮询，
  /// 避免息屏后仍在每秒唤醒主线程。
  AppForegroundProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appForegroundProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appForegroundHash();

  @$internal
  @override
  AppForeground create() => AppForeground();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$appForegroundHash() => r'ff3643393ef0247d8ace397f64308ba1fed626db';

/// 应用是否处于前台。后台播放时用它停掉只服务于 UI 的定时器与轮询，
/// 避免息屏后仍在每秒唤醒主线程。

abstract class _$AppForeground extends $Notifier<bool> {
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
