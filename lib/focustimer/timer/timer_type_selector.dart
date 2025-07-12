// timer_type_selector.dart
import 'package:flutter/material.dart';
import 'package:minimaltodo/focustimer/timer/timer_controller.dart';

import '../../helpers/globals.dart' as g show timerController;

class TimerTypeSelector extends StatelessWidget {

  const TimerTypeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTypeButton(
            context,
            'Focus',
            TimerType.focus,
            scheme,
            textTheme,
          ),
          const SizedBox(width: 4),
          _buildTypeButton(
            context,
            'Break',
            TimerType.timerBreak,
            scheme,
            textTheme,
          ),
        ],
      ),
    );
  }

  Widget _buildTypeButton(
      BuildContext context,
      String label,
      TimerType type,
      ColorScheme scheme,
      TextTheme textTheme,
      ) {
    final isSelected = g.timerController.currentType == type;
    final isDisabled = !g.timerController.isIdle;

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