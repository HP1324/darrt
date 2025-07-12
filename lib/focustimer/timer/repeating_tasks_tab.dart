// repeating_tasks_tab.dart
import 'package:flutter/material.dart';
import 'package:minimaltodo/focustimer/timer/timer_controller.dart';
import 'package:minimaltodo/focustimer/timer/task_selection_item.dart';
import 'package:minimaltodo/helpers/globals.dart' as g;

class RepeatingTasksTab extends StatefulWidget {
  final TimerController controller;

  const RepeatingTasksTab({super.key, required this.controller});

  @override
  State<RepeatingTasksTab> createState() => _RepeatingTasksTabState();
}

class _RepeatingTasksTabState extends State<RepeatingTasksTab> {
  bool _showTodayOnly = true;

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        // Filter checkbox
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: scheme.surfaceContainer.withValues(alpha: 0.5),
            border: Border(
              bottom: BorderSide(
                color: scheme.outline.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Checkbox(
                value: _showTodayOnly,
                onChanged: (value) {
                  setState(() {
                    _showTodayOnly = value ?? true;
                  });
                },
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Show only tasks active today',
                  style: textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Tasks list
        Expanded(
          child: ListenableBuilder(
            listenable: g.taskVm,
            builder: (context, child) {
              final repeatingTasks = g.taskVm.tasks.where((task) => task.isRepeating).toList();

              if (repeatingTasks.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.repeat,
                        size: 64,
                        color: scheme.onSurface.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No repeating tasks',
                        style: textTheme.headlineSmall?.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Create some repeating tasks to get started',
                        style: textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                );
              }

              // Filter tasks based on checkbox
              final filteredTasks = _showTodayOnly
                  ? repeatingTasks.where((task) => task.isActiveOn(DateTime.now())).toList()
                  : repeatingTasks;

              if (filteredTasks.isEmpty && _showTodayOnly) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.today_outlined,
                        size: 64,
                        color: scheme.onSurface.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No repeating tasks for today',
                        style: textTheme.headlineSmall?.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Uncheck the filter to see all repeating tasks',
                        style: textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredTasks.length,
                itemBuilder: (context, index) {
                  final task = filteredTasks[index];
                  return TaskSelectionItem(
                    task: task,
                    controller: widget.controller,
                    isSelected: widget.controller.selectedTasks.contains(task),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}