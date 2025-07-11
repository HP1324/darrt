// duration_selector.dart
import 'package:flutter/material.dart';
import 'package:minimaltodo/focustimer/timer/timer_controller.dart';

class DurationSelector extends StatelessWidget {
  final TimerController controller;

  const DurationSelector({super.key, required this.controller});

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
            onTap: controller.isIdle ? () => _showDurationPicker(context) : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Text(
                _formatDuration(controller.currentDuration),
                style: textTheme.bodyMedium?.copyWith(
                  color: controller.isIdle
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
        controller: controller,
        initialDuration: controller.currentDuration,
      ),
    );
  }
}

class DurationPickerDialog extends StatefulWidget {
  final TimerController controller;
  final int initialDuration;

  const DurationPickerDialog({
    super.key,
    required this.controller,
    required this.initialDuration,
  });

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
        'Set ${widget.controller.timerTypeLabel} Duration',
        style: textTheme.headlineSmall?.copyWith(
          color: scheme.onSurface,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${_selectedMinutes} minutes',
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
            if (widget.controller.currentType == TimerType.focus) {
              widget.controller.setFocusDuration(seconds);
            } else {
              widget.controller.setBreakDuration(seconds);
            }
            Navigator.pop(context);
          },
          child: Text('Set'),
        ),
      ],
    );
  }
}