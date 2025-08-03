// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'target_completion.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TargetCompletion {

 DateTime get date; int get daily;
/// Create a copy of TargetCompletion
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TargetCompletionCopyWith<TargetCompletion> get copyWith => _$TargetCompletionCopyWithImpl<TargetCompletion>(this as TargetCompletion, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TargetCompletion&&(identical(other.date, date) || other.date == date)&&(identical(other.daily, daily) || other.daily == daily));
}


@override
int get hashCode => Object.hash(runtimeType,date,daily);

@override
String toString() {
  return 'TargetCompletion(date: $date, daily: $daily)';
}


}

/// @nodoc
abstract mixin class $TargetCompletionCopyWith<$Res>  {
  factory $TargetCompletionCopyWith(TargetCompletion value, $Res Function(TargetCompletion) _then) = _$TargetCompletionCopyWithImpl;
@useResult
$Res call({
 DateTime date, int daily
});




}
/// @nodoc
class _$TargetCompletionCopyWithImpl<$Res>
    implements $TargetCompletionCopyWith<$Res> {
  _$TargetCompletionCopyWithImpl(this._self, this._then);

  final TargetCompletion _self;
  final $Res Function(TargetCompletion) _then;

/// Create a copy of TargetCompletion
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? daily = null,}) {
  return _then(_self.copyWith(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,daily: null == daily ? _self.daily : daily // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// @nodoc


class _TargetCompletion extends TargetCompletion {
  const _TargetCompletion({required this.date, this.daily = 0}): super._();
  

@override final  DateTime date;
@override@JsonKey() final  int daily;

/// Create a copy of TargetCompletion
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TargetCompletionCopyWith<_TargetCompletion> get copyWith => __$TargetCompletionCopyWithImpl<_TargetCompletion>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TargetCompletion&&(identical(other.date, date) || other.date == date)&&(identical(other.daily, daily) || other.daily == daily));
}


@override
int get hashCode => Object.hash(runtimeType,date,daily);

@override
String toString() {
  return 'TargetCompletion(date: $date, daily: $daily)';
}


}

/// @nodoc
abstract mixin class _$TargetCompletionCopyWith<$Res> implements $TargetCompletionCopyWith<$Res> {
  factory _$TargetCompletionCopyWith(_TargetCompletion value, $Res Function(_TargetCompletion) _then) = __$TargetCompletionCopyWithImpl;
@override @useResult
$Res call({
 DateTime date, int daily
});




}
/// @nodoc
class __$TargetCompletionCopyWithImpl<$Res>
    implements _$TargetCompletionCopyWith<$Res> {
  __$TargetCompletionCopyWithImpl(this._self, this._then);

  final _TargetCompletion _self;
  final $Res Function(_TargetCompletion) _then;

/// Create a copy of TargetCompletion
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? daily = null,}) {
  return _then(_TargetCompletion(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,daily: null == daily ? _self.daily : daily // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
