// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task_notifier_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TaskNotifierState {

 Map<int, bool> get oneTimeTaskCompletions; Map<int, Set<int>> get repeatingTaskCompletions;
/// Create a copy of TaskNotifierState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaskNotifierStateCopyWith<TaskNotifierState> get copyWith => _$TaskNotifierStateCopyWithImpl<TaskNotifierState>(this as TaskNotifierState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaskNotifierState&&const DeepCollectionEquality().equals(other.oneTimeTaskCompletions, oneTimeTaskCompletions)&&const DeepCollectionEquality().equals(other.repeatingTaskCompletions, repeatingTaskCompletions));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(oneTimeTaskCompletions),const DeepCollectionEquality().hash(repeatingTaskCompletions));

@override
String toString() {
  return 'TaskNotifierState(oneTimeTaskCompletions: $oneTimeTaskCompletions, repeatingTaskCompletions: $repeatingTaskCompletions)';
}


}

/// @nodoc
abstract mixin class $TaskNotifierStateCopyWith<$Res>  {
  factory $TaskNotifierStateCopyWith(TaskNotifierState value, $Res Function(TaskNotifierState) _then) = _$TaskNotifierStateCopyWithImpl;
@useResult
$Res call({
 Map<int, bool> oneTimeTaskCompletions, Map<int, Set<int>> repeatingTaskCompletions
});




}
/// @nodoc
class _$TaskNotifierStateCopyWithImpl<$Res>
    implements $TaskNotifierStateCopyWith<$Res> {
  _$TaskNotifierStateCopyWithImpl(this._self, this._then);

  final TaskNotifierState _self;
  final $Res Function(TaskNotifierState) _then;

/// Create a copy of TaskNotifierState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? oneTimeTaskCompletions = null,Object? repeatingTaskCompletions = null,}) {
  return _then(_self.copyWith(
oneTimeTaskCompletions: null == oneTimeTaskCompletions ? _self.oneTimeTaskCompletions : oneTimeTaskCompletions // ignore: cast_nullable_to_non_nullable
as Map<int, bool>,repeatingTaskCompletions: null == repeatingTaskCompletions ? _self.repeatingTaskCompletions : repeatingTaskCompletions // ignore: cast_nullable_to_non_nullable
as Map<int, Set<int>>,
  ));
}

}


/// @nodoc


class _TaskNotifierState extends TaskNotifierState {
  const _TaskNotifierState({required final  Map<int, bool> oneTimeTaskCompletions, required final  Map<int, Set<int>> repeatingTaskCompletions}): _oneTimeTaskCompletions = oneTimeTaskCompletions,_repeatingTaskCompletions = repeatingTaskCompletions,super._();
  

 final  Map<int, bool> _oneTimeTaskCompletions;
@override Map<int, bool> get oneTimeTaskCompletions {
  if (_oneTimeTaskCompletions is EqualUnmodifiableMapView) return _oneTimeTaskCompletions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_oneTimeTaskCompletions);
}

 final  Map<int, Set<int>> _repeatingTaskCompletions;
@override Map<int, Set<int>> get repeatingTaskCompletions {
  if (_repeatingTaskCompletions is EqualUnmodifiableMapView) return _repeatingTaskCompletions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_repeatingTaskCompletions);
}


/// Create a copy of TaskNotifierState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TaskNotifierStateCopyWith<_TaskNotifierState> get copyWith => __$TaskNotifierStateCopyWithImpl<_TaskNotifierState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TaskNotifierState&&const DeepCollectionEquality().equals(other._oneTimeTaskCompletions, _oneTimeTaskCompletions)&&const DeepCollectionEquality().equals(other._repeatingTaskCompletions, _repeatingTaskCompletions));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_oneTimeTaskCompletions),const DeepCollectionEquality().hash(_repeatingTaskCompletions));

@override
String toString() {
  return 'TaskNotifierState(oneTimeTaskCompletions: $oneTimeTaskCompletions, repeatingTaskCompletions: $repeatingTaskCompletions)';
}


}

/// @nodoc
abstract mixin class _$TaskNotifierStateCopyWith<$Res> implements $TaskNotifierStateCopyWith<$Res> {
  factory _$TaskNotifierStateCopyWith(_TaskNotifierState value, $Res Function(_TaskNotifierState) _then) = __$TaskNotifierStateCopyWithImpl;
@override @useResult
$Res call({
 Map<int, bool> oneTimeTaskCompletions, Map<int, Set<int>> repeatingTaskCompletions
});




}
/// @nodoc
class __$TaskNotifierStateCopyWithImpl<$Res>
    implements _$TaskNotifierStateCopyWith<$Res> {
  __$TaskNotifierStateCopyWithImpl(this._self, this._then);

  final _TaskNotifierState _self;
  final $Res Function(_TaskNotifierState) _then;

/// Create a copy of TaskNotifierState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? oneTimeTaskCompletions = null,Object? repeatingTaskCompletions = null,}) {
  return _then(_TaskNotifierState(
oneTimeTaskCompletions: null == oneTimeTaskCompletions ? _self._oneTimeTaskCompletions : oneTimeTaskCompletions // ignore: cast_nullable_to_non_nullable
as Map<int, bool>,repeatingTaskCompletions: null == repeatingTaskCompletions ? _self._repeatingTaskCompletions : repeatingTaskCompletions // ignore: cast_nullable_to_non_nullable
as Map<int, Set<int>>,
  ));
}


}

// dart format on
