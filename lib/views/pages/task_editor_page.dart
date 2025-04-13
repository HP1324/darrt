import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:minimaltodo/helpers/messages.dart';
import 'package:minimaltodo/helpers/mini_consts.dart';
import 'package:minimaltodo/helpers/mini_logger.dart';
import 'package:minimaltodo/helpers/mini_router.dart';
import 'package:minimaltodo/helpers/mini_box.dart';
import 'package:minimaltodo/services/category_service.dart';
import 'package:minimaltodo/services/notification_service.dart';
import 'package:minimaltodo/helpers/mini_utils.dart';
import 'package:minimaltodo/data_models/task.dart';
import 'package:minimaltodo/services/settings_service.dart';
import 'package:minimaltodo/view_models/category_view_model.dart';
import 'package:minimaltodo/view_models/task_view_model.dart';
import 'package:minimaltodo/views/pages/new_category_page.dart';
import 'package:page_transition/page_transition.dart';
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
  final titleController = TextEditingController();
  @override
  void initState() {
    super.initState();

    final taskVM = context.read<TaskViewModel>();
    widget.editMode ? taskVM.initEditTask(widget.taskToEdit!) : taskVM.initNewTask();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      MiniLogger.debug('Post frame callback is called');
      context
          .read<CategoryViewModel>()
          .resetCategorySelectionStatus(widget.editMode, widget.taskToEdit);
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) async {
        if (widget.editMode) {
          final taskVM = Provider.of<TaskViewModel>(context, listen: false);
          final catVM = Provider.of<CategoryViewModel>(context, listen: false);
          taskVM.setTitle();
          await taskVM.setCategories(catVM.selectedCategories);
          final message = await taskVM.editTask();
          if (context.mounted && message != null) {
            showToast(context: context, title: message, type: ToastificationType.success);
            Navigator.pop(context);
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
          padding: const EdgeInsets.only(left: 15, right: 15),
          child: SingleChildScrollView(
            child: Selector<TaskViewModel, (bool, bool)>(
                selector: (context, taskVM) => (taskVM.isRepeatEnabled, taskVM.isNotifyEnabled),
                builder: (context, data, _) {
                  final (isRepeatEnabled, isNotifyEnabled) = data;
                  return Column(
                    children: [
                      TaskTextField(editMode: widget.editMode),
                      const SizedBox(height: 50),
                      const SetCategoryButton(),
                      const SizedBox(height: 30),
                      const SetPriorityWidget(),
                      const SizedBox(height: 30),
                      Card(
                        elevation: 0,
                        child: SegmentedButton(
                          showSelectedIcon: false,
                          segments: [
                            ButtonSegment(
                              value: false,
                              label: Text('Single Task'),
                              icon: Icon(
                                Icons.calendar_today,
                                size: 18,
                                color: !isRepeatEnabled
                                    ? Theme.of(context).colorScheme.onPrimary
                                    : null,
                              ),
                            ),
                            ButtonSegment(
                              value: true,
                              label: Text('Recurring Task'),
                              icon: Icon(Icons.repeat,
                                  size: 18,
                                  color: isRepeatEnabled
                                      ? Theme.of(context).colorScheme.onPrimary
                                      : null),
                            ),
                          ],
                          selected: {isRepeatEnabled},
                          onSelectionChanged: (selected) {
                            context.read<TaskViewModel>().toggleRepeat(selected.first);
                          },
                          style: ButtonStyle(
                            shape: WidgetStatePropertyAll(
                              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      if (isRepeatEnabled) ...[
                        const RepeatingConfigWidget(),
                        const SizedBox(height: 10),
                        // NotificationSwitch(),
                        if (isNotifyEnabled) ...[

                          const SizedBox(height: 16),
                        ],
                      ] else ...[
                        // One-time task settings
                        SetDateWidget(editMode: widget.editMode, task: widget.taskToEdit),
                        const SizedBox(height: 8),
                        // SetTimeWidget(editMode: widget.editMode, task: widget.taskToEdit),
                        // const SizedBox(height: 16),
                        // NotificationSwitch(),
                        //
                        // if (isNotifyEnabled) ...[
                        //   const NotificationTypeSelector(),
                        //   const SizedBox(height: 8),
                        //   const NotificationOptionsWidget(),
                        // ],
                      ],
                      const NotificationTypeSelector(),
                      const RecurringReminderTimes(),
                      const SizedBox(height: 70),
                    ],
                  );
                }),
          ),
        ),
        floatingActionButton: widget.editMode
            ? null
            : FloatingActionButton(
                onPressed: () async {
                  context.read<TaskViewModel>().setTitle();
                  final message = await context
                      .read<TaskViewModel>()
                      .addNewTask(context.read<CategoryViewModel>().selectedCategories);
                  if (context.mounted) {
                    if (message != null) {
                      message == Messages.mTaskAdded ? Navigator.pop(context) : null;
                      final type = message == Messages.mTaskAdded
                          ? ToastificationType.success
                          : ToastificationType.error;
                      showToast(context: context, title: message, type: type);
                    }
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
  const TaskTextField({super.key, required this.editMode});
  final bool editMode;
  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 10,
      children: [
        Icon(Icons.assignment_outlined, size: 19),
        Expanded(
          child: TextField(
            focusNode: context.read<TaskViewModel>().textFieldNode,
            controller: context.read<TaskViewModel>().titleController,
            maxLines: null,
            autofocus: true,
            decoration: InputDecoration(
                hintText: editMode
                    ? context.read<TaskViewModel>().currentTask.title
                    : 'What\'s on your to-do list?',
                hintStyle: TextStyle(fontSize: Theme.of(context).textTheme.titleSmall!.fontSize)),
          ),
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
        context.read<TaskViewModel>().textFieldNode.unfocus();
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
                      child: Consumer<CategoryViewModel>(
                        builder: (context, categoryVM, _) {
                          final ids = categoryVM.selectedCategories.keys
                              .where((key) => categoryVM.selectedCategories[key]!)
                              .toList();
                          return FutureBuilder(
                            future: CategoryService.getCategoriesByIds(ids),
                            builder: (context, snapshot) {
                              final categories = snapshot.data ?? [];
                              return ListView.separated(
                                scrollDirection: Axis.horizontal,
                                shrinkWrap: true,
                                physics: BouncingScrollPhysics(),
                                separatorBuilder: (context, index) => const SizedBox(width: 4),
                                itemCount: categories.length,
                                itemBuilder: (context, index) {
                                  final category = snapshot.data![index];
                                  return Container(
                                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.primary.withAlpha(20),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          CategoryService.getIcon(category.iconCode),
                                          size: 12,
                                          color: category.color != null
                                              ? CategoryService.getColorFromString(
                                                  context, category.color!)
                                              : Theme.of(context).colorScheme.primary,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          category.name ?? '',
                                          style: Theme.of(context).textTheme.labelSmall,
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
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
            onTap: () => MiniRouter.to(context,
                child: NewCategoryPage(editMode: false), type: PageTransitionType.rightToLeft),
            title: Text('Create New Category', style: TextStyle(fontWeight: FontWeight.w500)),
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
            child: Consumer<CategoryViewModel>(
              builder: (context, categoryVM, _) {
                final categories = categoryVM.categories;
                return Scrollbar(
                    thickness: 8,
                    radius: const Radius.circular(4),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      controller: categoryVM.categoryBottomSheetScrollController,
                      itemCount: categories.length,
                      itemBuilder: (_, index) {
                        return CheckboxListTile(
                          value: categoryVM.selectedCategories[categories[index].id],
                          title: Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  CategoryService.getIcon(categories[index].iconCode),
                                  color: categories[index].color != null
                                      ? CategoryService.getColorFromString(
                                          context, categories[index].color!)
                                      : null,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  categories[index].name!,
                                  style: const TextStyle(overflow: TextOverflow.ellipsis),
                                ),
                              ),
                            ],
                          ),
                          onChanged: (selected) {
                            if (selected != null) {
                              categoryVM.updateSelectedCategories(categories[index].id!, selected);
                            }
                          },
                        );
                      },
                    ));
              },
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
                bottom: BorderSide(color: Theme.of(context).colorScheme.primary, width: 0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Priority',
                      style: TextStyle(
                          fontSize: Theme.of(context).textTheme.titleSmall!.fontSize,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withAlpha(20),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: GestureDetector(
                          onTap: () => context.read<TaskViewModel>().navigatePriority(false),
                          child: Icon(Icons.chevron_left),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Selector<TaskViewModel, String>(
                            selector: (context, taskVM) => taskVM.currentTask.priority!,
                            builder: (context, priority, _) {
                              return Text(
                                priority,
                                style: TextStyle(
                                  fontSize: Theme.of(context).textTheme.labelLarge!.fontSize,
                                  fontWeight: FontWeight.w400,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withAlpha(20),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: GestureDetector(
                          onTap: () => context.read<TaskViewModel>().navigatePriority(true),
                          child: Icon(Icons.chevron_right),
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

class SetDateWidget extends StatelessWidget {
  const SetDateWidget({super.key, required this.editMode, this.task});
  final bool editMode;
  final Task? task;

  @override
  Widget build(BuildContext context) {
    return Selector<TaskViewModel, DateTime>(
        selector: (context, taskVM) => taskVM.currentTask.dueDate!,
        builder: (context, dueDate, _) {
          return InkWell(
            onTap: () async {
              context.read<TaskViewModel>().textFieldNode.unfocus();
              final selectedDate = await showDatePicker(
                context: context,
                firstDate: DateTime.fromMillisecondsSinceEpoch(MiniBox.read(mFirstInstallDate))
                    .subtract(const Duration(days: 365)),
                lastDate: DateTime.now().add(const Duration(days: 18263)),
                initialDate: dueDate,
              );
              if (selectedDate != null && context.mounted) {
                context.read<TaskViewModel>().setDueDate(selectedDate);
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
                      border: Border(
                          bottom:
                              BorderSide(color: Theme.of(context).colorScheme.primary, width: 0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Date',
                              style: TextStyle(
                                  fontSize: Theme.of(context).textTheme.titleSmall!.fontSize,
                                  fontWeight: FontWeight.w500),
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
                                formatDateWith(dueDate, 'dd MMM, yyyy'),
                                style: TextStyle(
                                  fontSize: Theme.of(context).textTheme.labelMedium!.fontSize,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                context.read<TaskViewModel>().removeDueDate();
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

class NotificationTypeSelector extends StatelessWidget {
  const NotificationTypeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<TaskViewModel, String>(
      selector: (context, taskVM) => taskVM.currentTask.notifType!,
      builder: (context, notifType, _) {
        return Row(
          spacing: 10,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SegmentedButton(
              selectedIcon: Icon(
                Icons.check,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              style: SegmentedButton.styleFrom(
                  selectedBackgroundColor: Theme.of(context).colorScheme.primary),
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
              selected: {notifType},
              onSelectionChanged: (newSelection) {
                context.read<TaskViewModel>().updateNotificationType(newSelection.first);
              },
            ),
            InkWell(
              onTap: () {
                context.read<TaskViewModel>().textFieldNode.unfocus();
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                        content: Text(
                          Tutorial.mNotifAlarmDifference,
                          style:
                              TextStyle(fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize),
                        ),
                        actions: [
                          FilledButton(
                              onPressed: () async {
                                await SettingsService.openBatterySettings();
                              },
                              child: Text('Go to settings')),
                        ]);
                  },
                );
              },
              child: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                child: Icon(Icons.question_mark, color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ],
        );
      },
    );
  }
}

class RepeatingConfigWidget extends StatelessWidget {
  const RepeatingConfigWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SetStartEndDate(),
        const SizedBox(height: 10),
        Selector<TaskViewModel, String>(
          selector: (context, taskVM) => taskVM.repeatType!,
          builder: (context, repeatType, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SegmentedButton(
                      showSelectedIcon: false,
                      segments: [
                        ButtonSegment(value: 'weekly', label: Text('Weekly')),
                        ButtonSegment(value: 'monthly', label: Text('Monthly')),
                        ButtonSegment(value: 'yearly', label: Text('Yearly')),
                      ],
                      selected: {repeatType},
                      onSelectionChanged: (newSelection) {
                        context.read<TaskViewModel>().setRepeatType(newSelection.first);
                      },
                    ),
                  ],
                ),
                if (repeatType == 'weekly') _WeekdaySelector(),
                // Repeat type descriptions
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    _getRepeatTypeDescription(repeatType),
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  String _getRepeatTypeDescription(String repeatType) {
    switch (repeatType) {
      case 'weekly':
        return 'Repeat on specific days of the week';
      case 'monthly':
        return 'Repeat on the same date as start date each month';
      case 'yearly':
        return 'Repeat on the same date as start date each year';
      default:
        return '';
    }
  }
}

class SetStartEndDate extends StatelessWidget {
  const SetStartEndDate({super.key});
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14, left: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Selector<TaskViewModel, DateTime>(
              selector: (context, taskVM) => taskVM.taskStartDate,
              builder: (context, startDate, _) {
                return InkWell(
                  onTap: () async {
                    context.read<TaskViewModel>().textFieldNode.unfocus();
                    final selected = await showDatePicker(
                      context: context,
                      initialDate: startDate,
                      firstDate:
                          DateTime.fromMillisecondsSinceEpoch(MiniBox.read(mFirstInstallDate))
                              .subtract(Duration(days: 365)),
                      lastDate: DateTime.now().add(Duration(days: 18263)),
                    );
                    if (selected != null && context.mounted) {
                      context.read<TaskViewModel>().setTaskStartDate(selected);
                    }
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: colorScheme.outline.withAlpha(50))),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Column(
                          spacing: 2,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Start Date',
                              style: textTheme.labelLarge?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              DateFormat.yMMMd().format(startDate),
                              style: textTheme.labelMedium,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),

          const SizedBox(height: 15),
          // End Date
          Selector<TaskViewModel, (DateTime?, DateTime)>(
              selector: (context, taskVM) => (taskVM.taskEndDate, taskVM.taskStartDate),
              builder: (context, data, _) {
                final (endDate, startDate) = data;
                return InkWell(
                  onTap: () async {
                    context.read<TaskViewModel>().textFieldNode.unfocus();
                    final selectedEndDate = await showDatePicker(
                      context: context,
                      initialDate: endDate ?? startDate.add(const Duration(days: 1)),
                      firstDate: startDate,
                      lastDate: DateTime.now().add(Duration(days: 18263)),
                    );
                    if (selectedEndDate != null && context.mounted) {
                      context.read<TaskViewModel>().setTaskEndDate(selectedEndDate);
                    }
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: colorScheme.outline.withAlpha(50))),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.event_repeat,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            spacing: 3,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'End Date (Optional)',
                                style: textTheme.labelLarge?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              Text(
                                endDate != null
                                    ? DateFormat.yMMMd().format(endDate)
                                    : 'No end date',
                                style: textTheme.labelMedium,
                              ),
                            ],
                          ),
                        ),
                        if (endDate != null)
                          IconButton(
                            icon: Icon(
                              Icons.clear,
                              size: 18,
                              color: colorScheme.error,
                            ),
                            onPressed: () => context.read<TaskViewModel>().setTaskEndDate(null),
                          ),
                      ],
                    ),
                  ),
                );
              }),
        ],
      ),
    );
  }
}

class _WeekdaySelector extends StatelessWidget {
  const _WeekdaySelector();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Selector<TaskViewModel, List<int>>(
          selector: (context, taskVM) => taskVM.selectedWeekdays,
          builder: (context, selectedWeekdays, _) {
            return Padding(
              padding: const EdgeInsets.only(left: 10, top: 8, bottom: 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    7,
                    (index) {
                      final weekday = index + 1;
                      final dayName = DateFormat.EEEEE().format(DateTime(2024, 1, weekday));
                      final isSelected = selectedWeekdays.contains(weekday);
                      final isValid = context.read<TaskViewModel>().isWeekdayValid(weekday);

                      return Padding(
                        padding: EdgeInsets.only(right: index < 6 ? 4 : 0),
                        child: SizedBox(
                          width: 42,
                          child: FilterChip(
                            labelPadding: EdgeInsets.zero,
                            selectedColor: Theme.of(context).colorScheme.primary.withAlpha(230),
                            shape: CircleBorder(),
                            label: Text(dayName,
                                style: TextStyle(
                                    fontSize: Theme.of(context).textTheme.labelLarge!.fontSize)),
                            selected: isSelected && isValid,
                            onSelected: isValid
                                ? (selected) {
                                    final message =
                                        context.read<TaskViewModel>().toggleWeekday(weekday);
                                    if (message != null) {
                                      showToast(
                                        context: context,
                                        title: 'Can\'t remove',
                                        description: message,
                                        type: ToastificationType.warning,
                                        duration: Duration(milliseconds: 1900),
                                      );
                                    }
                                  }
                                : null,
                            showCheckmark: false,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class RecurringReminderTimes extends StatelessWidget {
  const RecurringReminderTimes({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      title: Text(
        "Add Reminders",
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontSize: 14,
            ),
      ),
      subtitle: Selector<TaskViewModel, List<TimeOfDay>>(
          selector: (context, taskVM) => taskVM.reminderTimesList,
          builder: (context, reminderTimesList, _) {
            return Text(
              reminderTimesList.isEmpty
                  ? 'Add up to 7 reminders per day'
                  : reminderTimesList.map((t) => t.format(context)).join(', '),
              style: Theme.of(context).textTheme.bodySmall,
            );
          }),
      trailing: const Icon(Icons.access_time),
      onTap: () async {
        context.read<TaskViewModel>().textFieldNode.unfocus();
        final allowed = await AwesomeNotifications().isNotificationAllowed();
        if (context.mounted) {
          if (allowed || _showNotificationRationale(context)) {
            showBottomSheet(context, colorScheme);
          }
        }
      },
    );
  }

  void showBottomSheet(BuildContext context, ColorScheme colorScheme) {
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

class ReminderTimesBottomSheet extends StatelessWidget {
  const ReminderTimesBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final mediaQuery = MediaQuery.of(context);
    //This padding was causing overflow issues, I realized after a long while and removed bottom padding
    // final bottomPadding = mediaQuery.viewInsets.bottom + mediaQuery.padding.bottom + 24;
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        // bottom: bottomPadding, // Handle keyboard
      ),
      constraints: BoxConstraints(
        maxHeight: mediaQuery.size.height * 0.7, // Maximum 70% of screen height
      ),
      child: Selector<TaskViewModel, List<TimeOfDay>>(
        selector: (context, taskVM) => taskVM.reminderTimesList,
        builder: (context, reminderTimesList, _) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Reminders',
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
              Flexible(
                child: reminderTimesList.isEmpty
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
                          children: reminderTimesList.map(
                            (time) {
                              return InputChip(
                                label: Text(time.format(context)),
                                avatar: const Icon(Icons.access_time, size: 16),
                                deleteIcon: const Icon(Icons.close, size: 16),
                                onDeleted: () =>
                                    context.read<TaskViewModel>().removeReminderTime(time),
                                onPressed: () async {
                                  final newTime = await showTimePicker(
                                    context: context,
                                    initialTime: time,
                                  );
                                  if (newTime != null && context.mounted) {
                                    context.read<TaskViewModel>().updateReminderTime(time, newTime);
                                  }
                                },
                                backgroundColor: colorScheme.surfaceContainerHighest,
                                side: BorderSide.none,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              );
                            },
                          ).toList(),
                        ),
                      ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: reminderTimesList.length >= 7
                      ? () {
                          context.read<TaskViewModel>().textFieldNode.unfocus();
                          showToast(
                            context: context,
                            title: 'Maximum 7 reminders allowed',
                            type: ToastificationType.warning,
                          );
                        }
                      : () async {
                          context.read<TaskViewModel>().textFieldNode.unfocus();
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (time != null && context.mounted) {
                            if (reminderTimesList.contains(time)) {
                              showToast(
                                context: context,
                                title: 'This time is already added',
                                type: ToastificationType.warning,
                              );
                            } else {
                              context.read<TaskViewModel>().addReminderTime(time);
                            }
                          }
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
  }
}
