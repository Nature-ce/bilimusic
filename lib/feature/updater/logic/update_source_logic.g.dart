// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_source_logic.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(UpdateSourceLogic)
final updateSourceLogicProvider = UpdateSourceLogicProvider._();

final class UpdateSourceLogicProvider
    extends $NotifierProvider<UpdateSourceLogic, UpdateSource> {
  UpdateSourceLogicProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updateSourceLogicProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updateSourceLogicHash();

  @$internal
  @override
  UpdateSourceLogic create() => UpdateSourceLogic();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UpdateSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UpdateSource>(value),
    );
  }
}

String _$updateSourceLogicHash() => r'aeaa5ca136f6640c15271e0aa2b3fe0311feb121';

abstract class _$UpdateSourceLogic extends $Notifier<UpdateSource> {
  UpdateSource build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<UpdateSource, UpdateSource>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<UpdateSource, UpdateSource>,
              UpdateSource,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
