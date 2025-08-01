import 'package:darrt/habits/build/state/build_habit_state_controller.dart';
import 'package:darrt/habits/build/ui/editor/habit_text_field.dart';
import 'package:darrt/helpers/globals.dart' as g;
import 'package:darrt/helpers/utils.dart';
import 'package:flutter/material.dart';

class StartDatePicker extends StatefulWidget {
  const StartDatePicker();

  @override
  State<StartDatePicker> createState() => _StartDatePickerState();
}

class _StartDatePickerState extends State<StartDatePicker> {
  Future<void> _selectDate() async {
    final currentDate = g.buildHabitSc.startDate;
    final endDate = g.buildHabitSc.endDate;

    final selectedDate = await showDialog<DateTime>(
      context: context,
      builder: (context) {
        return ListenableBuilder(
          listenable: g.buildHabitSc,
          builder: (context, child) {
            final currentColor =
                getColorFromString(g.buildHabitSc.color) ?? Theme.of(context).colorScheme.primary;
            final currentBackgroundColor = getLerpedColor(context, currentColor);

            return _DatePicker(
              initialDate: currentDate,
              firstDate: getFirstDate(),
              lastDate: endDate?.subtract(Duration(days: 1)) ?? getMaxDate(),
              accentColor: currentColor,
              backgroundColor: currentBackgroundColor,
            );
          },
        );
      },
    );

    if (selectedDate != null) {
      g.buildHabitSc.setStartDate(selectedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.of(context);
    final color = getColorFromString(g.buildHabitSc.color) ?? scheme.primary;

    return HabitTextField(
      labelText: 'Start date',
      readOnly: true,
      onTap: _selectDate,
      suffixIcon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!DateUtils.isSameDay(g.buildHabitSc.startDate, DateTime.now())) ...[
            IconButton(
              onPressed: () {
                g.buildHabitSc.resetStartDate();
              },
              icon: Icon(Icons.clear, color: color),
              padding: EdgeInsets.zero,
            ),
          ] else ...[
            Icon(Icons.calendar_today, color: color, size: 20),
          ],
        ],
      ),
    );
  }
}

class EndDatePicker extends StatefulWidget {
  const EndDatePicker();

  @override
  State<EndDatePicker> createState() => _EndDatePickerState();
}

class _EndDatePickerState extends State<EndDatePicker> {
  late final TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
    _updateDateText();
  }

  void _updateDateText() {
    final endDate = g.buildHabitSc.endDate;
    controller.text = endDate != null ? formatDateNoJm(endDate, 'dd/MM/yyyy') : '';
  }

  Future<void> _selectDate() async {
    final startDate = g.buildHabitSc.startDate;
    final currentEndDate = g.buildHabitSc.endDate;

    final selectedDate = await showDialog(
      context: context,
      builder: (context) {
        return ListenableBuilder(
          listenable: g.buildHabitSc,
          builder: (context, child) {
            final currentColor =
                getColorFromString(g.buildHabitSc.color) ?? Theme.of(context).colorScheme.primary;
            final currentBackgroundColor = getLerpedColor(context, currentColor);

            return _DatePicker(
              initialDate: currentEndDate ?? startDate.add(Duration(days: 7)),
              firstDate: startDate.add(Duration(days: 1)),
              lastDate: getMaxDate(),
              accentColor: currentColor,
              backgroundColor: currentBackgroundColor,
            );
          },
        );
      },
    );

    if (selectedDate != null) {
      g.buildHabitSc.setEndDate(selectedDate);
      _updateDateText();
    }
  }

  void _clearDate() {
    g.buildHabitSc.setEndDate(null);
    _updateDateText();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.of(context);
    final color = getColorFromString(g.buildHabitSc.color) ?? scheme.primary;
    final hasEndDate = g.buildHabitSc.endDate != null;

    return HabitTextField(
      controller: controller,
      labelText: 'End date (Optional)',
      hintText: 'Not set',
      readOnly: true,
      onTap: _selectDate,
      suffixIcon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasEndDate) ...[
            IconButton(
              onPressed: _clearDate,
              icon: Icon(Icons.clear, color: color),
              padding: EdgeInsets.zero,
            ),
          ] else ...[
            Icon(Icons.calendar_today, color: color, size: 20),
          ],
        ],
      ),
    );
  }
}

class _DatePicker extends StatelessWidget {
  final DateTime? initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final Color accentColor;
  final Color backgroundColor;

  const _DatePicker({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
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
        datePickerTheme: DatePickerThemeData(
          backgroundColor: backgroundColor,
          headerBackgroundColor: accentColor.withValues(alpha: 0.1),
          headerForegroundColor: accentColor,
          headerHeadlineStyle: theme.textTheme.headlineSmall?.copyWith(
            color: accentColor,
            fontWeight: FontWeight.bold,
          ),
          headerHelpStyle: theme.textTheme.labelMedium?.copyWith(
            color: accentColor.withValues(alpha: 0.8),
          ),
          weekdayStyle: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            fontWeight: FontWeight.w600,
          ),
          dayStyle: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
          dayForegroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.white;
            }
            if (states.contains(WidgetState.disabled)) {
              return theme.colorScheme.onSurface.withValues(alpha: 0.38);
            }
            return theme.colorScheme.onSurface;
          }),
          dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return accentColor;
            }
            if (states.contains(WidgetState.hovered)) {
              return accentColor.withValues(alpha: 0.08);
            }
            return null;
          }),
          todayForegroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.white;
            }
            return accentColor;
          }),
          todayBackgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return accentColor;
            }
            return null;
          }),
          todayBorder: BorderSide(color: accentColor, width: 1),
          yearStyle: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
          yearForegroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.white;
            }
            return theme.colorScheme.onSurface;
          }),
          yearBackgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return accentColor;
            }
            return null;
          }),
          rangePickerBackgroundColor: backgroundColor,
          rangePickerHeaderBackgroundColor: accentColor.withValues(alpha: 0.1),
          rangePickerHeaderForegroundColor: accentColor,
          rangeSelectionBackgroundColor: accentColor.withValues(alpha: 0.12),
          rangeSelectionOverlayColor: WidgetStateProperty.all(
            accentColor.withValues(alpha: 0.08),
          ),
          dividerColor: theme.colorScheme.outline.withValues(alpha: 0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
          shadowColor: Colors.black.withValues(alpha: 0.1),
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
      child: DatePickerDialog(
        initialDate: initialDate ?? DateTime.now(),
        firstDate: firstDate,
        lastDate: lastDate,
        initialCalendarMode: DatePickerMode.day,
      ),
    );
  }
}