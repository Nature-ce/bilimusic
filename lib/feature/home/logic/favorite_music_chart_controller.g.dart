// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorite_music_chart_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(favoriteMusicChartRepository)
final favoriteMusicChartRepositoryProvider =
    FavoriteMusicChartRepositoryProvider._();

final class FavoriteMusicChartRepositoryProvider
    extends
        $FunctionalProvider<
          FavoriteMusicChartRepository,
          FavoriteMusicChartRepository,
          FavoriteMusicChartRepository
        >
    with $Provider<FavoriteMusicChartRepository> {
  FavoriteMusicChartRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'favoriteMusicChartRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$favoriteMusicChartRepositoryHash();

  @$internal
  @override
  $ProviderElement<FavoriteMusicChartRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FavoriteMusicChartRepository create(Ref ref) {
    return favoriteMusicChartRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FavoriteMusicChartRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FavoriteMusicChartRepository>(value),
    );
  }
}

String _$favoriteMusicChartRepositoryHash() =>
    r'21eb0c0c26dcdaf5f6b871022aa86210d20bdbdf';

@ProviderFor(FavoriteMusicCharts)
final favoriteMusicChartsProvider = FavoriteMusicChartsProvider._();

final class FavoriteMusicChartsProvider
    extends $NotifierProvider<FavoriteMusicCharts, List<MusicChart>> {
  FavoriteMusicChartsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'favoriteMusicChartsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$favoriteMusicChartsHash();

  @$internal
  @override
  FavoriteMusicCharts create() => FavoriteMusicCharts();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<MusicChart> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<MusicChart>>(value),
    );
  }
}

String _$favoriteMusicChartsHash() =>
    r'a15e99878ad94b5141bd6cb704f278bdb6fc9991';

abstract class _$FavoriteMusicCharts extends $Notifier<List<MusicChart>> {
  List<MusicChart> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<MusicChart>, List<MusicChart>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<MusicChart>, List<MusicChart>>,
              List<MusicChart>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
