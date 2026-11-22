import 'package:bilimusic/feature/statistics/domain/daily_listening.dart';
import 'package:bilimusic/feature/statistics/logic/statistics_tracker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'weekly_listening.g.dart';

@riverpod
WeeklyListeningSummary weeklyListening(Ref ref) {
  return ref.watch(dailyListeningRepositoryProvider).summary();
}
