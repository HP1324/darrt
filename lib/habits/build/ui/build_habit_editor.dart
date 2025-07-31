import 'package:darrt/habits/build/state/build_habit_state_controller.dart';
import 'package:darrt/helpers/icon_color_storage.dart';
import 'package:darrt/helpers/utils.dart';
import 'package:flutter/material.dart';
import 'package:darrt/habits/build/models/build_habit.dart';
import 'package:darrt/category/models/entity_category.dart';
import 'package:darrt/helpers/globals.dart' as g;

class BuildHabitEditor extends StatefulWidget {
  const BuildHabitEditor({
    super.key,
    required this.edit,
    this.habit,
    this.category,
  }) : assert(!edit || habit != null);

  final bool edit;
  final BuildHabit? habit;
  final EntityCategory? category;

  @override
  State<BuildHabitEditor> createState() => _BuildHabitEditorState();
}

class _BuildHabitEditorState extends State<BuildHabitEditor> {
  @override
  void initState() {
    super.initState();
    g.buildHabitSc.initState(widget.edit, widget.habit);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.edit ? 'Edit Habit' : 'New Habit'),
        backgroundColor: colorScheme.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          spacing: 20,
          children: [
            HabitNameTextField(),
            HabitDescriptionTextField(),
            MeasurementTypeSelector(),
            // // Add CategorySelector here when ready
            // // CategorySelector(),
            HabitDateSection(),
            HabitTimeSection(),
            HabitRepeatSection(),
            HabitColorSelector(),
            const SizedBox(height: 100),
          ],
        ),
      ),
      floatingActionButton: SaveHabitButton(),
    );
  }
}

