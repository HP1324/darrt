import 'package:darrt/app/exceptions.dart';
import 'package:darrt/app/services/auto_backup_service.dart';
import 'package:darrt/app/services/backup_service.dart';
import 'package:darrt/app/services/google_sign_in_service.dart';
import 'package:darrt/app/services/mini_box.dart';
import 'package:darrt/app/services/toast_service.dart';
import 'package:darrt/helpers/consts.dart';
import 'package:darrt/helpers/mini_logger.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:workmanager/workmanager.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import './backup_state.dart';
part 'backup_provider.g.dart';

@riverpod
class BackupNotifier extends _$BackupNotifier {
  @override
  BackupState build() {
    final email = GoogleSignInService().currentUser?.email;
    final autoBackup = MiniBox().read(mAutoBackup) ?? false;
    final lastBackupDate = MiniBox().read(mLastBackupDate); // Already DateTime
    final frequency = MiniBox().read(mAutoBackupFrequency) ?? 'daily';

    return BackupState(
      currentEmail: email,
      autoBackup: autoBackup,
      lastBackupDate: lastBackupDate,
      autoBackupFrequency: frequency,
    );
  }

  Future<void> signIn(BuildContext context) async {
    if (state.isAnyOperationInProgress) return;

    try {
      if (await GoogleSignInService().getCurrentUserEmail() != null) {
        if (context.mounted) {
          final shouldContinue = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              content: Text('Sign out and sign in with another account?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text('No'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text('Yes'),
                ),
              ],
            ),
          );

          if (shouldContinue != true) return;
          await _signOut(context);
          await Future.delayed(Duration(milliseconds: 500));
        }
      }

      GoogleSignInAccount? account = await GoogleSignInService().signIn();

      if (account != null) {
        final email = account.email;
        if (context.mounted) showSuccessToast(context, 'Signed in to $email');
        MiniBox().write(mGoogleEmail, email);
        state = state.copyWith(currentEmail: email);

        final authentication = await account.authentication;
        MiniBox().write(mGoogleAuthToken, authentication.accessToken);
      } else {
        MiniBox().write(mAutoBackup, false);
        state = state.copyWith(autoBackup: false);
      }
    } catch (e, t) {
      MiniLogger.e('Sign in error: ${e.toString()}');
      MiniLogger.t('Stacktrace: $t');
    }
  }

  Future<void> signOut(BuildContext context) async {
    if (state.isAnyOperationInProgress) return;
    await _signOut(context);
  }

  Future<void> _signOut(BuildContext context) async {
    state = state.copyWith(autoBackup: false, currentEmail: null);
    if (context.mounted) showWarningToast(context, 'Signed out');
    MiniBox().write(mAutoBackup, false);
    await Workmanager().cancelByUniqueName(mAutoBackup);
    await GoogleSignInService().signOut();
    MiniBox().remove(mGoogleEmail);
  }

  Future<void> performBackup(BuildContext context) async {
    if (state.isAnyOperationInProgress) return;

    state = state.copyWith(isBackingUp: true);
    try {
      await BackupService().performBackup();
      if (context.mounted) {
        showSuccessToast(context, 'Backup completed successfully');
      }
      final now = DateTime.now();
      MiniBox().write(mLastBackupDate, now);
      state = state.copyWith(lastBackupDate: now);
    } on GoogleClientNotAuthenticatedError catch (e) {
      if (context.mounted) showErrorToast(context, e.userMessage!);
    } on InternetOffError catch (e) {
      if (context.mounted) showSuccessToast(context, e.userMessage!);
    } catch (e) {
      MiniLogger.e('${e.toString()}, type: ${e.runtimeType}');
      if (context.mounted) {
        showErrorToast(context, 'Unknown error occurred, try after sometime!');
      }
    } finally {
      state = state.copyWith(isBackingUp: false);
    }
  }

  Future<void> toggleAutoBackup(bool value, BuildContext context) async {
    if (state.isAnyOperationInProgress) return;

    try {
      if (GoogleSignInService().currentUser == null) {
        throw GoogleClientNotAuthenticatedError();
      }

      MiniBox().write(mAutoBackup, value);
      state = state.copyWith(autoBackup: value);

      if (value) {
        final frequency = state.autoBackupFrequency;
        Duration backupDuration = frequency == 'daily'
            ? Duration(minutes: 15)
            : frequency ==  'weekly'
            ? Duration(minutes: 20)
            : Duration(minutes: 25);
        MiniLogger.dp('Registering background task: frequency: $frequency, duration: $backupDuration');
        final ms = DateTime.now().millisecondsSinceEpoch;
        await registerAutoBackup(
          mAutoBackup,
          mAutoBackup,
          existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
          constraints: Constraints(networkType: NetworkType.connected),
          initialDelay: Duration(minutes: 15),
          frequency: backupDuration,
        );
        MiniLogger.dp(
          'Is work registered: ${await Workmanager().isScheduledByUniqueName(mAutoBackup)}',
        );
      } else {
        MiniLogger.dp('Cancelling background task');
        await cancelAutoBackup();
      }
    } on GoogleClientNotAuthenticatedError {
      if (context.mounted) showErrorToast(context, 'Sign in to continue!');
    }
  }

  Future<void> changeAutoBackupFrequency(String newFrequency) async {
    if (state.isAnyOperationInProgress) return;
    state = state.copyWith(autoBackupFrequency: newFrequency);

    final backupDuration = newFrequency == 'daily'
        ? Duration(minutes: 15)
        : newFrequency == 'weekly'
        ? Duration(minutes: 20)
        : Duration(minutes: 25);

    final ms = DateTime.now().millisecondsSinceEpoch;
    await registerAutoBackup(
      mAutoBackup,
      mAutoBackup,
      constraints: Constraints(networkType: NetworkType.connected),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
      frequency: backupDuration,
    );
    MiniLogger.dp('Is task replaced: ${await Workmanager().isScheduledByUniqueName(mAutoBackup)}');
    MiniBox().write(mAutoBackupFrequency, newFrequency);
  }

  Future<void> performRestore(BuildContext context) async {
    if (state.isAnyOperationInProgress) return;

    state = state.copyWith(isRestoring: true);
    try {
      await BackupService().performRestore();
      if (context.mounted) {
        await _showRestartDialog(context);
      }
    } on BackupFileNotFoundError catch (e) {
      if (context.mounted) showErrorToast(context, e.userMessage!);
    } on GoogleClientNotAuthenticatedError catch (e) {
      if (context.mounted) showErrorToast(context, e.userMessage!);
    } on InternetOffError catch (e) {
      if (context.mounted) showErrorToast(context, e.userMessage!);
    } finally {
      state = state.copyWith(isRestoring: false);
    }
  }

  Future<void> deleteBackup(BuildContext context) async {
    if (state.isAnyOperationInProgress) return;

    final shouldDelete = await _showDeleteConfirmationDialog(context);
    if (!shouldDelete) return;

    state = state.copyWith(isDeleting: true);
    try {
      await BackupService().deleteBackupFromGoogleDrive();
      if (context.mounted) {
        showSuccessToast(context, 'Backup deleted successfully');
      }
    } on BackupFileNotFoundError catch (e) {
      if (context.mounted) showErrorToast(context, e.userMessage!);
    } on GoogleClientNotAuthenticatedError catch (e) {
      if (context.mounted) showErrorToast(context, e.userMessage!);
    } on InternetOffError catch (e) {
      if (context.mounted) showErrorToast(context, e.userMessage!);
    } finally {
      state = state.copyWith(isDeleting: false);
    }
  }

  Future<bool> _showDeleteConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Theme.of(context).colorScheme.error,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  const Text('Delete Backup?'),
                ],
              ),
              content: const Text(
                'This will permanently delete your backup from Google Drive. This action cannot be undone.',
              ),
              actions: [
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                  child: const Text('Delete'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  Future<void> _showRestartDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Restart app'),
        content: Text(
          "Restore completed. Don't forget to restart the app to see restored data correctly.",
        ),
        actions: [
          FilledButton.icon(
            onPressed: () => Navigator.pop(context),
            label: Text('Got it'),
            icon: Icon(Icons.restart_alt),
          ),
        ],
      ),
    );
  }
}
