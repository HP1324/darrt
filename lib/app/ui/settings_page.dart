import 'package:flutter/material.dart';
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
    MiniBox().read(mGoogleEmail) ?? tapHereToSignIn,
  );

  final ValueNotifier<bool> isBackingUp = ValueNotifier(false);

  final ValueNotifier<bool> isRestoring = ValueNotifier(false);

  final ValueNotifier<bool> autoBackUp = ValueNotifier(MiniBox().read(mAutoBackup) ?? false);

  void _updateAutoBackup(bool value) async {
    autoBackUp.value = value;
    await MiniBox().write(mAutoBackup, value);
  }

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
            listenable: Listenable.merge([autoBackUp, g.settingsSc.lastBackupDate]),
            builder: (context, child) {
              final autoBackup = autoBackUp.value;
              final lastBackupDate = g.settingsSc.lastBackupDate.value;
              return CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                value: autoBackup,
                onChanged: (value) async {
                  try {
                    if (GoogleSignInService().currentUser == null)
                      throw GoogleClientNotAuthenticatedError();
                    if (value != null) {
                      _updateAutoBackup(value);
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
                          frequency: Duration(seconds: 10),
                        );
                      } else {
                        MiniLogger.dp('Cancelling background task');
                        await Workmanager().cancelByUniqueName(mAutoBackup);
                      }
                    }
                  } on GoogleClientNotAuthenticatedError {
                    if (context.mounted) {
                      showToast(
                        context,
                        type: ToastificationType.error,
                        description: 'Sign in to continue',
                      );
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
          AutobackupFrequencySelector(autoBackup: autoBackUp),
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
                              await BackupService().performRestore();
                              if (context.mounted) {
                                await _showRestartDialog(context);
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
                  MiniBox().remove(mGoogleEmail);
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
          MiniBox().remove(mGoogleEmail);
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
        await MiniBox().write(mGoogleEmail, email);
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

class AutobackupFrequencySelector extends StatefulWidget {
  const AutobackupFrequencySelector({super.key, required this.autoBackup});

  final ValueNotifier<bool> autoBackup;
  @override
  State<AutobackupFrequencySelector> createState() => _AutobackupFrequencySelectorState();
}

class _AutobackupFrequencySelectorState extends State<AutobackupFrequencySelector> {
  String currentFrequency = MiniBox().read(mAutoBackupFrequency) ?? 'daily';

  void changeFrequency(String? newFrequency) async {
    if (newFrequency != null) {
      currentFrequency = newFrequency;
      setState(() {});

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
      await MiniBox().write(mAutoBackupFrequency, newFrequency);
    }
  }

  Widget buildRadioButton(String label) {
    return Flexible(
      child: InkWell(
        onTap: () => changeFrequency(label.toLowerCase()),
        borderRadius: BorderRadius.circular(6),
        child: Container(
          // padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Radio<String>(
                value: label.toLowerCase(),
                onChanged: changeFrequency,
                groupValue: currentFrequency,
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              // const SizedBox(width: 4),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.autoBackup,
      builder: (context, value, child) {
        if (!value) return const SizedBox.shrink();
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
                buildRadioButton('Daily'),
                Container(
                  width: 1,
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  margin: const EdgeInsets.symmetric(vertical: 4),
                ),
                buildRadioButton('Weekly'),
                Container(
                  width: 1,
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  margin: const EdgeInsets.symmetric(vertical: 4),
                ),
                buildRadioButton('Monthly'),
              ],
            ),
          ),
        );
      },
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
              'Snooze reminder for (in minutes)',
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
                  value: notifReminderType,
                  label: Text('Notification'),
                  icon: Icon(Icons.notifications),
                ),
                ButtonSegment(
                  value: alarmReminderType,
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
                  isBackingUp.value = true;
                  try {
                    await BackupService().performBackup();
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
                  } catch (e) {
                    MiniLogger.e('${e.toString()}, type: ${e.runtimeType}');
                    if (context.mounted) {
                      showToast(
                        context,
                        type: ToastificationType.error,
                        description: 'Unknown error occurred, try after sometime',
                      );
                    }
                  } finally {
                    if (context.mounted) {
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
