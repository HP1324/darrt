import 'package:darrt/app/services/toast_service.dart';
import 'package:darrt/habits/build/state/build_habit_state_controller.dart';
import 'package:darrt/habits/build/ui/editor/habit_text_field.dart';
import 'package:darrt/helpers/globals.dart' as g;
import 'package:darrt/helpers/utils.dart';
import 'package:flutter/material.dart';

class _TimePicker extends StatelessWidget {
  final TimeOfDay? initialTime;
  final Color accentColor;
  final Color backgroundColor;

  const _TimePicker({
    required this.initialTime,
    required this.accentColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Theme(
      data: theme.copyWith(
        colorScheme: theme.colorScheme.copyWith(
          primary: accentColor,
          onPrimary: Colors.white,
          secondary: accentColor,
          surface: backgroundColor,
          onSurface: theme.colorScheme.onSurface,
        ),
        timePickerTheme: TimePickerThemeData(
          backgroundColor: backgroundColor,
          hourMinuteTextColor: accentColor,
          hourMinuteColor: accentColor.withValues(alpha: 0.1),
          dayPeriodTextColor: accentColor,
          dayPeriodColor: accentColor.withValues(alpha: 0.1),
          dialHandColor: accentColor,
          dialBackgroundColor: backgroundColor,
          dialTextColor: theme.colorScheme.onSurface,
          entryModeIconColor: accentColor,
          hourMinuteTextStyle: theme.textTheme.headlineMedium?.copyWith(
            color: accentColor,
            fontWeight: FontWeight.bold,
          ),
          dayPeriodTextStyle: theme.textTheme.titleMedium?.copyWith(
            color: accentColor,
            fontWeight: FontWeight.w600,
          ),
          helpTextStyle: theme.textTheme.labelMedium?.copyWith(
            color: accentColor.withValues(alpha: 0.8),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          hourMinuteShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          dayPeriodShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: accentColor,
            textStyle: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      child: TimePickerDialog(
        initialTime: initialTime ?? TimeOfDay.now(),
      ),
    );
  }
}

class StartTimePicker extends StatefulWidget {
  const StartTimePicker();

  @override
  State<StartTimePicker> createState() => _StartTimePickerState();
}

class _StartTimePickerState extends State<StartTimePicker> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> _selectTime() async {
    g.buildHabitSc.textFieldNode.unfocus();
    final currentTime = g.buildHabitSc.startTime;

    final selectedTime = await showDialog<TimeOfDay>(
      context: context,
      builder: (context) {
        return ListenableBuilder(
          listenable: g.buildHabitSc,
          builder: (context, child) {
            final currentColor =
                getColorFromString(g.buildHabitSc.color) ?? Theme.of(context).colorScheme.primary;
            final currentBackgroundColor = getLerpedColor(context, currentColor);

            return _TimePicker(
              initialTime: TimeOfDay.fromDateTime(currentTime ?? DateTime.now()),
              accentColor: currentColor,
              backgroundColor: currentBackgroundColor,
            );
          },
        );
      },
    );

    if (selectedTime != null) {
      if (g.buildHabitSc.endTime != null &&
          !selectedTime.isBefore(TimeOfDay.fromDateTime(g.buildHabitSc.endTime!))) {
        if (mounted) {
          showErrorToast(context, 'Start time must be before end time');
        }
        return;
      }
      g.buildHabitSc.setStartTime(selectedTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.of(context);
    final color = getColorFromString(g.buildHabitSc.color) ?? scheme.primary;
    final hasStartTime = g.buildHabitSc.startTime != null;

    return HabitTextField(
      controller: g.buildHabitSc.startTimeController,
      labelText: 'Start time (Optional)',
      hintText: 'Not set',
      readOnly: true,
      onTap: _selectTime,
      suffixIcon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasStartTime) ...[
            IconButton(
              onPressed: g.buildHabitSc.resetStartTime,
              icon: Icon(Icons.clear, color: color),
              padding: EdgeInsets.zero,
            ),
          ] else ...[
            Icon(Icons.access_time, color: color, size: 20),
          ],
        ],
      ),
    );
  }
}

class EndTimePicker extends StatefulWidget {
  const EndTimePicker();

  @override
  State<EndTimePicker> createState() => _EndTimePickerState();
}

class _EndTimePickerState extends State<EndTimePicker> {
  Future<void> _selectTime() async {
    g.buildHabitSc.textFieldNode.unfocus();
    final currentEndTime = g.buildHabitSc.endTime;
    if (g.buildHabitSc.startTime == null) {
      showErrorToast(context, 'Set start time first!');
      return;
    }
    final selectedTime = await showDialog<TimeOfDay>(
      context: context,
      builder: (context) {
        return ListenableBuilder(
          listenable: g.buildHabitSc,
          builder: (context, child) {
            final scheme = ColorScheme.of(context);
            final currentColor = getColorFromString(g.buildHabitSc.color) ?? scheme.primary;
            final currentBackgroundColor = getLerpedColor(context, currentColor);

            return _TimePicker(
              initialTime: TimeOfDay.fromDateTime(currentEndTime ?? DateTime.now()),
              accentColor: currentColor,
              backgroundColor: currentBackgroundColor,
            );
          },
        );
      },
    );

    if (selectedTime != null) {
      if (!selectedTime.isAfter(TimeOfDay.fromDateTime(g.buildHabitSc.startTime!))) {
        if (mounted) {
          showErrorToast(context, 'End time must be before start time');
        }
        return;
      }
      g.buildHabitSc.setEndTime(selectedTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.of(context);
    final color = getColorFromString(g.buildHabitSc.color) ?? scheme.primary;
    final hasEndTime = g.buildHabitSc.endTime != null;

    return HabitTextField(
      controller: g.buildHabitSc.endTimeController,
      labelText: 'End time (Optional)',
      hintText: 'Not set',
      readOnly: true,
      onTap: _selectTime,
      suffixIcon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasEndTime) ...[
            IconButton(
              onPressed: g.buildHabitSc.resetEndTime,
              icon: Icon(Icons.clear, color: color),
              padding: EdgeInsets.zero,
            ),
          ] else ...[
            Icon(Icons.access_time, color: color, size: 20),
          ],
        ],
      ),
    );
  }
}