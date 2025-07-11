// timer_type_selector.dart
import 'package:flutter/material.dart';
import 'package:minimaltodo/focustimer/timer/timer_controller.dart';

class TimerTypeSelector extends StatelessWidget {
  final TimerController controller;

  const TimerTypeSelector({super.key, required this.controller});

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
    final isSelected = controller.currentType == type;
    final isDisabled = !controller.isIdle;

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
      controller.switchToFocus();
    } else {
      controller.switchToBreak();
    }
  }
}