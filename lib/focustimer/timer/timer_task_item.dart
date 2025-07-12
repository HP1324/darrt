import 'package:flutter/material.dart';
import 'package:minimaltodo/task/models/task.dart';

import '../../helpers/globals.dart' as g show timerController, taskVm;

class TimerTaskItem extends StatefulWidget {
  const TimerTaskItem({super.key, required this.task});
  final Task task;
  @override
  State<TimerTaskItem> createState() => _TimerTaskItemState();
}

class _TimerTaskItemState extends State<TimerTaskItem> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([g.taskVm]),
      builder: (context, child) {
        final task = widget.task;
        final repeat = task.isRepeating;
        final repeatingCompletions = g.taskVm.repeatingTaskCompletions;
        final oneTimeCompletions = g.taskVm.onetimeTaskCompletions;
        final date = DateTime.now().millisecondsSinceEpoch;
        return Row(
          children: [
            Checkbox(
              value: repeat
                  ? repeatingCompletions[task.id]?.contains(date) ?? false
                  : oneTimeCompletions[task.id] ?? false,
              onChanged: (newValue) async {
                if (newValue != null) {
                  g.taskVm.toggleStatus(task, newValue, DateTime.now());
                  if (newValue) {
                    await Future.delayed(Duration(milliseconds: 900));
                    g.timerController.removeTask(task);
                  }
                }
              },
            ),
            Expanded(child: Text(task.title)),
            Transform.scale(
              scale: 0.6,
              child: IconButton.filled(
                onPressed: () {
                  g.timerController.removeTask(task);
                },
                icon: Icon(Icons.close),
              ),
            ),
          ],
        );
      },
    );
  }
}
