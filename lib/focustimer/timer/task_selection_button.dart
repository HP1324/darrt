// task_selection_button.dart
import 'package:flutter/material.dart';
import 'package:minimaltodo/focustimer/timer/timer_controller.dart';
import 'package:minimaltodo/focustimer/timer/task_selection_dialog.dart';

class TaskSelectionButton extends StatelessWidget {
  final TimerController controller;

  const TaskSelectionButton({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: scheme.primaryContainer,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      shadowColor: scheme.shadow.withValues(alpha: 0.1),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => showTaskSelectionDialog(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: scheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.taskalt,
                  color: scheme.onPrimary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Select Tasks',
                style: textTheme.titleMedium?.copyWith(
                  color: scheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                color: scheme.onPrimaryContainer,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTaskSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => TaskSelectionDialog(controller: controller),
    );
  }
}