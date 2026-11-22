// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'radar_play_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RadarPlayRecord _$RadarPlayRecordFromJson(Map<String, dynamic> json) =>
    _RadarPlayRecord(
      stableId: json['stableId'] as String,
      title: json['title'] as String,
      artist: json['artist'] as String,
      playedMs: (json['playedMs'] as num?)?.toInt() ?? 0,
      durationMs: (json['durationMs'] as num?)?.toInt() ?? 0,
      playCount: (json['playCount'] as num?)?.toInt() ?? 1,
      updatedAtMs: (json['updatedAtMs'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$RadarPlayRecordToJson(_RadarPlayRecord instance) =>
    <String, dynamic>{
      'stableId': instance.stableId,
      'title': instance.title,
      'artist': instance.artist,
      'playedMs': instance.playedMs,
      'durationMs': instance.durationMs,
      'playCount': instance.playCount,
      'updatedAtMs': instance.updatedAtMs,
    };
