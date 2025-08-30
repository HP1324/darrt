// timer_type_selector.dart
import 'package:darrt/app/extensions/extensions.dart';
import 'package:darrt/focustimer/timer/timer_controller.dart';
import 'package:flutter/material.dart';

import '../../helpers/globals.dart' as g show timerController;

class TimerTypeSelector extends StatelessWidget {
  const TimerTypeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.of(context);

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TypeButton(label: 'Focus', type:TimerType.focus),
          const SizedBox(width: 4),
          TypeButton(label: 'Break', type: TimerType.timerBreak),
        ],
      ),
    );
  }
}

class TypeButton extends StatelessWidget {
  const TypeButton({super.key, required this.label, required this.type});

  final String label;
  final TimerType type;

  @override
  Widget build(BuildContext context) {
    final isSelected = g.timerController.currentType == type;
    final isDisabled = !g.timerController.isIdle;
    final scheme = context.colorScheme;
    final textTheme = context.textTheme;
    return Material(
      color: isSelected ? scheme.primary : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: isDisabled ? null : () => _selectType(type),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            label,
            style: textTheme.bodyMedium?.copyWith(
              color: isSelected
                  ? scheme.onPrimary
                  : isDisabled
                  ? scheme.onSurfaceVariant.withValues(alpha: 0.5)
                  : scheme.onSurfaceVariant,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  void _selectType(TimerType type) {
    if (type == TimerType.focus) {
      g.timerController.switchToFocus();
    } else {
      g.timerController.switchToBreak();
    }
  }
}
