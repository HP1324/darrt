import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:minimaltodo/task/models/task.dart';
import 'package:minimaltodo/task/ui/task_note_bottom_sheet.dart';

import '../../helpers/globals.dart' as g show timerController, taskVm,soundController, taskSc;

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
      listenable: g.taskVm,
      builder: (context, child) {
        final task = widget.task;
        final repeat = task.isRepeating;
        final repeatingCompletions = g.taskVm.repeatingTaskCompletions;
        final oneTimeCompletions = g.taskVm.onetimeTaskCompletions;
        final date = DateUtils.dateOnly(DateTime.now()).millisecondsSinceEpoch;

        return Row(
          children: [
            Transform.scale(
              scale: 1.1,
              child: Checkbox(
                shape: StadiumBorder(),
                value: repeat
                    ? repeatingCompletions[task.id]?.contains(date) ?? false
                    : oneTimeCompletions[task.id] ?? false,
                onChanged: (newValue) async {
                  if (newValue != null) {
                    g.taskVm.toggleStatus(task, newValue, DateTime.now());
                  }
                },
              ),
            ),
            Expanded(child: Text(task.title)),
            IconButton(onPressed: ()async{
              await showModalBottomSheet(
              context: context,
              builder: (context) => TaskNoteBottomSheet(task: task,controller: g.taskVm),
              );
            }, icon: Icon(Icons.note_alt_outlined)),
            Transform.scale(
              scale: 0.4,
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
