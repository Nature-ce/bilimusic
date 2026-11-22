// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chart_detail_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ChartDetailController)
final chartDetailControllerProvider = ChartDetailControllerFamily._();

final class ChartDetailControllerProvider
    extends $AsyncNotifierProvider<ChartDetailController, ChartDetailData> {
  ChartDetailControllerProvider._({
    required ChartDetailControllerFamily super.from,
    required MusicChart super.argument,
  }) : super(
         retry: null,
         name: r'chartDetailControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$chartDetailControllerHash();

  @override
  String toString() {
    return r'chartDetailControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ChartDetailController create() => ChartDetailController();

  @override
  bool operator ==(Object other) {
    return other is ChartDetailControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$chartDetailControllerHash() =>
    r'78a6228a06f567c05f23fe2c9201f8d5b1cdc908';

final class ChartDetailControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          ChartDetailController,
          AsyncValue<ChartDetailData>,
          ChartDetailData,
          FutureOr<ChartDetailData>,
          MusicChart
        > {
  ChartDetailControllerFamily._()
    : super(
        retry: null,
        name: r'chartDetailControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ChartDetailControllerProvider call(MusicChart chart) =>
      ChartDetailControllerProvider._(argument: chart, from: this);

  @override
  String toString() => r'chartDetailControllerProvider';
}

abstract class _$ChartDetailController extends $AsyncNotifier<ChartDetailData> {
  late final _$args = ref.$arg as MusicChart;
  MusicChart get chart => _$args;

  FutureOr<ChartDetailData> build(MusicChart chart);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<ChartDetailData>, ChartDetailData>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ChartDetailData>, ChartDetailData>,
              AsyncValue<ChartDetailData>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
