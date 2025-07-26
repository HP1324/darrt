// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'backup_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BackupState {

 String? get currentEmail; bool get isBackingUp; bool get isRestoring; bool get isDeleting; bool get autoBackup; DateTime? get lastBackupDate; String get autoBackupFrequency;
/// Create a copy of BackupState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BackupStateCopyWith<BackupState> get copyWith => _$BackupStateCopyWithImpl<BackupState>(this as BackupState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BackupState&&(identical(other.currentEmail, currentEmail) || other.currentEmail == currentEmail)&&(identical(other.isBackingUp, isBackingUp) || other.isBackingUp == isBackingUp)&&(identical(other.isRestoring, isRestoring) || other.isRestoring == isRestoring)&&(identical(other.isDeleting, isDeleting) || other.isDeleting == isDeleting)&&(identical(other.autoBackup, autoBackup) || other.autoBackup == autoBackup)&&(identical(other.lastBackupDate, lastBackupDate) || other.lastBackupDate == lastBackupDate)&&(identical(other.autoBackupFrequency, autoBackupFrequency) || other.autoBackupFrequency == autoBackupFrequency));
}


@override
int get hashCode => Object.hash(runtimeType,currentEmail,isBackingUp,isRestoring,isDeleting,autoBackup,lastBackupDate,autoBackupFrequency);

@override
String toString() {
  return 'BackupState(currentEmail: $currentEmail, isBackingUp: $isBackingUp, isRestoring: $isRestoring, isDeleting: $isDeleting, autoBackup: $autoBackup, lastBackupDate: $lastBackupDate, autoBackupFrequency: $autoBackupFrequency)';
}


}

/// @nodoc
abstract mixin class $BackupStateCopyWith<$Res>  {
  factory $BackupStateCopyWith(BackupState value, $Res Function(BackupState) _then) = _$BackupStateCopyWithImpl;
@useResult
$Res call({
 String? currentEmail, bool isBackingUp, bool isRestoring, bool isDeleting, bool autoBackup, DateTime? lastBackupDate, String autoBackupFrequency
});




}
/// @nodoc
class _$BackupStateCopyWithImpl<$Res>
    implements $BackupStateCopyWith<$Res> {
  _$BackupStateCopyWithImpl(this._self, this._then);

  final BackupState _self;
  final $Res Function(BackupState) _then;

/// Create a copy of BackupState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? currentEmail = freezed,Object? isBackingUp = null,Object? isRestoring = null,Object? isDeleting = null,Object? autoBackup = null,Object? lastBackupDate = freezed,Object? autoBackupFrequency = null,}) {
  return _then(_self.copyWith(
currentEmail: freezed == currentEmail ? _self.currentEmail : currentEmail // ignore: cast_nullable_to_non_nullable
as String?,isBackingUp: null == isBackingUp ? _self.isBackingUp : isBackingUp // ignore: cast_nullable_to_non_nullable
as bool,isRestoring: null == isRestoring ? _self.isRestoring : isRestoring // ignore: cast_nullable_to_non_nullable
as bool,isDeleting: null == isDeleting ? _self.isDeleting : isDeleting // ignore: cast_nullable_to_non_nullable
as bool,autoBackup: null == autoBackup ? _self.autoBackup : autoBackup // ignore: cast_nullable_to_non_nullable
as bool,lastBackupDate: freezed == lastBackupDate ? _self.lastBackupDate : lastBackupDate // ignore: cast_nullable_to_non_nullable
as DateTime?,autoBackupFrequency: null == autoBackupFrequency ? _self.autoBackupFrequency : autoBackupFrequency // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// @nodoc


class _BackupState implements BackupState {
  const _BackupState({this.currentEmail, this.isBackingUp = false, this.isRestoring = false, this.isDeleting = false, this.autoBackup = false, this.lastBackupDate, this.autoBackupFrequency = 'daily'});
  

@override final  String? currentEmail;
@override@JsonKey() final  bool isBackingUp;
@override@JsonKey() final  bool isRestoring;
@override@JsonKey() final  bool isDeleting;
@override@JsonKey() final  bool autoBackup;
@override final  DateTime? lastBackupDate;
@override@JsonKey() final  String autoBackupFrequency;

/// Create a copy of BackupState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BackupStateCopyWith<_BackupState> get copyWith => __$BackupStateCopyWithImpl<_BackupState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BackupState&&(identical(other.currentEmail, currentEmail) || other.currentEmail == currentEmail)&&(identical(other.isBackingUp, isBackingUp) || other.isBackingUp == isBackingUp)&&(identical(other.isRestoring, isRestoring) || other.isRestoring == isRestoring)&&(identical(other.isDeleting, isDeleting) || other.isDeleting == isDeleting)&&(identical(other.autoBackup, autoBackup) || other.autoBackup == autoBackup)&&(identical(other.lastBackupDate, lastBackupDate) || other.lastBackupDate == lastBackupDate)&&(identical(other.autoBackupFrequency, autoBackupFrequency) || other.autoBackupFrequency == autoBackupFrequency));
}


@override
int get hashCode => Object.hash(runtimeType,currentEmail,isBackingUp,isRestoring,isDeleting,autoBackup,lastBackupDate,autoBackupFrequency);

@override
String toString() {
  return 'BackupState(currentEmail: $currentEmail, isBackingUp: $isBackingUp, isRestoring: $isRestoring, isDeleting: $isDeleting, autoBackup: $autoBackup, lastBackupDate: $lastBackupDate, autoBackupFrequency: $autoBackupFrequency)';
}


}

/// @nodoc
abstract mixin class _$BackupStateCopyWith<$Res> implements $BackupStateCopyWith<$Res> {
  factory _$BackupStateCopyWith(_BackupState value, $Res Function(_BackupState) _then) = __$BackupStateCopyWithImpl;
@override @useResult
$Res call({
 String? currentEmail, bool isBackingUp, bool isRestoring, bool isDeleting, bool autoBackup, DateTime? lastBackupDate, String autoBackupFrequency
});




}
/// @nodoc
class __$BackupStateCopyWithImpl<$Res>
    implements _$BackupStateCopyWith<$Res> {
  __$BackupStateCopyWithImpl(this._self, this._then);

  final _BackupState _self;
  final $Res Function(_BackupState) _then;

/// Create a copy of BackupState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? currentEmail = freezed,Object? isBackingUp = null,Object? isRestoring = null,Object? isDeleting = null,Object? autoBackup = null,Object? lastBackupDate = freezed,Object? autoBackupFrequency = null,}) {
  return _then(_BackupState(
currentEmail: freezed == currentEmail ? _self.currentEmail : currentEmail // ignore: cast_nullable_to_non_nullable
as String?,isBackingUp: null == isBackingUp ? _self.isBackingUp : isBackingUp // ignore: cast_nullable_to_non_nullable
as bool,isRestoring: null == isRestoring ? _self.isRestoring : isRestoring // ignore: cast_nullable_to_non_nullable
as bool,isDeleting: null == isDeleting ? _self.isDeleting : isDeleting // ignore: cast_nullable_to_non_nullable
as bool,autoBackup: null == autoBackup ? _self.autoBackup : autoBackup // ignore: cast_nullable_to_non_nullable
as bool,lastBackupDate: freezed == lastBackupDate ? _self.lastBackupDate : lastBackupDate // ignore: cast_nullable_to_non_nullable
as DateTime?,autoBackupFrequency: null == autoBackupFrequency ? _self.autoBackupFrequency : autoBackupFrequency // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
