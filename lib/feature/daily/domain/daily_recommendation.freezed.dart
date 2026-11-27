// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'daily_recommendation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DailyPick {

 String get title; String get artist; RadarReason get reason; String get coverUrl; int get durationSeconds; String get platform; String? get reasonDetail; String get bvid; int get aid; int? get cid; int? get page; String get videoTitle; String get videoAuthor; String get videoCoverUrl; String get videoDurationText;
/// Create a copy of DailyPick
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DailyPickCopyWith<DailyPick> get copyWith => _$DailyPickCopyWithImpl<DailyPick>(this as DailyPick, _$identity);

  /// Serializes this DailyPick to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DailyPick&&(identical(other.title, title) || other.title == title)&&(identical(other.artist, artist) || other.artist == artist)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.coverUrl, coverUrl) || other.coverUrl == coverUrl)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds)&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.reasonDetail, reasonDetail) || other.reasonDetail == reasonDetail)&&(identical(other.bvid, bvid) || other.bvid == bvid)&&(identical(other.aid, aid) || other.aid == aid)&&(identical(other.cid, cid) || other.cid == cid)&&(identical(other.page, page) || other.page == page)&&(identical(other.videoTitle, videoTitle) || other.videoTitle == videoTitle)&&(identical(other.videoAuthor, videoAuthor) || other.videoAuthor == videoAuthor)&&(identical(other.videoCoverUrl, videoCoverUrl) || other.videoCoverUrl == videoCoverUrl)&&(identical(other.videoDurationText, videoDurationText) || other.videoDurationText == videoDurationText));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,artist,reason,coverUrl,durationSeconds,platform,reasonDetail,bvid,aid,cid,page,videoTitle,videoAuthor,videoCoverUrl,videoDurationText);

@override
String toString() {
  return 'DailyPick(title: $title, artist: $artist, reason: $reason, coverUrl: $coverUrl, durationSeconds: $durationSeconds, platform: $platform, reasonDetail: $reasonDetail, bvid: $bvid, aid: $aid, cid: $cid, page: $page, videoTitle: $videoTitle, videoAuthor: $videoAuthor, videoCoverUrl: $videoCoverUrl, videoDurationText: $videoDurationText)';
}


}

