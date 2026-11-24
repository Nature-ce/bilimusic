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

  /// 个性化时把三档推荐理由的占比拼成一句话；冷启动返回兜底文案。
  String get reasonSummary {
    final List<DailyPick> personalized = picks
        .where((DailyPick pick) => pick.reason != RadarReason.coldStart)
        .toList(growable: false);
    if (personalized.isEmpty) {
      return '按你的收听口味挑选';
    }
    int familiar = 0;
    int related = 0;
    int explorer = 0;
    for (final DailyPick pick in personalized) {
      switch (pick.reason) {
        case RadarReason.familiarArtist:
          familiar += 1;
        case RadarReason.relatedPlaylist:
          related += 1;
        case RadarReason.explorer:
          explorer += 1;
        case RadarReason.coldStart:
          break;
      }
    }
    final List<int> shares = dailyReasonPercentages(<int>[
      familiar,
      related,
      explorer,
    ]);
    final List<String> parts = <String>[
      if (shares[0] > 0) '常听歌手 ${shares[0]}%',
      if (shares[1] > 0) '同歌单 ${shares[1]}%',
      if (shares[2] > 0) '换口味 ${shares[2]}%',
    ];
    return parts.isEmpty ? '按你的收听口味挑选' : parts.join(' · ');
  }
}

/// 让三段占比取整后正好加起来 100（最大余数法）。
List<int> dailyReasonPercentages(List<int> counts) {
  final int total = counts.fold<int>(0, (int sum, int value) => sum + value);
  if (total <= 0) {
    return const <int>[0, 0, 0];
  }
  final List<double> exact = counts
      .map((int value) => value * 100 / total)
      .toList(growable: false);
  final List<int> floors = exact
      .map((double value) => value.floor())
      .toList(growable: false);
  int remainder =
      100 - floors.fold<int>(0, (int sum, int value) => sum + value);
  final List<int> order =
      List<int>.generate(counts.length, (int index) => index)..sort(
        (int a, int b) => (exact[b] - exact[b].floorToDouble()).compareTo(
          exact[a] - exact[a].floorToDouble(),
        ),
      );
  final List<int> result = List<int>.of(floors);
  for (int index = 0; index < order.length && remainder > 0; index += 1) {
    result[order[index]] += 1;
    remainder -= 1;
  }
  return result;
}
