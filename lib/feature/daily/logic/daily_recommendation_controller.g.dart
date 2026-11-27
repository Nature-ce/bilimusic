// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_recommendation_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(dailyRecommendationStore)
final dailyRecommendationStoreProvider = DailyRecommendationStoreProvider._();

final class DailyRecommendationStoreProvider
    extends
        $FunctionalProvider<
          DailyRecommendationStore,
          DailyRecommendationStore,
          DailyRecommendationStore
        >
    with $Provider<DailyRecommendationStore> {
  DailyRecommendationStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dailyRecommendationStoreProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dailyRecommendationStoreHash();

  @$internal
  @override
  $ProviderElement<DailyRecommendationStore> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DailyRecommendationStore create(Ref ref) {
    return dailyRecommendationStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DailyRecommendationStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DailyRecommendationStore>(value),
    );
  }
}

String _$dailyRecommendationStoreHash() =>
    r'c0d425c687bda6e33c60199d0ca8206d6e8e6a2c';

/// 可替换的「今天」来源：生成与跨天判断都从这里取，测试里能固定 / 推进日期。

@ProviderFor(dailyNow)
final dailyNowProvider = DailyNowProvider._();

/// 可替换的「今天」来源：生成与跨天判断都从这里取，测试里能固定 / 推进日期。

final class DailyNowProvider
    extends $FunctionalProvider<DailyNow, DailyNow, DailyNow>
    with $Provider<DailyNow> {
  /// 可替换的「今天」来源：生成与跨天判断都从这里取，测试里能固定 / 推进日期。
  DailyNowProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dailyNowProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dailyNowHash();

  @$internal
  @override
  $ProviderElement<DailyNow> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DailyNow create(Ref ref) {
    return dailyNow(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DailyNow value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DailyNow>(value),
    );
  }
}

String _$dailyNowHash() => r'a4535174cc28d3fe668af355bbf75a466213f043';

@ProviderFor(dailyRecommendationRandom)
final dailyRecommendationRandomProvider = DailyRecommendationRandomProvider._();

final class DailyRecommendationRandomProvider
    extends $FunctionalProvider<Random, Random, Random>
    with $Provider<Random> {
  DailyRecommendationRandomProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dailyRecommendationRandomProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dailyRecommendationRandomHash();

  @$internal
  @override
  $ProviderElement<Random> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Random create(Ref ref) {
    return dailyRecommendationRandom(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Random value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Random>(value),
    );
  }
}

String _$dailyRecommendationRandomHash() =>
    r'05b164977765a4f2d21fc95edce3c64687035707';

@ProviderFor(dailyRecommendationRecommender)
final dailyRecommendationRecommenderProvider =
    DailyRecommendationRecommenderProvider._();

final class DailyRecommendationRecommenderProvider
    extends
        $FunctionalProvider<
          RadarRecommender,
          RadarRecommender,
          RadarRecommender
        >
    with $Provider<RadarRecommender> {
  DailyRecommendationRecommenderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dailyRecommendationRecommenderProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dailyRecommendationRecommenderHash();

  @$internal
  @override
  $ProviderElement<RadarRecommender> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  RadarRecommender create(Ref ref) {
    return dailyRecommendationRecommender(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RadarRecommender value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RadarRecommender>(value),
    );
  }
}

String _$dailyRecommendationRecommenderHash() =>
    r'74ab3e25cbef86f8c2bbc9750bd3973ff404b9fe';

/// 每日推荐：当天第一份生成后存进 prefs，之后重启、切页面都读同一份；
/// `dateKey` 不是今天就重新生成。

@ProviderFor(DailyRecommendationController)
final dailyRecommendationControllerProvider =
    DailyRecommendationControllerProvider._();

/// 每日推荐：当天第一份生成后存进 prefs，之后重启、切页面都读同一份；
/// `dateKey` 不是今天就重新生成。
final class DailyRecommendationControllerProvider
    extends
        $NotifierProvider<
          DailyRecommendationController,
          DailyRecommendationState
        > {
  /// 每日推荐：当天第一份生成后存进 prefs，之后重启、切页面都读同一份；
  /// `dateKey` 不是今天就重新生成。
  DailyRecommendationControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dailyRecommendationControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dailyRecommendationControllerHash();

  @$internal
  @override
  DailyRecommendationController create() => DailyRecommendationController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DailyRecommendationState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DailyRecommendationState>(value),
    );
  }
}

String _$dailyRecommendationControllerHash() =>
    r'2aa0164be4f7860ece1bbb5fc23189978d1e9732';

/// 每日推荐：当天第一份生成后存进 prefs，之后重启、切页面都读同一份；
/// `dateKey` 不是今天就重新生成。

abstract class _$DailyRecommendationController
    extends $Notifier<DailyRecommendationState> {
  DailyRecommendationState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<DailyRecommendationState, DailyRecommendationState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DailyRecommendationState, DailyRecommendationState>,
              DailyRecommendationState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