/// @nodoc
abstract mixin class $DailyPickCopyWith<$Res>  {
  factory $DailyPickCopyWith(DailyPick value, $Res Function(DailyPick) _then) = _$DailyPickCopyWithImpl;
@useResult
$Res call({
 String title, String artist, RadarReason reason, String coverUrl, int durationSeconds, String platform, String? reasonDetail, String bvid, int aid, int? cid, int? page, String videoTitle, String videoAuthor, String videoCoverUrl, String videoDurationText
});




}
/// @nodoc
class _$DailyPickCopyWithImpl<$Res>
    implements $DailyPickCopyWith<$Res> {
  _$DailyPickCopyWithImpl(this._self, this._then);

  final DailyPick _self;
  final $Res Function(DailyPick) _then;

/// Create a copy of DailyPick
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? artist = null,Object? reason = null,Object? coverUrl = null,Object? durationSeconds = null,Object? platform = null,Object? reasonDetail = freezed,Object? bvid = null,Object? aid = null,Object? cid = freezed,Object? page = freezed,Object? videoTitle = null,Object? videoAuthor = null,Object? videoCoverUrl = null,Object? videoDurationText = null,}) {
  return _then(_self.copyWith(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,artist: null == artist ? _self.artist : artist // ignore: cast_nullable_to_non_nullable
as String,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as RadarReason,coverUrl: null == coverUrl ? _self.coverUrl : coverUrl // ignore: cast_nullable_to_non_nullable
as String,durationSeconds: null == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as int,platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as String,reasonDetail: freezed == reasonDetail ? _self.reasonDetail : reasonDetail // ignore: cast_nullable_to_non_nullable
as String?,bvid: null == bvid ? _self.bvid : bvid // ignore: cast_nullable_to_non_nullable
as String,aid: null == aid ? _self.aid : aid // ignore: cast_nullable_to_non_nullable
as int,cid: freezed == cid ? _self.cid : cid // ignore: cast_nullable_to_non_nullable
as int?,page: freezed == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int?,videoTitle: null == videoTitle ? _self.videoTitle : videoTitle // ignore: cast_nullable_to_non_nullable
as String,videoAuthor: null == videoAuthor ? _self.videoAuthor : videoAuthor // ignore: cast_nullable_to_non_nullable
as String,videoCoverUrl: null == videoCoverUrl ? _self.videoCoverUrl : videoCoverUrl // ignore: cast_nullable_to_non_nullable
as String,videoDurationText: null == videoDurationText ? _self.videoDurationText : videoDurationText // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [DailyPick].
extension DailyPickPatterns on DailyPick {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DailyPick value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DailyPick() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DailyPick value)  $default,){
final _that = this;
switch (_that) {
case _DailyPick():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DailyPick value)?  $default,){
final _that = this;
switch (_that) {
case _DailyPick() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  String artist,  RadarReason reason,  String coverUrl,  int durationSeconds,  String platform,  String? reasonDetail,  String bvid,  int aid,  int? cid,  int? page,  String videoTitle,  String videoAuthor,  String videoCoverUrl,  String videoDurationText)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DailyPick() when $default != null:
return $default(_that.title,_that.artist,_that.reason,_that.coverUrl,_that.durationSeconds,_that.platform,_that.reasonDetail,_that.bvid,_that.aid,_that.cid,_that.page,_that.videoTitle,_that.videoAuthor,_that.videoCoverUrl,_that.videoDurationText);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  String artist,  RadarReason reason,  String coverUrl,  int durationSeconds,  String platform,  String? reasonDetail,  String bvid,  int aid,  int? cid,  int? page,  String videoTitle,  String videoAuthor,  String videoCoverUrl,  String videoDurationText)  $default,) {final _that = this;
switch (_that) {
case _DailyPick():
return $default(_that.title,_that.artist,_that.reason,_that.coverUrl,_that.durationSeconds,_that.platform,_that.reasonDetail,_that.bvid,_that.aid,_that.cid,_that.page,_that.videoTitle,_that.videoAuthor,_that.videoCoverUrl,_that.videoDurationText);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  String artist,  RadarReason reason,  String coverUrl,  int durationSeconds,  String platform,  String? reasonDetail,  String bvid,  int aid,  int? cid,  int? page,  String videoTitle,  String videoAuthor,  String videoCoverUrl,  String videoDurationText)?  $default,) {final _that = this;
switch (_that) {
case _DailyPick() when $default != null:
return $default(_that.title,_that.artist,_that.reason,_that.coverUrl,_that.durationSeconds,_that.platform,_that.reasonDetail,_that.bvid,_that.aid,_that.cid,_that.page,_that.videoTitle,_that.videoAuthor,_that.videoCoverUrl,_that.videoDurationText);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DailyPick extends DailyPick {
  const _DailyPick({required this.title, required this.artist, required this.reason, this.coverUrl = '', this.durationSeconds = 0, this.platform = '', this.reasonDetail, this.bvid = '', this.aid = 0, this.cid, this.page, this.videoTitle = '', this.videoAuthor = '', this.videoCoverUrl = '', this.videoDurationText = ''}): super._();
  factory _DailyPick.fromJson(Map<String, dynamic> json) => _$DailyPickFromJson(json);

@override final  String title;
@override final  String artist;
@override final  RadarReason reason;
@override@JsonKey() final  String coverUrl;
@override@JsonKey() final  int durationSeconds;
@override@JsonKey() final  String platform;
@override final  String? reasonDetail;
@override@JsonKey() final  String bvid;
@override@JsonKey() final  int aid;
@override final  int? cid;
@override final  int? page;
@override@JsonKey() final  String videoTitle;
@override@JsonKey() final  String videoAuthor;
@override@JsonKey() final  String videoCoverUrl;
@override@JsonKey() final  String videoDurationText;

/// Create a copy of DailyPick
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DailyPickCopyWith<_DailyPick> get copyWith => __$DailyPickCopyWithImpl<_DailyPick>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DailyPickToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DailyPick&&(identical(other.title, title) || other.title == title)&&(identical(other.artist, artist) || other.artist == artist)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.coverUrl, coverUrl) || other.coverUrl == coverUrl)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds)&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.reasonDetail, reasonDetail) || other.reasonDetail == reasonDetail)&&(identical(other.bvid, bvid) || other.bvid == bvid)&&(identical(other.aid, aid) || other.aid == aid)&&(identical(other.cid, cid) || other.cid == cid)&&(identical(other.page, page) || other.page == page)&&(identical(other.videoTitle, videoTitle) || other.videoTitle == videoTitle)&&(identical(other.videoAuthor, videoAuthor) || other.videoAuthor == videoAuthor)&&(identical(other.videoCoverUrl, videoCoverUrl) || other.videoCoverUrl == videoCoverUrl)&&(identical(other.videoDurationText, videoDurationText) || other.videoDurationText == videoDurationText));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,artist,reason,coverUrl,durationSeconds,platform,reasonDetail,bvid,aid,cid,page,videoTitle,videoAuthor,videoCoverUrl,videoDurationText);

