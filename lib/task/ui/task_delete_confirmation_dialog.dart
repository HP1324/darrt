import 'package:darrt/app/services/toast_service.dart';
import 'package:darrt/helpers/globals.dart' as g;
import 'package:flutter/material.dart';

class TaskDeleteConfirmationDialog extends StatelessWidget {
  const TaskDeleteConfirmationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
      title: const Text('Delete Tasks'),
      content: const Text('Are you sure you want to delete these tasks?'),
      actions: [
        FilledButton(
          onPressed: () {
            final message = g.taskVm.deleteMultipleItems();
            Navigator.pop(context);
            if (context.mounted) {
              showSuccessToast(context, message);
            }
          },
          style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(theme.colorScheme.error)),
          child: const Text('Delete'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            g.taskVm.clearSelection();
          },
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}