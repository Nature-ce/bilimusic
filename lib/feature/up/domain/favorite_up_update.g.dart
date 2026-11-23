// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorite_up_update.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FavoriteUpUpdate _$FavoriteUpUpdateFromJson(Map<String, dynamic> json) =>
    _FavoriteUpUpdate(
      mid: (json['mid'] as num).toInt(),
      fetchedAtEpochMs: (json['fetchedAtEpochMs'] as num).toInt(),
      latestPublishAtEpochMs: (json['latestPublishAtEpochMs'] as num?)?.toInt(),
      todayVideoCount: (json['todayVideoCount'] as num?)?.toInt() ?? 0,
      failed: json['failed'] as bool? ?? false,
    );

Map<String, dynamic> _$FavoriteUpUpdateToJson(_FavoriteUpUpdate instance) =>
    <String, dynamic>{
      'mid': instance.mid,
      'fetchedAtEpochMs': instance.fetchedAtEpochMs,
      'latestPublishAtEpochMs': instance.latestPublishAtEpochMs,
      'todayVideoCount': instance.todayVideoCount,
      'failed': instance.failed,
    };
