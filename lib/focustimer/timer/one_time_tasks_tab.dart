// one_time_tasks_tab.dart
import 'package:flutter/material.dart';
import 'package:minimaltodo/focustimer/timer/timer_controller.dart';
import 'package:minimaltodo/focustimer/timer/task_selection_item.dart';
import 'package:minimaltodo/helpers/globals.dart' as g;

class OneTimeTasksTab extends StatelessWidget {
  final TimerController controller;

  const OneTimeTasksTab({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.of(context);
    final textTheme = Theme.of(context).textTheme;

    return ListenableBuilder(
      listenable: g.taskVm,
      builder: (context, child) {
        final oneTimeTasks = g.taskVm.tasks.where((task) => !task.isRepeating).toList();

        if (oneTimeTasks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.task_outlined,
                  size: 64,
                  color: scheme.onSurface.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'No one-time tasks',
                  style: textTheme.headlineSmall?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Create some tasks to get started',
                  style: textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          );
        }

        // Group tasks by date
        final groupedTasks = _groupTasksByDate(oneTimeTasks);

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: groupedTasks.length,
          itemBuilder: (context, index) {
            final entry = groupedTasks.entries.elementAt(index);
            final dateKey = entry.key;
            final tasks = entry.value;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: scheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _formatDateHeader(dateKey),
                    style: textTheme.titleSmall?.copyWith(
                      color: scheme.onSecondaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                // Tasks for this date
                ...tasks.map((task) => TaskSelectionItem(
                  task: task,
                  controller: controller,
                  isSelected: controller.selectedTasks.contains(task),
                )),

                const SizedBox(height: 16),
              ],
            );
          },
        );
      },
    );
  }

  Map<String, List<dynamic>> _groupTasksByDate(List<dynamic> tasks) {
    final Map<String, List<dynamic>> grouped = {};
    final now = DateTime.now();

    for (final task in tasks) {
      final dueDate = task.dueDate;
      String dateKey;

      if (dueDate == null) {
        dateKey = 'no_date';
      } else {
        final difference = dueDate.difference(DateTime(now.year, now.month, now.day)).inDays;
        if (difference == 0) {
          dateKey = 'today';
        } else if (difference == 1) {
          dateKey = 'tomorrow';
        } else if (difference > 1) {
          dateKey = 'future_${difference}';
        } else {
          dateKey = 'overdue_${difference.abs()}';
        }
      }

      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(task);
    }

    // Sort groups by priority (today, tomorrow, future dates, overdue, no date)
    final sortedEntries = grouped.entries.toList()..sort((a, b) {
      final aKey = a.key;
      final bKey = b.key;

      if (aKey == 'today') return -1;
      if (bKey == 'today') return 1;
      if (aKey == 'tomorrow') return -1;
      if (bKey == 'tomorrow') return 1;
      if (aKey.startsWith('future') && bKey.startsWith('future')) {
        final aDays = int.parse(aKey.split('_')[1]);
        final bDays = int.parse(bKey.split('_')[1]);
        return aDays.compareTo(bDays);
      }
      if (aKey.startsWith('future')) return -1;
      if (bKey.startsWith('future')) return 1;
      if (aKey.startsWith('overdue') && bKey.startsWith('overdue')) {
        final aDays = int.parse(aKey.split('_')[1]);
        final bDays = int.parse(bKey.split('_')[1]);
        return bDays.compareTo(aDays);
      }
      if (aKey.startsWith('overdue')) return -1;
      if (bKey.startsWith('overdue')) return 1;
      return 0;
    });

    return Map.fromEntries(sortedEntries);
  }

  String _formatDateHeader(String dateKey) {
    if (dateKey == 'today') return 'Today';
    if (dateKey == 'tomorrow') return 'Tomorrow';
    if (dateKey == 'no_date') return 'No Due Date';
    if (dateKey.startsWith('future')) {
      final days = int.parse(dateKey.split('_')[1]);
      return 'In $days days';
    }
    if (dateKey.startsWith('overdue')) {
      final days = int.parse(dateKey.split('_')[1]);
      return 'Overdue ($days days)';
    }
    return dateKey;
  }
}