import 'package:freezed_annotation/freezed_annotation.dart';

part 'favorite_up_update.freezed.dart';
part 'favorite_up_update.g.dart';

@freezed
abstract class FavoriteUpUpdate with _$FavoriteUpUpdate {
  const factory FavoriteUpUpdate({
    required int mid,
    required int fetchedAtEpochMs,
    int? latestPublishAtEpochMs,
    @Default(0) int todayVideoCount,
    @Default(false) bool failed,
  }) = _FavoriteUpUpdate;

  factory FavoriteUpUpdate.fromJson(Map<String, dynamic> json) =>
      _$FavoriteUpUpdateFromJson(json);
}
