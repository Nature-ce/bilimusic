// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'daily_recommendation_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DailyRecommendationState {

 List<DailyPick> get picks; bool get isLoading; String get dateKey; int get generatedAtEpochMs; String? get errorMessage;
/// Create a copy of DailyRecommendationState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DailyRecommendationStateCopyWith<DailyRecommendationState> get copyWith => _$DailyRecommendationStateCopyWithImpl<DailyRecommendationState>(this as DailyRecommendationState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DailyRecommendationState&&const DeepCollectionEquality().equals(other.picks, picks)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.dateKey, dateKey) || other.dateKey == dateKey)&&(identical(other.generatedAtEpochMs, generatedAtEpochMs) || other.generatedAtEpochMs == generatedAtEpochMs)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(picks),isLoading,dateKey,generatedAtEpochMs,errorMessage);

@override
String toString() {
  return 'DailyRecommendationState(picks: $picks, isLoading: $isLoading, dateKey: $dateKey, generatedAtEpochMs: $generatedAtEpochMs, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $DailyRecommendationStateCopyWith<$Res>  {
  factory $DailyRecommendationStateCopyWith(DailyRecommendationState value, $Res Function(DailyRecommendationState) _then) = _$DailyRecommendationStateCopyWithImpl;
@useResult
$Res call({
 List<DailyPick> picks, bool isLoading, String dateKey, int generatedAtEpochMs, String? errorMessage
});




}
/// @nodoc
class _$DailyRecommendationStateCopyWithImpl<$Res>
    implements $DailyRecommendationStateCopyWith<$Res> {
  _$DailyRecommendationStateCopyWithImpl(this._self, this._then);

  final DailyRecommendationState _self;
  final $Res Function(DailyRecommendationState) _then;

/// Create a copy of DailyRecommendationState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? picks = null,Object? isLoading = null,Object? dateKey = null,Object? generatedAtEpochMs = null,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
picks: null == picks ? _self.picks : picks // ignore: cast_nullable_to_non_nullable
as List<DailyPick>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,dateKey: null == dateKey ? _self.dateKey : dateKey // ignore: cast_nullable_to_non_nullable
as String,generatedAtEpochMs: null == generatedAtEpochMs ? _self.generatedAtEpochMs : generatedAtEpochMs // ignore: cast_nullable_to_non_nullable
as int,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DailyRecommendationState].
extension DailyRecommendationStatePatterns on DailyRecommendationState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DailyRecommendationState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DailyRecommendationState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DailyRecommendationState value)  $default,){
final _that = this;
switch (_that) {
case _DailyRecommendationState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DailyRecommendationState value)?  $default,){
final _that = this;
switch (_that) {
case _DailyRecommendationState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<DailyPick> picks,  bool isLoading,  String dateKey,  int generatedAtEpochMs,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DailyRecommendationState() when $default != null:
return $default(_that.picks,_that.isLoading,_that.dateKey,_that.generatedAtEpochMs,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<DailyPick> picks,  bool isLoading,  String dateKey,  int generatedAtEpochMs,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _DailyRecommendationState():
return $default(_that.picks,_that.isLoading,_that.dateKey,_that.generatedAtEpochMs,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<DailyPick> picks,  bool isLoading,  String dateKey,  int generatedAtEpochMs,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _DailyRecommendationState() when $default != null:
return $default(_that.picks,_that.isLoading,_that.dateKey,_that.generatedAtEpochMs,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _DailyRecommendationState extends DailyRecommendationState {
  const _DailyRecommendationState({final  List<DailyPick> picks = const <DailyPick>[], this.isLoading = true, this.dateKey = '', this.generatedAtEpochMs = 0, this.errorMessage}): _picks = picks,super._();
  

 final  List<DailyPick> _picks;
@override@JsonKey() List<DailyPick> get picks {
  if (_picks is EqualUnmodifiableListView) return _picks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_picks);
}

@override@JsonKey() final  bool isLoading;
@override@JsonKey() final  String dateKey;
@override@JsonKey() final  int generatedAtEpochMs;
@override final  String? errorMessage;

/// Create a copy of DailyRecommendationState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DailyRecommendationStateCopyWith<_DailyRecommendationState> get copyWith => __$DailyRecommendationStateCopyWithImpl<_DailyRecommendationState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DailyRecommendationState&&const DeepCollectionEquality().equals(other._picks, _picks)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.dateKey, dateKey) || other.dateKey == dateKey)&&(identical(other.generatedAtEpochMs, generatedAtEpochMs) || other.generatedAtEpochMs == generatedAtEpochMs)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_picks),isLoading,dateKey,generatedAtEpochMs,errorMessage);

@override
String toString() {
  return 'DailyRecommendationState(picks: $picks, isLoading: $isLoading, dateKey: $dateKey, generatedAtEpochMs: $generatedAtEpochMs, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$DailyRecommendationStateCopyWith<$Res> implements $DailyRecommendationStateCopyWith<$Res> {
  factory _$DailyRecommendationStateCopyWith(_DailyRecommendationState value, $Res Function(_DailyRecommendationState) _then) = __$DailyRecommendationStateCopyWithImpl;
@override @useResult
$Res call({
 List<DailyPick> picks, bool isLoading, String dateKey, int generatedAtEpochMs, String? errorMessage
});




}
/// @nodoc
class __$DailyRecommendationStateCopyWithImpl<$Res>
    implements _$DailyRecommendationStateCopyWith<$Res> {
  __$DailyRecommendationStateCopyWithImpl(this._self, this._then);

  final _DailyRecommendationState _self;
  final $Res Function(_DailyRecommendationState) _then;

/// Create a copy of DailyRecommendationState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? picks = null,Object? isLoading = null,Object? dateKey = null,Object? generatedAtEpochMs = null,Object? errorMessage = freezed,}) {
  return _then(_DailyRecommendationState(
picks: null == picks ? _self._picks : picks // ignore: cast_nullable_to_non_nullable
as List<DailyPick>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,dateKey: null == dateKey ? _self.dateKey : dateKey // ignore: cast_nullable_to_non_nullable
as String,generatedAtEpochMs: null == generatedAtEpochMs ? _self.generatedAtEpochMs : generatedAtEpochMs // ignore: cast_nullable_to_non_nullable
as int,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
