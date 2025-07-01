// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'folder_state_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FolderState {

 String get color; String get icon;
/// Create a copy of FolderState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FolderStateCopyWith<FolderState> get copyWith => _$FolderStateCopyWithImpl<FolderState>(this as FolderState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FolderState&&(identical(other.color, color) || other.color == color)&&(identical(other.icon, icon) || other.icon == icon));
}


@override
int get hashCode => Object.hash(runtimeType,color,icon);

@override
String toString() {
  return 'FolderState(color: $color, icon: $icon)';
}


}

/// @nodoc
abstract mixin class $FolderStateCopyWith<$Res>  {
  factory $FolderStateCopyWith(FolderState value, $Res Function(FolderState) _then) = _$FolderStateCopyWithImpl;
@useResult
$Res call({
 String color, String icon
});




}
/// @nodoc
class _$FolderStateCopyWithImpl<$Res>
    implements $FolderStateCopyWith<$Res> {
  _$FolderStateCopyWithImpl(this._self, this._then);

  final FolderState _self;
  final $Res Function(FolderState) _then;

/// Create a copy of FolderState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? color = null,Object? icon = null,}) {
  return _then(_self.copyWith(
color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// @nodoc


class _FolderState extends FolderState {
  const _FolderState({required this.color, required this.icon}): super._();
  

@override final  String color;
@override final  String icon;

/// Create a copy of FolderState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FolderStateCopyWith<_FolderState> get copyWith => __$FolderStateCopyWithImpl<_FolderState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FolderState&&(identical(other.color, color) || other.color == color)&&(identical(other.icon, icon) || other.icon == icon));
}


@override
int get hashCode => Object.hash(runtimeType,color,icon);

@override
String toString() {
  return 'FolderState(color: $color, icon: $icon)';
}


}

/// @nodoc
abstract mixin class _$FolderStateCopyWith<$Res> implements $FolderStateCopyWith<$Res> {
  factory _$FolderStateCopyWith(_FolderState value, $Res Function(_FolderState) _then) = __$FolderStateCopyWithImpl;
@override @useResult
$Res call({
 String color, String icon
});




}
/// @nodoc
class __$FolderStateCopyWithImpl<$Res>
    implements _$FolderStateCopyWith<$Res> {
  __$FolderStateCopyWithImpl(this._self, this._then);

  final _FolderState _self;
  final $Res Function(_FolderState) _then;

/// Create a copy of FolderState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? color = null,Object? icon = null,}) {
  return _then(_FolderState(
color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