class HabitNameTextField extends StatelessWidget {
  const HabitNameTextField({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: g.buildHabitSc.textController,
              focusNode: g.buildHabitSc.textFieldNode,
              decoration: InputDecoration(
                hintText: 'Enter habit name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest,
              ),
              style: textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}

class HabitDescriptionTextField extends StatelessWidget {
  const HabitDescriptionTextField({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Description (Optional)',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: g.buildHabitSc.descriptionController,
              focusNode: g.buildHabitSc.descriptionNode,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Add a description for your habit',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest,
              ),
              style: textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class MeasurementTypeSelector extends StatelessWidget {
  const MeasurementTypeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    final textTheme = Theme.of(context).textTheme;

    return ListenableBuilder(
      listenable: g.buildHabitSc,
      builder: (context, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'How do you want to track this habit?',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                RadioListTile<String>(
                  value: 'boolean',
                  groupValue: g.buildHabitSc.measurementType,
                  onChanged: (value) => g.buildHabitSc.setMeasurementType(value!),
                  title: Text('With a Yes/No'),
                  subtitle: Text('Just mark as done when completed'),
                  contentPadding: EdgeInsets.zero,
                ),
                RadioListTile<String>(
                  value: 'count',
                  groupValue: g.buildHabitSc.measurementType,
                  onChanged: (value) => g.buildHabitSc.setMeasurementType(value!),
                  title: Text('Count something'),
                  subtitle: Text('Track numbers like glasses, pages, etc.'),
                  contentPadding: EdgeInsets.zero,
                ),
                if (g.buildHabitSc.measurementType == 'count') ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: g.buildHabitSc.unitController,
                    focusNode: g.buildHabitSc.unitNode,
                    decoration: InputDecoration(
                      labelText: 'Unit of measurement',
                      hintText: 'glasses, pages, minutes, km',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: colorScheme.surfaceContainerHighest,
                    ),
                    onChanged: (value) => g.buildHabitSc.setMeasurementUnit(value),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class HabitDateSection extends StatelessWidget {
  const HabitDateSection({super.key});

  void _showStartDatePicker(BuildContext context) {
    showDatePicker(
      context: context,
      initialDate: g.buildHabitSc.startDate,
      firstDate: DateTime.now().subtract(Duration(days: 365)),
      lastDate: DateTime.now().add(Duration(days: 365)),
    ).then((date) {
      if (date != null) {
        g.buildHabitSc.setStartDate(date);
      }
    });
  }

  void _showEndDatePicker(BuildContext context) {
    showDatePicker(
      context: context,
      initialDate: g.buildHabitSc.endDate ?? g.buildHabitSc.startDate.add(Duration(days: 30)),
      firstDate: g.buildHabitSc.startDate,
      lastDate: DateTime.now().add(Duration(days: 365)),
    ).then((date) {
      g.buildHabitSc.setEndDate(date);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    final textTheme = Theme.of(context).textTheme;

    return ListenableBuilder(
      listenable: g.buildHabitSc,
      builder: (context, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dates',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: Icon(Icons.calendar_today, color: colorScheme.primary),
                  title: Text('Start Date'),
                  subtitle: Text(
                    '${g.buildHabitSc.startDate.day}/${g.buildHabitSc.startDate.month}/${g.buildHabitSc.startDate.year}',
                  ),
                  trailing: Icon(Icons.edit),
                  onTap: () => _showStartDatePicker(context),
                  contentPadding: EdgeInsets.zero,
                ),
                ListTile(
                  leading: Icon(Icons.event, color: colorScheme.secondary),
                  title: Text('End Date (Optional)'),
                  subtitle: Text(
                    g.buildHabitSc.endDate != null
                        ? '${g.buildHabitSc.endDate!.day}/${g.buildHabitSc.endDate!.month}/${g.buildHabitSc.endDate!.year}'
                        : 'No end date',
                  ),
                  trailing: g.buildHabitSc.endDate != null
                      ? IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () => g.buildHabitSc.setEndDate(null),
                        )
                      : Icon(Icons.add),
                  onTap: () => _showEndDatePicker(context),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class HabitTimeSection extends StatelessWidget {
  const HabitTimeSection({super.key});

  void _showStartTimePicker(BuildContext context) {
    showTimePicker(
      context: context,
      initialTime: g.buildHabitSc.startTime != null
          ? TimeOfDay.fromDateTime(g.buildHabitSc.startTime!)
          : TimeOfDay.now(),
    ).then((time) {
      if (time != null) {
        final dateTime = DateTime(1970, 1, 1, time.hour, time.minute);
        g.buildHabitSc.setStartTime(dateTime);
      }
    });
  }

  void _showEndTimePicker(BuildContext context) {
    showTimePicker(
      context: context,
      initialTime: g.buildHabitSc.endTime != null
          ? TimeOfDay.fromDateTime(g.buildHabitSc.endTime!)
          : TimeOfDay.now(),
    ).then((time) {
      if (time != null) {
        final dateTime = DateTime(1970, 1, 1, time.hour, time.minute);
        g.buildHabitSc.setEndTime(dateTime);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    final textTheme = Theme.of(context).textTheme;

    return ListenableBuilder(
      listenable: g.buildHabitSc,
      builder: (context, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Time (Optional)',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        leading: Icon(Icons.schedule, color: colorScheme.primary),
                        title: Text('Start Time'),
                        subtitle: Text(
                          g.buildHabitSc.startTime != null
                              ? TimeOfDay.fromDateTime(g.buildHabitSc.startTime!).format(context)
                              : 'Not set',
                        ),
                        onTap: () => _showStartTimePicker(context),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    Expanded(
                      child: ListTile(
                        leading: Icon(Icons.schedule_outlined, color: colorScheme.secondary),
                        title: Text('End Time'),
                        subtitle: Text(
                          g.buildHabitSc.endTime != null
                              ? TimeOfDay.fromDateTime(g.buildHabitSc.endTime!).format(context)
                              : 'Not set',
                        ),
                        onTap: () => _showEndTimePicker(context),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class HabitRepeatSection extends StatelessWidget {
  const HabitRepeatSection({super.key});

  void _showRepeatConfigDialog(BuildContext context) {
    // You can implement a dialog or bottom sheet for repeat configuration
    // For now, just a placeholder
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Repeat Configuration'),
        content: Text('Repeat configuration UI will be implemented here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    final textTheme = Theme.of(context).textTheme;

    return ListenableBuilder(
      listenable: g.buildHabitSc,
      builder: (context, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Repeat Schedule',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: Icon(Icons.repeat, color: colorScheme.primary),
                  title: Text('Repeat Pattern'),
                  subtitle: Text(g.buildHabitSc.repeatConfig.description),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showRepeatConfigDialog(context),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class HabitColorSelector extends StatelessWidget {
  const HabitColorSelector({super.key});

  void _showColorPicker(BuildContext context) {
    showColorPicker(
      context,
      onColorSelected: (color) {
        g.buildHabitSc.setColor(color);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    final textTheme = Theme.of(context).textTheme;

    return ListenableBuilder(
      listenable: g.buildHabitSc,
      builder: (context, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Color Theme',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: _getColorFromString(g.buildHabitSc.color) ?? colorScheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: colorScheme.outline),
                    ),
                  ),
                  title: Text('Habit Color'),
                  subtitle: Text(g.buildHabitSc.color),
                  trailing: Icon(Icons.palette, color: colorScheme.primary),
                  onTap: () => _showColorPicker(context),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color? _getColorFromString(String colorString) {
    return IconColorStorage.colors[colorString];
  }
}

class SaveHabitButton extends StatelessWidget {
  const SaveHabitButton({super.key});


  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    final textTheme = Theme.of(context).textTheme;

    return FloatingActionButton(
      onPressed: () {
        // Save logic will be implemented here
      },
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      child: Icon(Icons.done),
    );
  }
}
