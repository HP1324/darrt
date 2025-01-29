import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:minimaltodo/app_router.dart';
import 'package:minimaltodo/services/category_service.dart';
import 'package:minimaltodo/view_models/general_view_model.dart';
import 'package:page_transition/page_transition.dart';
import 'package:minimaltodo/data_models/category_model.dart';
import 'package:minimaltodo/services/notification_service.dart';
import 'package:minimaltodo/global_utils.dart';
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
  late final TaskViewModel _taskVM;
  @override
  void initState() {
    super.initState();
    _taskVM = context.read<TaskViewModel>();
    widget.editMode ? _taskVM.initEditTask(widget.taskToEdit!) : _taskVM.initNewTask();
  }

  @override
  Widget build(BuildContext context) {
    final tvm = Provider.of<TaskViewModel>(context, listen: false);

    return PopScope(
      onPopInvokedWithResult: (_, __) async {
        if (widget.editMode) {
          final changes = await tvm.editTask();
          if (changes > 0) {
            // showToast(title: 'Task Edited');
          }
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
          child: SingleChildScrollView(
            child: Consumer<TaskViewModel>(
                builder: (context, taskVM, _) {
              return Column(
                children: [
                  const SizedBox(height: 20),
                  TaskTextField(editMode: widget.editMode),
                  const SizedBox(height: 50),
                  Row(
                    children: [
                      Flexible(flex: 2, child: const SetCategoryButton()),
                      Flexible(flex: 3, child: const SetPriorityWidget()),
                    ],
                  ),
                  const SizedBox(height: 50),
                  Row(
                    children: [
                      Flexible(child: SetDateWidget(editMode: widget.editMode, task: widget.editMode ? widget.taskToEdit : null,)),
                      Flexible(child:  SetTimeWidget(editMode:widget.editMode, task:  widget.editMode ? widget.taskToEdit : null)),
                    ],
                  ),
                  const SizedBox(height: 30),
                  NotificationSwitch(),
                  const SizedBox(height: 20),
                  if (taskVM.currentTask.isNotifyEnabled!) ...[
                    NotificationTypeSelector(),
                    const SizedBox(height: 20),
                    NotificationOptionsWidget(),
                  ],
                ],
              );
            }),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final navigator = Navigator.of(context);
            final isNotifEnabled = tvm.currentTask.isNotifyEnabled;
            if (tvm.titleController.text.trim().isNotEmpty) {
              tvm.title = tvm.titleController.text;
            }
            if (!widget.editMode) {
              tvm.currentTask.printTask();
              final success = await tvm.addNewTask();
              logger.d('Task added: $success');
              if (success) {
                navigator.pop();
                showToast(title: 'Task Added');
                logger.d('Scheduled notifications ${AwesomeNotifications().listScheduledNotifications()}');
              }
            } else {
              final changes = await tvm.editTask();
              if (changes > 0) {
                navigator.pop();
                showToast(title: 'Task edited');
              }
            }
            if (isNotifEnabled!) {
              await NotificationService.createTaskNotification(tvm.currentTask);
            } else {
              await NotificationService.removeTaskNotification(tvm.currentTask);
            }
            tvm.titleController.clear();
          },
          shape: const CircleBorder(),
          child: const Icon(Icons.done),
        ),
      ),
    );
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
                hintStyle: TextStyle(fontSize: Theme.of(context).textTheme.titleSmall!.fontSize)
              ),
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
            onTap: () => AppRouter.to(context, child: NewListPage(editMode: false), type: PageTransitionType.rightToLeft),
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
                          tvm.list = selected;
                          logger.d('chosen list: ${selected.name}, icon: ${selected.iconCode}');
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
  const SetDateWidget({super.key,required this.editMode, this.task});
  final bool editMode;
  final Task? task;

  @override
  Widget build(BuildContext context) {
    return Consumer2<TaskViewModel,GeneralViewModel>(builder: (context, taskVM,generalVM, _) {
      return InkWell(
        onTap: () async {
          generalVM.textFieldNode.unfocus();
          final selectedDate = await showDatePicker(
            context: context,
            firstDate: DateTime.now().subtract(const Duration(days: 365)),
            lastDate: DateTime.now().add(const Duration(days: 18263)),
            initialDate: editMode ? task!.dueDate : DateTime.now(),
          );
          if(selectedDate != null) {
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
    return Consumer2<TaskViewModel,GeneralViewModel>(builder: (context, taskVM,generalVM, _) {
      return InkWell(
        onTap: () async {
          generalVM.textFieldNode.unfocus();
          final selectedTime = await showTimePicker(
            context: context,
            initialTime:TimeOfDay.fromDateTime(taskVM.currentTask.dueDate!),
          );
          if(selectedTime != null) {
            taskVM.time = selectedTime!;
          }
          logger.d('DueDate with time: ${taskVM.currentTask.dueDate}');
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
                            // taskVM.removeTime();
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
        title:
            Text("Enable notification", style: TextStyle(fontSize: Theme.of(context).textTheme.titleSmall!.fontSize, fontWeight: FontWeight.w500)),
        value: taskVM.currentTask.isNotifyEnabled!,
        onChanged: (value) async {
          if (await NotificationService.managePermission(context)) {
            taskVM.toggleNotifSwitch(value);
            logger.d('isNotifyEnabled: ${taskVM.currentTask.isNotifyEnabled}');
            logger.d('Notification Time at the time of toggling: ${taskVM.currentTask.notifyTime}');
          }
        },
      );
    });
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
              style: TextStyle(fontSize: Theme.of(context).textTheme.titleMedium!.fontSize, fontWeight: FontWeight.w500),
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
                  label: Text('Soft Reminder'),
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
            spacing: 0,
            runSpacing: 0,
            runAlignment: WrapAlignment.start,
            children: [
              _TimeOption(minutes: 0,   label: 'On time'),
              _TimeOption(minutes: 5,   label: '5 min'),
              _TimeOption(minutes: 10,  label: '10 min'),
              _TimeOption(minutes: 15,  label: '15 min'),
              _TimeOption(minutes: 30,  label: '30 min'),
              _TimeOption(minutes: 45,  label: '45 min'),
              _TimeOption(minutes: 60,  label: '1 hour'),
              _TimeOption(minutes: 120, label: '2 hour'),
              _TimeOption(minutes: 180, label: '3 hour'),
              _TimeOption(minutes: 240, label: '4 hour'),
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
              logger.d('notify time after selecting it from chips: ${tvm.currentTask.notifyTime}');
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
