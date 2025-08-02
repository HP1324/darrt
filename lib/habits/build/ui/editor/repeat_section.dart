import 'package:darrt/habits/build/state/build_habit_state_controller.dart';
import 'package:darrt/helpers/globals.dart' as g;
import 'package:darrt/helpers/utils.dart';
import 'package:flutter/material.dart';

class RepeatTypeSelector extends StatelessWidget {
  const RepeatTypeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: g.buildHabitSc,
      builder: (context, child) {
        final config = g.buildHabitSc.repeatConfig;
        final selectedType = config.type ?? 'weekly';

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Make the radio options expand to fill available space
            Expanded(
              flex: 5,
              child: Card(
                color: getLerpedColor(context, getColorFromString(g.buildHabitSc.color)),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Theme.of(context).dividerColor),
                ),
                child: Row(
                  children: [
                    // Each option takes equal space within the card
                    Expanded(
                      child: _buildRadioOption(context, 'Weekly', 'weekly', selectedType),
                    ),
                    Expanded(
                      child: _buildRadioOption(context, 'Monthly', 'monthly', selectedType),
                    ),
                    Expanded(
                      child: _buildRadioOption(context, 'Yearly', 'yearly', selectedType),
                    ),
                  ],
                ),
              ),
            ),
            // Help button takes less space
            RepeatTypeHelpButton(),
          ],
        );
      },
    );
  }

  Widget _buildRadioOption(BuildContext context, String label, String value, String selectedType) {
    final isSelected = value == selectedType;
    final theme = Theme.of(context);
    final habitColor = getColorFromString(g.buildHabitSc.color) ?? theme.colorScheme.primary;

    // Make the tap area cover the entire width of each section
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => g.buildHabitSc.setRepeatType(value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Use visualDensity to make radio buttons more compact if needed
          Radio<String>(
            value: value,
            groupValue: selectedType,
            onChanged: (val) => g.buildHabitSc.setRepeatType(val!),
            visualDensity: VisualDensity.compact,
            activeColor: habitColor, // Custom active color
            fillColor: MaterialStateProperty.resolveWith<Color>((states) {
              if (states.contains(MaterialState.selected)) {
                return habitColor; // Fill color when selected
              }
              return theme.colorScheme.outline; // Default border color when not selected
            }),
          ),
          // Use shorter text when width is limited
          Flexible(
            child: FittedBox(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? habitColor : theme.textTheme.bodyLarge?.color,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RepeatTypeHelpButton extends StatelessWidget {
  const RepeatTypeHelpButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      // borderRadius: BorderRadius.circular(16),
      onPressed: () {
        g.buildHabitSc.textFieldNode.unfocus();
        _showRepeatTypeDialog(context);
      },
      icon: Icon(Icons.info_outline),
    );
  }

  void _showRepeatTypeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ListenableBuilder(
        listenable: g.buildHabitSc,
        builder: (context, child) {
          final colorScheme = Theme.of(context).colorScheme;
          final textTheme = Theme.of(context).textTheme;
          final habitColor = getColorFromString(g.buildHabitSc.color) ?? colorScheme.primary;

          return AlertDialog(
            backgroundColor: colorScheme.surface,
            surfaceTintColor: Colors.transparent,
            title: Row(
              children: [
                Icon(Icons.repeat_rounded, color: habitColor),
                const SizedBox(width: 12),
                Text(
                  'Repeat Options',
                  style: textTheme.titleLarge?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRepeatTypeSection(
                      context: context,
                      title: 'Weekly',
                      icon: Icons.view_week_rounded,
                      description:
                      'Select specific days of the week for your task to repeat on. At least one day must be selected',
                      habitColor: habitColor,
                    ),
                    _buildWeeklyExample(context, habitColor),
                    const Divider(),
                    _buildRepeatTypeSection(
                      context: context,
                      title: 'Monthly',
                      icon: Icons.calendar_month_rounded,
                      description:
                      'Habit repeats on the same date as start date every month (e.g., on the 15th of each month).',
                      habitColor: habitColor,
                    ),
                    const Divider(),
                    _buildRepeatTypeSection(
                      context: context,
                      title: 'Yearly',
                      icon: Icons.event_repeat_rounded,
                      description:
                      'Habit repeats on the same date as start date every year (e.g., January 1st each year).',
                      habitColor: habitColor,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Got it',
                  style: TextStyle(
                    color: habitColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRepeatTypeSection({
    required BuildContext context,
    required String title,
    required IconData icon,
    required String description,
    required Color habitColor,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.titleMedium?.copyWith(
                    color: habitColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyExample(BuildContext context, Color habitColor) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final weekDays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final selectedDays = [true, false, true, false, true, false, false]; // Example selection

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Example:',
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: List.generate(
              weekDays.length,
                  (index) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selectedDays[index]
                        ? habitColor
                        : colorScheme.surfaceContainerHighest,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    weekDays[index],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: selectedDays[index]
                          ? colorScheme.onPrimary
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Habit will repeat on Monday, Wednesday and Friday until end date (if specified).',
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class WeekdaySelector extends StatelessWidget {
  const WeekdaySelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment(-0.74, 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(
            7,
                (index) {
              final List<String> days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
              return ListenableBuilder(
                listenable: g.buildHabitSc,
                builder: (context, child) {
                  final weekdays = g.buildHabitSc.repeatConfig.days;
                  final isSelected =
                      weekdays.contains(index + 1) && g.buildHabitSc.isWeekdayValid(index + 1);
                  final scheme = Theme.of(context).colorScheme;
                  final color = getColorFromString(g.buildHabitSc.color) ?? scheme.primary;

                  // Calculate proper text color based on background brightness
                  final textColor = isSelected
                      ? _getContrastingTextColor(color)
                      : scheme.onSurfaceVariant;

                  return InkWell(
                    onTap: () {
                      final isValid = g.buildHabitSc.isWeekdayValid(index + 1);
                      if (!isValid) return;
                      g.buildHabitSc.toggleWeekday(index + 1, !isSelected);
                    },
                    customBorder: CircleBorder(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 7),
                      child: Container(
                        width: 25,
                        height: 25,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? color
                              : scheme.surfaceContainerHighest,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          days[index],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  // Helper method to determine contrasting text color
  Color _getContrastingTextColor(Color backgroundColor) {
    // Calculate relative luminance
    final luminance = backgroundColor.computeLuminance();
    // Use white text for dark backgrounds, black for light backgrounds
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}

