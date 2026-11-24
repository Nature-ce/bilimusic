import 'package:bilimusic/feature/daily/domain/daily_recommendation.dart';
import 'package:bilimusic/feature/radar/domain/radar_pick.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'daily_recommendation_state.freezed.dart';

@freezed
abstract class DailyRecommendationState with _$DailyRecommendationState {
  const DailyRecommendationState._();

  const factory DailyRecommendationState({
    @Default(<DailyPick>[]) List<DailyPick> picks,
    @Default(true) bool isLoading,
    @Default('') String dateKey,
    @Default(0) int generatedAtEpochMs,
    String? errorMessage,
  }) = _DailyRecommendationState;

  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;

  bool get isPersonalized =>
      picks.any((DailyPick pick) => pick.reason != RadarReason.coldStart);
}
