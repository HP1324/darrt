// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task_state_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TaskState {

 Map<TaskCategory, bool> get categorySelection; DateTime get dueDate; bool get isRepeating; DateTime get startDate; DateTime? get endDate; DateTime? get time; RepeatConfig get repeatConfig; List<Reminder> get reminders; String get priority; int get currentPriority;
/// Create a copy of TaskState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaskStateCopyWith<TaskState> get copyWith => _$TaskStateCopyWithImpl<TaskState>(this as TaskState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaskState&&const DeepCollectionEquality().equals(other.categorySelection, categorySelection)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.isRepeating, isRepeating) || other.isRepeating == isRepeating)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.time, time) || other.time == time)&&(identical(other.repeatConfig, repeatConfig) || other.repeatConfig == repeatConfig)&&const DeepCollectionEquality().equals(other.reminders, reminders)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.currentPriority, currentPriority) || other.currentPriority == currentPriority));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(categorySelection),dueDate,isRepeating,startDate,endDate,time,repeatConfig,const DeepCollectionEquality().hash(reminders),priority,currentPriority);

@override
String toString() {
  return 'TaskState(categorySelection: $categorySelection, dueDate: $dueDate, isRepeating: $isRepeating, startDate: $startDate, endDate: $endDate, time: $time, repeatConfig: $repeatConfig, reminders: $reminders, priority: $priority, currentPriority: $currentPriority)';
}


}

/// @nodoc
abstract mixin class $TaskStateCopyWith<$Res>  {
  factory $TaskStateCopyWith(TaskState value, $Res Function(TaskState) _then) = _$TaskStateCopyWithImpl;
@useResult
$Res call({
 Map<TaskCategory, bool> categorySelection, DateTime dueDate, bool isRepeating, DateTime startDate, DateTime? endDate, DateTime? time, RepeatConfig repeatConfig, List<Reminder> reminders, String priority, int currentPriority
});




}
/// @nodoc
class _$TaskStateCopyWithImpl<$Res>
    implements $TaskStateCopyWith<$Res> {
  _$TaskStateCopyWithImpl(this._self, this._then);

  final TaskState _self;
  final $Res Function(TaskState) _then;

/// Create a copy of TaskState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? categorySelection = null,Object? dueDate = null,Object? isRepeating = null,Object? startDate = null,Object? endDate = freezed,Object? time = freezed,Object? repeatConfig = null,Object? reminders = null,Object? priority = null,Object? currentPriority = null,}) {
  return _then(_self.copyWith(
categorySelection: null == categorySelection ? _self.categorySelection : categorySelection // ignore: cast_nullable_to_non_nullable
as Map<TaskCategory, bool>,dueDate: null == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime,isRepeating: null == isRepeating ? _self.isRepeating : isRepeating // ignore: cast_nullable_to_non_nullable
as bool,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,time: freezed == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as DateTime?,repeatConfig: null == repeatConfig ? _self.repeatConfig : repeatConfig // ignore: cast_nullable_to_non_nullable
as RepeatConfig,reminders: null == reminders ? _self.reminders : reminders // ignore: cast_nullable_to_non_nullable
as List<Reminder>,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as String,currentPriority: null == currentPriority ? _self.currentPriority : currentPriority // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// @nodoc


class _TaskState extends TaskState {
  const _TaskState({required final  Map<TaskCategory, bool> categorySelection, required this.dueDate, required this.isRepeating, required this.startDate, this.endDate, this.time, required this.repeatConfig, required final  List<Reminder> reminders, required this.priority, required this.currentPriority}): _categorySelection = categorySelection,_reminders = reminders,super._();
  

 final  Map<TaskCategory, bool> _categorySelection;
@override Map<TaskCategory, bool> get categorySelection {
  if (_categorySelection is EqualUnmodifiableMapView) return _categorySelection;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_categorySelection);
}

@override final  DateTime dueDate;
@override final  bool isRepeating;
@override final  DateTime startDate;
@override final  DateTime? endDate;
@override final  DateTime? time;
@override final  RepeatConfig repeatConfig;
 final  List<Reminder> _reminders;
@override List<Reminder> get reminders {
  if (_reminders is EqualUnmodifiableListView) return _reminders;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_reminders);
}

@override final  String priority;
@override final  int currentPriority;

/// Create a copy of TaskState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TaskStateCopyWith<_TaskState> get copyWith => __$TaskStateCopyWithImpl<_TaskState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TaskState&&const DeepCollectionEquality().equals(other._categorySelection, _categorySelection)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.isRepeating, isRepeating) || other.isRepeating == isRepeating)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.time, time) || other.time == time)&&(identical(other.repeatConfig, repeatConfig) || other.repeatConfig == repeatConfig)&&const DeepCollectionEquality().equals(other._reminders, _reminders)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.currentPriority, currentPriority) || other.currentPriority == currentPriority));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_categorySelection),dueDate,isRepeating,startDate,endDate,time,repeatConfig,const DeepCollectionEquality().hash(_reminders),priority,currentPriority);

@override
String toString() {
  return 'TaskState(categorySelection: $categorySelection, dueDate: $dueDate, isRepeating: $isRepeating, startDate: $startDate, endDate: $endDate, time: $time, repeatConfig: $repeatConfig, reminders: $reminders, priority: $priority, currentPriority: $currentPriority)';
}


}

/// @nodoc
abstract mixin class _$TaskStateCopyWith<$Res> implements $TaskStateCopyWith<$Res> {
  factory _$TaskStateCopyWith(_TaskState value, $Res Function(_TaskState) _then) = __$TaskStateCopyWithImpl;
@override @useResult
$Res call({
 Map<TaskCategory, bool> categorySelection, DateTime dueDate, bool isRepeating, DateTime startDate, DateTime? endDate, DateTime? time, RepeatConfig repeatConfig, List<Reminder> reminders, String priority, int currentPriority
});




}
/// @nodoc
class __$TaskStateCopyWithImpl<$Res>
    implements _$TaskStateCopyWith<$Res> {
  __$TaskStateCopyWithImpl(this._self, this._then);

  final _TaskState _self;
  final $Res Function(_TaskState) _then;

/// Create a copy of TaskState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? categorySelection = null,Object? dueDate = null,Object? isRepeating = null,Object? startDate = null,Object? endDate = freezed,Object? time = freezed,Object? repeatConfig = null,Object? reminders = null,Object? priority = null,Object? currentPriority = null,}) {
  return _then(_TaskState(
categorySelection: null == categorySelection ? _self._categorySelection : categorySelection // ignore: cast_nullable_to_non_nullable
as Map<TaskCategory, bool>,dueDate: null == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime,isRepeating: null == isRepeating ? _self.isRepeating : isRepeating // ignore: cast_nullable_to_non_nullable
as bool,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,time: freezed == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as DateTime?,repeatConfig: null == repeatConfig ? _self.repeatConfig : repeatConfig // ignore: cast_nullable_to_non_nullable
as RepeatConfig,reminders: null == reminders ? _self._reminders : reminders // ignore: cast_nullable_to_non_nullable
as List<Reminder>,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as String,currentPriority: null == currentPriority ? _self.currentPriority : currentPriority // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
