import 'package:flutter/material.dart';
import 'package:darrt/focustimer/timer/task_selection_dialog.dart';
import 'package:darrt/focustimer/timer/timer_task_item.dart';

import '../../helpers/globals.dart' as g show timerController;

class TimerTaskSelectionExpansionTile extends StatefulWidget {
  const TimerTaskSelectionExpansionTile({super.key});

  @override
  State<TimerTaskSelectionExpansionTile> createState() => _TimerTaskSelectionExpansionTileState();
}

class _TimerTaskSelectionExpansionTileState extends State<TimerTaskSelectionExpansionTile> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: g.timerController,
      builder: (context, child) {
        final tasks = g.timerController.selectedTasks;
        return ExpansionTile(
          shape: RoundedRectangleBorder(),
          maintainState: true,
          title: Text('Tasks in progress'),
          children: [
            if (tasks.isEmpty) _EmptyTaskTimerListIndicator(),
            ...tasks.map((task) {
              return TimerTaskItem(task: task);
            }),
            _SelectTasksButton(),
          ],
        );
      },
    );
  }
}

class _EmptyTaskTimerListIndicator extends StatelessWidget {
  const _EmptyTaskTimerListIndicator();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'No tasks selected',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectTasksButton extends StatelessWidget {
  const _SelectTasksButton();

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () async {
        await showDialog(
          context: context,
          builder: (context) => TaskSelectionDialog(),
        );
      },
      icon: Icon(Icons.add),
      label: Text('Select Tasks'),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    );
  }
}
