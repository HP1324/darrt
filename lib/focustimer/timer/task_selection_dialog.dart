import 'package:flutter/material.dart';
import 'package:minimaltodo/task/models/task.dart';

import '../../helpers/globals.dart' as g show taskVm, timerController;

class TaskSelectionDialog extends StatefulWidget {
  const TaskSelectionDialog({super.key});

  @override
  State<TaskSelectionDialog> createState() => _TaskSelectionDialogState();
}

class _TaskSelectionDialogState extends State<TaskSelectionDialog> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([g.taskVm, g.timerController]),
      builder: (context, child) {
        final allTasks = g.taskVm.tasks;
        return AlertDialog(
          content: ListView.builder(
            itemCount: allTasks.length,
            itemBuilder: (context, index) {
              return _TaskSelectionItem(task: allTasks[index]);
            },
          ),
        );
      },
    );
  }
}

class _TaskSelectionItem extends StatefulWidget {
  const _TaskSelectionItem({required this.task});
  final Task task;
  @override
  State<_TaskSelectionItem> createState() => _TaskSelectionItemState();
}

class _TaskSelectionItemState extends State<_TaskSelectionItem> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([g.timerController]),
      builder: (context, child) {
        final task = widget.task;
        return Row(
          children: [
            Checkbox(
              value: g.timerController.isTaskSelected(task),
              onChanged: (newValue) {
                if (newValue != null) {
                  if (newValue) {
                    g.timerController.addTask(task);
                  } else {
                    g.timerController.removeTask(task);
                  }
                }
              },
            ),
            Text(task.title),
          ],
        );
      },
    );
  }
}
