import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:minimaltodo/data_models/category.dart';
import 'package:minimaltodo/data_models/task.dart';
import 'package:minimaltodo/theme/app_theme.dart';
import 'package:minimaltodo/view_models/task_view_model.dart';
import 'package:minimaltodo/views/task_item.dart';
import 'package:minimaltodo/global_utils.dart';
import 'package:provider/provider.dart';

class CategoryTasksPage extends StatefulWidget {
  final CategoryModel category;

  const CategoryTasksPage({super.key, required this.category});

  @override
  State<CategoryTasksPage> createState() => _CategoryTasksPageState();
}

class _CategoryTasksPageState extends State<CategoryTasksPage> {
  Set<int> _selectedTaskIds = {};
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
    return Scaffold(
      backgroundColor: AppTheme.background50,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
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
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.background50,
                ),
              )
            : Text(
                widget.category.categoryName ?? 'Unnamed List',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.background50,
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
                              showToast(title:'Tasks deleted');
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
          final tasksInCategory = widget.category.categoryId == -1
              ? taskVM.tasks.where((task) => 
                  task.category == null || 
                  task.category?.categoryId == null ||
                  task.category?.categoryName == null
                ).toList()
              : taskVM.tasks
                  .where((task) => task.category?.categoryId == widget.category.categoryId)
                  .toList();

          if (tasksInCategory.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.background100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Iconsax.clipboard_text,
                      size: 48,
                      color: AppTheme.primary.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'No Tasks Yet',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'This list is empty',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            );
          }

          // Group tasks by date
          final groupedTasks = <DateTime, List<Task>>{};
          for (var task in tasksInCategory) {
            final date = task.dueDate ?? task.createdAt ?? DateTime.now();
            final dateOnly = DateTime(date.year, date.month, date.day);
            if (!groupedTasks.containsKey(dateOnly)) {
              groupedTasks[dateOnly] = [];
            }
            groupedTasks[dateOnly]!.add(task);
          }

          // Sort dates
          final sortedDates = groupedTasks.keys.toList()
            ..sort((a, b) => a.compareTo(b));

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
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
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
