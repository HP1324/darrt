import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:minimaltodo/app/state/value_notifiers.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart'
    as auth;
import 'package:minimaltodo/helpers/mini_box.dart';
import 'package:minimaltodo/helpers/mini_logger.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as auth;
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
  ValueNotifier<String> currentEmail = ValueNotifier(MiniBox.read(mGoogleEmail) ?? 'Sign in');
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        spacing: 0,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Backup & Restore', style: Theme.of(context).textTheme.titleMedium),
          Divider(height: 0),
          ListTile(
            visualDensity: VisualDensity.compact,
            onTap: () {
              signInToGoogle(context);
            },
            contentPadding: EdgeInsets.zero,
            title: Text('Google Account'),
            subtitle: ValueListenableBuilder(
              valueListenable: currentEmail,
              builder: (context, value, widget) {
                return Text(value);
              },
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
              OutlinedButton.icon(onPressed: (){}, label: Text('Restore data'),icon: Icon(Icons.settings_backup_restore_sharp)),
              OutlinedButton.icon(onPressed: (){}, label: Text('Sign out',style: TextStyle(color: Theme.of(context).colorScheme.error))),
            ],
          ),
        ],
      ),
    );
  }

  final signIn = GoogleSignIn(
    // clientId: googleClientId,
    scopes: [drive.DriveApi.driveFileScope],
  );
  dynamic signInToGoogle(BuildContext context) async {
    try {
      GoogleSignInAccount? account;
      if (await signIn.isSignedIn()) {
        if (context.mounted) {
          await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: Text('Sign out of current account and sign in to another account?'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('No'),
                  ),
                  FilledButton(
                    onPressed: () async {

                      pop() {
                        Navigator.pop(context);
                      }

                      await signIn.signOut();
                      currentEmail.value = 'Sign in';
                      if(context.mounted) {
                        showSignInToast(
                          context,
                          ToastificationType.warning,
                          'Signed out of google account',
                        );
                      }
                      await Future.delayed(Duration(milliseconds: 1000));

                      account = await signIn.signIn();
                      if (account != null) {
                        currentEmail.value = signIn.currentUser?.email ?? '';
                        debugPrint('context mounted ${context.mounted}');
                        if (context.mounted) {
                          showSignInToast(
                              context,
                              ToastificationType.success,
                              'Signed in to ${account?.email}'
                          );
                        }
                      }
                      pop();
                      await MiniBox.write(mGoogleEmail, currentEmail.value);

                      debugPrint('account null: ${account == null}');
                    },
                    child: Text('Yes'),
                  ),
                ],
              );
            },
          );
        }
      } else {
        account = await signIn.signIn();
      }
      if (account != null) {
        await MiniBox.write(mGoogleEmail, signIn.currentUser?.email);
        currentEmail.value = signIn.currentUser?.email ?? '';
        final client = await signIn.authenticatedClient();
        if (client != null) {
          // final userDrive = drive.DriveApi(client);
          // userDrive.files.create(drive.File(name: 'minitodo_backup.json'));
        }
      } else {
        debugPrint('Client is null');
      }
    } catch (e, t) {
      MiniLogger.e(
        'Error signing in: ${(e as PlatformException).toString()}, type: ${e.runtimeType}',
      );
      MiniLogger.t('Stacktrace: ${t.toString()}');
    }
  }

  Future<String> getCurrentUserEmail() async {
    final email = MiniBox.read(mGoogleEmail);
    return Future.value(email);
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
