// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bili_client.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(BiliClient)
final biliClientProvider = BiliClientProvider._();

final class BiliClientProvider extends $NotifierProvider<BiliClient, Dio> {
  BiliClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'biliClientProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$biliClientHash();

  @$internal
  @override
  BiliClient create() => BiliClient();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Dio value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Dio>(value),
    );
  }
}

String _$biliClientHash() => r'af653c600f477324554744b0b524452417c9f956';

abstract class _$BiliClient extends $Notifier<Dio> {
  Dio build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Dio, Dio>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Dio, Dio>,
              Dio,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
