import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:minimaltodo/data_models/task.dart';
import 'package:minimaltodo/helpers/mini_enums.dart';
import 'package:minimaltodo/helpers/mini_utils.dart';
import 'package:minimaltodo/views/widgets/empty_tasks_indicator.dart';
import 'package:provider/provider.dart';
import 'package:minimaltodo/view_models/task_view_model.dart';
import 'package:minimaltodo/view_models/calendar_view_model.dart';
import 'package:minimaltodo/views/widgets/task_item.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this,initialIndex: 1);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _deleteSelectedTasks(BuildContext context) {
    final taskVM = Provider.of<TaskViewModel>(context, listen: false);
    final calendarVM = Provider.of<CalendarViewModel>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Tasks'),
        content: Text('Delete ${calendarVM.selectedTaskIds.length} tasks?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              for (var id in calendarVM.selectedTaskIds) {
                final task = taskVM.tasks.firstWhere((t) => t.id == id);
                taskVM.deleteTask(task);
              }
              calendarVM.clearSelection();
              Navigator.pop(context);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer< CalendarViewModel>(builder: (context,  calendarVM, _) {
      return Column(
        children: [
          if (calendarVM.isSelectionMode)
            ListTile(
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: calendarVM.clearSelection,
              ),
              title: Text('${calendarVM.selectedTaskIds.length} selected'),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _deleteSelectedTasks(context),
              ),
            ),
          const SizedBox(
            height: 80,
            child: ScrollableDateBar(),
          ),
          Container(
            height: 35,
            margin: const EdgeInsets.only(left: 6, right: 6, bottom: 6),
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer.withAlpha(15), borderRadius: BorderRadius.circular(12)),
            child: TabBar(
              onTap: (currentTab) {},
              splashBorderRadius: BorderRadius.circular(10),
              dividerHeight: 0,
              labelStyle: Theme.of(context).textTheme.titleSmall!.copyWith(fontWeight: FontWeight.bold),
              unselectedLabelStyle: Theme.of(context).textTheme.titleSmall!.copyWith(fontWeight: FontWeight.w500),
              controller: _tabController,
              tabs: const [
                Tab(text: 'All'),
                Tab(text: 'Single'),
                Tab(text: 'Recurring'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                TaskListView(
                  taskType: TaskType.all,
                ),
                TaskListView(
                  taskType: TaskType.single,
                ),
                TaskListView(
                  taskType: TaskType.recurring,
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}



class TaskListView extends StatefulWidget {
  const TaskListView({
    super.key,
    required this.taskType,
  });

  final TaskType taskType;

  @override
  State<TaskListView> createState() => _TaskListViewState();
}

class _TaskListViewState extends State<TaskListView> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer2<TaskViewModel, CalendarViewModel>(
      builder: (context, taskVM, calVM, _) {
        var tasks = calVM.getTasksForDate(calVM.selectedDate, taskVM.tasks);
        switch (widget.taskType) {
          case TaskType.all:
            tasks = tasks;
            break;
          case TaskType.single:
            tasks = tasks.where((t) => !t.isRepeating!).toList();
          case TaskType.recurring:
            tasks = tasks.where((t) => t.isRepeating!).toList();
        }
        return tasks.isEmpty
            ? Center(
                child: EmptyTasksIndicator(
                  icon: Iconsax.task_square,
                  message: 'No tasks for this date',
                ),
              )
            : ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return TaskItem(
                    key: ValueKey('task_${task.id}'),
                    task: task.toLightweightEntity(),
                    isSelected: calVM.selectedTaskIds.contains(task.id),
                    isSelectionMode: calVM.selectedTaskIds.isNotEmpty,
                    onLongPress: () => calVM.toggleTaskSelection(task),
                    onSelect: (_) => calVM.toggleTaskSelection(task),
                  );
                },
              );
      },
    );
  }
}

class ScrollableDateBar extends StatelessWidget {
  const ScrollableDateBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CalendarViewModel>(
      builder: (context, calendarVM, _) {
        return ListView.builder(
          controller: calendarVM.dateScrollController,
          scrollDirection: Axis.horizontal,
          itemExtent: calendarVM.dateItemWidth,
          physics: const BouncingScrollPhysics(),
          itemCount: calendarVM.dates.length,
          itemBuilder: (context, index) => DateItem(
            date: calendarVM.dates[index],
            calendarVM: calendarVM,
          ),
        );
      },
    );
  }
}

class DateItem extends StatelessWidget {
  const DateItem({
    super.key,
    required this.date,
    required this.calendarVM,
  });

  final DateTime date;
  final CalendarViewModel calendarVM;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = calendarVM.isSameDay(date, calendarVM.selectedDate);
    final isToday = calendarVM.isSameDay(date, DateTime.now());

    return GestureDetector(
      onTap: () => calendarVM.setSelectedDate(date),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary
              : isToday
                  ? colorScheme.primaryContainer
                  : colorScheme.primary.withAlpha(14),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                formatDateWith(date, 'EEE'),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: isSelected
                          ? colorScheme.onPrimary
                          : isToday
                              ? colorScheme.onPrimaryContainer
                              : colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 4),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? colorScheme.primaryContainer.withAlpha(150) : colorScheme.primary.withAlpha(20),
                ),
                child: Center(
                  child: Text(
                    date.day.toString(),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: isSelected
                              ? colorScheme.onPrimary
                              : isToday
                                  ? colorScheme.onPrimaryContainer
                                  : colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
