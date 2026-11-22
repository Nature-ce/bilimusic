// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'radar_play_history_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(radarPlayHistoryStore)
final radarPlayHistoryStoreProvider = RadarPlayHistoryStoreProvider._();

final class RadarPlayHistoryStoreProvider
    extends
        $FunctionalProvider<
          RadarPlayHistoryStore,
          RadarPlayHistoryStore,
          RadarPlayHistoryStore
        >
    with $Provider<RadarPlayHistoryStore> {
  RadarPlayHistoryStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'radarPlayHistoryStoreProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$radarPlayHistoryStoreHash();

  @$internal
  @override
  $ProviderElement<RadarPlayHistoryStore> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RadarPlayHistoryStore create(Ref ref) {
    return radarPlayHistoryStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RadarPlayHistoryStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RadarPlayHistoryStore>(value),
    );
  }
}

String _$radarPlayHistoryStoreHash() =>
    r'cc5c2dfbd82b0befb4878e19497730e6d89f5bba';

/// 记录「你听了什么、听了多久」，供私人雷达算口味。
///
/// 和「最近播放进度」不同，这边保留的是历史记录（歌名 / 歌手 / 听了多久 /
/// 听了几遍），重启后还在，雷达靠它学习口味。

@ProviderFor(RadarPlayHistoryController)
final radarPlayHistoryControllerProvider =
    RadarPlayHistoryControllerProvider._();

/// 记录「你听了什么、听了多久」，供私人雷达算口味。
///
/// 和「最近播放进度」不同，这边保留的是历史记录（歌名 / 歌手 / 听了多久 /
/// 听了几遍），重启后还在，雷达靠它学习口味。
final class RadarPlayHistoryControllerProvider
    extends
        $NotifierProvider<RadarPlayHistoryController, List<RadarPlayRecord>> {
  /// 记录「你听了什么、听了多久」，供私人雷达算口味。
  ///
  /// 和「最近播放进度」不同，这边保留的是历史记录（歌名 / 歌手 / 听了多久 /
  /// 听了几遍），重启后还在，雷达靠它学习口味。
  RadarPlayHistoryControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'radarPlayHistoryControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$radarPlayHistoryControllerHash();

  @$internal
  @override
  RadarPlayHistoryController create() => RadarPlayHistoryController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<RadarPlayRecord> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<RadarPlayRecord>>(value),
    );
  }
}

String _$radarPlayHistoryControllerHash() =>
    r'c6b53180fe7f169245a1d3c377b9d23eea4df357';

/// 记录「你听了什么、听了多久」，供私人雷达算口味。
///
/// 和「最近播放进度」不同，这边保留的是历史记录（歌名 / 歌手 / 听了多久 /
/// 听了几遍），重启后还在，雷达靠它学习口味。

abstract class _$RadarPlayHistoryController
    extends $Notifier<List<RadarPlayRecord>> {
  List<RadarPlayRecord> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<RadarPlayRecord>, List<RadarPlayRecord>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<RadarPlayRecord>, List<RadarPlayRecord>>,
              List<RadarPlayRecord>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
