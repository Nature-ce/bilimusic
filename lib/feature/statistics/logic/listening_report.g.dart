// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listening_report.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(listeningReport)
final listeningReportProvider = ListeningReportProvider._();

final class ListeningReportProvider
    extends
        $FunctionalProvider<ListeningReport, ListeningReport, ListeningReport>
    with $Provider<ListeningReport> {
  ListeningReportProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'listeningReportProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$listeningReportHash();

  @$internal
  @override
  $ProviderElement<ListeningReport> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ListeningReport create(Ref ref) {
    return listeningReport(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ListeningReport value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ListeningReport>(value),
    );
  }
}

String _$listeningReportHash() => r'3e3d962f35f391150f472e295ae83d79168f4c54';
