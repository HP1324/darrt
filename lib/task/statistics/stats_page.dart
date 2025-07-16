import 'package:darrt/task/models/task.dart';
import 'package:darrt/task/statistics/stats_calendar_widget.dart';
import 'package:darrt/task/statistics/task_stats.dart';
import 'package:fl_chart/fl_chart.dart';
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            StatsCalendarWidget(task: widget.task),
            _StreakDisplay(),
            _WeeklyProgressChart(stats: g.taskVm.currentTaskStats!),
          ],
        ),
      ),
    );
  }
}

class _StreakDisplay extends StatelessWidget {
  const _StreakDisplay();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: g.taskVm,
      builder: (context, child) {
        return Text('${g.taskVm.currentTaskStats?.currentStreakLength}');
      },
    );
  }
}

class _WeeklyProgressChart extends StatelessWidget {
  const _WeeklyProgressChart({required this.stats});
  final TaskStats stats;
  @override
  Widget build(BuildContext context)
  {
    final data = getWeeklyChartData(stats);
    return SizedBox(height: 300, child: BarChart(getBarChartData(data)));
  }
  List<Map<String, dynamic>> getWeeklyChartData(TaskStats stats) {
    final now = DateUtils.dateOnly(DateTime.now());
    final past7Days = List.generate(7, (i) => now.subtract(Duration(days: 5 - i)));

    return past7Days.map((day) {
      final count = stats.completions.any((d) => DateUtils.isSameDay(d, day)) ? 1 : 0;
      return {
        'date': '${day.month}/${day.day}',
        'count': count,
      };
    }).toList();
  }

  BarChartData getBarChartData(List<Map<String, dynamic>> data) {
    return BarChartData(
      barGroups: data.map((entry) {
        return BarChartGroupData(
          x: data.indexOf(entry),
          barRods: [
            BarChartRodData(
              toY: entry['count'].toDouble(),
              color: Colors.blue,
            ),
          ],
        );
      }).toList(),
      gridData: FlGridData(show: false),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              return Text(data[value.toInt()]['date']);
            },
          ),
        ),
      ),
    );
  }
}

