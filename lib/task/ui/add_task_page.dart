// ignore_for_file: avoid_print

import 'package:awesome_notifications/awesome_notifications.dart' show AwesomeNotifications;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:minimaltodo/app/notification/notification_service.dart';
import 'package:minimaltodo/app/setting/settings_service.dart';
import 'package:minimaltodo/category/ui/add_category_page.dart';
import 'package:minimaltodo/category/ui/category_chip.dart';
import 'package:minimaltodo/helpers/consts.dart';
import 'package:minimaltodo/helpers/messages.dart';
import 'package:minimaltodo/helpers/mini_box.dart';
import 'package:minimaltodo/helpers/mini_router.dart';
import 'package:minimaltodo/helpers/utils.dart';
import 'package:minimaltodo/task/state/task_state_controller.dart';
import 'package:minimaltodo/task/models/reminder.dart';
import 'package:minimaltodo/task/models/task.dart';
import 'package:toastification/toastification.dart';
import 'package:minimaltodo/helpers/globals.dart' as g;

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({super.key, required this.edit, this.task}) : assert(!edit || task != null);

  ///Flag to indicate whether a task is being edited or a new task is being created
  final bool edit;
  final Task? task;
  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  @override
  void initState() {
    super.initState();
    g.taskSc.initState(widget.edit, widget.edit ? widget.task : null);
  }

  @override
  void dispose() {
    g.taskSc.clearState();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('Task page build');
    return Scaffold(
      appBar: AppBar(title: Text(widget.edit ? widget.task!.title : 'Add New Task')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 13.0),
        child: SingleChildScrollView(
          child: Column(
            spacing: 20,
            children: [
              const TitleTextField(),
              const CategorySelector(),
              // const PrioritySelector(),
              const TaskTypeSelector(),
              const DueDateOrRepeatConfigSection(),
              const AddRemindersWidget(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      floatingActionButton: Transform.scale(
        scale: 0.9,
        child: FloatingActionButton(
          onPressed: () {
            _putTask(context);
          },
          child: Icon(Icons.done),
        ),
      ),
    );
  }

  void _putTask(BuildContext context) {
    Task newTask = g.taskSc.buildModel(edit: widget.edit, model: widget.task);
    final message = g.taskVm.putItem(newTask, edit: widget.edit);
    var type = ToastificationType.success;
    if (message == Messages.mTaskAdded || message == Messages.mTaskEdited) {
      Navigator.pop(context);
    } else {
      type = ToastificationType.error;
    }
    showToast(context, type: type, description: message);
  }
}

class DueDateOrRepeatConfigSection extends StatelessWidget {
  const DueDateOrRepeatConfigSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: g.taskSc,
      builder: (context, child) {
        final isRepeating = g.taskSc.isRepeating;
        final type = g.taskSc.repeatConfig.type;
        return Column(
          spacing: 10.0,
          children: [
            if (isRepeating) ...[
              const DateRangeSelector(),
              const RepeatTypeSelector(),
              if (type == 'weekly') const WeekdaySelector(),
            ] else
              const DuedateSelector(),
          ],
        );
      },
    );
  }
}

class TitleTextField extends StatelessWidget {
  const TitleTextField({super.key});

  @override
  Widget build(BuildContext context) {
    return StructuredRow(
      leadingIcon: Icons.assignment_outlined,
      expanded: Expanded(
        child: TextField(
          textCapitalization: TextCapitalization.sentences,
          controller: g.taskSc.textController,
          autofocus: true,
          maxLines: null,
          focusNode: g.taskSc.textFieldNode,
          keyboardType: TextInputType.multiline,
          decoration:
              InputDecoration(hintText: 'Enter your task here', border: UnderlineInputBorder()),
        ),
      ),
      trailing: IconButton(
        onPressed: () {},
        icon: Icon(Icons.keyboard_voice),
      ),
    );
  }
}

class AddRemindersWidget extends StatelessWidget {
  const AddRemindersWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        g.taskSc.textFieldNode.unfocus();
        final allowed = await AwesomeNotifications().isNotificationAllowed();
        if (context.mounted) {
          if ((allowed || await _showNotificationRationale(context)) && context.mounted) {
            _showRemindersBottomSheet(context);
          }
        }
      },
      child: StructuredRow(
        leadingIcon: Icons.notification_add_outlined,
        expanded: Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Reminders",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14),
              ),
              ListenableBuilder(
                listenable: g.taskSc,
                builder: (context, widget) {
                  final reminders = g.taskSc.reminders;
                  return Text(
                    reminders.isEmpty
                        ? 'Click here to add reminders per day'
                        : reminders.map((r) => r.time.format(context)).join(', '),
                    style: Theme.of(context).textTheme.bodySmall,
                  );
                },
              ),
            ],
          ),
        ),
        trailing: IconButton(
          onPressed: () {
            g.taskSc.textFieldNode.unfocus();
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                  content: Text(
                    Messages.mNotifAlarmDifference,
                    style: TextStyle(fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize),
                  ),
                  actions: [
                    FilledButton(
                      onPressed: () async {
                        await SettingsService.openBatterySettings();
                      },
                      child: Text('Go to settings'),
                    ),
                  ],
                );
              },
            );
          },
          icon: Icon(Icons.info_outline),
        ),
      ),
    );
  }

  void _showRemindersBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.only(left: 24, right: 24, top: 24),
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
          child: ListenableBuilder(
            listenable: g.taskSc,
            builder: (context, child) {
              final textTheme = Theme.of(context).textTheme;
              final scheme = Theme.of(context).colorScheme;
              final reminders = g.taskSc.reminders;
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Reminders',
                        style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Flexible(
                    child: reminders.isEmpty
                        ? Center(
                            child: Text(
                              'No reminders set',
                              style: textTheme.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
                            ),
                          )
                        : ListView.builder(
                            itemCount: reminders.length,
                            itemBuilder: (context, index) {
                              debugPrint(
                                  'Reminder ${index + 1} time in list: ${reminders[index].time.hour}:${reminders[index].time.minute}');
                              return ReminderItem(
                                reminder: reminders[index],
                                onTap: () {
                                  showReminderDialog(
                                    context,
                                    edit: true,
                                    reminder: reminders[index],
                                  );
                                },
                                onRemove: () {
                                  g.taskSc.removeReminder(reminders[index]);
                                },
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () async {
                        showReminderDialog(context);
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add Reminder'),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Future<bool> _showNotificationRationale(BuildContext context) async {
    bool userAllowed = false;
    await showAdaptiveDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
          title: const Text('Permission required'),
          content: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
                'Please allow the application to send notifications, otherwise we won\'t be able to remind you about your tasks.'),
          ),
          actions: [
            InkWell(
              onTap: () async {
                final navigator = Navigator.of(context);
                final allowed = await AwesomeNotifications().requestPermissionToSendNotifications();
                if (allowed && context.mounted) {
                  await MiniBox.write(mNotificationsEnabled, allowed);
                  await NotificationService.initNotifChannels();
                }
                userAllowed = allowed;
                navigator.pop();
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: const Row(
                  children: [
                    Text('Go to notification settings'),
                    Icon(Icons.chevron_right),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
    return userAllowed;
  }
}

class DuedateSelector extends StatelessWidget {
  const DuedateSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: g.taskSc,
      builder: (context, child) {
        return DateSelector(
          icon: Icons.calendar_today,
          title: 'Date',
          date: g.taskSc.dueDate,
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              firstDate: DateTime.fromMillisecondsSinceEpoch(MiniBox.read(mFirstInstallDate)),
              lastDate: DateTime.now().add(Duration(days: maxExtentDateDays)),
            );
            if (date != null) {
              g.taskSc.setDueDate(date);
            }
          },
          onClear: () => g.taskSc.resetDueDate(),
        );
      },
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
                listenable: g.taskSc,
                builder: (context, child) {
                  final weekdays = g.taskSc.repeatConfig.days;
                  final isSelected =
                      weekdays.contains(index + 1) && g.taskSc.isWeekdayValid(index + 1);
                  final colorScheme = Theme.of(context).colorScheme;

                  return InkWell(
                    onTap: () {
                      final isValid = g.taskSc.isWeekdayValid(index + 1);
                      if (!isValid) return;
                      g.taskSc.toggleWeekday(index + 1, !isSelected);
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
                              ? colorScheme.primary
                              : colorScheme.surfaceContainerHighest,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          days[index],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color:
                                isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
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
}

class RepeatTypeSelector extends StatelessWidget {
  const RepeatTypeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: g.taskSc,
      builder: (context, child) {
        final config = g.taskSc.repeatConfig;
        final selectedType = config.type ?? 'weekly';

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Make the radio options expand to fill available space
            Expanded(
              flex: 5,
              child: Card(
                // margin: const EdgeInsets.only(right: 8),
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

    // Make the tap area cover the entire width of each section
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => g.taskSc.setRepeatType(value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Use visualDensity to make radio buttons more compact if needed
          Radio<String>(
            value: value,
            groupValue: selectedType,
            onChanged: (val) => g.taskSc.setRepeatType(val!),
            visualDensity: VisualDensity.compact,
          ),
          // Use shorter text when width is limited
          Flexible(
            child: FittedBox(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color:
                          isSelected ? theme.colorScheme.primary : theme.textTheme.bodyLarge?.color,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DateRangeSelector extends StatelessWidget {
  const DateRangeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: g.taskSc,
      builder: (context, child) {
        return Column(
          spacing: 10,
          children: [
            DateSelector(
              icon: Icons.calendar_today_outlined,
              title: 'Start Date',
              date: g.taskSc.startDate,
              onTap: () async {
                g.taskSc.textFieldNode.unfocus();
                final date = await showDatePicker(
                  context: context,
                  firstDate: DateTime.fromMillisecondsSinceEpoch(MiniBox.read(mFirstInstallDate)),
                  lastDate: DateTime.now().add(Duration(days: maxExtentDateDays)),
                );
                if (date != null) {
                  g.taskSc.setStartDate(date);
                }
              },
              onClear: () {
                g.taskSc.resetStartDate();
              },
            ),
            DateSelector(
              icon: Icons.event_repeat,
              title: 'End Date (Optional)',
              date: g.taskSc.endDate,
              onTap: () async {
                g.taskSc.textFieldNode.unfocus();
                final date = await showDatePicker(
                  context: context,
                  firstDate: g.taskSc.startDate.add(Duration(days: 1)),
                  lastDate: DateTime.now().add(Duration(days: maxExtentDateDays)),
                );
                if (date != null) {
                  g.taskSc.setEndDate(date);
                }
              },
              onClear: () {
                g.taskSc.resetEndDate();
              },
            ),
          ],
        );
      },
    );
  }
}

class ReminderDialog extends StatefulWidget {
  final bool edit;
  final Reminder? reminder;
  final Function(Reminder) onSaved;

  const ReminderDialog({
    super.key,
    required this.edit,
    this.reminder,
    required this.onSaved,
  }) : assert(!edit || reminder != null, 'Reminder must be provided when editing');

  @override
  State<ReminderDialog> createState() => _ReminderDialogState();
}

class _ReminderDialogState extends State<ReminderDialog> {
  late String _selectedType;
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    // Initialize from existing reminder if editing, else defaults
    _selectedType = widget.edit ? widget.reminder!.type : 'notif';
    _selectedTime = widget.edit ? widget.reminder!.time : TimeOfDay.now();
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && mounted) {
      setState(() => _selectedTime = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.edit ? 'Edit reminder' : 'Add a reminder',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 3,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Reminder type',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          SegmentedButton(
            showSelectedIcon: false,
            style: SegmentedButton.styleFrom(
              backgroundColor:
                  Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
            segments: [
              ButtonSegment(
                value: 'notif',
                label: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_outlined,
                      size: 18,
                      color: _selectedType == 'notif'
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    const Text('Notification'),
                  ],
                ),
              ),
              ButtonSegment(
                value: 'alarm',
                label: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.alarm_outlined,
                      size: 18,
                      color: _selectedType == 'alarm'
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    const Text('Alarm'),
                  ],
                ),
              ),
            ],
            selected: {_selectedType},
            onSelectionChanged: (val) => setState(() => _selectedType = val.first),
          ),
          const SizedBox(height: 24),
          Text(
            'Time',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _selectTime,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).colorScheme.outline),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedTime.format(context),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
                    Icon(
                      Icons.access_time_rounded,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
        ),
        FilledButton(
          onPressed: () {
            final newReminder = Reminder(
              id: DateTime.now().millisecondsSinceEpoch.remainder(10000),
              type: _selectedType,
              time: _selectedTime,
            );
            widget.onSaved(newReminder);
            Navigator.of(context).pop();
          },
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
          ),
          child: const Text('Save'),
        ),
      ],
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }
}

void showReminderDialog(BuildContext context, {bool edit = false, Reminder? reminder}) {
  debugPrint('Reminder time: ${reminder?.time.hour}:${reminder?.time.minute}');
  showAdaptiveDialog(
    context: context,
    builder: (context) => ReminderDialog(
      edit: edit,
      reminder: reminder,
      onSaved: (newReminder) {
        g.taskSc.putReminder(edit: edit, reminder: newReminder, oldReminder: reminder);
      },
    ),
  );
}

class TaskTypeSelector extends StatelessWidget {
  const TaskTypeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return StructuredRow(
      leadingIcon: Icons.repeat,
      expanded: Expanded(
        child: Text('Repeat Task', style: theme.textTheme.titleMedium!.copyWith()),
      ),
      trailing: ListenableBuilder(
        listenable: g.taskSc,
        builder: (context, child) {
          final repeat = g.taskSc.isRepeating;
          return Transform.scale(
            scale: 0.9,
            child: Checkbox(
              value: repeat,
              onChanged: (value) {
                if (value != null) g.taskSc.toggleRepeat(value);
              },
            ),
          );
        },
      ),
    );
  }
}

class CategorySelector extends StatelessWidget {
  const CategorySelector({super.key});
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return StructuredRow(
        leadingIcon: Icons.category_outlined,
        expanded: Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                children: [
                  Row(
                    children: [
                      Text(
                        'Categories',
                        style: TextStyle(fontSize: textTheme.labelLarge!.fontSize),
                      ),
                      // Icon(Icons.arrow_drop_down, size: 20)
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.03,
                child: ListenableBuilder(
                  listenable: g.taskSc,
                  builder: (context, child) {
                    final map = g.taskSc.categorySelection;
                    final categories = map.entries.where((e) => e.value).map((e) => e.key).toList();
                    return ListView.separated(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      physics: BouncingScrollPhysics(),
                      separatorBuilder: (context, index) => const SizedBox(width: 2),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        return CategoryChip(category: category);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        trailing: IconButton(
          onPressed: () {
            g.taskSc.textFieldNode.unfocus();
            _showCategorySelectionBottomSheet(context);
          },
          icon: Icon(Icons.add),
        ),);
  }

  Future<dynamic> _showCategorySelectionBottomSheet(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 8),
            ListTile(
              onTap: () => MiniRouter.to(context, AddCategoryPage(edit: false)),
              title:
                  const Text('Create New Category', style: TextStyle(fontWeight: FontWeight.w500)),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.add),
              ),
              trailing: const Icon(Icons.list_alt),
            ),
            Expanded(
              child: Scrollbar(
                thickness: 8,
                radius: const Radius.circular(4),
                child: ListenableBuilder(
                  listenable: Listenable.merge([g.taskSc, g.taskVm]),
                  builder: (context, child) => ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: g.catVm.categories.length,
                    itemBuilder: (_, index) {
                      final cat = g.catVm.categories[index];
                      final map = g.taskSc.categorySelection;
                      return CheckboxListTile(
                        value: map[cat] ?? false,
                        title:
                            Text(cat.name, style: const TextStyle(overflow: TextOverflow.ellipsis)),
                        onChanged: (selected) {
                          if (selected != null) {
                            g.taskSc.setCategory(cat, selected);
                          }
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PrioritySelector extends StatelessWidget {
  const PrioritySelector({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.flag_outlined, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(color: Theme.of(context).colorScheme.primary, width: 0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Priority',
                    style: TextStyle(
                        fontSize: Theme.of(context).textTheme.titleSmall!.fontSize,
                        fontWeight: FontWeight.w500)),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => g.taskSc.navigatePriority(false),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withAlpha(20),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.chevron_left),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: ListenableBuilder(
                            listenable: g.taskSc,
                            builder: (context, child) => Text(
                              g.taskSc.priority,
                              style: TextStyle(
                                fontSize: Theme.of(context).textTheme.labelLarge!.fontSize,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => g.taskSc.navigatePriority(true),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withAlpha(20),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.chevron_right),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class DateSelector extends StatelessWidget {
  const DateSelector({
    super.key,
    required this.title,
    required this.onTap,
    this.date,
    this.onClear,
    required this.icon,
  });

  final String title;
  final VoidCallback onTap;
  final DateTime? date;
  final VoidCallback? onClear; // Callback when clear icon is tapped
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: StructuredRow(
        leadingIcon: icon,
        expanded: Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.labelLarge?.copyWith(),
              ),
              Text(
                date == null ? 'No end date' : DateFormat.yMMMd().format(date!),
                style: textTheme.labelMedium!.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        trailing: Builder(
          builder: (context) {
            if (date != null) {
              return IconButton(
                icon: Icon(
                  Icons.clear,
                  size: 20,
                  color: scheme.error,
                ),
                onPressed: onClear,
              );
            }
            return SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class ReminderItem extends StatelessWidget {
  final Reminder reminder;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const ReminderItem({
    super.key,
    required this.reminder,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Text(
                reminder.time.format(context),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
              const SizedBox(width: 16),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    reminder.type == 'alarm' ? Icons.alarm : Icons.notifications,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    reminder.type == 'alarm' ? 'Alarm' : 'Notification',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.close, color: Theme.of(context).colorScheme.error),
                onPressed: onRemove,
                tooltip: 'Remove reminder',
              ),
            ],
          ),
        ),
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
        g.taskSc.textFieldNode.unfocus();
        _showRepeatTypeDialog(context);
      },
      icon: Icon(Icons.info_outline),
    );
  }

  void _showRepeatTypeDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        title: Row(
          children: [
            Icon(Icons.repeat_rounded, color: colorScheme.primary),
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
                ),
                _buildWeeklyExample(context),
                const Divider(),
                _buildRepeatTypeSection(
                  context: context,
                  title: 'Monthly',
                  icon: Icons.calendar_month_rounded,
                  description:
                      'Task repeats on the same date as start date every month (e.g., on the 15th of each month).',
                ),
                const Divider(),
                _buildRepeatTypeSection(
                  context: context,
                  title: 'Yearly',
                  icon: Icons.event_repeat_rounded,
                  description:
                      'Task repeats on the same date as start date every year (e.g., January 1st each year).',
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
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRepeatTypeSection({
    required BuildContext context,
    required String title,
    required IconData icon,
    required String description,
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
                    color: colorScheme.onSurface,
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

  Widget _buildWeeklyExample(BuildContext context) {
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
                        ? colorScheme.primary
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
          'Task will repeat on Monday, Wednesday and Friday until end date (if specified).',
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class StructuredRow extends StatelessWidget {
  const StructuredRow(
      {super.key, required this.leadingIcon, required this.expanded, this.trailing});
  final IconData leadingIcon;
  final Widget expanded;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(leadingIcon),
        const SizedBox(width: 10),
        Expanded(child: expanded),
        trailing ?? const SizedBox.shrink(),
      ],
    );
  }
}
