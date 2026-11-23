// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'metadata_backfill_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MetadataBackfillController)
final metadataBackfillControllerProvider =
    MetadataBackfillControllerProvider._();

final class MetadataBackfillControllerProvider
    extends
        $NotifierProvider<MetadataBackfillController, MetadataBackfillState> {
  MetadataBackfillControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'metadataBackfillControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$metadataBackfillControllerHash();

  @$internal
  @override
  MetadataBackfillController create() => MetadataBackfillController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MetadataBackfillState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MetadataBackfillState>(value),
    );
  }
}

String _$metadataBackfillControllerHash() =>
    r'5ca5199664d2f31d8b4d729e963e59539c0cd4e6';

abstract class _$MetadataBackfillController
    extends $Notifier<MetadataBackfillState> {
  MetadataBackfillState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<MetadataBackfillState, MetadataBackfillState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<MetadataBackfillState, MetadataBackfillState>,
              MetadataBackfillState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
