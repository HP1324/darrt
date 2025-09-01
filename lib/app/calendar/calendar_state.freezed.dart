// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'calendar_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CalendarState {

 DateTime get selectedDate; DateTime get previousSelectedDate;
/// Create a copy of CalendarState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CalendarStateCopyWith<CalendarState> get copyWith => _$CalendarStateCopyWithImpl<CalendarState>(this as CalendarState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CalendarState&&(identical(other.selectedDate, selectedDate) || other.selectedDate == selectedDate)&&(identical(other.previousSelectedDate, previousSelectedDate) || other.previousSelectedDate == previousSelectedDate));
}


@override
int get hashCode => Object.hash(runtimeType,selectedDate,previousSelectedDate);

@override
String toString() {
  return 'CalendarState(selectedDate: $selectedDate, previousSelectedDate: $previousSelectedDate)';
}


}

/// @nodoc
abstract mixin class $CalendarStateCopyWith<$Res>  {
  factory $CalendarStateCopyWith(CalendarState value, $Res Function(CalendarState) _then) = _$CalendarStateCopyWithImpl;
@useResult
$Res call({
 DateTime selectedDate, DateTime previousSelectedDate
});




}
/// @nodoc
class _$CalendarStateCopyWithImpl<$Res>
    implements $CalendarStateCopyWith<$Res> {
  _$CalendarStateCopyWithImpl(this._self, this._then);

  final CalendarState _self;
  final $Res Function(CalendarState) _then;

/// Create a copy of CalendarState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? selectedDate = null,Object? previousSelectedDate = null,}) {
  return _then(_self.copyWith(
selectedDate: null == selectedDate ? _self.selectedDate : selectedDate // ignore: cast_nullable_to_non_nullable
as DateTime,previousSelectedDate: null == previousSelectedDate ? _self.previousSelectedDate : previousSelectedDate // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// @nodoc


class _CalendarState extends CalendarState {
  const _CalendarState({required this.selectedDate, required this.previousSelectedDate}): super._();
  

@override final  DateTime selectedDate;
@override final  DateTime previousSelectedDate;

/// Create a copy of CalendarState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CalendarStateCopyWith<_CalendarState> get copyWith => __$CalendarStateCopyWithImpl<_CalendarState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CalendarState&&(identical(other.selectedDate, selectedDate) || other.selectedDate == selectedDate)&&(identical(other.previousSelectedDate, previousSelectedDate) || other.previousSelectedDate == previousSelectedDate));
}


@override
int get hashCode => Object.hash(runtimeType,selectedDate,previousSelectedDate);

@override
String toString() {
  return 'CalendarState(selectedDate: $selectedDate, previousSelectedDate: $previousSelectedDate)';
}


}

/// @nodoc
abstract mixin class _$CalendarStateCopyWith<$Res> implements $CalendarStateCopyWith<$Res> {
  factory _$CalendarStateCopyWith(_CalendarState value, $Res Function(_CalendarState) _then) = __$CalendarStateCopyWithImpl;
@override @useResult
$Res call({
 DateTime selectedDate, DateTime previousSelectedDate
});




}
/// @nodoc
class __$CalendarStateCopyWithImpl<$Res>
    implements _$CalendarStateCopyWith<$Res> {
  __$CalendarStateCopyWithImpl(this._self, this._then);

  final _CalendarState _self;
  final $Res Function(_CalendarState) _then;

/// Create a copy of CalendarState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? selectedDate = null,Object? previousSelectedDate = null,}) {
  return _then(_CalendarState(
selectedDate: null == selectedDate ? _self.selectedDate : selectedDate // ignore: cast_nullable_to_non_nullable
as DateTime,previousSelectedDate: null == previousSelectedDate ? _self.previousSelectedDate : previousSelectedDate // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
