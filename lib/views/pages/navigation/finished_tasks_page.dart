import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:minimaltodo/data_models/task.dart';
import 'package:minimaltodo/view_models/task_view_model.dart';
import 'package:minimaltodo/views/widgets/task_item.dart';
import 'package:provider/provider.dart';

class FinishedTasksPage extends StatefulWidget {
  const FinishedTasksPage({super.key});

  @override
  State<FinishedTasksPage> createState() => _FinishedTasksPageState();
}

class _FinishedTasksPageState extends State<FinishedTasksPage> {
  final Set<int> _selectedTaskIds = {};
  bool _isSelectionMode = false;

  void _toggleTaskSelection(Task task) {
    setState(() {
      if (_selectedTaskIds.contains(task.id)) {
        _selectedTaskIds.remove(task.id);
        if (_selectedTaskIds.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedTaskIds.add(task.id!);
        _isSelectionMode = true;
      }
    });
  }

  void _startSelectionMode(Task task) {
    if (!_isSelectionMode) {
      setState(() {
        _isSelectionMode = true;
        _selectedTaskIds.add(task.id!);
      });
    }
  }

  void _clearSelection() {
    setState(() {
      _selectedTaskIds.clear();
      _isSelectionMode = false;
    });
  }

  Widget _buildTaskItem(Task task) {
    final isSelected = _selectedTaskIds.contains(task.id);
    return TaskItem(
      key: ValueKey(task.id),
      task: task,
      isSelected: isSelected,
      isSelectionMode: _isSelectionMode,
      onLongPress: () => _startSelectionMode(task),
      onSelect: (selected) => _toggleTaskSelection(task),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskViewModel>(
      builder: (context, tvm, _) {
        List<Task> tasks = tvm.tasks;
        List<Task> finished = tasks.where((task) => task.isDone ?? false).toList()
          ..sort((a, b) => b.finishedAt!.compareTo(a.finishedAt!)); // Sort by newest first
        Color color = Theme.of(context).colorScheme.onSurfaceVariant.withAlpha(100);
        if (finished.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline, size: 50,color:color,),
                const SizedBox(height: 16),
                Text(
                  'No finished tasks yet',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500,color: color,),
                ),
              ],
            ),
          );
        }

        // Group tasks by completion date
        final groupedTasks = <DateTime, List<Task>>{};
        for (var task in finished) {
          final date = task.finishedAt!;
          final dateOnly = DateTime(date.year, date.month, date.day);
          if (!groupedTasks.containsKey(dateOnly)) {
            groupedTasks[dateOnly] = [];
          }
          groupedTasks[dateOnly]!.add(task);
        }

        // Sort dates in reverse order (newest first)
        final sortedDates = groupedTasks.keys.toList()..sort((a, b) => b.compareTo(a));

        return Column(
          children: [
            if (_isSelectionMode)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: _clearSelection,
                    ),
                    Text(
                      '${_selectedTaskIds.length} selected',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Tasks'),
                            content: Text('Delete ${_selectedTaskIds.length} tasks?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  for (var id in _selectedTaskIds) {
                                    final task = tasks.firstWhere((t) => t.id == id);
                                    tvm.deleteTask(task);
                                  }
                                  _clearSelection();
                                  Navigator.pop(context);
                                  // showToast(title: 'Tasks deleted');
                                },
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            Expanded(
              child: ListView(
                children: [
                  ...sortedDates.map((date) {
                    final tasksForDate = groupedTasks[date]!;
                    String dateTitle;
                    final now = DateTime.now();
                    if (date.year == now.year && date.month == now.month && date.day == now.day) {
                      dateTitle = 'Today';
                    } else if (date.year == now.year && date.month == now.month && date.day == now.subtract(const Duration(days: 1)).day) {
                      dateTitle = 'Yesterday';
                    } else {
                      dateTitle = DateFormat('E, MMMM d, y').format(date);
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            dateTitle,
                            style: TextStyle(
                              fontSize: Theme.of(context).textTheme.titleSmall!.fontSize,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        ...tasksForDate.map((task) => _buildTaskItem(task)),
                        const SizedBox(height: 8),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
