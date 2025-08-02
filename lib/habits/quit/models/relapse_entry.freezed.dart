// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'relapse_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RelapseEntry {

 DateTime get dateTime; String? get trigger;
/// Create a copy of RelapseEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RelapseEntryCopyWith<RelapseEntry> get copyWith => _$RelapseEntryCopyWithImpl<RelapseEntry>(this as RelapseEntry, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RelapseEntry&&(identical(other.dateTime, dateTime) || other.dateTime == dateTime)&&(identical(other.trigger, trigger) || other.trigger == trigger));
}


@override
int get hashCode => Object.hash(runtimeType,dateTime,trigger);

@override
String toString() {
  return 'RelapseEntry(dateTime: $dateTime, trigger: $trigger)';
}


}

/// @nodoc
abstract mixin class $RelapseEntryCopyWith<$Res>  {
  factory $RelapseEntryCopyWith(RelapseEntry value, $Res Function(RelapseEntry) _then) = _$RelapseEntryCopyWithImpl;
@useResult
$Res call({
 DateTime dateTime, String? trigger
});




}
/// @nodoc
class _$RelapseEntryCopyWithImpl<$Res>
    implements $RelapseEntryCopyWith<$Res> {
  _$RelapseEntryCopyWithImpl(this._self, this._then);

  final RelapseEntry _self;
  final $Res Function(RelapseEntry) _then;

/// Create a copy of RelapseEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? dateTime = null,Object? trigger = freezed,}) {
  return _then(_self.copyWith(
dateTime: null == dateTime ? _self.dateTime : dateTime // ignore: cast_nullable_to_non_nullable
as DateTime,trigger: freezed == trigger ? _self.trigger : trigger // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// @nodoc


class _RelpaseEntry implements RelapseEntry {
  const _RelpaseEntry({required this.dateTime, this.trigger});
  

@override final  DateTime dateTime;
@override final  String? trigger;

/// Create a copy of RelapseEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RelpaseEntryCopyWith<_RelpaseEntry> get copyWith => __$RelpaseEntryCopyWithImpl<_RelpaseEntry>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RelpaseEntry&&(identical(other.dateTime, dateTime) || other.dateTime == dateTime)&&(identical(other.trigger, trigger) || other.trigger == trigger));
}


@override
int get hashCode => Object.hash(runtimeType,dateTime,trigger);

@override
String toString() {
  return 'RelapseEntry(dateTime: $dateTime, trigger: $trigger)';
}


}

/// @nodoc
abstract mixin class _$RelpaseEntryCopyWith<$Res> implements $RelapseEntryCopyWith<$Res> {
  factory _$RelpaseEntryCopyWith(_RelpaseEntry value, $Res Function(_RelpaseEntry) _then) = __$RelpaseEntryCopyWithImpl;
@override @useResult
$Res call({
 DateTime dateTime, String? trigger
});




}
/// @nodoc
class __$RelpaseEntryCopyWithImpl<$Res>
    implements _$RelpaseEntryCopyWith<$Res> {
  __$RelpaseEntryCopyWithImpl(this._self, this._then);

  final _RelpaseEntry _self;
  final $Res Function(_RelpaseEntry) _then;

/// Create a copy of RelapseEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? dateTime = null,Object? trigger = freezed,}) {
  return _then(_RelpaseEntry(
dateTime: null == dateTime ? _self.dateTime : dateTime // ignore: cast_nullable_to_non_nullable
as DateTime,trigger: freezed == trigger ? _self.trigger : trigger // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
