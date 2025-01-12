import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:minimaltodo/services/list_service.dart';
import 'package:minimaltodo/view_models/general_view_model.dart';
import 'package:page_transition/page_transition.dart';
import 'package:minimaltodo/data_models/list_model.dart';
import 'package:minimaltodo/services/notification_service.dart';
import 'package:minimaltodo/theme/app_theme.dart';
import 'package:minimaltodo/global_utils.dart';
import 'package:minimaltodo/data_models/task.dart';
import 'package:minimaltodo/view_models/list_view_model.dart';
import 'package:minimaltodo/view_models/priority_view_model.dart';
import 'package:minimaltodo/view_models/task_view_model.dart';
import 'package:minimaltodo/views/pages/new_list_page.dart';
import 'package:minimaltodo/views/widgets/custom_text_field.dart';
import 'package:minimaltodo/views/pages/notification_settings_page.dart';
import 'package:provider/provider.dart';

//ignore: must_be_immutable
class TaskEditorPage extends StatefulWidget {
  TaskEditorPage({super.key, this.taskToEdit, required this.editMode});
  Task? taskToEdit;
  bool editMode;

  @override
  State<TaskEditorPage> createState() => _TaskEditorPageState();
}

class _TaskEditorPageState extends State<TaskEditorPage> {
  final titleController = TextEditingController();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    logger.d('Build called');
    final tvm = Provider.of<TaskViewModel>(context, listen: false);
    //Have to reset the task because the previous data is still in the task, if [tvmodel.currentTask] is not reset, then it will cause,
    //one serious issue, that is adding new task will modify not add new, instead it will edit the existing task.
    tvm.currentTask = Task();
    if (widget.editMode) tvm.currentTask = widget.taskToEdit!;
    return PopScope(
      onPopInvokedWithResult: (_, __) async {
        if (widget.editMode) {
          final changes = await tvm.editTask();
          if (changes > 0) {
            showToast(title: 'Task Edited');
          }
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
        appBar: AppBar(
          leading: CupertinoNavigationBarBackButton(color: Colors.white),
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
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20),
          child: SingleChildScrollView(
            child: Column(
              spacing: 20,
              children: [
                TaskTextField(titleController: titleController, widget: widget),
                const SetPriorityWidget(),
                const AddToListButton(),
                DateTimePickerButton(mounted: mounted),
                GotoNotificationSettings(widget: widget),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final navigator = Navigator.of(context);
            final isNotifEnabled = tvm.currentTask.isNotifyEnabled;
            if (!widget.editMode) {
              tvm.currentTask.printTask();
              final success = await tvm.addNewTask();
              logger.d('Task added: $success');
              if (success) {
                navigator.pop();
                showToast(title: 'Task Added');
                logger.d(
                    'Scheduled notifications ${AwesomeNotifications().listScheduledNotifications()}');
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
          },
          shape: const CircleBorder(),
          child: const Icon(Icons.done),
        ),
      ),
    );
  }
}

class TaskTextField extends StatelessWidget {
  const TaskTextField({
    super.key,
    required this.titleController,
    required this.widget,
  });

  final TextEditingController titleController;
  final TaskEditorPage widget;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withAlpha(100),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.edit_note_rounded, color: Colors.white, size: 28),
                SizedBox(width: 10),
                Text(
                  'Task',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: Theme.of(context).textTheme.titleLarge!.fontSize,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withAlpha(60),
                  width: 1.5,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CustomTextField(
                  controller: titleController,
                  isMaxLinesNull: true,
                  autoFocus: true,
                  fillColor: Colors.transparent,
                  hintText:
                      widget.editMode ? 'What needs changing?' : 'What\'s on your to-do list?',
                  onChanged: (_) {
                    final tvm = Provider.of<TaskViewModel>(context, listen: false);
                    tvm.title = titleController.text;
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SetPriorityWidget extends StatelessWidget {
  const SetPriorityWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer2<PriorityViewModel, TaskViewModel>(
      builder: (_, pvm, tvm, __) {
        return Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Set a priority',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: Theme.of(context).textTheme.titleMedium!.fontSize,
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    pvm.priorities.length,
                    (index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: ChoiceChip(
                          label: Text(pvm.priorities[index]),
                          selected: pvm.currentValue == index,
                          color: pvm.setChipColor(index),
                          labelStyle: TextStyle(color: pvm.setLabelColor(index)),
                          checkmarkColor: Colors.white,
                          onSelected: (selected) {
                            pvm.updatePriority(selected, index);
                            tvm.priority = pvm.currentPriority!;
                          },
                        ),
                      );
                    },
                  ).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class AddToListButton extends StatelessWidget {
  const AddToListButton({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Theme.of(context).colorScheme.primary,
      onTap: () {
        final gvm = Provider.of<GeneralViewModel>(context, listen: false);
        gvm.textFieldNode.unfocus();
        showModalBottomSheet(
          backgroundColor: Colors.transparent,
          useRootNavigator: true,
          context: context,
          builder: (_) {
            return Container(
              decoration:  BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.surfaceVariant,
                    Colors.white,
                  ],
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  ListTile(
                    onTap: () {
                      Navigator.of(context).push(PageTransition(
                          child: NewListPage(
                            editMode: false,
                          ),
                          type: PageTransitionType.leftToRightWithFade));
                    },
                    title: Text(
                      'Create New List',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.add, color: Theme.of(context).colorScheme.primary),
                    ),
                    trailing:
                        Icon(Icons.list_alt, color: Theme.of(context).colorScheme.primary),
                  ),
                  Expanded(
                    child: Consumer2<ListViewModel, TaskViewModel>(
                      builder: (_, lvm, tvm, __) {
                        List<ListModel> items = lvm.lists;
                        return Scrollbar(
                          thickness: 8,
                          radius: const Radius.circular(4),
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            controller: lvm.listScrollController,
                            itemCount: items.length,
                            itemBuilder: (_, index) {
                              return Card(
                                elevation: 0,
                                color: (tvm.currentTask.list ?? items[0]) == items[index]
                                    ? Theme.of(context).colorScheme.surface
                                    : Colors.transparent,
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                child: RadioListTile(
                                  activeColor: items[index].listColor != null
                                      ? ListService.getColorFromString(items[index].listColor!)
                                      : Theme.of(context).colorScheme.primary,
                                  value: items[index],
                                  groupValue: tvm.currentTask.list ?? items[0],
                                  title: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: items[index].listColor != null
                                              ? ListService.getColorFromString(
                                                      items[index].listColor!)
                                                  .withAlpha(50)
                                              : Theme.of(context).colorScheme.primary.withAlpha(50),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          ListService.getIcon(items[index].iconCode),
                                          color: items[index].listColor != null
                                              ? ListService.getColorFromString(
                                                  items[index].listColor!)
                                              : Theme.of(context).colorScheme.primary,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        items[index].name!,
                                        style: TextStyle(
                                          fontWeight:
                                              (tvm.currentTask.list ?? items[0]) == items[index]
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                  onChanged: (selected) {
                                    lvm.updateChosenList(selected!);
                                    tvm.list = selected;
                                    logger.d(
                                        'chosen list: ${selected.name}, icon: ${selected.iconCode}');
                                  },
                                ),
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
                      child: CupertinoButton(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                        onPressed: () {
                          Navigator.of(context).pop();
                          showToast(title: 'Added to the list');
                        },
                        child: Text(
                          'Done',
                          style: TextStyle(
                              fontSize: Theme.of(context).textTheme.labelLarge!.fontSize,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(
                  CupertinoIcons.folder,
                  color: Theme.of(context).colorScheme.primary,
                ),
                Text(
                  'Add to a list',
                  style: TextStyle(
                      fontSize: Theme.of(context).textTheme.titleMedium!.fontSize,
                      color: Theme.of(context).colorScheme.primary),
                ),
                Icon(
                  CupertinoIcons.chevron_right,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
            Consumer<TaskViewModel>(builder: (_, tvm, __) {
              debugPrint('Chosen list in consumer ${tvm.currentTask.list?.name ?? 'General'}');
              return Text(
                tvm.currentTask.list?.name ?? 'General',
                style: TextStyle(fontSize: Theme.of(context).textTheme.labelLarge!.fontSize),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class DateTimePickerButton extends StatelessWidget {
  const DateTimePickerButton({
    super.key,
    required this.mounted,
  });

  final bool mounted;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Consumer2<TaskViewModel, GeneralViewModel>(builder: (_, tvm, gvm, __) {
            return InkWell(
              onTap: () {
                showDatePicker(
                        context: context,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 18250)))
                    .then((selectedDate) {
                  if (selectedDate != null && mounted) {
                    showTimePicker(context: context, initialTime: TimeOfDay.now())
                        .then((selectedTime) {
                      if (selectedTime != null) {
                        final dueDateChanged = tvm.updateDueDate(selectedDate, selectedTime);
                        if (!dueDateChanged) {
                          showToast(
                              title: 'Invalid date or time',
                              bgColor: Colors.red.shade400,
                              fgColor: Colors.white,
                              alignment: Alignment.center);
                        }
                      }
                    });
                  }
                  gvm.textFieldNode.unfocus();
                });
              },
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Icon(
                            Icons.calendar_month,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          Text(
                            'Set due date',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: Theme.of(context).textTheme.titleMedium!.fontSize),
                          ),
                          Icon(
                            CupertinoIcons.chevron_right,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ],
                      ),
                      if (tvm.currentTask.dueDate != null)
                        Text(
                          formatDateTime(tvm.currentTask.dueDate!),
                        )
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
        IconButton(
            onPressed: () {
              final taskVM = Provider.of<TaskViewModel>(context, listen: false);
              taskVM.removeDueDate();
            },
            icon: const Icon(
              Icons.close,
              size: 34,
              color: Colors.red,
            )),
      ],
    );
  }
}

class GotoNotificationSettings extends StatelessWidget {
  const GotoNotificationSettings({
    super.key,
    required this.widget,
  });

  final TaskEditorPage widget;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:
          BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(10)),
      child: Consumer<TaskViewModel>(builder: (_, taskVM, __) {
        return ListTile(
            onTap: () {
              if (taskVM.currentTask.dueDate != null) {
                Navigator.push(
                    context,
                    PageTransition(
                        child: TaskNotificationSettingsPage(), type: PageTransitionType.fade));
                taskVM.setNotifConfigInUI();
              } else {
                showToast(
                    title: 'Please set a due date first',
                    fgColor: Colors.white,
                    bgColor: Colors.red,
                    alignment: Alignment.center);
              }
            },
            title: Text(
              'Notification Settings',
              style: TextStyle(fontSize: Theme.of(context).textTheme.titleMedium!.fontSize),
            ),
            trailing: Icon(Icons.notifications));
      }),
    );
  }
}
