import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:minimaltodo/app/exceptions.dart';
import 'package:minimaltodo/app/services/backup_service.dart';
import 'package:minimaltodo/app/services/google_sign_in_service.dart';
import 'package:minimaltodo/app/state/controllers/settings_state_controller.dart';
import 'package:minimaltodo/helpers/globals.dart' as g;
import 'package:minimaltodo/helpers/mini_box.dart';
import 'package:minimaltodo/helpers/mini_logger.dart';
import 'package:minimaltodo/helpers/object_box.dart';
import 'package:minimaltodo/helpers/utils.dart';
import 'package:restart_app/restart_app.dart';
import 'package:toastification/toastification.dart';
import 'package:workmanager/workmanager.dart';
import '../../helpers/consts.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            spacing: 18,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DefaultReminderTypeSection(),
              Divider(),
              SnoozeSection(),
              Divider(),
              DriveBackupSection(),
            ],
          ),
        ),
      ),
    );
  }
}

class DriveBackupSection extends StatefulWidget {
  const DriveBackupSection({super.key});

  @override
  State<DriveBackupSection> createState() => _DriveBackupSectionState();
}

class _DriveBackupSectionState extends State<DriveBackupSection> {
  final GoogleSignInService _googleService = GoogleSignInService();

  final ValueNotifier<String> currentEmail = ValueNotifier(MiniBox.read(mGoogleEmail) ?? 'Sign in');

  final ValueNotifier<bool> isBackingUp = ValueNotifier(false);

  final ValueNotifier<bool> isRestoring = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Backup & Restore', style: Theme.of(context).textTheme.titleMedium),
          Divider(height: 0),
          ListTile(
            visualDensity: VisualDensity.compact,
            onTap: () => handleGoogleSignIn(context),
            contentPadding: EdgeInsets.zero,
            title: Text('Google Account'),
            subtitle: ValueListenableBuilder(
              valueListenable: currentEmail,
              builder: (context, value, _) {
                return Text(value);
              },
            ),
            trailing: _BackupButton(),
          ),
          ListenableBuilder(
            listenable: Listenable.merge([g.settingsSc.autoBackUp, g.settingsSc.lastBackupDate]),
            builder: (context, child) {
              final autoBackup = g.settingsSc.autoBackUp.value;
              final lastBackupDate = g.settingsSc.lastBackupDate.value;
              return CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                value: autoBackup,
                onChanged: (value) async{
                  if (value != null) {
                    g.settingsSc.updateAutoBackup(value);
                    if (value) {
                      // await Workmanager().registerPeriodicTask('auto_backup', 'auto_backup', frequency: Duration(minutes: 15));
                      await Workmanager().registerOneOffTask('auto_backup', 'auto_backup', initialDelay: Duration(seconds: 5));
                    }else{
                      await Workmanager().cancelByUniqueName('auto_backup');
                    }
                  }
                },
                title: Text('Auto backup'),
                subtitle: Text(
                  lastBackupDate != null
                      ? 'Last backup: ${formatDate(lastBackupDate, 'dd/MM/yyyy')}'
                      : 'Backup has not been done yet',
                ),
              );
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ValueListenableBuilder<bool>(
                valueListenable: isRestoring,
                builder: (context, restoring, _) {
                  return OutlinedButton.icon(
                    onPressed: restoring
                        ? null
                        : () async {
                            isRestoring.value = true;
                            try {
                              final backupFile = await BackupService()
                                  .downloadCompressedFileFromGoogleDrive();
                              await BackupService().restoreDataFromBackupFile(backupFile);

                              if (context.mounted) {
                                //Rationale dialog to restart the app using restart_app package
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text('Restart app'),
                                    content: Text(
                                      "Restore completed. Don't forget to restart the app to see restored data correctly.",
                                    ),
                                    actions: [
                                      FilledButton.icon(
                                        onPressed: () async {
                                          // ObjectBox.store.close();
                                          // if(ObjectBox.store.isClosed()) {
                                          //   await Restart.restartApp();
                                          // }
                                          Navigator.pop(context);
                                        },
                                        label: Text('Got it'),
                                        icon: Icon(Icons.restart_alt),
                                      ),
                                    ],
                                  ),
                                );
                                // showToast(
                                //   context,
                                //   type: ToastificationType.success,
                                //   description: 'Restore completed successfully',
                                // );
                              }
                            } on BackupFileNotFoundError catch (e) {
                              if (context.mounted) {
                                showToast(
                                  context,
                                  type: ToastificationType.error,
                                  description: e.userMessage!,
                                );
                              }
                            } catch (e, t) {
                              MiniLogger.e('Error restoring data: ${e.toString()}');
                              MiniLogger.t('Stacktrace: $t');
                              if (context.mounted) {
                                showToast(
                                  context,
                                  type: ToastificationType.error,
                                  description: 'Restore failed',
                                );
                              }
                            } finally {
                              isRestoring.value = false;
                            }
                          },
                    icon: const Icon(Icons.settings_backup_restore_sharp),
                    label: restoring
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Restore data'),
                  );
                },
              ),
              OutlinedButton.icon(
                onPressed: () async {
                  await _googleService.signOut();
                  currentEmail.value = 'Sign in';
                  MiniBox.remove(mGoogleEmail);
                  if (context.mounted) {
                    showSignInToast(
                      context,
                      ToastificationType.warning,
                      'Signed out of Google account',
                    );
                  }
                },
                icon: Icon(Icons.logout, color: Theme.of(context).colorScheme.error),
                label: Text(
                  'Sign out',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ],
          ),
          //Widget to delete backup from google drive
          _DeleteBackupSection(),
        ],
      ),
    );
  }

  Future<void> handleGoogleSignIn(BuildContext context) async {
    try {
      if (await _googleService.getCurrentUserEmail() != null) {
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

          await _googleService.signOut();
          currentEmail.value = 'Sign in';
          MiniBox.remove(mGoogleEmail);
          showSignInToast(context, ToastificationType.warning, 'Signed out');
          await Future.delayed(Duration(milliseconds: 900));
        }
      }

      final account = await _googleService.signIn();
      if (account != null) {
        final email = account.email;
        currentEmail.value = email;
        await MiniBox.write(mGoogleEmail, email);
        if (context.mounted) {
          showSignInToast(context, ToastificationType.success, 'Signed in to $email');
        }

        final client = await _googleService.getAuthenticatedClient();
        if (client != null) {
          final userDrive = drive.DriveApi(client);
          // Use userDrive for backup operations
        }
      }
    } catch (e, t) {
      MiniLogger.e('Sign in error: ${e.toString()}');
      MiniLogger.t('Stacktrace: $t');
    }
  }

  void showSignInToast(context, type, description) {
    showToast(
      context,
      type: type,
      description: description,
      duration: Duration(milliseconds: 1700),
    );
  }
}

