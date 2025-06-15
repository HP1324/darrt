// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'note_state_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$NoteState {

 String get color; DateTime get createdAt; DateTime get updatedAt; Map<Folder, bool> get folderSelection;
/// Create a copy of NoteState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NoteStateCopyWith<NoteState> get copyWith => _$NoteStateCopyWithImpl<NoteState>(this as NoteState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NoteState&&(identical(other.color, color) || other.color == color)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other.folderSelection, folderSelection));
}


@override
int get hashCode => Object.hash(runtimeType,color,createdAt,updatedAt,const DeepCollectionEquality().hash(folderSelection));

@override
String toString() {
  return 'NoteState(color: $color, createdAt: $createdAt, updatedAt: $updatedAt, folderSelection: $folderSelection)';
}


}

/// @nodoc
abstract mixin class $NoteStateCopyWith<$Res>  {
  factory $NoteStateCopyWith(NoteState value, $Res Function(NoteState) _then) = _$NoteStateCopyWithImpl;
@useResult
$Res call({
 String color, DateTime createdAt, DateTime updatedAt, Map<Folder, bool> folderSelection
});




}
/// @nodoc
class _$NoteStateCopyWithImpl<$Res>
    implements $NoteStateCopyWith<$Res> {
  _$NoteStateCopyWithImpl(this._self, this._then);

  final NoteState _self;
  final $Res Function(NoteState) _then;

/// Create a copy of NoteState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? color = null,Object? createdAt = null,Object? updatedAt = null,Object? folderSelection = null,}) {
  return _then(_self.copyWith(
color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,folderSelection: null == folderSelection ? _self.folderSelection : folderSelection // ignore: cast_nullable_to_non_nullable
as Map<Folder, bool>,
  ));
}

}


/// @nodoc


class _NoteState extends NoteState {
  const _NoteState({required this.color, required this.createdAt, required this.updatedAt, required final  Map<Folder, bool> folderSelection}): _folderSelection = folderSelection,super._();
  

@override final  String color;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
 final  Map<Folder, bool> _folderSelection;
@override Map<Folder, bool> get folderSelection {
  if (_folderSelection is EqualUnmodifiableMapView) return _folderSelection;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_folderSelection);
}


/// Create a copy of NoteState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NoteStateCopyWith<_NoteState> get copyWith => __$NoteStateCopyWithImpl<_NoteState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NoteState&&(identical(other.color, color) || other.color == color)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other._folderSelection, _folderSelection));
}


@override
int get hashCode => Object.hash(runtimeType,color,createdAt,updatedAt,const DeepCollectionEquality().hash(_folderSelection));

@override
String toString() {
  return 'NoteState(color: $color, createdAt: $createdAt, updatedAt: $updatedAt, folderSelection: $folderSelection)';
}


}

/// @nodoc
abstract mixin class _$NoteStateCopyWith<$Res> implements $NoteStateCopyWith<$Res> {
  factory _$NoteStateCopyWith(_NoteState value, $Res Function(_NoteState) _then) = __$NoteStateCopyWithImpl;
@override @useResult
$Res call({
 String color, DateTime createdAt, DateTime updatedAt, Map<Folder, bool> folderSelection
});




}
/// @nodoc
class __$NoteStateCopyWithImpl<$Res>
    implements _$NoteStateCopyWith<$Res> {
  __$NoteStateCopyWithImpl(this._self, this._then);

  final _NoteState _self;
  final $Res Function(_NoteState) _then;

/// Create a copy of NoteState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? color = null,Object? createdAt = null,Object? updatedAt = null,Object? folderSelection = null,}) {
  return _then(_NoteState(
color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,folderSelection: null == folderSelection ? _self._folderSelection : folderSelection // ignore: cast_nullable_to_non_nullable
as Map<Folder, bool>,
  ));
}


}

// dart format on
