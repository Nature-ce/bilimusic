// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'statistics_tracker.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(dailyListeningRepository)
final dailyListeningRepositoryProvider = DailyListeningRepositoryProvider._();

final class DailyListeningRepositoryProvider
    extends
        $FunctionalProvider<
          DailyListeningRepository,
          DailyListeningRepository,
          DailyListeningRepository
        >
    with $Provider<DailyListeningRepository> {
  DailyListeningRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dailyListeningRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dailyListeningRepositoryHash();

  @$internal
  @override
  $ProviderElement<DailyListeningRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DailyListeningRepository create(Ref ref) {
    return dailyListeningRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DailyListeningRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DailyListeningRepository>(value),
    );
  }
}

String _$dailyListeningRepositoryHash() =>
    r'c696f5e7e9790df3a3b3db4a3dd671e25d30c6b5';

@ProviderFor(statisticsTracker)
final statisticsTrackerProvider = StatisticsTrackerProvider._();

final class StatisticsTrackerProvider
    extends
        $FunctionalProvider<
          StatisticsTracker,
          StatisticsTracker,
          StatisticsTracker
        >
    with $Provider<StatisticsTracker> {
  StatisticsTrackerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'statisticsTrackerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$statisticsTrackerHash();

  @$internal
  @override
  $ProviderElement<StatisticsTracker> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  StatisticsTracker create(Ref ref) {
    return statisticsTracker(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StatisticsTracker value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StatisticsTracker>(value),
    );
  }
}

String _$statisticsTrackerHash() => r'39d9ccc9f0440db700079a514239f3d61db1699b';