class SnoozeSection extends StatelessWidget {
  const SnoozeSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Snooze for (in minutes)',
              style: theme.textTheme.titleMedium,
            ),
          ],
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [1, 5, 10, 15, 20, 25, 30, 45, 50, 60].map((minutes) {
            return ValueListenableBuilder(
              valueListenable: g.settingsSc.snoozeMinutes,
              builder: (context, value, child) {
                return ChoiceChip(
                  showCheckmark: false,
                  shape: StadiumBorder(),
                  label: Text('$minutes'),
                  selected: value == minutes,
                  onSelected: (selected) {
                    if (selected) {
                      g.settingsSc.updateSnoozeMinutes(minutes);
                    }
                  },
                );
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}

class DefaultReminderTypeSection extends StatelessWidget {
  const DefaultReminderTypeSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      spacing: 10,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Default reminder type', style: theme.textTheme.titleMedium),
        ValueListenableBuilder(
          valueListenable: g.settingsSc.defaultReminderType,
          builder: (context, value, child) {
            return SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'notif',
                  label: Text('Notification'),
                  icon: Icon(Icons.notifications),
                ),
                ButtonSegment(
                  value: 'alarm',
                  label: Text('Alarm'),
                  icon: Icon(Icons.alarm),
                ),
              ],
              selected: {value},
              onSelectionChanged: (Set<String> selection) {
                g.settingsSc.updateDefaultReminder(selection.first);
              },
            );
          },
        ),
      ],
    );
  }
}

class _BackupButton extends StatefulWidget {
  const _BackupButton({super.key});

  @override
  State<_BackupButton> createState() => _BackupButtonState();
}

class _BackupButtonState extends State<_BackupButton> {
  final ValueNotifier<bool> isBackingUp = ValueNotifier(false);

  @override
  void dispose() {
    isBackingUp.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isBackingUp,
      builder: (context, backingUp, _) {
        return OutlinedButton.icon(
          onPressed: backingUp
              ? null // optional: disable button while backing up
              : () async {
                  final backupService = BackupService();
                  if (await GoogleSignInService().isSignedIn()) {
                    isBackingUp.value = true;
                    try {
                      final backupFile = await backupService.generateBackupJsonFile();
                      await backupService.uploadFileToGoogleDrive(backupFile);
                      if (context.mounted) {
                        showToast(
                          context,
                          type: ToastificationType.success,
                          description: 'Backup successful',
                        );
                      }
                      g.settingsSc.updateLastBackupDate(DateTime.now());
                    } catch (e) {
                      if (context.mounted) {
                        showToast(
                          context,
                          type: ToastificationType.error,
                          description: 'Backup failed',
                        );
                      }
                    } finally {
                      isBackingUp.value = false;
                    }
                  }
                },
          icon: const Icon(Icons.backup),
          label: backingUp
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Backup'),
        );
      },
    );
  }
}

class _DeleteBackupSection extends StatefulWidget {
  const _DeleteBackupSection({super.key});

  @override
  State<_DeleteBackupSection> createState() => _DeleteBackupSectionState();
}

class _DeleteBackupSectionState extends State<_DeleteBackupSection> {
  final ValueNotifier<bool> isDeleting = ValueNotifier(false);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.error.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          'Delete Backup',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        trailing: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ValueListenableBuilder<bool>(
            valueListenable: isDeleting,
            builder: (context, deleting, child) {
              return IconButton(
                onPressed: deleting
                    ? null
                    : () async {
                        // Disable button while deleting
                        final shouldDelete = await _showDeleteConfirmationDialog(context);
                        if (shouldDelete) {
                          isDeleting.value = true;
                          try {
                            await BackupService().deleteBackupFromGoogleDrive();
                            if (context.mounted) {
                              showToast(
                                context,
                                type: ToastificationType.success,
                                description: 'Backup deleted successfully.',
                              );
                            }
                          } on BackupFileNotFoundError catch (e) {
                            if (context.mounted) {
                              showToast(
                                context,
                                type: ToastificationType.error,
                                description: e.message!,
                              );
                            }
                          } finally {
                            isDeleting.value = false; // Use finally to ensure it's always reset
                          }
                        }
                      },
                icon: deleting
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
                tooltip: 'Delete backup',
              );
            },
          ),
        ),
      ),
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
