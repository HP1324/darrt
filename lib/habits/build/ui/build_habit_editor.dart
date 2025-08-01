import 'package:darrt/app/services/toast_service.dart';
import 'package:darrt/category/models/entity_category.dart';
import 'package:darrt/habits/build/models/build_habit.dart';
import 'package:darrt/habits/build/state/build_habit_state_controller.dart';
import 'package:darrt/helpers/globals.dart' as g;
import 'package:darrt/helpers/utils.dart';
import 'package:flutter/material.dart';

class BuildHabitEditor extends StatefulWidget {
  const BuildHabitEditor({super.key, required this.edit, this.habit, this.category})
    : assert(!edit || habit != null);

  final BuildHabit? habit;
  final bool edit;

  final EntityCategory? category;
  @override
  State<BuildHabitEditor> createState() => _BuildHabitEditorState();
}

class _BuildHabitEditorState extends State<BuildHabitEditor> {
  @override
  void initState() {
    super.initState();
    g.buildHabitSc.initState(widget.edit, widget.habit, widget.category);
  }

  @override
  void dispose() {
    debugPrint("dispose called");
    g.buildHabitSc.clearState();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: g.buildHabitSc,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: getLerpedColor(context, getColorFromString(g.buildHabitSc.color)),
          appBar: AppBar(
            backgroundColor: getLerpedColor(context, getColorFromString(g.buildHabitSc.color)),
            leading: BackButton(),
            title: FittedBox(child: Text(widget.edit ? widget.habit!.name : 'Build A New Habit')),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Column(
                spacing: 20,
                children: [
                  const SizedBox(),
                  Row(
                    children: [
                      Expanded(child: _HabitNameField()),
                      const SizedBox(width: 12),
                      _HabitColorPicker(),
                    ],
                  ),
                  _HabitDescriptionField(),
                  Row(
                    spacing: 8,
                    children: [
                      Expanded(child: _StartDatePicker()),
                      Expanded(child: _EndDatePicker()),
                    ],
                  ),
                  _MeasurementTypeSelector(),
                  AnimatedSwitcher(
                    duration: Duration(milliseconds: 300),
                    child: g.buildHabitSc.measurementType == MeasurementType.boolean
                        ? Row(
                            spacing: 8,
                            children: [
                              Expanded(child: _StartTimePicker()),
                              Expanded(child: _EndTimePicker()),
                            ],
                          )
                        : SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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

class _HabitNameField extends StatelessWidget {
  const _HabitNameField({super.key});

  @override
  Widget build(BuildContext context) {
    return _HabitTextField(
      controller: g.buildHabitSc.textController,
      focusNode: g.buildHabitSc.textFieldNode,
      autoFocus: true,
      labelText: 'Habit Name',
    );
  }
}

class _HabitColorPicker extends StatelessWidget {
  const _HabitColorPicker({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.of(context);
    final color = getColorFromString(g.buildHabitSc.color) ?? scheme.primary;

    return Container(
      height: 56,
      width: 56,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: scheme.outline,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            g.buildHabitSc.textFieldNode.unfocus();
            showColorPicker(
              context,
              onColorSelected: (color) {
                g.buildHabitSc.setColor(color);
                Navigator.pop(context);
              },
            );
          },
        ),
      ),
    );
  }
}

class _HabitDescriptionField extends StatelessWidget {
  const _HabitDescriptionField({super.key});

  @override
  Widget build(BuildContext context) {
    return _HabitTextField(
      controller: g.buildHabitSc.descriptionController,
      focusNode: g.buildHabitSc.descriptionFocusNode,
      autoFocus: false,
      labelText: 'Description (Optional)',
      hintText: "Why is this habit important to you?",
    );
  }
}

class _MeasurementTypeSelector extends StatelessWidget {
  const _MeasurementTypeSelector();

  @override
  Widget build(BuildContext context) {
    final textTheme = TextTheme.of(context);
    final scheme = ColorScheme.of(context);
    final color = getColorFromString(g.buildHabitSc.color) ?? scheme.primary;
    final type = g.buildHabitSc.measurementType;

    return Column(
      spacing: 8,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Track progress with',
          style: textTheme.titleSmall?.copyWith(color: color, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<MeasurementType>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment<MeasurementType>(
                value: MeasurementType.boolean,
                label: Text('Yes/No'),
              ),
              ButtonSegment<MeasurementType>(
                value: MeasurementType.count,
                label: Text('Numeric Value'),
              ),
            ],
            selected: {type},
            onSelectionChanged: (Set<MeasurementType> newSelection) {
              g.buildHabitSc.setMeasurementType(newSelection.first);
            },
            style: SegmentedButton.styleFrom(
              backgroundColor: Colors.transparent,
              selectedBackgroundColor: color.withValues(alpha: 0.2),
              selectedForegroundColor: color,
              foregroundColor: scheme.onSurface,
              side: BorderSide(color: color.withValues(alpha: 0.5)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
      ],
    );
  }
}

class _HabitTextField extends StatelessWidget {
  const _HabitTextField({
    this.controller,
    required this.labelText,
    this.focusNode,
    this.autoFocus = false,
    this.hintText,
    this.enabled,
    this.keyboardType,
    this.readOnly = false,
    this.onTap,
    this.suffixIcon,
  });
  final TextEditingController? controller;
  final String labelText;
  final FocusNode? focusNode;
  final bool autoFocus;
  final String? hintText;
  final bool? enabled;
  final TextInputType? keyboardType;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.of(context);
    final color = getColorFromString(g.buildHabitSc.color) ?? scheme.primary;

    return TextField(
      keyboardType: keyboardType,
      controller: controller,
      focusNode: focusNode,
      enabled: enabled,
      readOnly: readOnly,
      autofocus: autoFocus,
      onTap: onTap,
      decoration: InputDecoration(
        hintText: hintText,
        labelText: labelText,
        suffixIcon: suffixIcon,
        labelStyle: TextStyle(color: color),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: color),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: color),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: color, width: 2),
        ),
      ),
    );
  }
}

class _StartDatePicker extends StatefulWidget {
  const _StartDatePicker();

  @override
  State<_StartDatePicker> createState() => _StartDatePickerState();
}

class _StartDatePickerState extends State<_StartDatePicker> {
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

    return _HabitTextField(
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

class _EndDatePicker extends StatefulWidget {
  const _EndDatePicker();

  @override
  State<_EndDatePicker> createState() => _EndDatePickerState();
}

class _EndDatePickerState extends State<_EndDatePicker> {
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

    return _HabitTextField(
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

class _StartTimePicker extends StatefulWidget {
  const _StartTimePicker();

  @override
  State<_StartTimePicker> createState() => _StartTimePickerState();
}

class _StartTimePickerState extends State<_StartTimePicker> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> _selectTime() async {
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

    return _HabitTextField(
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

class _EndTimePicker extends StatefulWidget {
  const _EndTimePicker();

  @override
  State<_EndTimePicker> createState() => _EndTimePickerState();
}

class _EndTimePickerState extends State<_EndTimePicker> {
  Future<void> _selectTime() async {
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

    return _HabitTextField(
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
