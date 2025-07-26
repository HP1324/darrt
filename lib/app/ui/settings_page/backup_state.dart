import 'package:freezed_annotation/freezed_annotation.dart';
part 'backup_state.freezed.dart';
@freezed
abstract class BackupState with _$BackupState {
  const factory BackupState({
    String? currentEmail,
    @Default(false) bool isBackingUp,
    @Default(false) bool isRestoring,
    @Default(false) bool isDeleting,
    @Default(false) bool autoBackup,
    DateTime? lastBackupDate,
    @Default('daily') String autoBackupFrequency,
  }) = _BackupState;
}

extension AccessBackupState on BackupState{
  bool get isAnyOperationInProgress => isBackingUp || isRestoring || isDeleting;

}
