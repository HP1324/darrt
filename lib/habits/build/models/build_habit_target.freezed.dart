// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'build_habit_target.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BuildHabitTarget {

 int get daily; int get weekly; int get monthly; int get yearly;
/// Create a copy of BuildHabitTarget
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BuildHabitTargetCopyWith<BuildHabitTarget> get copyWith => _$BuildHabitTargetCopyWithImpl<BuildHabitTarget>(this as BuildHabitTarget, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BuildHabitTarget&&(identical(other.daily, daily) || other.daily == daily)&&(identical(other.weekly, weekly) || other.weekly == weekly)&&(identical(other.monthly, monthly) || other.monthly == monthly)&&(identical(other.yearly, yearly) || other.yearly == yearly));
}


@override
int get hashCode => Object.hash(runtimeType,daily,weekly,monthly,yearly);

@override
String toString() {
  return 'BuildHabitTarget(daily: $daily, weekly: $weekly, monthly: $monthly, yearly: $yearly)';
}


}

/// @nodoc
abstract mixin class $BuildHabitTargetCopyWith<$Res>  {
  factory $BuildHabitTargetCopyWith(BuildHabitTarget value, $Res Function(BuildHabitTarget) _then) = _$BuildHabitTargetCopyWithImpl;
@useResult
$Res call({
 int daily, int weekly, int monthly, int yearly
});




}
/// @nodoc
class _$BuildHabitTargetCopyWithImpl<$Res>
    implements $BuildHabitTargetCopyWith<$Res> {
  _$BuildHabitTargetCopyWithImpl(this._self, this._then);

  final BuildHabitTarget _self;
  final $Res Function(BuildHabitTarget) _then;

/// Create a copy of BuildHabitTarget
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? daily = null,Object? weekly = null,Object? monthly = null,Object? yearly = null,}) {
  return _then(_self.copyWith(
daily: null == daily ? _self.daily : daily // ignore: cast_nullable_to_non_nullable
as int,weekly: null == weekly ? _self.weekly : weekly // ignore: cast_nullable_to_non_nullable
as int,monthly: null == monthly ? _self.monthly : monthly // ignore: cast_nullable_to_non_nullable
as int,yearly: null == yearly ? _self.yearly : yearly // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// @nodoc


class _BuildHabitTarget extends BuildHabitTarget {
  const _BuildHabitTarget({this.daily = 0, this.weekly = 0, this.monthly = 0, this.yearly = 0}): super._();
  

@override@JsonKey() final  int daily;
@override@JsonKey() final  int weekly;
@override@JsonKey() final  int monthly;
@override@JsonKey() final  int yearly;

/// Create a copy of BuildHabitTarget
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BuildHabitTargetCopyWith<_BuildHabitTarget> get copyWith => __$BuildHabitTargetCopyWithImpl<_BuildHabitTarget>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BuildHabitTarget&&(identical(other.daily, daily) || other.daily == daily)&&(identical(other.weekly, weekly) || other.weekly == weekly)&&(identical(other.monthly, monthly) || other.monthly == monthly)&&(identical(other.yearly, yearly) || other.yearly == yearly));
}


@override
int get hashCode => Object.hash(runtimeType,daily,weekly,monthly,yearly);

@override
String toString() {
  return 'BuildHabitTarget(daily: $daily, weekly: $weekly, monthly: $monthly, yearly: $yearly)';
}


}

/// @nodoc
abstract mixin class _$BuildHabitTargetCopyWith<$Res> implements $BuildHabitTargetCopyWith<$Res> {
  factory _$BuildHabitTargetCopyWith(_BuildHabitTarget value, $Res Function(_BuildHabitTarget) _then) = __$BuildHabitTargetCopyWithImpl;
@override @useResult
$Res call({
 int daily, int weekly, int monthly, int yearly
});




}
/// @nodoc
class __$BuildHabitTargetCopyWithImpl<$Res>
    implements _$BuildHabitTargetCopyWith<$Res> {
  __$BuildHabitTargetCopyWithImpl(this._self, this._then);

  final _BuildHabitTarget _self;
  final $Res Function(_BuildHabitTarget) _then;

/// Create a copy of BuildHabitTarget
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? daily = null,Object? weekly = null,Object? monthly = null,Object? yearly = null,}) {
  return _then(_BuildHabitTarget(
daily: null == daily ? _self.daily : daily // ignore: cast_nullable_to_non_nullable
as int,weekly: null == weekly ? _self.weekly : weekly // ignore: cast_nullable_to_non_nullable
as int,monthly: null == monthly ? _self.monthly : monthly // ignore: cast_nullable_to_non_nullable
as int,yearly: null == yearly ? _self.yearly : yearly // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
