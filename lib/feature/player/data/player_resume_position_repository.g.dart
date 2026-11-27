// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_resume_position_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(playerResumePositionRepository)
final playerResumePositionRepositoryProvider =
    PlayerResumePositionRepositoryProvider._();

final class PlayerResumePositionRepositoryProvider
    extends
        $FunctionalProvider<
          PlayerResumePositionRepository,
          PlayerResumePositionRepository,
          PlayerResumePositionRepository
        >
    with $Provider<PlayerResumePositionRepository> {
  PlayerResumePositionRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'playerResumePositionRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$playerResumePositionRepositoryHash();

  @$internal
  @override
  $ProviderElement<PlayerResumePositionRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PlayerResumePositionRepository create(Ref ref) {
    return playerResumePositionRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PlayerResumePositionRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PlayerResumePositionRepository>(
        value,
      ),
    );
  }
}

String _$playerResumePositionRepositoryHash() =>
    r'eeaa18fb75f5a4b676c17bae7d88a072926079e9';
