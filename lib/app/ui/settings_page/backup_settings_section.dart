//ignore_for_file: curly_braces_in_flow_control_structures
import 'package:darrt/app/ui/settings_page/backup_provider.dart';
import 'package:darrt/app/ui/settings_page/backup_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:darrt/helpers/utils.dart' show formatDate;



// UI Components
class BackupSettingsSection extends ConsumerWidget {
  const BackupSettingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

class SignInSection extends ConsumerWidget {
  const SignInSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final backupState = ref.watch(backupNotifierProvider);
    final backupNotifier = ref.read(backupNotifierProvider.notifier);

    if (backupState.currentEmail == null) {
      return ListTile(
        title: Text('Sign in to continue'),
        trailing: OutlinedButton.icon(
          onPressed: backupState.isAnyOperationInProgress 
              ? null 
              : () => backupNotifier.signIn(context),
          label: Text('Sign in'),
          icon: Icon(Icons.login),
        ),
        contentPadding: EdgeInsets.zero,
      );
    }

    return ListTile(
      visualDensity: VisualDensity.compact,
      onTap: backupState.isAnyOperationInProgress 
          ? null 
          : () => backupNotifier.signIn(context),
      contentPadding: EdgeInsets.zero,
      title: Text('Google Account'),
      subtitle: Text(backupState.currentEmail!),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          BackupButton(),
          Tooltip(
            message: 'Sign out',
            child: IconButton(
              onPressed: backupState.isAnyOperationInProgress 
                  ? null 
                  : () => backupNotifier.signOut(context),
              icon: Icon(
                Icons.logout,
                color: backupState.isAnyOperationInProgress
                    ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)
                    : Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BackupButton extends ConsumerWidget {
  const BackupButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final backupState = ref.watch(backupNotifierProvider);
    final backupNotifier = ref.read(backupNotifierProvider.notifier);

    return Tooltip(
      message: 'Backup',
      child: IconButton(
        onPressed: backupState.isAnyOperationInProgress
            ? null
            : () => backupNotifier.performBackup(context),
        icon: backupState.isBackingUp
            ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator())
            : Icon(
                Icons.backup,
                color: backupState.isAnyOperationInProgress
                    ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)
                    : Theme.of(context).colorScheme.primary,
              ),
      ),
    );
  }
}

class AutoBackupSection extends ConsumerWidget {
  const AutoBackupSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final backupState = ref.watch(backupNotifierProvider);
    final backupNotifier = ref.read(backupNotifierProvider.notifier);

    return Column(
      children: [
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
          value: backupState.autoBackup,
          onChanged: backupState.isAnyOperationInProgress
              ? null
              : (value) {
                  if (value != null) {
                    backupNotifier.toggleAutoBackup(value, context);
                  }
                },
          title: Text('Auto backup'),
          subtitle: Text(
            backupState.lastBackupDate != null
                ? 'Last backup: ${formatDate(backupState.lastBackupDate!, 'dd/MM/yyyy')}'
                : 'Backup has not been done yet',
          ),
        ),
        if (backupState.autoBackup) AutoBackupFrequencySelector(),
      ],
    );
  }
}

class AutoBackupFrequencySelector extends ConsumerWidget {
  const AutoBackupFrequencySelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final backupState = ref.watch(backupNotifierProvider);
    final backupNotifier = ref.read(backupNotifierProvider.notifier);
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
            _buildRadioButton(context, ref, 'Daily', backupState.autoBackupFrequency),
            Container(
              width: 1,
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
              margin: const EdgeInsets.symmetric(vertical: 4),
            ),
            _buildRadioButton(context, ref, 'Weekly', backupState.autoBackupFrequency),
            Container(
              width: 1,
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
              margin: const EdgeInsets.symmetric(vertical: 4),
            ),
            _buildRadioButton(context, ref, 'Monthly', backupState.autoBackupFrequency),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioButton(BuildContext context, WidgetRef ref, String label, String currentFrequency) {
    final backupState = ref.watch(backupNotifierProvider);
    final backupNotifier = ref.read(backupNotifierProvider.notifier);

    return Flexible(
      child: InkWell(
        onTap: backupState.isAnyOperationInProgress
            ? null
            : () => backupNotifier.changeAutoBackupFrequency(label.toLowerCase()),
        borderRadius: BorderRadius.circular(6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Radio<String>(
              value: label.toLowerCase(),
              onChanged: backupState.isAnyOperationInProgress
                  ? null
                  : (value) {
                      if (value != null) {
                        backupNotifier.changeAutoBackupFrequency(value);
                      }
                    },
              groupValue: currentFrequency,
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            Flexible(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 13,
                  color: backupState.isAnyOperationInProgress
                      ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)
                      : null,
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
}

class RestoreSection extends ConsumerWidget {
  const RestoreSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final backupState = ref.watch(backupNotifierProvider);
    final backupNotifier = ref.read(backupNotifierProvider.notifier);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: backupState.isAnyOperationInProgress
              ? null
              : () => backupNotifier.performRestore(context),
          icon: const Icon(Icons.settings_backup_restore_sharp),
          label: backupState.isRestoring
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : FittedBox(child: const Text('Restore data')),
        ),
      ),
    );
  }
}

class DeleteBackupSection extends ConsumerWidget {
  const DeleteBackupSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final backupState = ref.watch(backupNotifierProvider);
    final backupNotifier = ref.read(backupNotifierProvider.notifier);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: backupState.isAnyOperationInProgress
              ? null
              : () => backupNotifier.deleteBackup(context),
          icon: backupState.isDeleting
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(
                  Icons.delete,
                  color: backupState.isAnyOperationInProgress
                      ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)
                      : Theme.of(context).colorScheme.error,
                  size: 20,
                ),
          label: FittedBox(child: Text('Delete backup')),
        ),
      ),
    );
  }
}