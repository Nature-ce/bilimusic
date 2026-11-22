// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recent_playback_progress_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(RecentPlaybackProgressController)
final recentPlaybackProgressControllerProvider =
    RecentPlaybackProgressControllerProvider._();

final class RecentPlaybackProgressControllerProvider
    extends
        $NotifierProvider<RecentPlaybackProgressController, Map<String, int>> {
  RecentPlaybackProgressControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recentPlaybackProgressControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recentPlaybackProgressControllerHash();

  @$internal
  @override
  RecentPlaybackProgressController create() =>
      RecentPlaybackProgressController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, int> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, int>>(value),
    );
  }
}

String _$recentPlaybackProgressControllerHash() =>
    r'caae38b4f11d5bc27d29bece862fbe3d06f7b53c';

abstract class _$RecentPlaybackProgressController
    extends $Notifier<Map<String, int>> {
  Map<String, int> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Map<String, int>, Map<String, int>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Map<String, int>, Map<String, int>>,
              Map<String, int>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
