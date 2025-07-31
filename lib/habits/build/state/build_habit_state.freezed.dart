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

 String get name; DateTime get startDate; String get color; String get measurementType; String get measurementUnit; Map<EntityCategory, bool> get categorySelection; List<Reminder> get reminders; BuildHabitRepeatConfig get repeatConfig; DateTime? get startTime; DateTime? get endTime; String? get description; DateTime? get endDate;
/// Create a copy of BuildHabitState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BuildHabitStateCopyWith<BuildHabitState> get copyWith => _$BuildHabitStateCopyWithImpl<BuildHabitState>(this as BuildHabitState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BuildHabitState&&(identical(other.name, name) || other.name == name)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.color, color) || other.color == color)&&(identical(other.measurementType, measurementType) || other.measurementType == measurementType)&&(identical(other.measurementUnit, measurementUnit) || other.measurementUnit == measurementUnit)&&const DeepCollectionEquality().equals(other.categorySelection, categorySelection)&&const DeepCollectionEquality().equals(other.reminders, reminders)&&const DeepCollectionEquality().equals(other.repeatConfig, repeatConfig)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.description, description) || other.description == description)&&(identical(other.endDate, endDate) || other.endDate == endDate));
}


@override
int get hashCode => Object.hash(runtimeType,name,startDate,color,measurementType,measurementUnit,const DeepCollectionEquality().hash(categorySelection),const DeepCollectionEquality().hash(reminders),const DeepCollectionEquality().hash(repeatConfig),startTime,endTime,description,endDate);

@override
String toString() {
  return 'BuildHabitState(name: $name, startDate: $startDate, color: $color, measurementType: $measurementType, measurementUnit: $measurementUnit, categorySelection: $categorySelection, reminders: $reminders, repeatConfig: $repeatConfig, startTime: $startTime, endTime: $endTime, description: $description, endDate: $endDate)';
}


}

/// @nodoc
abstract mixin class $BuildHabitStateCopyWith<$Res>  {
  factory $BuildHabitStateCopyWith(BuildHabitState value, $Res Function(BuildHabitState) _then) = _$BuildHabitStateCopyWithImpl;
@useResult
$Res call({
 String name, DateTime startDate, String color, String measurementType, String measurementUnit, Map<EntityCategory, bool> categorySelection, List<Reminder> reminders, BuildHabitRepeatConfig repeatConfig, DateTime? startTime, DateTime? endTime, String? description, DateTime? endDate
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
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? startDate = null,Object? color = null,Object? measurementType = null,Object? measurementUnit = null,Object? categorySelection = null,Object? reminders = null,Object? repeatConfig = freezed,Object? startTime = freezed,Object? endTime = freezed,Object? description = freezed,Object? endDate = freezed,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String,measurementType: null == measurementType ? _self.measurementType : measurementType // ignore: cast_nullable_to_non_nullable
as String,measurementUnit: null == measurementUnit ? _self.measurementUnit : measurementUnit // ignore: cast_nullable_to_non_nullable
as String,categorySelection: null == categorySelection ? _self.categorySelection : categorySelection // ignore: cast_nullable_to_non_nullable
as Map<EntityCategory, bool>,reminders: null == reminders ? _self.reminders : reminders // ignore: cast_nullable_to_non_nullable
as List<Reminder>,repeatConfig: freezed == repeatConfig ? _self.repeatConfig : repeatConfig // ignore: cast_nullable_to_non_nullable
as BuildHabitRepeatConfig,startTime: freezed == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime?,endTime: freezed == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as DateTime?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// @nodoc


class _BuildHabitState extends BuildHabitState {
  const _BuildHabitState({required this.name, required this.startDate, required this.color, required this.measurementType, required this.measurementUnit, required final  Map<EntityCategory, bool> categorySelection, required final  List<Reminder> reminders, required this.repeatConfig, this.startTime, this.endTime, this.description, this.endDate}): _categorySelection = categorySelection,_reminders = reminders,super._();
  

@override final  String name;
@override final  DateTime startDate;
@override final  String color;
@override final  String measurementType;
@override final  String measurementUnit;
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

@override final  BuildHabitRepeatConfig repeatConfig;
@override final  DateTime? startTime;
@override final  DateTime? endTime;
@override final  String? description;
@override final  DateTime? endDate;

/// Create a copy of BuildHabitState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BuildHabitStateCopyWith<_BuildHabitState> get copyWith => __$BuildHabitStateCopyWithImpl<_BuildHabitState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BuildHabitState&&(identical(other.name, name) || other.name == name)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.color, color) || other.color == color)&&(identical(other.measurementType, measurementType) || other.measurementType == measurementType)&&(identical(other.measurementUnit, measurementUnit) || other.measurementUnit == measurementUnit)&&const DeepCollectionEquality().equals(other._categorySelection, _categorySelection)&&const DeepCollectionEquality().equals(other._reminders, _reminders)&&const DeepCollectionEquality().equals(other.repeatConfig, repeatConfig)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.description, description) || other.description == description)&&(identical(other.endDate, endDate) || other.endDate == endDate));
}


@override
int get hashCode => Object.hash(runtimeType,name,startDate,color,measurementType,measurementUnit,const DeepCollectionEquality().hash(_categorySelection),const DeepCollectionEquality().hash(_reminders),const DeepCollectionEquality().hash(repeatConfig),startTime,endTime,description,endDate);

@override
String toString() {
  return 'BuildHabitState(name: $name, startDate: $startDate, color: $color, measurementType: $measurementType, measurementUnit: $measurementUnit, categorySelection: $categorySelection, reminders: $reminders, repeatConfig: $repeatConfig, startTime: $startTime, endTime: $endTime, description: $description, endDate: $endDate)';
}


}

/// @nodoc
abstract mixin class _$BuildHabitStateCopyWith<$Res> implements $BuildHabitStateCopyWith<$Res> {
  factory _$BuildHabitStateCopyWith(_BuildHabitState value, $Res Function(_BuildHabitState) _then) = __$BuildHabitStateCopyWithImpl;
@override @useResult
$Res call({
 String name, DateTime startDate, String color, String measurementType, String measurementUnit, Map<EntityCategory, bool> categorySelection, List<Reminder> reminders, BuildHabitRepeatConfig repeatConfig, DateTime? startTime, DateTime? endTime, String? description, DateTime? endDate
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
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? startDate = null,Object? color = null,Object? measurementType = null,Object? measurementUnit = null,Object? categorySelection = null,Object? reminders = null,Object? repeatConfig = freezed,Object? startTime = freezed,Object? endTime = freezed,Object? description = freezed,Object? endDate = freezed,}) {
  return _then(_BuildHabitState(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String,measurementType: null == measurementType ? _self.measurementType : measurementType // ignore: cast_nullable_to_non_nullable
as String,measurementUnit: null == measurementUnit ? _self.measurementUnit : measurementUnit // ignore: cast_nullable_to_non_nullable
as String,categorySelection: null == categorySelection ? _self._categorySelection : categorySelection // ignore: cast_nullable_to_non_nullable
as Map<EntityCategory, bool>,reminders: null == reminders ? _self._reminders : reminders // ignore: cast_nullable_to_non_nullable
as List<Reminder>,repeatConfig: freezed == repeatConfig ? _self.repeatConfig : repeatConfig // ignore: cast_nullable_to_non_nullable
as BuildHabitRepeatConfig,startTime: freezed == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime?,endTime: freezed == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as DateTime?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
