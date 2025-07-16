import 'package:darrt/task/models/task.dart';
import 'package:darrt/task/statistics/stats_calendar_widget.dart';
import 'package:flutter/material.dart';

import '../../helpers/globals.dart' as g show taskVm;
class StatsPage extends StatefulWidget {
  const StatsPage({super.key, required this.task});
  final Task task;
  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  @override
  void initState() {
    super.initState();
    g.taskVm.initTaskStats(widget.task);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.task.title.replaceAll('\n', ' '))),
      body: Column(
        children: [
          StatsCalendarWidget(task: widget.task),
        ],
      ),
    );
  }
}
