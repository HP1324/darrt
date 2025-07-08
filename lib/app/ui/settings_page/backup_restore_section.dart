//ignore_for_file: curly_braces_in_flow_control_structures
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:minimaltodo/app/exceptions.dart';
import 'package:minimaltodo/app/services/backup_service.dart';
import 'package:minimaltodo/app/services/google_sign_in_service.dart';
import 'package:minimaltodo/app/services/mini_box.dart';
import 'package:minimaltodo/app/services/toast_service.dart';
import 'package:minimaltodo/helpers/consts.dart';
import 'package:minimaltodo/helpers/mini_logger.dart';
import 'package:minimaltodo/helpers/utils.dart' show formatDate;
import 'package:workmanager/workmanager.dart';

class BackupRestoreSection extends StatefulWidget {
  const BackupRestoreSection({super.key});

  @override
  State<BackupRestoreSection> createState() => _BackupRestoreSectionState();
}

class _BackupRestoreSectionState extends State<BackupRestoreSection> {
  final ValueNotifier<DateTime?> lastBackupDate = ValueNotifier(
    MiniBox().read(mLastBackupDate) != null
        ? DateTime.fromMillisecondsSinceEpoch(MiniBox().read(mLastBackupDate))
        : null,
  );

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
          SignInOutBackupRow(lastBackupDate: lastBackupDate),
          AutoBackupSection(lastBackupDate: lastBackupDate),
        ],
      ),
    );
  }
}

class AutoBackupSection extends StatefulWidget {
  const AutoBackupSection({super.key, required this.lastBackupDate});
  final ValueNotifier<DateTime?> lastBackupDate;
  @override
  State<AutoBackupSection> createState() => _AutoBackupSectionState();
}

class _AutoBackupSectionState extends State<AutoBackupSection> {
  bool autoBackup = MiniBox().read(mAutoBackup) ?? false;
  @override
  Widget build(BuildContext context) {
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
                setState(() {
                  autoBackup = value;
                });
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
                  await Workmanager().registerOneOffTask(
                    mAutoBackup,
                    mAutoBackup,
                    initialDelay: Duration(seconds: 5),
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
          subtitle: ValueListenableBuilder(
            valueListenable: widget.lastBackupDate,
            builder: (context, value, child) {
              return Text(
                value != null
                    ? 'Last backup: ${formatDate(value, 'dd/MM/yyyy')}'
                    : 'Backup has not been done yet',
              );
            },
          ),
        ),
        if (autoBackup) AutobackupFrequencySelector(),
      ],
    );
  }
}

class AutobackupFrequencySelector extends StatefulWidget {
  const AutobackupFrequencySelector({super.key});

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
    );
  }

  @override
  Widget build(BuildContext context) {
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
  }
}

class SignInOutBackupRow extends StatefulWidget {
  const SignInOutBackupRow({super.key, required this.lastBackupDate});
  final ValueNotifier<DateTime?> lastBackupDate;
  @override
  State<SignInOutBackupRow> createState() => _SignInOutBackupRowState();
}

class _SignInOutBackupRowState extends State<SignInOutBackupRow> {
  String? currentEmail;

  @override
  void initState() {
    super.initState();
    final account = GoogleSignInService().currentUser;
    if (account != null) {
      currentEmail = account.email;
    }
  }

  @override
  Widget build(BuildContext context) {
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
      subtitle: Text(currentEmail!),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _BackupButton(lastBackupDate: widget.lastBackupDate),
          Tooltip(
            message: 'Sign out',
            child: IconButton(
              onPressed: () async {
                setState(() {
                  currentEmail = null;
                });
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
          setState(() {
            currentEmail = null;
          });
          await GoogleSignInService().signOut();

          MiniBox().remove(mGoogleEmail);
          if (context.mounted) showWarningToast(context, 'Signed out');

          await Future.delayed(Duration(milliseconds: 500));
        }
      }

      GoogleSignInAccount? account = await GoogleSignInService().signIn();

      if (account != null) {
        final email = account.email;
        setState(() {
          currentEmail = email;
        });
        if (context.mounted) showSuccessToast(context, 'Signed in to $email');
        await MiniBox().write(mGoogleEmail, email);

        final authentication = await account.authentication;
        await MiniBox().write(mGoogleAuthToken, authentication.accessToken);
      }
    } catch (e, t) {
      MiniLogger.e('Sign in error: ${e.toString()}');
      MiniLogger.t('Stacktrace: $t');
    }
  }
}

class _BackupButton extends StatefulWidget {
  const _BackupButton({required this.lastBackupDate});
  final ValueNotifier<DateTime?> lastBackupDate;

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
        return Tooltip(
          message: 'Backup',
          child: IconButton(
            onPressed: backingUp
                ? null // optional: disable button while backing up
                : () async {
                    isBackingUp.value = true;
                    try {
                      await BackupService().performBackup();
                      if (context.mounted)
                        showSuccessToast(context, 'Backup completed successfully');
                      widget.lastBackupDate.value = DateTime.now();
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
                        isBackingUp.value = false;
                      }
                    }
                  },
            icon: backingUp
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
