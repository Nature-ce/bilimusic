// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weekly_listening.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(weeklyListening)
final weeklyListeningProvider = WeeklyListeningProvider._();

final class WeeklyListeningProvider
    extends
        $FunctionalProvider<
          WeeklyListeningSummary,
          WeeklyListeningSummary,
          WeeklyListeningSummary
        >
    with $Provider<WeeklyListeningSummary> {
  WeeklyListeningProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'weeklyListeningProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$weeklyListeningHash();

  @$internal
  @override
  $ProviderElement<WeeklyListeningSummary> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  WeeklyListeningSummary create(Ref ref) {
    return weeklyListening(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WeeklyListeningSummary value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WeeklyListeningSummary>(value),
    );
  }
}

String _$weeklyListeningHash() => r'477aac0bcc61c61cdde4ae9dc1e3425ef88ac65d';
