//ignore_for_file: curly_braces_in_flow_control_structures
import 'package:darrt/app/services/boxpref.dart';
import 'package:darrt/app/services/object_box.dart';
import 'package:darrt/objectbox.g.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:darrt/app/exceptions.dart';
import 'package:darrt/app/services/backup_service.dart';
import 'package:darrt/app/services/google_sign_in_service.dart';
import 'package:darrt/app/services/mini_box.dart';
import 'package:darrt/app/services/toast_service.dart';
import 'package:darrt/helpers/consts.dart';
import 'package:darrt/helpers/mini_logger.dart';
import 'package:darrt/helpers/utils.dart' show formatDate;
import 'package:workmanager/workmanager.dart';

class BackupSettingsSection extends StatelessWidget {
  const BackupSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Backup & Restore', style: theme.textTheme.titleMedium),
          Divider(height: 0),
          SignInSection(),
          AutoBackupSection(),
          RestoreSection(),
          DeleteBackupSection(),
        ],
      ),
    );
  }
}

class SignInSection extends StatelessWidget {
  const SignInSection({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<BoxPref>>(
      stream: ObjectBox()
          .prefsBox
          .query(BoxPref_.key.equals(mGoogleEmail))
          .watch(triggerImmediately: true)
          .map((query) => query.find()),
      builder: (context, snapshot) {
        final prefs = snapshot.data;
        final currentEmail = prefs?.isNotEmpty == true ? prefs!.first.value : null;

        if (currentEmail == null) {
          return ListTile(
            title: Text('Sign in to continue'),
            trailing: OutlinedButton.icon(
              onPressed: () => _handleGoogleSignIn(context),
              label: Text('Sign in'),
              icon: Icon(Icons.login),
            ),
            contentPadding: EdgeInsets.zero,
          );
        }

        return ListTile(
          visualDensity: VisualDensity.compact,
          onTap: () => _handleGoogleSignIn(context),
          contentPadding: EdgeInsets.zero,
          title: Text('Google Account'),
          subtitle: Text(currentEmail),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              BackupButton(),
              Tooltip(
                message: 'Sign out',
                child: IconButton(
                  onPressed: () async {
                    MiniBox().write(mAutoBackup, false);
                    await Workmanager().cancelByUniqueName(mAutoBackup);
                    await GoogleSignInService().signOut();
                    MiniBox().remove(mGoogleEmail);
                    if (context.mounted) showWarningToast(context, 'Signed out');
                  },
                  icon: Icon(Icons.logout, color: Theme.of(context).colorScheme.error),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleGoogleSignIn(BuildContext context) async {
    try {
      if (await GoogleSignInService().getCurrentUserEmail() != null) {
        if (context.mounted) {
          final shouldContinue = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              content: Text('Sign out and sign in with another account?'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context, false), child: Text('No')),
                FilledButton(onPressed: () => Navigator.pop(context, true), child: Text('Yes')),
              ],
            ),
          );

          if (shouldContinue != true) return;
          await GoogleSignInService().signOut();
          MiniBox().remove(mGoogleEmail);
          if (context.mounted) showWarningToast(context, 'Signed out');
          await Future.delayed(Duration(milliseconds: 500));
        }
      }

      GoogleSignInAccount? account = await GoogleSignInService().signIn();

      if (account != null) {
        final email = account.email;
        if (context.mounted) showSuccessToast(context, 'Signed in to $email');
        MiniBox().write(mGoogleEmail, email);

        final authentication = await account.authentication;
        MiniBox().write(mGoogleAuthToken, authentication.accessToken);
      } else {
        MiniBox().write(mAutoBackup, false);
      }
    } catch (e, t) {
      MiniLogger.e('Sign in error: ${e.toString()}');
      MiniLogger.t('Stacktrace: $t');
    }
  }
}

class BackupButton extends StatelessWidget {
  const BackupButton({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<BoxPref>>(
      stream: ObjectBox()
          .prefsBox
          .query(BoxPref_.key.equals(mIsBackingUp))
          .watch(triggerImmediately: true)
          .map((query) => query.find()),
      builder: (context, snapshot) {
        final prefs = snapshot.data;
        final isBackingUp = prefs?.isNotEmpty == true && prefs!.first.value == 'true';

        return Tooltip(
          message: 'Backup',
          child: IconButton(
            onPressed: isBackingUp
                ? null
                : () async {
              MiniBox().write(mIsBackingUp, true);
              try {
                await BackupService().performBackup();
                if (context.mounted)
                  showSuccessToast(context, 'Backup completed successfully');
                final now = DateTime.now();
                MiniBox().write(mLastBackupDate, now);
              } on GoogleClientNotAuthenticatedError catch (e) {
                if (context.mounted) showErrorToast(context, e.userMessage!);
              } on InternetOffError catch (e) {
                if (context.mounted) showSuccessToast(context, e.userMessage!);
              } catch (e) {
                MiniLogger.e('${e.toString()}, type: ${e.runtimeType}');
                if (context.mounted)
                  showErrorToast(context, 'Unknown error occurred, try after sometime!');
              } finally {
                if (context.mounted) {
                  MiniBox().write(mIsBackingUp, false);
                }
              }
            },
            icon: isBackingUp
                ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator())
                : Icon(
              Icons.backup,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        );
      },
    );
  }
}

class AutoBackupSection extends StatelessWidget {
  const AutoBackupSection({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<BoxPref>>(
      stream: ObjectBox()
          .prefsBox
          .query(BoxPref_.key.equals(mAutoBackup))
          .watch(triggerImmediately: true)
          .map((query) => query.find()),
      builder: (context, snapshot) {
        final prefs = snapshot.data;
        final autoBackup = prefs?.isNotEmpty == true && prefs!.first.value == 'true';

        return Column(
          children: [
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
              value: autoBackup,
              onChanged: (value) async {
                try {
                  if (GoogleSignInService().currentUser == null)
                    throw GoogleClientNotAuthenticatedError();
                  if (value != null) {
                    MiniBox().write(mAutoBackup, value);
                    if (value) {
                      final frequency = MiniBox().read(mAutoBackupFrequency) ?? 'daily';
                      Duration duration = frequency == 'daily'
                          ? Duration(days: 1)
                          : frequency == 'weekly'
                          ? Duration(days: 7)
                          : Duration(days: 30);
                      MiniLogger.dp(
                        'Registering background task: frequency: $frequency, duration: $duration',
                      );
                      await Workmanager().registerPeriodicTask(
                        mAutoBackup,
                        mAutoBackup,
                        initialDelay: Duration(seconds: 5),
                        frequency: Duration(minutes: 15),
                      );
                    } else {
                      MiniLogger.dp('Cancelling background task');
                      await Workmanager().cancelByUniqueName(mAutoBackup);
                    }
                  }
                } on GoogleClientNotAuthenticatedError {
                  if (context.mounted) showErrorToast(context, 'Sign in to continue!');
                }
              },
              title: Text('Auto backup'),
              subtitle: StreamBuilder<List<BoxPref>>(
                stream: ObjectBox()
                    .prefsBox
                    .query(BoxPref_.key.equals(mLastBackupDate))
                    .watch(triggerImmediately: true)
                    .map((query) => query.find()),
                builder: (context, snapshot) {
                  final prefs = snapshot.data;
                  final lastBackupDateMs = prefs?.isNotEmpty == true
                      ? prefs!.first.value
                      : null;
                  DateTime? lastBackupDate;
                  if(lastBackupDateMs != null) {
                     lastBackupDate = DateTime.fromMillisecondsSinceEpoch(
                        int.parse(lastBackupDateMs));
                  }
                  return Text(
                    lastBackupDate != null
                        ? 'Last backup: ${formatDate(lastBackupDate, 'dd/MM/yyyy')}'
                        : 'Backup has not been done yet',
                  );
                },
              ),
            ),
            if (autoBackup) AutoBackupFrequencySelector(),
          ],
        );
      },
    );
  }
}

class AutoBackupFrequencySelector extends StatelessWidget {
  const AutoBackupFrequencySelector({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<BoxPref>>(
      stream: ObjectBox()
          .prefsBox
          .query(BoxPref_.key.equals(mAutoBackupFrequency))
          .watch(triggerImmediately: true)
          .map((query) => query.find()),
      builder: (context, snapshot) {
        final prefs = snapshot.data;
        final currentFrequency = prefs?.isNotEmpty == true ? prefs!.first.value : 'daily';

        final theme = Theme.of(context);
        return Container(
          margin: const EdgeInsets.all(5),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: IntrinsicHeight(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildRadioButton(context, 'Daily', currentFrequency),
                Container(
                  width: 1,
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  margin: const EdgeInsets.symmetric(vertical: 4),
                ),
                _buildRadioButton(context, 'Weekly', currentFrequency),
                Container(
                  width: 1,
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  margin: const EdgeInsets.symmetric(vertical: 4),
                ),
                _buildRadioButton(context, 'Monthly', currentFrequency),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRadioButton(BuildContext context, String label, String? currentFrequency) {
    return Flexible(
      child: InkWell(
        onTap: () => _changeFrequency(label.toLowerCase()),
        borderRadius: BorderRadius.circular(6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Radio<String>(
              value: label.toLowerCase(),
              onChanged: _changeFrequency,
              groupValue: currentFrequency,
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            Flexible(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _changeFrequency(String? newFrequency) async {
    if (newFrequency != null) {
      final duration = newFrequency == 'daily'
          ? Duration(days: 1)
          : newFrequency == 'weekly'
          ? Duration(days: 7)
          : Duration(days: 30);
      await Workmanager().cancelByUniqueName(mAutoBackup);
      await Workmanager().registerPeriodicTask(
        mAutoBackup,
        mAutoBackup,
        frequency: duration,
      );
      MiniBox().write(mAutoBackupFrequency, newFrequency);
    }
  }
}

class RestoreSection extends StatelessWidget {
  const RestoreSection({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<BoxPref>>(
      stream: ObjectBox()
          .prefsBox
          .query(BoxPref_.key.equals(mIsRestoring))
          .watch(triggerImmediately: true)
          .map((query) => query.find()),
      builder: (context, snapshot) {
        final prefs = snapshot.data;
        final isRestoring = prefs?.isNotEmpty == true && prefs!.first.value == 'true';

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: isRestoring
                  ? null
                  : () async {
                MiniBox().write(mIsRestoring, true);
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
                  MiniBox().write(mIsRestoring, false);
                }
              },
              icon: const Icon(Icons.settings_backup_restore_sharp),
              label: isRestoring
                  ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : FittedBox(child: const Text('Restore data')),
            ),
          ),
        );
      },
    );
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

class DeleteBackupSection extends StatelessWidget {
  const DeleteBackupSection({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<BoxPref>>(
      stream: ObjectBox()
          .prefsBox
          .query(BoxPref_.key.equals(mIsDeleting))
          .watch(triggerImmediately: true)
          .map((query) => query.find()),
      builder: (context, snapshot) {
        final prefs = snapshot.data;
        final isDeleting = prefs?.isNotEmpty == true && prefs!.first.value == 'true';

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: isDeleting
                  ? null
                  : () async {
                final shouldDelete = await _showDeleteConfirmationDialog(context);
                if (shouldDelete) {
                  MiniBox().write(mIsDeleting, true);
                  try {
                    await BackupService().deleteBackupFromGoogleDrive();
                    if (context.mounted)
                      showSuccessToast(context, 'Backup deleted successfully');
                  } on BackupFileNotFoundError catch (e) {
                    if (context.mounted) showErrorToast(context, e.userMessage!);
                  } on GoogleClientNotAuthenticatedError catch (e) {
                    if (context.mounted) showErrorToast(context, e.userMessage!);
                  } on InternetOffError catch (e) {
                    if (context.mounted) showErrorToast(context, e.userMessage!);
                  } finally {
                    MiniBox().write(mIsDeleting, false);
                  }
                }
              },
              icon: isDeleting
                  ? const SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : Icon(
                Icons.delete,
                color: Theme.of(context).colorScheme.error,
                size: 20,
              ),
              label: FittedBox(child: Text('Delete backup')),
            ),
          ),
        );
      },
    );
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
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ),
          ],
        );
      },
    ) ??
        false;
  }
}