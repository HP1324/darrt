import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:minimaltodo/helpers/mini_consts.dart';
import 'package:minimaltodo/helpers/mini_logger.dart';
import 'package:minimaltodo/helpers/mini_router.dart';
import 'package:minimaltodo/helpers/mini_storage.dart';
import 'package:minimaltodo/services/category_service.dart';
import 'package:minimaltodo/view_models/general_view_model.dart';
import 'package:page_transition/page_transition.dart';
import 'package:minimaltodo/data_models/category_model.dart';
import 'package:minimaltodo/services/notification_service.dart';
import 'package:minimaltodo/helpers/mini_utils.dart';
import 'package:minimaltodo/data_models/task.dart';
import 'package:minimaltodo/view_models/category_view_model.dart';
import 'package:minimaltodo/view_models/task_view_model.dart';
import 'package:minimaltodo/views/pages/new_list_page.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';

//ignore: must_be_immutable
class TaskEditorPage extends StatefulWidget {
  TaskEditorPage({super.key, this.taskToEdit, required this.editMode});
  Task? taskToEdit;
  bool editMode;

  @override
  State<TaskEditorPage> createState() => _TaskEditorPageState();
}

class _TaskEditorPageState extends State<TaskEditorPage> {
  @override
  void initState() {
    super.initState();
    final taskVM = context.read<TaskViewModel>();
    widget.editMode ? taskVM.initEditTask(widget.taskToEdit!) : taskVM.initNewTask();
  }

