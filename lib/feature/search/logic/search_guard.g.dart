// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_guard.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// B 站搜索接口的全局熔断状态。
///
/// 高频搜索会触发风控，此时接口对同一 IP 往往返回「成功但结果为空」，
/// 连普通搜索页都会显示「没有找到相关视频」。这里把状态集中起来：
/// 匹配器上报限流、搜索页据此给出明确提示，并统一冷却，避免继续硬搜。

@ProviderFor(SearchGuard)
final searchGuardProvider = SearchGuardProvider._();

/// B 站搜索接口的全局熔断状态。
///
/// 高频搜索会触发风控，此时接口对同一 IP 往往返回「成功但结果为空」，
/// 连普通搜索页都会显示「没有找到相关视频」。这里把状态集中起来：
/// 匹配器上报限流、搜索页据此给出明确提示，并统一冷却，避免继续硬搜。
final class SearchGuardProvider
    extends $NotifierProvider<SearchGuard, Duration> {
  /// B 站搜索接口的全局熔断状态。
  ///
  /// 高频搜索会触发风控，此时接口对同一 IP 往往返回「成功但结果为空」，
  /// 连普通搜索页都会显示「没有找到相关视频」。这里把状态集中起来：
  /// 匹配器上报限流、搜索页据此给出明确提示，并统一冷却，避免继续硬搜。
  SearchGuardProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchGuardProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchGuardHash();

  @$internal
  @override
  SearchGuard create() => SearchGuard();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Duration value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Duration>(value),
    );
  }
}

String _$searchGuardHash() => r'0b80a1d4226c95a837fbcc5bcc28d54ce1eca3d9';

/// B 站搜索接口的全局熔断状态。
///
/// 高频搜索会触发风控，此时接口对同一 IP 往往返回「成功但结果为空」，
/// 连普通搜索页都会显示「没有找到相关视频」。这里把状态集中起来：
/// 匹配器上报限流、搜索页据此给出明确提示，并统一冷却，避免继续硬搜。

abstract class _$SearchGuard extends $Notifier<Duration> {
  Duration build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Duration, Duration>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Duration, Duration>,
              Duration,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
