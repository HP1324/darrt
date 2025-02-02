import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CalendarViewModel>().restoreScrollPosition();
    });
  }

  @override
  void deactivate() {
    context.read<CalendarViewModel>().saveScrollPosition();
    super.deactivate();
  }

  void _deleteSelectedTasks(BuildContext context, TaskViewModel taskVM,
      CalendarViewModel calendarVM) {
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
        final scheduledTasks =
            taskVM.tasks.where((task) => task.dueDate != null).toList();

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
                  onPressed: () =>
                      _deleteSelectedTasks(context, taskVM, calendarVM),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 2, 16, 2),
              child: Text(
                DateFormat('EEE, d MMM, yyyy').format(calendarVM.selectedDate),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
              ),
            ),
            ScrollableDateBar(
              calendarVM: calendarVM,
              onDateSelected: calendarVM.setSelectedDate,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(top: 16),
                children: [
                  Builder(
                    builder: (context) {
                      final tasksForSelectedDate = calendarVM.getTasksForDate(
                        calendarVM.selectedDate,
                        taskVM.tasks,
                      );

                      if (tasksForSelectedDate.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Iconsax.calendar_1,
                                  size: 64,
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No tasks scheduled for this day',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tap the + button to add a new task',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return Column(
                        children: tasksForSelectedDate
                            .map((task) => TaskItem(
                                  key: ValueKey(
                                      '${task.id}_${task.isDone}_${calendarVM.selectedDate}'),
                                  task: task,
                                  isSelected: calendarVM.selectedTaskIds
                                      .contains(task.id),
                                  isSelectionMode: calendarVM.isSelectionMode,
                                  onLongPress: () =>
                                      calendarVM.toggleTaskSelection(task),
                                  onSelect: (_) =>
                                      calendarVM.toggleTaskSelection(task),
                                ))
                            .toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class ScrollableDateBar extends StatelessWidget {
  final CalendarViewModel calendarVM;
  final ValueChanged<DateTime> onDateSelected;

  const ScrollableDateBar({
    super.key,
    required this.calendarVM,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final taskVM = Provider.of<TaskViewModel>(context);

    return SizedBox(
      height: 80,
      child: ListView.builder(
        controller: calendarVM.scrollController,
        scrollDirection: Axis.horizontal,
        itemExtent: calendarVM.dateItemWidth,
        physics: const BouncingScrollPhysics(),
        itemCount: calendarVM.dates.length,
        itemBuilder: (context, index) {
          final date = calendarVM.dates[index];
          final isSelected =
              calendarVM.isSameDay(date, calendarVM.selectedDate);
          final isToday = calendarVM.isSameDay(date, DateTime.now());

          // Get tasks for this date (including repeating tasks)
          final tasksForDate = calendarVM.getTasksForDate(date, taskVM.tasks);

          return GestureDetector(
            onTap: () => onDateSelected(date),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? colorScheme.primary
                    : isToday
                        ? colorScheme.primaryContainer
                        : colorScheme.surfaceVariant.withAlpha(50),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateFormat('EEE').format(date),
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
                        color: isSelected
                            ? colorScheme.primaryContainer.withAlpha(100)
                            : isToday
                                ? colorScheme.primary.withAlpha(100)
                                : colorScheme.surfaceVariant.withAlpha(30),
                      ),
                      child: Center(
                        child: Text(
                          date.day.toString(),
                          style:
                              Theme.of(context).textTheme.labelMedium?.copyWith(
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
      ),
    );
  }
}
