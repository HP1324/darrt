import 'package:flutter/material.dart';
import 'package:minimaltodo/view_models/task_view_model.dart';
import 'package:minimaltodo/views/widgets/task_item.dart';
import 'package:provider/provider.dart';

class TaskSelectionPage extends StatefulWidget {
  const TaskSelectionPage({super.key});

  @override
  State<TaskSelectionPage> createState() => _TaskSelectionPageState();
}

class _TaskSelectionPageState extends State<TaskSelectionPage> {
  final Set<int> _selectedTaskIds = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          _selectedTaskIds.isEmpty 
              ? 'Select Tasks' 
              : '${_selectedTaskIds.length} Selected',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          if (_selectedTaskIds.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
              onPressed: () {
                // Handle bulk delete
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Tasks'),
                    content: Text(
                      'Are you sure you want to delete ${_selectedTaskIds.length} tasks?'
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          // Delete selected tasks
                          final taskVM = Provider.of<TaskViewModel>(
                            context, 
                            listen: false
                          );
                          for (final taskId in _selectedTaskIds) {
                            final task = taskVM.tasks.firstWhere(
                              (t) => t.id == taskId
                            );
                            taskVM.deleteTask(task);
                          }
                          _selectedTaskIds.clear();
                          Navigator.pop(context);
                          setState(() {});
                        },
                        child: const Text(
                          'Delete',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: Consumer<TaskViewModel>(
        builder: (context, taskVM, _) {
          final tasks = taskVM.tasks;
          
          if (tasks.isEmpty) {
            return const Center(
              child: Text('No tasks available'),
            );
          }

          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              final isSelected = _selectedTaskIds.contains(task.id);
              
              return TaskItem(
                key: ValueKey('task_${task.id}'),
                task: task,
                isSelected: _selectedTaskIds.contains(task.id),
                isSelectionMode: true,
                onSelect: (_) {
                  setState(() {
                    if (_selectedTaskIds.contains(task.id)) {
                      _selectedTaskIds.remove(task.id);
                    } else {
                      _selectedTaskIds.add(task.id!);
                    }
                  });
                },
              );
            },
          );
        },
      ),
    );
  }
}
