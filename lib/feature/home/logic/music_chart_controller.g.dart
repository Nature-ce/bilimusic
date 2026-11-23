// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'music_chart_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(musicChartRepository)
final musicChartRepositoryProvider = MusicChartRepositoryProvider._();

final class MusicChartRepositoryProvider
    extends
        $FunctionalProvider<
          MusicChartRepository,
          MusicChartRepository,
          MusicChartRepository
        >
    with $Provider<MusicChartRepository> {
  MusicChartRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'musicChartRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$musicChartRepositoryHash();

  @$internal
  @override
  $ProviderElement<MusicChartRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  MusicChartRepository create(Ref ref) {
    return musicChartRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MusicChartRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MusicChartRepository>(value),
    );
  }
}

String _$musicChartRepositoryHash() =>
    r'1bda9568e33bc036117c8fa1ecf1ef6c24f1d328';

/// 首页排行榜：三个平台各加载自己的默认榜单，供卡片与完整列表共用。
///
/// 之前一次只持有一个平台的榜单，首页只能竖着放一排平台 chip；
/// 现在卡片要同时显示 3 个平台的前三名，所以按平台分开缓存。

@ProviderFor(MusicChartController)
final musicChartControllerProvider = MusicChartControllerProvider._();

/// 首页排行榜：三个平台各加载自己的默认榜单，供卡片与完整列表共用。
///
/// 之前一次只持有一个平台的榜单，首页只能竖着放一排平台 chip；
/// 现在卡片要同时显示 3 个平台的前三名，所以按平台分开缓存。
final class MusicChartControllerProvider
    extends $NotifierProvider<MusicChartController, MusicChartState> {
  /// 首页排行榜：三个平台各加载自己的默认榜单，供卡片与完整列表共用。
  ///
  /// 之前一次只持有一个平台的榜单，首页只能竖着放一排平台 chip；
  /// 现在卡片要同时显示 3 个平台的前三名，所以按平台分开缓存。
  MusicChartControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'musicChartControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$musicChartControllerHash();

  @$internal
  @override
  MusicChartController create() => MusicChartController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MusicChartState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MusicChartState>(value),
    );
  }
}

String _$musicChartControllerHash() =>
    r'f8b42b51123702dc6081560d32c01d6720f10571';

/// 首页排行榜：三个平台各加载自己的默认榜单，供卡片与完整列表共用。
///
/// 之前一次只持有一个平台的榜单，首页只能竖着放一排平台 chip；
/// 现在卡片要同时显示 3 个平台的前三名，所以按平台分开缓存。

abstract class _$MusicChartController extends $Notifier<MusicChartState> {
  MusicChartState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<MusicChartState, MusicChartState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<MusicChartState, MusicChartState>,
              MusicChartState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
