// completion_actions.dart
import 'package:flutter/material.dart';
import 'package:darrt/focustimer/timer/timer_controller.dart';

class CompletionActions extends StatelessWidget {
  final TimerController controller;

  const CompletionActions({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.celebration,
            size: 32,
            color: scheme.onTertiaryContainer,
          ),
          const SizedBox(height: 8),
          Text(
            '${controller.timerTypeLabel} Complete!',
            style: textTheme.titleMedium?.copyWith(
              color: scheme.onTertiaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FilledButton.tonal(
                onPressed: controller.continueAfterCompletion,
                child: Text('Continue'),
              ),
              FilledButton(
                onPressed: () {
                  // Switch to break if focus completed, or focus if break completed
                  if (controller.currentType == TimerType.focus) {
                    controller.switchToBreak();
                  } else {
                    controller.switchToFocus();
                  }
                },
                child: Text(
                  controller.currentType == TimerType.focus
                      ? 'Take Break'
                      : 'Start Focus',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}