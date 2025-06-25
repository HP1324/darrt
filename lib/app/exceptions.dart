import 'package:minimaltodo/app/services/backup_service.dart' show backupFileZipName;

class BackupFileNotFoundError implements Exception {
  String? message;
  String? userMessage;
  BackupFileNotFoundError([
    this.message = 'No backup file "$backupFileZipName" found in Google Drive.',
    this.userMessage = 'No backup found in Google Drive.',
  ]);
}

class InternetOffError implements Exception {
  final String message;
  InternetOffError(this.message);
}

class GoogleClientNotAuthenticatedError implements Exception {
  String? message;
  String? userMessage;
  GoogleClientNotAuthenticatedError([this.message = 'Google client not authenticated', this.userMessage = 'Please Sign in to continue']);
}
