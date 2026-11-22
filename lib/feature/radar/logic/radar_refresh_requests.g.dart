// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'radar_refresh_requests.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 「换一批推荐」的请求计数：播放页菜单点一下就 +1，刷歌页收到后重算一批。

@ProviderFor(RadarRefreshRequests)
final radarRefreshRequestsProvider = RadarRefreshRequestsProvider._();

/// 「换一批推荐」的请求计数：播放页菜单点一下就 +1，刷歌页收到后重算一批。
final class RadarRefreshRequestsProvider
    extends $NotifierProvider<RadarRefreshRequests, int> {
  /// 「换一批推荐」的请求计数：播放页菜单点一下就 +1，刷歌页收到后重算一批。
  RadarRefreshRequestsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'radarRefreshRequestsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$radarRefreshRequestsHash();

  @$internal
  @override
  RadarRefreshRequests create() => RadarRefreshRequests();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$radarRefreshRequestsHash() =>
    r'd0e4eef95bf383b52060e3208e3c5182936e9d71';

/// 「换一批推荐」的请求计数：播放页菜单点一下就 +1，刷歌页收到后重算一批。

abstract class _$RadarRefreshRequests extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
