// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'habit_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HabitState {

 String get name; String? get description; DateTime get startDate; DateTime? get endDate;
/// Create a copy of HabitState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HabitStateCopyWith<HabitState> get copyWith => _$HabitStateCopyWithImpl<HabitState>(this as HabitState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HabitState&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate));
}


@override
int get hashCode => Object.hash(runtimeType,name,description,startDate,endDate);

@override
String toString() {
  return 'HabitState(name: $name, description: $description, startDate: $startDate, endDate: $endDate)';
}


}

/// @nodoc
abstract mixin class $HabitStateCopyWith<$Res>  {
  factory $HabitStateCopyWith(HabitState value, $Res Function(HabitState) _then) = _$HabitStateCopyWithImpl;
@useResult
$Res call({
 String name, String? description, DateTime startDate, DateTime? endDate
});




}
/// @nodoc
class _$HabitStateCopyWithImpl<$Res>
    implements $HabitStateCopyWith<$Res> {
  _$HabitStateCopyWithImpl(this._self, this._then);

  final HabitState _self;
  final $Res Function(HabitState) _then;

/// Create a copy of HabitState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? description = freezed,Object? startDate = null,Object? endDate = freezed,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// @nodoc


class _HabitState extends HabitState {
  const _HabitState({required this.name, this.description, required this.startDate, this.endDate}): super._();
  

@override final  String name;
@override final  String? description;
@override final  DateTime startDate;
@override final  DateTime? endDate;

/// Create a copy of HabitState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HabitStateCopyWith<_HabitState> get copyWith => __$HabitStateCopyWithImpl<_HabitState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HabitState&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate));
}


@override
int get hashCode => Object.hash(runtimeType,name,description,startDate,endDate);

@override
String toString() {
  return 'HabitState(name: $name, description: $description, startDate: $startDate, endDate: $endDate)';
}


}

/// @nodoc
abstract mixin class _$HabitStateCopyWith<$Res> implements $HabitStateCopyWith<$Res> {
  factory _$HabitStateCopyWith(_HabitState value, $Res Function(_HabitState) _then) = __$HabitStateCopyWithImpl;
@override @useResult
$Res call({
 String name, String? description, DateTime startDate, DateTime? endDate
});




}
/// @nodoc
class __$HabitStateCopyWithImpl<$Res>
    implements _$HabitStateCopyWith<$Res> {
  __$HabitStateCopyWithImpl(this._self, this._then);

  final _HabitState _self;
  final $Res Function(_HabitState) _then;

/// Create a copy of HabitState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? description = freezed,Object? startDate = null,Object? endDate = freezed,}) {
  return _then(_HabitState(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
