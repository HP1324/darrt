// ignore_for_file: avoid_print

import 'package:awesome_notifications/awesome_notifications.dart' show AwesomeNotifications;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:minimaltodo/app/services/notification_service.dart';
import 'package:minimaltodo/category/category_model.dart';
import 'package:minimaltodo/category/logic/category_view_model.dart';
import 'package:minimaltodo/category/ui/add_category_page.dart';
import 'package:minimaltodo/category/ui/category_chip.dart';
import 'package:minimaltodo/helpers/consts.dart';
import 'package:minimaltodo/helpers/messages.dart';
import 'package:minimaltodo/helpers/mini_box.dart';
import 'package:minimaltodo/helpers/utils.dart';
import 'package:minimaltodo/task/logic/task_state_controller.dart';
import 'package:minimaltodo/task/logic/task_view_model.dart';
import 'package:minimaltodo/task/reminder.dart';
import 'package:minimaltodo/task/repeat_config.dart';
import 'package:minimaltodo/task/task.dart';

import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';

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
    if (widget.edit) {
      context.read<TaskStateController>().initTaskState(widget.task!);
    }
  }

  late TaskStateController controller;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    controller = context.read<TaskStateController>();
  }

  @override
  void dispose() {
    controller.clearTaskState();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.edit ? widget.task!.title : 'Add New Task')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: SingleChildScrollView(
          child: Column(
            spacing: 20,
            children: [
              Row(
                spacing: 10,
                children: [
                  Icon(Icons.assignment_outlined, size: 19),
                  Expanded(
                    child: TextField(
                      textCapitalization: TextCapitalization.sentences,
                      controller: context.read<TaskStateController>().titleController,
                      autofocus: true,
                      focusNode: context.read<TaskStateController>().textFieldNode,
                      decoration: InputDecoration(
                        hintText: 'Enter your task here',
                      ),
                    ),
                  ),
                ],
              ),
              const CategorySelector(),
              const PrioritySelector(),
              const TaskTypeSelector(),
              if (context.select((TaskStateController controller) => controller.isRepeating)) ...[
                const DateRangeSelector(),
                const RepeatTypeSelector(),
                if (context
                        .select((TaskStateController controller) => controller.repeatConfig)
                        .type ==
                    'weekly')
                  const WeekdaySelector(),
              ] else ...[
                const DuedateSelector(),
              ],
              const AddRemindersWidget()
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final categories = context
              .read<CategoryViewModel>()
              .categories
              .where((c) => context.read<TaskStateController>().categorySelection[c] == true)
              .toList();
          Task newTask =
              context.read<TaskStateController>().buildTask(edit: widget.edit, task: widget.task);
          final message = context
              .read<TaskViewModel>()
              .putTask(newTask, categories: categories, edit: widget.edit);
          var type = ToastificationType.success;
          if (message == Messages.mTaskAdded || message == Messages.mTaskEdited) {
            Navigator.pop(context);
          } else {
            type = ToastificationType.error;
          }
          showToast(context, type: type, description: message);
        },
        child: Icon(Icons.done),
      ),
    );
  }
}

