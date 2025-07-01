import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:minimaltodo/app/exceptions.dart';
import 'package:minimaltodo/app/services/backup_service.dart';
import 'package:minimaltodo/app/services/google_sign_in_service.dart';
import 'package:minimaltodo/helpers/globals.dart' as g;
import 'package:minimaltodo/helpers/mini_box.dart';
import 'package:minimaltodo/helpers/mini_logger.dart';
import 'package:minimaltodo/helpers/utils.dart';
import 'package:toastification/toastification.dart';
import 'package:workmanager/workmanager.dart';
import '../../helpers/consts.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';

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
              BackupRestoreSection(),
            ],
          ),
        ),
      ),
    );
  }
}

class BackupRestoreSection extends StatefulWidget {
  const BackupRestoreSection({super.key});

  @override
  State<BackupRestoreSection> createState() => _BackupRestoreSectionState();
}

class _BackupRestoreSectionState extends State<BackupRestoreSection> {
  final GoogleSignInService _googleService = GoogleSignInService();

  final ValueNotifier<String> currentEmail = ValueNotifier(
    MiniBox.read(mGoogleEmail) ?? tapHereToSignIn,
  );

  final ValueNotifier<bool> isBackingUp = ValueNotifier(false);

  final ValueNotifier<bool> isRestoring = ValueNotifier(false);

  @override
  void dispose() {
    currentEmail.dispose();
    isBackingUp.dispose();
    isRestoring.dispose();
    super.dispose();
  }

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
                onChanged: (value) async {
                  if (value != null) {
                    g.settingsSc.updateAutoBackup(value);
                    if (value) {
                      // await Workmanager().registerPeriodicTask('auto_backup', 'auto_backup', frequency: Duration(minutes: 15));
                      await Workmanager().registerOneOffTask(
                        'auto_backup',
                        'auto_backup',
                        initialDelay: Duration(seconds: 5),
                      );
                    } else {
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
                            } on GoogleClientNotAuthenticatedError catch (e) {
                              if (context.mounted) {
                                showToast(
                                  context,
                                  type: ToastificationType.error,
                                  description: e.userMessage!,
                                );
                              }
                            } on InternetOffError catch (e) {
                              if (context.mounted) {
                                showToast(
                                  context,
                                  type: ToastificationType.error,
                                  description: e.userMessage!,
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
                  currentEmail.value = tapHereToSignIn;
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
          currentEmail.value = tapHereToSignIn;
          MiniBox.remove(mGoogleEmail);
          if (context.mounted) {
            showSignInToast(context, ToastificationType.warning, 'Signed out');
          }
          await Future.delayed(Duration(milliseconds: 900));
        }
      }

      final GoogleSignInAccount? account = await _googleService.signIn();

      if (account != null) {
        final email = account.email;
        currentEmail.value = email;
        showSignInToast(context, ToastificationType.success, 'Signed in to $email');
        await MiniBox.write(mGoogleEmail, email);
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
  const _BackupButton();

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
                  if (!await InternetConnection().hasInternetAccess && context.mounted) {
                    showToast(
                      context,
                      type: ToastificationType.error,
                      description: 'No internet connection',
                    );
                    return;
                  }
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
                    } on GoogleClientNotAuthenticatedError catch (e) {
                      if (context.mounted) {
                        showToast(
                          context,
                          type: ToastificationType.error,
                          description: e.userMessage!,
                        );
                      }
                    } on InternetOffError catch (e) {
                      if (context.mounted) {
                        showToast(
                          context,
                          type: ToastificationType.error,
                          description: e.userMessage!,
                        );
                      }
                    } finally {
                      if (context.mounted) {
                        isBackingUp.value = false;
                      }
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
  const _DeleteBackupSection();

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
                          } on GoogleClientNotAuthenticatedError catch (e) {
                            if (context.mounted) {
                              showToast(
                                context,
                                type: ToastificationType.error,
                                description: e.userMessage!,
                              );
                            }
                          } on InternetOffError catch (e) {
                            if (context.mounted) {
                              showToast(
                                context,
                                type: ToastificationType.error,
                                description: e.userMessage!,
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
