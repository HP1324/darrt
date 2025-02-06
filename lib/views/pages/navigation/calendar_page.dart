import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:minimaltodo/data_models/task.dart';
import 'package:minimaltodo/helpers/mini_logger.dart';
import 'package:minimaltodo/helpers/mini_utils.dart';
import 'package:minimaltodo/services/database_service.dart';
import 'package:minimaltodo/services/task_service.dart';
import 'package:minimaltodo/views/widgets/empty_list_placeholder.dart';
import 'package:provider/provider.dart';
import 'package:minimaltodo/view_models/task_view_model.dart';
import 'package:minimaltodo/view_models/calendar_view_model.dart';
import 'package:minimaltodo/views/widgets/task_item.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   context.read<CalendarViewModel>().restoreScrollPosition();
    // });
  }

  @override
  void deactivate() {
    // context.read<CalendarViewModel>().saveScrollPosition();
    super.deactivate();
  }

  void _deleteSelectedTasks(BuildContext context, TaskViewModel taskVM, CalendarViewModel calendarVM) {
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
    return Consumer2<TaskViewModel, CalendarViewModel>(
      builder: (context, taskVM, calendarVM, _) {
        final tasks = taskVM.tasks;
        final filteredTasks = calendarVM.filterTasks(tasks);
        final tasksForSelectedDate = calendarVM.getTasksForDate(calendarVM.selectedDate, filteredTasks);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                  onPressed: () => _deleteSelectedTasks(context, taskVM, calendarVM),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: Row(
                children: [
                  Text(
                    formatDateWith(calendarVM.selectedDate, 'EEE, d MMM, yyyy'),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                  ),
                  const Spacer(),
                  // Task type toggle
                  InkWell(
                    onTap: calendarVM.cycleTaskFilter,
                    borderRadius: BorderRadius.circular(4), // Optional, for ripple effect shaping
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            calendarVM.getTaskFilterIcon(),
                            size: 18,
                          ),
                          const SizedBox(width: 4), // Space between icon and text
                          Text(
                            calendarVM.getTaskFilterLabel(),
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ScrollableDateBar(),
            Expanded(
              child: tasksForSelectedDate.isEmpty
                  ? Center(
                      child: Text(
                        switch (calendarVM.taskFilter) {
                          TaskFilterType.all => 'No tasks',
                          TaskFilterType.single => 'No single tasks',
                          TaskFilterType.recurring => 'No recurring tasks',
                        },
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: tasksForSelectedDate.length,
                      itemBuilder: (context, index) {
                        final task = tasksForSelectedDate[index];
                        return TaskItem(
                          key: ValueKey('task_${task.id}'),
                          task: task.toLightweightEntity(),
                          onLongPress: () => calendarVM.toggleTaskSelection(task),
                          isSelected: calendarVM.selectedTaskIds.contains(task.id),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  // Future<List<Task>> getTasks(TaskFilterType taskFilter) async {
  //   final tasks = await TaskService.getTasks();
  //   if (taskFilter == TaskFilterType.all) {
  //     return tasks;
  //   }
  //   if (taskFilter == TaskFilterType.single) {
  //     return tasks.where((t) => !t.isRepeating!).toList();
  //   } else {
  //     return tasks.where((t) => t.isRepeating!).toList();
  //   }
  // }
}

class ScrollableDateBar extends StatelessWidget {
  const ScrollableDateBar({super.key});

  @override
  Widget build(BuildContext context) {
    MiniLogger.debug('Scrollable Date bar rebuilt');
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 80,
      child: Consumer<CalendarViewModel>(builder: (context, calendarVM, _) {
        return ListView.builder(
          controller: calendarVM.dateScrollController,
          scrollDirection: Axis.horizontal,
          itemExtent: calendarVM.dateItemWidth,
          physics: const BouncingScrollPhysics(),
          itemCount: calendarVM.dates.length,
          itemBuilder: (context, index) {
            final date = calendarVM.dates[index];
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
          },
        );
      }),
    );
  }
}