class AddRemindersWidget extends StatelessWidget {
  const AddRemindersWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        "Reminders",
        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14),
      ),
      subtitle: Consumer<TaskStateController>(builder: (context, controller, _) {
        return Text(
          controller.reminders.isEmpty
              ? 'Click here to add reminders per day'
              : controller.reminders.map((r) => r.time.format(context)).join(', '),
          style: Theme.of(context).textTheme.bodySmall,
        );
      }),
      trailing: const Icon(Icons.access_time),
      onTap: () async {
        context.read<TaskStateController>().textFieldNode.unfocus();
        final allowed = await AwesomeNotifications().isNotificationAllowed();
        if (context.mounted) {
          if (allowed || _showNotificationRationale(context)) {
            showBottomSheet(context);
          }
        }
      },
    );
  }
  void showBottomSheet(BuildContext context){
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
          child: Consumer<TaskStateController>(
            builder: (context, controller, _) {
              final textTheme = Theme.of(context).textTheme;
              final scheme = Theme.of(context).colorScheme;
              final reminders = controller.reminders;

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
                        style:
                        textTheme.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
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
                            controller.removeReminder(reminders[index]);
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
  bool _showNotificationRationale(BuildContext context) {
    bool userAllowed = false;
    showAdaptiveDialog(
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
                  await NotificationService.initializeNotificationChannels();
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
  const DuedateSelector({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskStateController>(
      builder: (context, controller, _) {
        return DateSelector(
          icon: Icons.calendar_today,
          title: 'Set Date',
          date: controller.dueDate,
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(Duration(days: 30)),
            );
            if (date != null) {
              controller.setDueDate(date);
            }
          },
        );
      },
    );
  }
}

class WeekdaySelector extends StatelessWidget {
  const WeekdaySelector({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(
          7,
          (index) {
            List<String> days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
            return Selector<TaskStateController, List<int>>(
              selector: (context, controller) => controller.repeatConfig.days,
              builder: (context, weekdays, _) {
                return ChoiceChip(
                  labelPadding: EdgeInsets.zero,
                  shape: CircleBorder(),
                  showCheckmark: false,
                  label: Text(days[index]),
                  selected: weekdays.contains(index + 1) &&
                      context.read<TaskStateController>().isWeekdayValid(index + 1),
                  onSelected: (selected) {
                    final isValid = context.read<TaskStateController>().isWeekdayValid(index + 1);
                    if (!isValid) return;
                    context.read<TaskStateController>().toggleWeekday(index + 1, selected);
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class RepeatTypeSelector extends StatelessWidget {
  const RepeatTypeSelector({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Selector<TaskStateController, RepeatConfig>(
        selector: (context, controller) => controller.repeatConfig,
        builder: (context, config, _) {
          return SegmentedButton(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(value: 'weekly', label: Text('Weekly')),
              ButtonSegment(value: 'monthly', label: Text('Monthly')),
              ButtonSegment(value: 'yearly', label: Text('Yearly')),
            ],
            selected: {config.type ?? 'weekly'},
            onSelectionChanged: (selected) {
              context.read<TaskStateController>().setRepeatType(selected.first);
            },
          );
        });
  }
}

class DateRangeSelector extends StatelessWidget {
  const DateRangeSelector({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskStateController>(
      builder: (context, controller, _) {
        return Column(
          spacing: 10,
          children: [
            DateSelector(
              icon: Icons.calendar_today_outlined,
              title: 'Start Date',
              date: controller.startDate,
              onTap: () async {
                controller.textFieldNode.unfocus();
                final date = await showDatePicker(
                  context: context,
                  firstDate: DateTime(1, 1, 2024),
                  lastDate: DateTime.now().add(Duration(days: 300)),
                );
                if (date != null) {
                  controller.setStartDate(date);
                }
              },
              onClear: () {
                controller.resetStartDate();
              },
            ),
            DateSelector(
              icon: Icons.event_repeat,
              title: 'End Date (Optional)',
              date: controller.endDate,
              onTap: () async {
                controller.textFieldNode.unfocus();
                final date = await showDatePicker(
                  context: context,
                  firstDate: controller.startDate.add(Duration(days: 1)),
                  lastDate: DateTime.now().add(Duration(days: 300)),
                );
                if (date != null) {
                  controller.setEndDate(date);
                }
              },
              onClear: () {
                controller.resetEndDate();
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
        context
            .read<TaskStateController>()
            .putReminder(edit: edit, reminder: newReminder, oldReminder: reminder);
      },
    ),
  );
}

class TaskTypeSelector extends StatelessWidget {
  const TaskTypeSelector({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Selector<TaskStateController, bool>(
      selector: (context, controller) => controller.isRepeating,
      builder: (context, repeat, _) {
        return SegmentedButton(
          showSelectedIcon: false,
          segments: [
            ButtonSegment(
              value: false,
              label: Text('Single Task',style: TextStyle(fontSize: Theme.of(context).textTheme.labelMedium?.fontSize)),
              icon: Icon(
                Icons.calendar_today,
                size: 18,
                color: !repeat ? Theme.of(context).colorScheme.onPrimary : null,
              ),
            ),
            ButtonSegment(
              value: true,
              label: Text('Recurring Task',style: TextStyle(fontSize: Theme.of(context).textTheme.labelMedium?.fontSize)),
              icon: Icon(
                Icons.repeat,
                size: 18,
                color: repeat ? Theme.of(context).colorScheme.onPrimary : null,
              ),
            ),
          ],
          selected: {repeat},
          onSelectionChanged: (selected) {
            context.read<TaskStateController>().toggleRepeat(selected.first);
          },
          style: ButtonStyle(
            shape: WidgetStatePropertyAll(StadiumBorder()),
          ),
        );
      },
    );

  }
}

class CategorySelector extends StatelessWidget {
  const CategorySelector({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.read<TaskStateController>().textFieldNode.unfocus();
        showModalBottomSheet(
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
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AddCategoryPage(edit: false)),
                  ),
                  title: const Text('Create New Category',
                      style: TextStyle(fontWeight: FontWeight.w500)),
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
                    child: Consumer<CategoryViewModel>(
                      builder: (context, catVM, _) => ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        itemCount: catVM.categories.length,
                        itemBuilder: (_, index) {
                          final cat = catVM.categories[index];
                          return Selector<TaskStateController, Map<CategoryModel, bool>>(
                            selector: (_, controller) => controller.categorySelection,
                            builder: (context, map, _) => CheckboxListTile(
                              value: map[cat] ?? false,
                              title: Text(cat.name,
                                  style: const TextStyle(overflow: TextOverflow.ellipsis)),
                              onChanged: (selected) {
                                if (selected != null) {
                                  context.read<TaskStateController>().setCategory(cat, selected);
                                }
                              },
                            ),
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
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.folder_outlined, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Theme.of(context).colorScheme.primary, width: 0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Categories',
                        style: TextStyle(
                            fontSize: Theme.of(context).textTheme.titleSmall!.fontSize,
                            fontWeight: FontWeight.w500),
                      ),
                      Icon(Icons.keyboard_arrow_down_rounded, size: 22),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                    child: ShaderMask(
                      shaderCallback: (bounds) {
                        return LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Colors.transparent,
                            Colors.black,
                            Colors.black,
                            Colors.transparent
                          ],
                          stops: [0.0, 0.05, 0.95, 1.0],
                        ).createShader(bounds);
                      },
                      blendMode: BlendMode.dstIn,
                      child: Selector<TaskStateController, Map<CategoryModel, bool>>(
                        selector: (context, controller) => controller.categorySelection,
                        builder: (context, map, _) {
                          final categories =
                              map.entries.where((e) => e.value).map((e) => e.key).toList();
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
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
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
                        onTap: () => context.read<TaskStateController>().navigatePriority(false),
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
                          child: Selector<TaskStateController, String>(
                            selector: (_, controller) => controller.priority,
                            builder: (context, priority, _) => Text(
                              priority,
                              style: TextStyle(
                                fontSize: Theme.of(context).textTheme.labelLarge!.fontSize,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.read<TaskStateController>().navigatePriority(true),
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
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: colorScheme.outline.withAlpha(50)),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.labelLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    date == null ? 'No end date' : DateFormat.yMMMd().format(date!),
                    style: textTheme.labelMedium,
                  ),
                ],
              ),
            ),
            if (date != null)
              IconButton(
                icon: Icon(
                  Icons.clear,
                  size: 18,
                  color: colorScheme.error,
                ),
                onPressed: onClear,
              ),
          ],
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
