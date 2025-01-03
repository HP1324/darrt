import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:minimaltodo/data_models/list_model.dart';
import 'package:minimaltodo/services/notification_service.dart';
import 'package:minimaltodo/theme/app_theme.dart';
import 'package:minimaltodo/global_utils.dart';
import 'package:minimaltodo/data_models/task.dart';
import 'package:minimaltodo/view_models/list_view_model.dart';
import 'package:minimaltodo/view_models/duedate_view_model.dart';
import 'package:minimaltodo/view_models/priority_view_model.dart';
import 'package:minimaltodo/view_models/task_view_model.dart';
import 'package:minimaltodo/views/pages/new_list_page.dart';
import 'package:minimaltodo/views/helper_widgets/custom_text_field.dart';
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
      onPopInvokedWithResult: (_, __) {
        final cvmodel = Provider.of<ListViewModel>(context, listen: false);
        final pvmodel = Provider.of<PriorityViewModel>(context, listen: false);
        cvmodel.resetList();
        pvmodel.resetPriority();
        tvm.resetSelectedMinutes();
      },
      child: Scaffold(
        backgroundColor: AppTheme.background50,
        appBar: AppBar(
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
            if (isNotifEnabled!)
              await NotificationService.createTaskNotification(tvm.currentTask);
            else
              await NotificationService.removeTaskNotification(tvm.currentTask);
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
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primary,
            AppTheme.secondary,
          ],
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.3),
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
                color: AppTheme.background100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CustomTextField(
                  controller: titleController,
                  isMaxLinesNull: true,
                  isAutoFocus: false,
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
            color: AppTheme.background100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Set a priority',
                style: TextStyle(
                  color: AppTheme.primary,
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
      splashColor: AppTheme.primary,
      onTap: () {
        showModalBottomSheet(
          backgroundColor: Colors.transparent,
          useRootNavigator: true,
          context: context,
          builder: (_) {
            return Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.background50,
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
                          child: NewListPage(), type: PageTransitionType.leftToRightWithFade));
                    },
                    title: const Text(
                      'Create New List',
                      style: TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.background100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.add, color: AppTheme.primary),
                    ),
                    trailing: const Icon(Icons.list_alt, color: AppTheme.primary),
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
                                color: lvm.chosenList == items[index]
                                    ? AppTheme.background100
                                    : Colors.transparent,
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                child: RadioListTile<ListModel>(
                                  activeColor: AppTheme.primary,
                                  value: items[index],
                                  groupValue: lvm.chosenList,
                                  title: Text(
                                    items[index].name!,
                                    style: TextStyle(
                                      fontWeight: lvm.chosenList == items[index]
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                  onChanged: (selected) {
                                    lvm.updateChosenList(selected!);
                                    tvm.list = lvm.chosenList!;
                                    logger.d('chosen list: ${lvm.chosenList!.name}');
                                    logger.d("Chosen list icon: ${lvm.chosenList!.iconCode}");
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
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(12),
                        onPressed: () {
                          final cvm = Provider.of<ListViewModel>(context, listen: false);
                          final tvm = Provider.of<TaskViewModel>(context, listen: false);
                          tvm.list = cvm.chosenList!;
                          debugPrint(
                              'TVM list: ${tvm.currentTask.list!.name}, CVM list: ${cvm.chosenList!.name}');
                          Navigator.of(context).pop();
                          showToast(title: 'Added to the list');
                        },
                        child: Text(
                          'Done',
                          style: TextStyle(
                              fontSize: Theme.of(context).textTheme.labelLarge!.fontSize, color: Colors.white, fontWeight: FontWeight.bold),
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
          color: AppTheme.background100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
             Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(
                  CupertinoIcons.folder,
                  color: AppTheme.primary,
                ),
                Text(
                  'Add to a list',
                  style: TextStyle(fontSize: Theme.of(context).textTheme.titleMedium!.fontSize, color: AppTheme.primary),
                ),
                Icon(
                  CupertinoIcons.chevron_right,
                  color: AppTheme.primary,
                ),
              ],
            ),
            Consumer<TaskViewModel>(builder: (_, tvm, __) {
              debugPrint('Chosen list in consumer' +
                  '${tvm.currentTask.list?.name ?? 'General'}');
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
          child: Consumer2<TaskViewModel, DuedateViewModel>(builder: (_, tvm, nvm, __) {
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
                        nvm.updateDateTime(selectedDate, selectedTime);
                        if (nvm.notifyAt != null) {
                          tvm.dueDate = nvm.notifyAt;
                          showToast(title: 'Task scheduled!', alignment: Alignment.center);
                        } else {
                          showToast(
                              title: 'Invalid date or time',
                              bgColor: Colors.red.shade400,
                              fgColor: Colors.white,
                              alignment: Alignment.center);
                        }
                      }
                    });
                  }
                });
              },
              child: Container(
                // height: 70,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: AppTheme.background100,
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
                            color: AppTheme.primary,
                          ),
                          Text(
                            'Set due date',
                            style: TextStyle(color: AppTheme.primary, fontSize: Theme.of(context).textTheme.titleMedium!.fontSize),
                          ),
                          Icon(
                            CupertinoIcons.chevron_right,
                            color: AppTheme.primary,
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
              final dateVM = Provider.of<DuedateViewModel>(context, listen: false);
              final taskVM = Provider.of<TaskViewModel>(context, listen: false);
              dateVM.removeDueDate();
              taskVM.removeDueDate();
              showToast(title: 'Due date removed', alignment: Alignment.center);
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
          BoxDecoration(color: AppTheme.background100, borderRadius: BorderRadius.circular(10)),
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
