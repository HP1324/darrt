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

 String get name; DateTime get startDate; Color get color; String? get description; DateTime? get endDate;
/// Create a copy of BuildHabitState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BuildHabitStateCopyWith<BuildHabitState> get copyWith => _$BuildHabitStateCopyWithImpl<BuildHabitState>(this as BuildHabitState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BuildHabitState&&(identical(other.name, name) || other.name == name)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.color, color) || other.color == color)&&(identical(other.description, description) || other.description == description)&&(identical(other.endDate, endDate) || other.endDate == endDate));
}


@override
int get hashCode => Object.hash(runtimeType,name,startDate,color,description,endDate);

@override
String toString() {
  return 'BuildHabitState(name: $name, startDate: $startDate, color: $color, description: $description, endDate: $endDate)';
}


}

/// @nodoc
abstract mixin class $BuildHabitStateCopyWith<$Res>  {
  factory $BuildHabitStateCopyWith(BuildHabitState value, $Res Function(BuildHabitState) _then) = _$BuildHabitStateCopyWithImpl;
@useResult
$Res call({
 String name, DateTime startDate, Color color, String? description, DateTime? endDate
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
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? startDate = null,Object? color = null,Object? description = freezed,Object? endDate = freezed,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as Color,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// @nodoc


class _BuildHabitState extends BuildHabitState {
  const _BuildHabitState({required this.name, required this.startDate, required this.color, this.description, this.endDate}): super._();
  

@override final  String name;
@override final  DateTime startDate;
@override final  Color color;
@override final  String? description;
@override final  DateTime? endDate;

/// Create a copy of BuildHabitState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BuildHabitStateCopyWith<_BuildHabitState> get copyWith => __$BuildHabitStateCopyWithImpl<_BuildHabitState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BuildHabitState&&(identical(other.name, name) || other.name == name)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.color, color) || other.color == color)&&(identical(other.description, description) || other.description == description)&&(identical(other.endDate, endDate) || other.endDate == endDate));
}


@override
int get hashCode => Object.hash(runtimeType,name,startDate,color,description,endDate);

@override
String toString() {
  return 'BuildHabitState(name: $name, startDate: $startDate, color: $color, description: $description, endDate: $endDate)';
}


}

/// @nodoc
abstract mixin class _$BuildHabitStateCopyWith<$Res> implements $BuildHabitStateCopyWith<$Res> {
  factory _$BuildHabitStateCopyWith(_BuildHabitState value, $Res Function(_BuildHabitState) _then) = __$BuildHabitStateCopyWithImpl;
@override @useResult
$Res call({
 String name, DateTime startDate, Color color, String? description, DateTime? endDate
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
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? startDate = null,Object? color = null,Object? description = freezed,Object? endDate = freezed,}) {
  return _then(_BuildHabitState(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as Color,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
