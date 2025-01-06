import 'package:flutter/material.dart';
import 'package:minimaltodo/data_models/task.dart';
import 'package:minimaltodo/theme/app_theme.dart';
import 'package:minimaltodo/view_models/task_view_model.dart';
import 'package:minimaltodo/views/widgets/task_item.dart';
import 'package:minimaltodo/global_utils.dart';
import 'package:provider/provider.dart';

class FinishedTasksPage extends StatefulWidget {
  const FinishedTasksPage({super.key});

  @override
  State<FinishedTasksPage> createState() => _FinishedTasksPageState();
}

class _FinishedTasksPageState extends State<FinishedTasksPage> {
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
    return Consumer<TaskViewModel>(
      builder: (context, tvm, _) {
        List<Task> tasks = tvm.tasks;
        List<Task> finished = tasks
            .where((task) => task.isDone ?? false)
            .toList();

        if (finished.isEmpty) {
          return const Center(
            child: Text(
              'No finished tasks yet',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          );
        }

        return Column(
          children: [
            if (_isSelectionMode)
              Container(
                color: AppTheme.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: _clearSelection,
                    ),
                    Text(
                      '${_selectedTaskIds.length} selected',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.white),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Tasks'),
                            content: Text(
                              'Delete ${_selectedTaskIds.length} tasks?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  for (var id in _selectedTaskIds) {
                                    final task =
                                        tasks.firstWhere((t) => t.id == id);
                                    tvm.deleteTask(task);
                                  }
                                  _clearSelection();
                                  Navigator.pop(context);
                                  showToast(title: 'Tasks deleted');
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
              child: ListView.builder(
                itemCount: finished.length,
                itemBuilder: (context, index) {
                  return _buildTaskItem(finished[index]);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
