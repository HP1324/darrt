// duration_selector.dart
import 'package:flutter/material.dart';
import 'package:darrt/focustimer/timer/timer_controller.dart';

import '../../helpers/globals.dart' as g show timerController;

class DurationSelector extends StatelessWidget {
  const DurationSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Duration: ',
          style: textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        Material(
          color: scheme.surfaceContainer,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: g.timerController.isIdle ? () => _showDurationPicker(context) : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Text(
                _formatDuration(g.timerController.currentDuration),
                style: textTheme.bodyMedium?.copyWith(
                  color: g.timerController.isIdle
                      ? scheme.primary
                      : scheme.onSurfaceVariant.withValues(alpha: 0.5),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    return '${minutes}m';
  }

  void _showDurationPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => DurationPickerDialog(
        initialDuration: g.timerController.currentDuration,
      ),
    );
  }
}

class DurationPickerDialog extends StatefulWidget {
  final int initialDuration;

  const DurationPickerDialog({super.key, required this.initialDuration});

  @override
  State<DurationPickerDialog> createState() => _DurationPickerDialogState();
}

class _DurationPickerDialogState extends State<DurationPickerDialog> {
  late int _selectedMinutes;

  @override
  void initState() {
    super.initState();
    _selectedMinutes = widget.initialDuration ~/ 60;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.of(context);
    final textTheme = Theme.of(context).textTheme;

    return AlertDialog(
      title: Text(
        'Set ${g.timerController.timerTypeLabel} Duration',
        style: textTheme.headlineSmall?.copyWith(
          color: scheme.onSurface,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$_selectedMinutes minutes',
            style: textTheme.headlineMedium?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Slider(
            value: _selectedMinutes.toDouble(),
            min: 1,
            max: 120,
            divisions: 119,
            onChanged: (value) {
              setState(() {
                _selectedMinutes = value.round();
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final seconds = _selectedMinutes * 60;
            if (g.timerController.currentType == TimerType.focus) {
              g.timerController.setFocusDuration(seconds);
            } else {
              g.timerController.setBreakDuration(seconds);
            }
            Navigator.pop(context);
          },
          child: Text('Set'),
        ),
      ],
    );
  }
}
