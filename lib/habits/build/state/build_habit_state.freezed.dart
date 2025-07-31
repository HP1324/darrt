// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'build_habit_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BuildHabitState {

 DateTime get startDate; String get color; Map<EntityCategory, bool> get categorySelection; List<Reminder> get reminders; RepeatConfig get repeatConfig; DateTime? get startTime; DateTime? get endTime; DateTime? get endDate;
/// Create a copy of BuildHabitState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BuildHabitStateCopyWith<BuildHabitState> get copyWith => _$BuildHabitStateCopyWithImpl<BuildHabitState>(this as BuildHabitState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BuildHabitState&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.color, color) || other.color == color)&&const DeepCollectionEquality().equals(other.categorySelection, categorySelection)&&const DeepCollectionEquality().equals(other.reminders, reminders)&&(identical(other.repeatConfig, repeatConfig) || other.repeatConfig == repeatConfig)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.endDate, endDate) || other.endDate == endDate));
}


@override
int get hashCode => Object.hash(runtimeType,startDate,color,const DeepCollectionEquality().hash(categorySelection),const DeepCollectionEquality().hash(reminders),repeatConfig,startTime,endTime,endDate);

@override
String toString() {
  return 'BuildHabitState(startDate: $startDate, color: $color, categorySelection: $categorySelection, reminders: $reminders, repeatConfig: $repeatConfig, startTime: $startTime, endTime: $endTime, endDate: $endDate)';
}


}

/// @nodoc
abstract mixin class $BuildHabitStateCopyWith<$Res>  {
  factory $BuildHabitStateCopyWith(BuildHabitState value, $Res Function(BuildHabitState) _then) = _$BuildHabitStateCopyWithImpl;
@useResult
$Res call({
 DateTime startDate, String color, Map<EntityCategory, bool> categorySelection, List<Reminder> reminders, RepeatConfig repeatConfig, DateTime? startTime, DateTime? endTime, DateTime? endDate
});




}
/// @nodoc
class _$BuildHabitStateCopyWithImpl<$Res>
    implements $BuildHabitStateCopyWith<$Res> {
  _$BuildHabitStateCopyWithImpl(this._self, this._then);

  final BuildHabitState _self;
  final $Res Function(BuildHabitState) _then;

/// Create a copy of BuildHabitState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? startDate = null,Object? color = null,Object? categorySelection = null,Object? reminders = null,Object? repeatConfig = null,Object? startTime = freezed,Object? endTime = freezed,Object? endDate = freezed,}) {
  return _then(_self.copyWith(
startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String,categorySelection: null == categorySelection ? _self.categorySelection : categorySelection // ignore: cast_nullable_to_non_nullable
as Map<EntityCategory, bool>,reminders: null == reminders ? _self.reminders : reminders // ignore: cast_nullable_to_non_nullable
as List<Reminder>,repeatConfig: null == repeatConfig ? _self.repeatConfig : repeatConfig // ignore: cast_nullable_to_non_nullable
as RepeatConfig,startTime: freezed == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime?,endTime: freezed == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as DateTime?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// @nodoc


class _BuildHabitState extends BuildHabitState {
  const _BuildHabitState({required this.startDate, required this.color, required final  Map<EntityCategory, bool> categorySelection, required final  List<Reminder> reminders, required this.repeatConfig, this.startTime, this.endTime, this.endDate}): _categorySelection = categorySelection,_reminders = reminders,super._();
  

@override final  DateTime startDate;
@override final  String color;
 final  Map<EntityCategory, bool> _categorySelection;
@override Map<EntityCategory, bool> get categorySelection {
  if (_categorySelection is EqualUnmodifiableMapView) return _categorySelection;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_categorySelection);
}

 final  List<Reminder> _reminders;
@override List<Reminder> get reminders {
  if (_reminders is EqualUnmodifiableListView) return _reminders;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_reminders);
}

@override final  RepeatConfig repeatConfig;
@override final  DateTime? startTime;
@override final  DateTime? endTime;
@override final  DateTime? endDate;

/// Create a copy of BuildHabitState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BuildHabitStateCopyWith<_BuildHabitState> get copyWith => __$BuildHabitStateCopyWithImpl<_BuildHabitState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BuildHabitState&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.color, color) || other.color == color)&&const DeepCollectionEquality().equals(other._categorySelection, _categorySelection)&&const DeepCollectionEquality().equals(other._reminders, _reminders)&&(identical(other.repeatConfig, repeatConfig) || other.repeatConfig == repeatConfig)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.endDate, endDate) || other.endDate == endDate));
}


@override
int get hashCode => Object.hash(runtimeType,startDate,color,const DeepCollectionEquality().hash(_categorySelection),const DeepCollectionEquality().hash(_reminders),repeatConfig,startTime,endTime,endDate);

@override
String toString() {
  return 'BuildHabitState(startDate: $startDate, color: $color, categorySelection: $categorySelection, reminders: $reminders, repeatConfig: $repeatConfig, startTime: $startTime, endTime: $endTime, endDate: $endDate)';
}


}

/// @nodoc
abstract mixin class _$BuildHabitStateCopyWith<$Res> implements $BuildHabitStateCopyWith<$Res> {
  factory _$BuildHabitStateCopyWith(_BuildHabitState value, $Res Function(_BuildHabitState) _then) = __$BuildHabitStateCopyWithImpl;
@override @useResult
$Res call({
 DateTime startDate, String color, Map<EntityCategory, bool> categorySelection, List<Reminder> reminders, RepeatConfig repeatConfig, DateTime? startTime, DateTime? endTime, DateTime? endDate
});




}
/// @nodoc
class __$BuildHabitStateCopyWithImpl<$Res>
    implements _$BuildHabitStateCopyWith<$Res> {
  __$BuildHabitStateCopyWithImpl(this._self, this._then);

  final _BuildHabitState _self;
  final $Res Function(_BuildHabitState) _then;

/// Create a copy of BuildHabitState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? startDate = null,Object? color = null,Object? categorySelection = null,Object? reminders = null,Object? repeatConfig = null,Object? startTime = freezed,Object? endTime = freezed,Object? endDate = freezed,}) {
  return _then(_BuildHabitState(
startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String,categorySelection: null == categorySelection ? _self._categorySelection : categorySelection // ignore: cast_nullable_to_non_nullable
as Map<EntityCategory, bool>,reminders: null == reminders ? _self._reminders : reminders // ignore: cast_nullable_to_non_nullable
as List<Reminder>,repeatConfig: null == repeatConfig ? _self.repeatConfig : repeatConfig // ignore: cast_nullable_to_non_nullable
as RepeatConfig,startTime: freezed == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime?,endTime: freezed == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as DateTime?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
