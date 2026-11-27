// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_recommendation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DailyPick _$DailyPickFromJson(Map<String, dynamic> json) => _DailyPick(
  title: json['title'] as String,
  artist: json['artist'] as String,
  reason: $enumDecode(_$RadarReasonEnumMap, json['reason']),
  coverUrl: json['coverUrl'] as String? ?? '',
  durationSeconds: (json['durationSeconds'] as num?)?.toInt() ?? 0,
  platform: json['platform'] as String? ?? '',
  reasonDetail: json['reasonDetail'] as String?,
  bvid: json['bvid'] as String? ?? '',
  aid: (json['aid'] as num?)?.toInt() ?? 0,
  cid: (json['cid'] as num?)?.toInt(),
  page: (json['page'] as num?)?.toInt(),
  videoTitle: json['videoTitle'] as String? ?? '',
  videoAuthor: json['videoAuthor'] as String? ?? '',
  videoCoverUrl: json['videoCoverUrl'] as String? ?? '',
  videoDurationText: json['videoDurationText'] as String? ?? '',
);

Map<String, dynamic> _$DailyPickToJson(_DailyPick instance) =>
    <String, dynamic>{
      'title': instance.title,
      'artist': instance.artist,
      'reason': _$RadarReasonEnumMap[instance.reason]!,
      'coverUrl': instance.coverUrl,
      'durationSeconds': instance.durationSeconds,
      'platform': instance.platform,
      'reasonDetail': instance.reasonDetail,
      'bvid': instance.bvid,
      'aid': instance.aid,
      'cid': instance.cid,
      'page': instance.page,
      'videoTitle': instance.videoTitle,
      'videoAuthor': instance.videoAuthor,
      'videoCoverUrl': instance.videoCoverUrl,
      'videoDurationText': instance.videoDurationText,
    };

const _$RadarReasonEnumMap = {
  RadarReason.familiarArtist: 'familiarArtist',
  RadarReason.relatedPlaylist: 'relatedPlaylist',
  RadarReason.explorer: 'explorer',
  RadarReason.coldStart: 'coldStart',
};

_DailyRecommendation _$DailyRecommendationFromJson(Map<String, dynamic> json) =>
    _DailyRecommendation(
      dateKey: json['dateKey'] as String,
      generatedAtEpochMs: (json['generatedAtEpochMs'] as num?)?.toInt() ?? 0,
      picks:
          (json['picks'] as List<dynamic>?)
              ?.map((e) => DailyPick.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <DailyPick>[],
    );

Map<String, dynamic> _$DailyRecommendationToJson(
  _DailyRecommendation instance,
) => <String, dynamic>{
  'dateKey': instance.dateKey,
  'generatedAtEpochMs': instance.generatedAtEpochMs,
  'picks': instance.picks,
};
