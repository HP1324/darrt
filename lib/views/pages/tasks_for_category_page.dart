import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:minimaltodo/data_models/category_model.dart';
import 'package:minimaltodo/data_models/task.dart';
import 'package:minimaltodo/services/category_service.dart';
import 'package:minimaltodo/view_models/task_view_model.dart';
import 'package:minimaltodo/views/widgets/task_item.dart';
import 'package:provider/provider.dart';

class TasksForCategoryPage extends StatefulWidget {
  final CategoryModel list;

  const TasksForCategoryPage({super.key, required this.list});

  @override
  State<TasksForCategoryPage> createState() => _TasksForCategoryPageState();
}

class _TasksForCategoryPageState extends State<TasksForCategoryPage> {
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
    return TaskItem(
      key: ValueKey('task_${task.id}'),
      task: task,
      isSelected: _selectedTaskIds.contains(task.id),
      isSelectionMode: _isSelectionMode,
      onLongPress: () => _startSelectionMode(task),
      onSelect: (_) => _toggleTaskSelection(task),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(30),
        elevation: 0,
        leading: _isSelectionMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: _clearSelection,
              )
            : null,
        title: _isSelectionMode
            ? Text(
                '${_selectedTaskIds.length} selected',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              )
            : Text(
                widget.list.name ?? 'Unnamed List',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
        centerTitle: true,
        actions: _isSelectionMode
            ? [
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
                              final taskVM = context.read<TaskViewModel>();
                              for (var id in _selectedTaskIds) {
                                final task = taskVM.tasks.firstWhere((t) => t.id == id);
                                taskVM.deleteTask(task);
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
              ]
            : null,
      ),
      body: Consumer<TaskViewModel>(
        builder: (context, taskVM, _) {
          final tasksInList =
              taskVM.tasks.where((task) => task.category?.id == widget.list.id).toList();

          if (tasksInList.isEmpty) {
            return Center(
              child: Column(
                spacing: 15,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CategoryService.getIcon(widget.list.iconCode),
                    size: 48,
                    color: CategoryService.getColorFromString(context, widget.list.color),
                  ),
                  Text('No Tasks Yet',style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            );
          }
          final groupedTasks = {};
          for (var task in tasksInList) {
            final date = task.dueDate ?? task.createdAt ?? DateTime.now();
            final dateOnly = DateTime(date.year, date.month, date.day);
            if (!groupedTasks.containsKey(dateOnly)) {
              groupedTasks[dateOnly] = [];
            }
            groupedTasks[dateOnly]!.add(task);
          }

          // Sort dates
          final sortedDates = groupedTasks.keys.toList()..sort((a, b) => a.compareTo(b));

          return ListView.builder(
            itemCount: sortedDates.length,
            itemBuilder: (context, index) {
              final date = sortedDates[index];
              final tasks = groupedTasks[date]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      DateFormat('E, MMMM d, y').format(date),
                      style: TextStyle(
                        fontSize: Theme.of(context).textTheme.titleSmall!.fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ...tasks.map((task) => _buildTaskItem(task)),
                  const SizedBox(height: 8),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
