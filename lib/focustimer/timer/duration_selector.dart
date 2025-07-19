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
  late int _selectedHours;
  late int _selectedMinutes;

  @override
  void initState() {
    super.initState();
    // Convert initial duration from seconds to hours, minutes
    final totalSeconds = widget.initialDuration;
    _selectedHours = totalSeconds ~/ 3600;
    _selectedMinutes = (totalSeconds % 3600) ~/ 60;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Set Duration'),
      content: SizedBox(
        height: 200,
        child: Row(
          spacing: 10,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Hours picker
            Expanded(
              child: Column(
                children: [
                  const Text('Hours', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListWheelScrollView.useDelegate(
                      controller: FixedExtentScrollController(
                        initialItem: _selectedHours,
                      ),
                      itemExtent: 40,
                      perspective: 0.005,
                      diameterRatio: 1.2,
                      physics: const FixedExtentScrollPhysics(),
                      childDelegate: ListWheelChildBuilderDelegate(
                        childCount: 24, // 0-23 hours
                        builder: (context, index) {
                          final isSelected = index == _selectedHours;
                          return Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Theme.of(context).primaryColor.withOpacity(0.1)
                                  : null,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              index.toString().padLeft(2, '0'),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected
                                    ? Theme.of(context).primaryColor
                                    : null,
                              ),
                            ),
                          );
                        },
                      ),
                      onSelectedItemChanged: (index) {
                        setState(() {
                          _selectedHours = index;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Minutes picker
            Expanded(
              child: Column(
                children: [
                  const Text('Minutes', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListWheelScrollView.useDelegate(
                      controller: FixedExtentScrollController(
                        initialItem: _selectedMinutes,
                      ),
                      itemExtent: 40,
                      perspective: 0.005,
                      diameterRatio: 1.2,
                      physics: const FixedExtentScrollPhysics(),
                      childDelegate: ListWheelChildBuilderDelegate(
                        childCount: 60, // 0-59 minutes
                        builder: (context, index) {
                          final isSelected = index == _selectedMinutes;
                          return Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Theme.of(context).primaryColor.withOpacity(0.1)
                                  : null,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              index.toString().padLeft(2, '0'),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected
                                    ? Theme.of(context).primaryColor
                                    : null,
                              ),
                            ),
                          );
                        },
                      ),
                      onSelectedItemChanged: (index) {
                        setState(() {
                          _selectedMinutes = index;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final totalSeconds = (_selectedHours * 3600) + (_selectedMinutes * 60);
             _selectedMinutes = totalSeconds ~/ 60;

            final seconds = _selectedMinutes * 60;
            if (g.timerController.currentType == TimerType.focus) {
              g.timerController.setFocusDuration(seconds);
            } else {
              g.timerController.setBreakDuration(seconds);
            }
            Navigator.pop(context);
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}