@override
String toString() {
  return 'DailyPick(title: $title, artist: $artist, reason: $reason, coverUrl: $coverUrl, durationSeconds: $durationSeconds, platform: $platform, reasonDetail: $reasonDetail, bvid: $bvid, aid: $aid, cid: $cid, page: $page, videoTitle: $videoTitle, videoAuthor: $videoAuthor, videoCoverUrl: $videoCoverUrl, videoDurationText: $videoDurationText)';
}


}

/// @nodoc
abstract mixin class _$DailyPickCopyWith<$Res> implements $DailyPickCopyWith<$Res> {
  factory _$DailyPickCopyWith(_DailyPick value, $Res Function(_DailyPick) _then) = __$DailyPickCopyWithImpl;
@override @useResult
$Res call({
 String title, String artist, RadarReason reason, String coverUrl, int durationSeconds, String platform, String? reasonDetail, String bvid, int aid, int? cid, int? page, String videoTitle, String videoAuthor, String videoCoverUrl, String videoDurationText
});




}
/// @nodoc
class __$DailyPickCopyWithImpl<$Res>
    implements _$DailyPickCopyWith<$Res> {
  __$DailyPickCopyWithImpl(this._self, this._then);

  final _DailyPick _self;
  final $Res Function(_DailyPick) _then;

/// Create a copy of DailyPick
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? artist = null,Object? reason = null,Object? coverUrl = null,Object? durationSeconds = null,Object? platform = null,Object? reasonDetail = freezed,Object? bvid = null,Object? aid = null,Object? cid = freezed,Object? page = freezed,Object? videoTitle = null,Object? videoAuthor = null,Object? videoCoverUrl = null,Object? videoDurationText = null,}) {
  return _then(_DailyPick(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,artist: null == artist ? _self.artist : artist // ignore: cast_nullable_to_non_nullable
as String,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as RadarReason,coverUrl: null == coverUrl ? _self.coverUrl : coverUrl // ignore: cast_nullable_to_non_nullable
as String,durationSeconds: null == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as int,platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as String,reasonDetail: freezed == reasonDetail ? _self.reasonDetail : reasonDetail // ignore: cast_nullable_to_non_nullable
as String?,bvid: null == bvid ? _self.bvid : bvid // ignore: cast_nullable_to_non_nullable
as String,aid: null == aid ? _self.aid : aid // ignore: cast_nullable_to_non_nullable
as int,cid: freezed == cid ? _self.cid : cid // ignore: cast_nullable_to_non_nullable
as int?,page: freezed == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int?,videoTitle: null == videoTitle ? _self.videoTitle : videoTitle // ignore: cast_nullable_to_non_nullable
as String,videoAuthor: null == videoAuthor ? _self.videoAuthor : videoAuthor // ignore: cast_nullable_to_non_nullable
as String,videoCoverUrl: null == videoCoverUrl ? _self.videoCoverUrl : videoCoverUrl // ignore: cast_nullable_to_non_nullable
as String,videoDurationText: null == videoDurationText ? _self.videoDurationText : videoDurationText // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$DailyRecommendation {

 String get dateKey; int get generatedAtEpochMs; List<DailyPick> get picks;
/// Create a copy of DailyRecommendation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DailyRecommendationCopyWith<DailyRecommendation> get copyWith => _$DailyRecommendationCopyWithImpl<DailyRecommendation>(this as DailyRecommendation, _$identity);

  /// Serializes this DailyRecommendation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DailyRecommendation&&(identical(other.dateKey, dateKey) || other.dateKey == dateKey)&&(identical(other.generatedAtEpochMs, generatedAtEpochMs) || other.generatedAtEpochMs == generatedAtEpochMs)&&const DeepCollectionEquality().equals(other.picks, picks));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,dateKey,generatedAtEpochMs,const DeepCollectionEquality().hash(picks));

@override
String toString() {
  return 'DailyRecommendation(dateKey: $dateKey, generatedAtEpochMs: $generatedAtEpochMs, picks: $picks)';
}


}

/// @nodoc
abstract mixin class $DailyRecommendationCopyWith<$Res>  {
  factory $DailyRecommendationCopyWith(DailyRecommendation value, $Res Function(DailyRecommendation) _then) = _$DailyRecommendationCopyWithImpl;
@useResult
$Res call({
 String dateKey, int generatedAtEpochMs, List<DailyPick> picks
});




}
/// @nodoc
class _$DailyRecommendationCopyWithImpl<$Res>
    implements $DailyRecommendationCopyWith<$Res> {
  _$DailyRecommendationCopyWithImpl(this._self, this._then);

  final DailyRecommendation _self;
  final $Res Function(DailyRecommendation) _then;

/// Create a copy of DailyRecommendation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? dateKey = null,Object? generatedAtEpochMs = null,Object? picks = null,}) {
  return _then(_self.copyWith(
dateKey: null == dateKey ? _self.dateKey : dateKey // ignore: cast_nullable_to_non_nullable
as String,generatedAtEpochMs: null == generatedAtEpochMs ? _self.generatedAtEpochMs : generatedAtEpochMs // ignore: cast_nullable_to_non_nullable
as int,picks: null == picks ? _self.picks : picks // ignore: cast_nullable_to_non_nullable
as List<DailyPick>,
  ));
}

}


/// Adds pattern-matching-related methods to [DailyRecommendation].
extension DailyRecommendationPatterns on DailyRecommendation {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DailyRecommendation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DailyRecommendation() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DailyRecommendation value)  $default,){
final _that = this;
switch (_that) {
case _DailyRecommendation():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DailyRecommendation value)?  $default,){
final _that = this;
switch (_that) {
case _DailyRecommendation() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String dateKey,  int generatedAtEpochMs,  List<DailyPick> picks)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DailyRecommendation() when $default != null:
return $default(_that.dateKey,_that.generatedAtEpochMs,_that.picks);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String dateKey,  int generatedAtEpochMs,  List<DailyPick> picks)  $default,) {final _that = this;
switch (_that) {
case _DailyRecommendation():
return $default(_that.dateKey,_that.generatedAtEpochMs,_that.picks);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String dateKey,  int generatedAtEpochMs,  List<DailyPick> picks)?  $default,) {final _that = this;
switch (_that) {
case _DailyRecommendation() when $default != null:
return $default(_that.dateKey,_that.generatedAtEpochMs,_that.picks);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DailyRecommendation extends DailyRecommendation {
  const _DailyRecommendation({required this.dateKey, this.generatedAtEpochMs = 0, final  List<DailyPick> picks = const <DailyPick>[]}): _picks = picks,super._();
  factory _DailyRecommendation.fromJson(Map<String, dynamic> json) => _$DailyRecommendationFromJson(json);

@override final  String dateKey;
@override@JsonKey() final  int generatedAtEpochMs;
 final  List<DailyPick> _picks;
@override@JsonKey() List<DailyPick> get picks {
  if (_picks is EqualUnmodifiableListView) return _picks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_picks);
}


/// Create a copy of DailyRecommendation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DailyRecommendationCopyWith<_DailyRecommendation> get copyWith => __$DailyRecommendationCopyWithImpl<_DailyRecommendation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DailyRecommendationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DailyRecommendation&&(identical(other.dateKey, dateKey) || other.dateKey == dateKey)&&(identical(other.generatedAtEpochMs, generatedAtEpochMs) || other.generatedAtEpochMs == generatedAtEpochMs)&&const DeepCollectionEquality().equals(other._picks, _picks));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,dateKey,generatedAtEpochMs,const DeepCollectionEquality().hash(_picks));

@override
String toString() {
  return 'DailyRecommendation(dateKey: $dateKey, generatedAtEpochMs: $generatedAtEpochMs, picks: $picks)';
}


}

/// @nodoc
abstract mixin class _$DailyRecommendationCopyWith<$Res> implements $DailyRecommendationCopyWith<$Res> {
  factory _$DailyRecommendationCopyWith(_DailyRecommendation value, $Res Function(_DailyRecommendation) _then) = __$DailyRecommendationCopyWithImpl;
@override @useResult
$Res call({
 String dateKey, int generatedAtEpochMs, List<DailyPick> picks
});




}
/// @nodoc
class __$DailyRecommendationCopyWithImpl<$Res>
    implements _$DailyRecommendationCopyWith<$Res> {
  __$DailyRecommendationCopyWithImpl(this._self, this._then);

  final _DailyRecommendation _self;
  final $Res Function(_DailyRecommendation) _then;

/// Create a copy of DailyRecommendation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? dateKey = null,Object? generatedAtEpochMs = null,Object? picks = null,}) {
  return _then(_DailyRecommendation(
dateKey: null == dateKey ? _self.dateKey : dateKey // ignore: cast_nullable_to_non_nullable
as String,generatedAtEpochMs: null == generatedAtEpochMs ? _self.generatedAtEpochMs : generatedAtEpochMs // ignore: cast_nullable_to_non_nullable
as int,picks: null == picks ? _self._picks : picks // ignore: cast_nullable_to_non_nullable
as List<DailyPick>,
  ));
}


}

// dart format on
