import 'package:flutter/material.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:minimaltodo/app/services/google_sign_in_service.dart';
import 'package:minimaltodo/app/state/value_notifiers.dart';
import 'package:minimaltodo/helpers/mini_box.dart';
import 'package:minimaltodo/helpers/mini_logger.dart';
import 'package:minimaltodo/helpers/utils.dart';
import 'package:toastification/toastification.dart';
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
  final ValueNotifier<String> currentEmail =
  ValueNotifier(MiniBox.read(mGoogleEmail) ?? 'Sign in');

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
              builder: (context, value, _) => Text(value),
            ),
            trailing: OutlinedButton.icon(
              onPressed: () {},
              label: Text('Backup'),
              icon: Icon(Icons.backup),
            ),
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            value: true,
            onChanged: (value) {},
            title: Text('Auto backup'),
            subtitle: Text('Last backup: 12 Feb 2025, 12:32 PM'),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton.icon(
                onPressed: () {},
                icon: Icon(Icons.settings_backup_restore_sharp),
                label: Text('Restore data'),
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
        ],
      ),
    );
  }

  Future<void> handleGoogleSignIn(BuildContext context) async {
    try {
      if (await _googleService.isSignedIn()) {
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
        if(context.mounted) {
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
              valueListenable: snoozeMinutes,
              builder: (context, value, child) {
                return ChoiceChip(
                  showCheckmark: false,
                  shape: StadiumBorder(),
                  label: Text('$minutes'),
                  selected: value == minutes,
                  onSelected: (selected) {
                    if (selected) {
                      updateSnoozeMinutes(minutes);
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
          valueListenable: defaultReminderType,
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
                updateDefaultReminder(selection.first);
              },
            );
          },
        ),
      ],
    );
  }
}