  @override
  Widget build(BuildContext context) {
    final taskVM = Provider.of<TaskViewModel>(context, listen: false);
    MiniLogger.debug('build called');
    return PopScope(
      onPopInvokedWithResult: (didPop, result) async {
        if (widget.editMode) {
          final navigator = Navigator.of(context);
          final changes = await taskVM.editTask();
          if (changes > 0 && context.mounted) {
            toastification.show(context: context, title: Text('Task edited'));
            navigator.pop();
          }
          await _handleNotificationLogic(taskVM);
          taskVM.titleController.clear();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(),
          backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(20),
          title: widget.editMode
              ? Text(
            widget.taskToEdit!.title!,
            style: TextStyle(fontSize: Theme.of(context).textTheme.headlineSmall!.fontSize),
          )
              : Text(
            'New Task',
            style: TextStyle(fontSize: Theme.of(context).textTheme.headlineSmall!.fontSize),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Scrollbar(
            thickness: 0.1,
            child: SingleChildScrollView(
              child: Consumer<TaskViewModel>(builder: (context, taskVM, _) {
                return Column(
                  children: [
                    TaskTextField(editMode: widget.editMode),
                    const SizedBox(height: 50),
                    Row(
                      children: [
                        Flexible(flex: 2, child: const SetCategoryButton()),
                        Flexible(flex: 3, child: const SetPriorityWidget()),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Card(
                      elevation: 0,
                      color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(30),
                      child: SegmentedButton<bool>(
                        segments: const [
                          ButtonSegment<bool>(
                            value: false,
                            label: Text('Single Task'),
                            icon: Icon(Icons.calendar_today, size: 18),
                          ),
                          ButtonSegment<bool>(
                            value: true,
                            label: Text('Recurring Task'),
                            icon: Icon(Icons.repeat, size: 18),
                          ),
                        ],
                        selected: {taskVM.isRepeatEnabled},
                        onSelectionChanged: (selected) {
                          taskVM.toggleRepeat(selected.first);
                        },
                        style: ButtonStyle(
                          shape: WidgetStatePropertyAll(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          backgroundColor: WidgetStateProperty.resolveWith(
                                (states) {
                              if (states.contains(WidgetState.selected)) {
                                return Theme.of(context).colorScheme.primaryContainer;
                              }
                              return Theme.of(context).colorScheme.surface;
                            },
                          ),
                          foregroundColor: WidgetStateProperty.resolveWith(
                                (states) {
                              if (states.contains(WidgetState.selected)) {
                                return Theme.of(context).colorScheme.onPrimaryContainer;
                              }
                              return Theme.of(context).colorScheme.onSurface;
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    if (taskVM.isRepeatEnabled) ...[
                      const RepeatingConfigWidget(),
                      const SizedBox(height: 20),
                      NotificationSwitch(),
                      if (taskVM.currentTask.isNotifyEnabled ?? false) ...[
                        const NotificationTypeSelector(),
                        const SizedBox(height: 16),
                        const RecurringReminderTimes(),
                      ],
                    ] else ...[
                      // One-time task settings
                      SetDateWidget(editMode: widget.editMode, task: widget.taskToEdit),
                      const SizedBox(height: 8),
                      SetTimeWidget(editMode: widget.editMode, task: widget.taskToEdit),
                      const SizedBox(height: 16),
                      NotificationSwitch(),
                      if (taskVM.currentTask.isNotifyEnabled ?? false) ...[
                        const NotificationTypeSelector(),
                        const SizedBox(height: 8),
                        const NotificationOptionsWidget(),
                      ],
                    ],
                  ],
                );
              }),
            ),
          ),
        ),
        floatingActionButton: widget.editMode
            ? null
            : FloatingActionButton(
          onPressed: () async {
            final navigator = Navigator.of(context);
            final isNotifEnabled = taskVM.currentTask.isNotifyEnabled;
            if (taskVM.titleController.text.trim().isNotEmpty) {
              taskVM.title = taskVM.titleController.text;
            }

            final success = await taskVM.addNewTask();
            MiniLogger.debug('Task added: $success');
            if (success) {
              navigator.pop();
              MiniLogger.debug('Scheduled notifications ${AwesomeNotifications().listScheduledNotifications()}');
            }
            await _handleNotificationLogic(taskVM);
            taskVM.titleController.clear();
          },
          shape: const CircleBorder(),
          child: const Icon(Icons.done),
        ),
      ),
    );
  }

  Future<void> _handleNotificationLogic(TaskViewModel taskVM) async {
    if (taskVM.currentTask.isNotifyEnabled!) {
      await NotificationService.createTaskNotification(taskVM.currentTask);
    } else {
      await NotificationService.removeTaskNotification(taskVM.currentTask);
    }
  }
}

class TaskTextField extends StatelessWidget {
  const TaskTextField({super.key, required this.editMode});
  final bool editMode;
  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 10,
      children: [
        Icon(Icons.assignment_outlined, size: 19),
        Expanded(
          child: Consumer2<GeneralViewModel, TaskViewModel>(builder: (context, generalVM, taskVM, _) {
            return TextField(
              focusNode: generalVM.textFieldNode,
              controller: taskVM.titleController,
              maxLines: null,
              autofocus: true,
              decoration: InputDecoration(
                  hintText: editMode ? taskVM.currentTask.title : 'What\'s on your to-do list?',
                  hintStyle: TextStyle(fontSize: Theme.of(context).textTheme.titleSmall!.fontSize)),
            );
          }),
        ),
      ],
    );
  }
}

class SetCategoryButton extends StatelessWidget {
  const SetCategoryButton({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        final gvm = Provider.of<GeneralViewModel>(context, listen: false);
        gvm.textFieldNode.unfocus();
        showModalBottomSheet(
          context: context,
          builder: (_) {
            return _CategorySelectionBottomSheet();
          },
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
                border: Border(bottom: BorderSide(color: Theme.of(context).colorScheme.primary, width: 0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Category',
                        style: TextStyle(fontSize: Theme.of(context).textTheme.titleSmall!.fontSize, fontWeight: FontWeight.w500),
                      ),
                      Icon(Icons.keyboard_arrow_down_rounded, size: 22),
                    ],
                  ),
                  Consumer<TaskViewModel>(
                    builder: (_, tvm, __) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          tvm.currentTask.category?.name ?? 'General',
                          style: TextStyle(
                              fontSize: Theme.of(context).textTheme.labelMedium!.fontSize,
                              fontWeight: FontWeight.w400,
                              overflow: TextOverflow.ellipsis),
                          maxLines: 1,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategorySelectionBottomSheet extends StatefulWidget {
  const _CategorySelectionBottomSheet();

  @override
  State<_CategorySelectionBottomSheet> createState() => _CategorySelectionBottomSheetState();
}

class _CategorySelectionBottomSheetState extends State<_CategorySelectionBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      child: Column(
        children: [
          const SizedBox(height: 8),
          ListTile(
            onTap: () => MiniRouter.to(context, child: NewListPage(editMode: false), type: PageTransitionType.rightToLeft),
            title: Text('Create New List', style: TextStyle(fontWeight: FontWeight.w500)),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.add),
            ),
            trailing: Icon(Icons.list_alt),
          ),
          Expanded(
            child: Consumer2<CategoryViewModel, TaskViewModel>(
              builder: (_, categoryVM, tvm, __) {
                List<CategoryModel> items = categoryVM.categories;
                return Scrollbar(
                  thickness: 8,
                  radius: const Radius.circular(4),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    controller: categoryVM.categoryScrollController,
                    itemCount: items.length,
                    itemBuilder: (_, index) {
                      return RadioListTile(
                        value: items[index],
                        groupValue: tvm.currentTask.category ?? items[0],
                        title: Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                CategoryService.getIcon(items[index].iconCode),
                                color: items[index].color != null ? CategoryService.getColorFromString(context, items[index].color!) : null,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                items[index].name!,
                                style: TextStyle(
                                    fontWeight: (tvm.currentTask.category ?? items[0]) == items[index] ? FontWeight.bold : FontWeight.normal,
                                    overflow: TextOverflow.ellipsis),
                              ),
                            ),
                          ],
                        ),
                        onChanged: (selected) {
                          categoryVM.updateChosenCategory(selected!);
                          tvm.category = selected;
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Done',
                  style: TextStyle(
                    fontSize: Theme.of(context).textTheme.labelMedium!.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SetPriorityWidget extends StatelessWidget {
  const SetPriorityWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.flag_outlined, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Theme.of(context).colorScheme.primary, width: 0.5),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Priority',
                      style: TextStyle(fontSize: Theme.of(context).textTheme.titleSmall!.fontSize, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                Consumer<TaskViewModel>(
                  builder: (context, taskVM, __) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => taskVM.navigatePriority(false),
                            child: Icon(
                              Icons.chevron_left,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                taskVM.currentTask.priority!,
                                style: TextStyle(fontSize: Theme.of(context).textTheme.labelMedium!.fontSize, fontWeight: FontWeight.w400),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => taskVM.navigatePriority(true),
                            child: Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.primary),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class SetDateWidget extends StatelessWidget {
  const SetDateWidget({super.key, required this.editMode, this.task});
  final bool editMode;
  final Task? task;

  @override
  Widget build(BuildContext context) {
    return Consumer2<TaskViewModel, GeneralViewModel>(builder: (context, taskVM, generalVM, _) {
      return InkWell(
        onTap: () async {
          generalVM.textFieldNode.unfocus();
          final selectedDate = await showDatePicker(
            context: context,
            firstDate: DateTime.parse(MiniBox.read(mFirstInstallDate)).subtract(const Duration(days: 365)),
            lastDate: DateTime.now().add(const Duration(days: 18263)),
            initialDate: editMode ? task!.dueDate : DateTime.now(),
          );
          if (selectedDate != null) {
            taskVM.dueDate = selectedDate;
          }
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.calendar_today_outlined, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Theme.of(context).colorScheme.primary, width: 0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Date',
                          style: TextStyle(fontSize: Theme.of(context).textTheme.titleSmall!.fontSize, fontWeight: FontWeight.w500),
                        ),
                        Icon(Icons.keyboard_arrow_down_rounded, size: 22),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            formatDateWith(taskVM.currentTask.dueDate ?? DateTime.now(), 'dd MMM, yyyy'),
                            style: TextStyle(
                              fontSize: Theme.of(context).textTheme.labelMedium!.fontSize,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            taskVM.removeDueDate();
                          },
                          child: Icon(Icons.close, size: 19),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class SetTimeWidget extends StatelessWidget {
  const SetTimeWidget({super.key, required this.editMode, this.task});
  final bool editMode;
  final Task? task;
  @override
  Widget build(BuildContext context) {
    return Consumer2<TaskViewModel, GeneralViewModel>(builder: (context, taskVM, generalVM, _) {
      return InkWell(
        onTap: () async {
          generalVM.textFieldNode.unfocus();
          final selectedTime = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(taskVM.currentTask.dueDate!),
          );
          if (selectedTime != null) {
            taskVM.time = selectedTime;
          }
          MiniLogger.debug('DueDate with time: ${taskVM.currentTask.dueDate}');
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.access_time_outlined, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Theme.of(context).colorScheme.primary, width: 0.5),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Time',
                          style: TextStyle(fontSize: Theme.of(context).textTheme.titleSmall!.fontSize, fontWeight: FontWeight.w500),
                        ),
                        Icon(Icons.keyboard_arrow_down_rounded, size: 22),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            formatTime(taskVM.currentTask.dueDate ?? DateTime.now()),
                            style: TextStyle(
                              fontSize: Theme.of(context).textTheme.labelMedium!.fontSize,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            taskVM.removeTime();
                          },
                          child: Icon(Icons.close, size: 19),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class NotificationSwitch extends StatelessWidget {
  const NotificationSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskViewModel>(builder: (context, taskVM, _) {
      return SwitchListTile(
        activeColor: Theme.of(context).colorScheme.primary,
        title: Text("Enable notification", style: TextStyle(fontSize: Theme.of(context).textTheme.titleSmall!.fontSize, fontWeight: FontWeight.w500)),
        value: taskVM.currentTask.isNotifyEnabled!,
        onChanged: (value) async {
          final allowed = await AwesomeNotifications().isNotificationAllowed();
          if (allowed) {
            taskVM.toggleNotifSwitch(value);
          } else {
            _showNotificationRationale(context, taskVM, value);
          }
        },
      );
    });
  }

  void _showNotificationRationale(BuildContext context, TaskViewModel taskVM, bool value) {
    if (context.mounted) {
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
                  'Please allow the application to send notifications, otherwise we won\'t be able to remind you about your important tasks.'),
            ),
            actions: [
              InkWell(
                onTap: () async {
                  final navigator = Navigator.of(context);
                  final allowed = await AwesomeNotifications().requestPermissionToSendNotifications();
                  if (allowed) {
                    taskVM.toggleNotifSwitch(value);
                    await GetStorage().write(mNotificationsEnabled, allowed);
                    await NotificationService.initializeNotificationChannels();
                  }
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
    }
  }
}

class NotificationTypeSelector extends StatelessWidget {
  const NotificationTypeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskViewModel>(
      builder: (context, tvm, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notification Type',
              style: TextStyle(fontSize: Theme.of(context).textTheme.titleSmall!.fontSize, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),
            SegmentedButton(
              selectedIcon: Icon(
                Icons.check,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              style: SegmentedButton.styleFrom(selectedBackgroundColor: Theme.of(context).colorScheme.primary),
              segments: [
                ButtonSegment(
                  value: 'notif',
                  label: Text('Notification'),
                  icon: Icon(Icons.notifications_none_outlined),
                ),
                ButtonSegment(
                  value: 'alarm',
                  label: Text('Alarm'),
                  icon: Icon(Icons.alarm),
                ),
              ],
              selected: {tvm.currentTask.notifType ?? 'notif'},
              onSelectionChanged: (newSelection) {
                tvm.updateNotificationType(newSelection.first);
              },
            ),
          ],
        );
      },
    );
  }
}

class NotificationOptionsWidget extends StatelessWidget {
  const NotificationOptionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).primaryColor.withAlpha(100)),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notify me before',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 12),
          Wrap(
            spacing: 5,
            runSpacing: 5,
            runAlignment: WrapAlignment.start,
            children: [
              _TimeOption(minutes: 0, label: 'On time'),
              _TimeOption(minutes: 5, label: '5 min'),
              _TimeOption(minutes: 10, label: '10 min'),
              _TimeOption(minutes: 15, label: '15 min'),
              _TimeOption(minutes: 30, label: '30 min'),
              _TimeOption(minutes: 45, label: '45 min'),
              _TimeOption(minutes: 60, label: '1 hour'),
              _TimeOption(minutes: 120, label: '2 hours'),
              _TimeOption(minutes: 180, label: '3 hours'),
              _TimeOption(minutes: 240, label: '4 hours'),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimeOption extends StatelessWidget {
  const _TimeOption({
    required this.minutes,
    required this.label,
  });

  final int minutes;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskViewModel>(
      builder: (context, tvm, _) {
        final isSelected = tvm.selectedMinutes == minutes;
        return Material(
          color: isSelected ? Theme.of(context).colorScheme.outlineVariant : null,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              final isUpdated = tvm.updateNotifyTime(minutes);
              if (!isUpdated) {
                showToast(context: context, title: 'This time has gone', type: ToastificationType.warning);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Text(label),
            ),
          ),
        );
      },
    );
  }
}

class RepeatingConfigWidget extends StatelessWidget {
  const RepeatingConfigWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final taskVM = Provider.of<TaskViewModel>(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHighest.withAlpha(50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.primary.withAlpha(15),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Icon(Icons.repeat, color: colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Repeat Configuration',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Date Range Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Date Range',
                  style: textTheme.titleSmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),

                // Start Date
                InkWell(
                  onTap: () async {
                    context.read<GeneralViewModel>().textFieldNode.unfocus();
                    final selected = await showDatePicker(
                      context: context,
                      initialDate: taskVM.taskStartDate,
                      firstDate: DateTime.parse(MiniBox.read(mFirstInstallDate)).subtract(Duration(days: 365)),
                      lastDate: DateTime.now().add(Duration(days: 18263)),
                    );
                    if (selected != null) {
                      taskVM.setTaskStartDate(selected);
                    }
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: colorScheme.outline.withAlpha(50)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 18,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Start Date',
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              DateFormat.yMMMd().format(taskVM.taskStartDate),
                              style: textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // End Date
                InkWell(
                  onTap: () async {
                    context.read<GeneralViewModel>().textFieldNode.unfocus();
                    final selected = await showDatePicker(
                      context: context,
                      initialDate: taskVM.taskEndDate ?? taskVM.taskStartDate.add(const Duration(days: 1)),
                      firstDate: taskVM.taskStartDate,
                      lastDate: DateTime.now().add(Duration(days: 18263)),
                    );
                    taskVM.setTaskEndDate(selected);
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: colorScheme.outline.withAlpha(50)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.event_repeat,
                          size: 18,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'End Date (Optional)',
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              Text(
                                taskVM.taskEndDate != null ? DateFormat.yMMMd().format(taskVM.taskEndDate!) : 'No end date',
                                style: textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        if (taskVM.taskEndDate != null)
                          IconButton(
                            icon: Icon(
                              Icons.clear,
                              size: 18,
                              color: colorScheme.error,
                            ),
                            onPressed: () => taskVM.setTaskEndDate(null),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Repeat Type Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Repeat Type',
                  style: textTheme.titleSmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),

                // Repeat Type Radio Buttons with better styling
                _RepeatTypeOption(
                  title: 'Weekly',
                  subtitle: 'Repeat on specific days of the week',
                  value: 'weekly',
                  groupValue: taskVM.repeatType,
                  onChanged: (value) => taskVM.setRepeatType(value!),
                ),

                if (taskVM.repeatType == 'weekly')
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 16),
                    child: _WeekdaySelector(taskVM: taskVM),
                  ),

                _RepeatTypeOption(
                  title: 'Monthly',
                  subtitle: 'Repeat on the same date as start date each month',
                  value: 'monthly',
                  groupValue: taskVM.repeatType,
                  onChanged: (value) => taskVM.setRepeatType(value!),
                ),

                _RepeatTypeOption(
                  title: 'Yearly',
                  subtitle: 'Repeat on the same date as start date each year',
                  value: 'yearly',
                  groupValue: taskVM.repeatType,
                  onChanged: (value) => taskVM.setRepeatType(value!),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Radio Option Widget
class _RepeatTypeOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final String value;
  final String? groupValue;
  final ValueChanged<String?> onChanged;

  const _RepeatTypeOption({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isSelected = value == groupValue;

    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Row(
          children: [
            Radio(
              value: value,
              groupValue: groupValue,
              onChanged: onChanged,
              activeColor: colorScheme.primary,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.bodyMedium?.copyWith(
                      color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeekdaySelector extends StatelessWidget {
  final TaskViewModel taskVM;

  const _WeekdaySelector({required this.taskVM});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Days',
            style: textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: List.generate(7, (index) {
              final weekday = index + 1;
              final dayName = DateFormat.E().format(DateTime(2024, 1, weekday));
              final isSelected = taskVM.selectedWeekdays.contains(weekday);
              final isValid = taskVM.isWeekdayValid(weekday);

              return FilterChip(
                label: Text(dayName),
                selected: isSelected && isValid,
                onSelected: isValid ? (selected) => taskVM.toggleWeekday(weekday) : null,
                showCheckmark: false,
              );
            }),
          ),
        ],
      ),
    );
  }
}

class RecurringReminderTimes extends StatelessWidget {
  const RecurringReminderTimes({super.key});

  @override
  Widget build(BuildContext context) {
    final taskVM = Provider.of<TaskViewModel>(context);
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      title: Text(
        "Daily Reminder Times",
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontSize: 14,
        ),
      ),
      subtitle: Text(
        taskVM.reminderTimesList.isEmpty ? 'No reminders set' : taskVM.reminderTimesList.map((t) => t.format(context)).join(', '),
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: const Icon(Icons.access_time),
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          builder: (ctx) => ReminderTimesBottomSheet(),
        );
      },
    );
  }
}

class ReminderTimesBottomSheet extends StatelessWidget {
  const ReminderTimesBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final taskVM = Provider.of<TaskViewModel>(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final mediaQuery = MediaQuery.of(context);
    final bottomPadding = mediaQuery.viewInsets.bottom + mediaQuery.padding.bottom + 24;
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: bottomPadding, // Handle keyboard
      ),
      constraints: BoxConstraints(
        maxHeight: mediaQuery.size.height * 0.7, // Maximum 70% of screen height
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Daily Reminders',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Set up to 7 reminder times that will repeat daily',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Flexible(
            child: taskVM.reminderTimesList.isEmpty
                ? Center(
              child: Text(
                'No reminders set',
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            )
                : SingleChildScrollView(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: taskVM.reminderTimesList.map((time) {
                  return InputChip(
                    label: Text(time.format(context)),
                    avatar: const Icon(Icons.access_time, size: 16),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () => taskVM.removeReminderTime(time),
                    onPressed: () async {
                      final newTime = await showTimePicker(
                        context: context,
                        initialTime: time,
                      );
                      if (newTime != null) {
                        taskVM.updateReminderTime(time, newTime);
                      }
                    },
                    backgroundColor: colorScheme.surfaceVariant,
                    side: BorderSide.none,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: taskVM.reminderTimesList.length >= 7
                  ? () {
                showToast(
                  context: context,
                  title: 'Maximum 7 reminders allowed',
                  type: ToastificationType.warning,
                );
              }
                  : () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (time != null) {
                  if (taskVM.reminderTimesList.contains(time)) {
                    if (context.mounted) {
                      showToast(
                        context: context,
                        title: 'This time is already added',
                        type: ToastificationType.warning,
                      );
                    }
                  } else {
                    taskVM.addReminderTime(time);
                  }
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Reminder Time'),
            ),
          ),
        ],
      ),
    );
  }
}
