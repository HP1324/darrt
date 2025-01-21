import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:minimaltodo/theme/app_theme.dart';
import 'package:minimaltodo/view_models/task_view_model.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class ProductivityStatsPage extends StatelessWidget {
  const ProductivityStatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(15),
        elevation: 0,
        title: Text(
          'Productivity Stats',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer<TaskViewModel>(
        builder: (context, taskVM, _) {
          final totalTasks = taskVM.tasks.length;
          final completedTasks = taskVM.tasks.where((task) => task.isDone!).length;
          final pendingTasks = totalTasks - completedTasks;
          final completionRate = totalTasks > 0 ? (completedTasks / totalTasks * 100).toStringAsFixed(1) : '0.0';

          // Calculate tasks by priority
          final urgentPriorityTasks = taskVM.tasks.where((task) => task.priority == 'Urgent').length;
          final highPriorityTasks = taskVM.tasks.where((task) => task.priority == 'High').length;
          final mediumPriorityTasks = taskVM.tasks.where((task) => task.priority == 'Medium').length;
          final lowPriorityTasks = taskVM.tasks.where((task) => task.priority == 'Low').length;

          // Find max tasks for chart scaling
          final maxTasks = [urgentPriorityTasks, highPriorityTasks, mediumPriorityTasks, lowPriorityTasks]
              .reduce((curr, next) => curr > next ? curr : next)
              .toDouble();

          // Calculate tasks completed today
          final today = DateTime.now();
          final todaysTasks = taskVM.tasks
              .where((task) =>
                  task.dueDate != null && task.dueDate!.year == today.year && task.dueDate!.month == today.month && task.dueDate!.day == today.day)
              .toList();

          final tasksCompletedToday = todaysTasks
              .where((task) =>
                  task.isDone! &&
                  task.finishedAt != null &&
                  task.finishedAt!.year == today.year &&
                  task.finishedAt!.month == today.month &&
                  task.finishedAt!.day == today.day)
              .length;

          // Calculate weekly progress
          final List<Map<String, dynamic>> weeklyData = [];
          for (int i = 6; i >= 0; i--) {
            final date = DateTime.now().subtract(Duration(days: i));
            final tasksForDay = taskVM.tasks
                .where((task) =>
                    task.dueDate != null && task.dueDate!.year == date.year && task.dueDate!.month == date.month && task.dueDate!.day == date.day)
                .toList();

            final completedTasks = tasksForDay
                .where((task) =>
                    task.isDone! &&
                    task.finishedAt != null &&
                    task.finishedAt!.year == date.year &&
                    task.finishedAt!.month == date.month &&
                    task.finishedAt!.day == date.day)
                .length;

            weeklyData.add({
              'date': date,
              'total': tasksForDay.length,
              'completed': completedTasks,
            });
          }

          // Find max tasks for weekly chart scaling
          final maxWeeklyTasks = weeklyData.map((data) => data['total'] as int).reduce((curr, next) => curr > next ? curr : next).toDouble();

          // Calculate monthly progress
          final List<Map<String, dynamic>> monthlyData = [];
          for (int i = 29; i >= 0; i--) {
            final date = DateTime.now().subtract(Duration(days: i));
            final tasksForDay = taskVM.tasks
                .where((task) =>
                    task.dueDate != null && task.dueDate!.year == date.year && task.dueDate!.month == date.month && task.dueDate!.day == date.day)
                .toList();

            final completedTasks = tasksForDay
                .where((task) =>
                    task.isDone! &&
                    task.finishedAt != null &&
                    task.finishedAt!.year == date.year &&
                    task.finishedAt!.month == date.month &&
                    task.finishedAt!.day == date.day)
                .length;

            monthlyData.add({
              'date': date,
              'total': tasksForDay.length,
              'completed': completedTasks,
            });
          }

          // Find max tasks for monthly chart scaling
          final maxMonthlyTasks = monthlyData.map((data) => data['total'] as int).reduce((curr, next) => curr > next ? curr : next).toDouble();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Today's Progress Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Today's Progress",
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              DateFormat('MMM d, yyyy').format(today),
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: _CircularProgressIndicator(
                                value: tasksCompletedToday,
                                total: todaysTasks.length,
                                label: 'Completed Today',
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _CircularProgressIndicator(
                                value: completedTasks,
                                total: totalTasks,
                                label: 'Overall Progress',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Tasks by Priority Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tasks by Priority',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 220,
                                child: BarChart(
                                  BarChartData(
                                    alignment: BarChartAlignment.spaceAround,
                                    maxY: maxTasks + 2,
                                    barTouchData: BarTouchData(
                                      enabled: true,
                                      touchTooltipData: BarTouchTooltipData(
                                        tooltipBgColor: Colors.grey[800]!,
                                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                          String priority;
                                          switch (group.x) {
                                            case 0:
                                              priority = 'Urgent';
                                            case 1:
                                              priority = 'High';
                                            case 2:
                                              priority = 'Medium';
                                            case 3:
                                              priority = 'Low';
                                            default:
                                              priority = '';
                                          }
                                          return BarTooltipItem(
                                            '$priority\n${rod.toY.toInt()} tasks',
                                            const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    titlesData: FlTitlesData(
                                      show: true,
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 30,
                                          getTitlesWidget: (value, meta) {
                                            String text = '';
                                            Color color = Colors.black;
                                            switch (value.toInt()) {
                                              case 0:
                                                text = 'Urgent';
                                                color = Colors.red;
                                                break;
                                              case 1:
                                                text = 'High';
                                                color = Colors.purple;
                                                break;
                                              case 2:
                                                text = 'Medium';
                                                color = Colors.orange;
                                                break;
                                              case 3:
                                                text = 'Low';
                                                color = Colors.green;
                                                break;
                                            }
                                            return Padding(
                                              padding: const EdgeInsets.only(top: 8),
                                              child: Text(
                                                text,
                                                style: TextStyle(
                                                  color: color,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      leftTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 30,
                                          getTitlesWidget: (value, meta) {
                                            if (value == value.roundToDouble()) {
                                              return Text(
                                                value.toInt().toString(),
                                                style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 12,
                                                ),
                                              );
                                            }
                                            return const Text('');
                                          },
                                        ),
                                      ),
                                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    ),
                                    borderData: FlBorderData(show: false),
                                    gridData: FlGridData(
                                      show: true,
                                      horizontalInterval: 1,
                                      drawVerticalLine: false,
                                      getDrawingHorizontalLine: (value) {
                                        return FlLine(
                                          color: Colors.grey[300],
                                          strokeWidth: 1,
                                          dashArray: [5, 5],
                                        );
                                      },
                                    ),
                                    barGroups: [
                                      BarChartGroupData(
                                        x: 0,
                                        barRods: [
                                          BarChartRodData(
                                            toY: urgentPriorityTasks.toDouble(),
                                            color: Colors.red[400],
                                            width: 20,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                        ],
                                      ),
                                      BarChartGroupData(
                                        x: 1,
                                        barRods: [
                                          BarChartRodData(
                                            toY: highPriorityTasks.toDouble(),
                                            color: Colors.purple[400],
                                            width: 20,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                        ],
                                      ),
                                      BarChartGroupData(
                                        x: 2,
                                        barRods: [
                                          BarChartRodData(
                                            toY: mediumPriorityTasks.toDouble(),
                                            color: Colors.orange[400],
                                            width: 20,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                        ],
                                      ),
                                      BarChartGroupData(
                                        x: 3,
                                        barRods: [
                                          BarChartRodData(
                                            toY: lowPriorityTasks.toDouble(),
                                            color: Colors.green[400],
                                            width: 20,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Weekly Progress Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Weekly Progress',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 250,
                          child: LineChart(
                            LineChartData(
                              minX: 0,
                              maxX: 6,
                              minY: 0,
                              maxY: maxWeeklyTasks + 2,
                              clipData: FlClipData.all(),
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: true,
                                horizontalInterval: 1,
                                verticalInterval: 1,
                                getDrawingHorizontalLine: (value) {
                                  return FlLine(
                                    color: Colors.grey[300],
                                    strokeWidth: 1,
                                    dashArray: [5, 5],
                                  );
                                },
                                getDrawingVerticalLine: (value) {
                                  return FlLine(
                                    color: Colors.grey[300],
                                    strokeWidth: 1,
                                    dashArray: [5, 5],
                                  );
                                },
                              ),
                              titlesData: FlTitlesData(
                                show: true,
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 30,
                                    getTitlesWidget: (value, meta) {
                                      if (value >= 0 && value <= 6) {
                                        final date = weeklyData[value.toInt()]['date'] as DateTime;
                                        return Padding(
                                          padding: const EdgeInsets.only(top: 8),
                                          child: Text(
                                            DateFormat('EEE').format(date),
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        );
                                      }
                                      return const Text('');
                                    },
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 30,
                                    getTitlesWidget: (value, meta) {
                                      if (value == value.roundToDouble()) {
                                        return Text(
                                          value.toInt().toString(),
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        );
                                      }
                                      return const Text('');
                                    },
                                  ),
                                ),
                                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              ),
                              borderData: FlBorderData(show: false),
                              lineBarsData: [
                                // Total Tasks Line
                                LineChartBarData(
                                  spots: List.generate(7, (index) {
                                    return FlSpot(
                                      index.toDouble(),
                                      weeklyData[index]['total'].toDouble(),
                                    );
                                  }),
                                  isCurved: true,
                                  color: Colors.blue[600],
                                  barWidth: 3,
                                  isStrokeCapRound: true,
                                  dotData: FlDotData(
                                    show: true,
                                    getDotPainter: (spot, percent, barData, index) {
                                      return FlDotCirclePainter(
                                        radius: 6,
                                        color: Colors.white,
                                        strokeWidth: 3,
                                        strokeColor: Colors.blue[600]!,
                                      );
                                    },
                                  ),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    color: Colors.blue[600]!.withAlpha(40),
                                  ),
                                ),
                                // Completed Tasks Line
                                LineChartBarData(
                                  spots: List.generate(7, (index) {
                                    return FlSpot(
                                      index.toDouble(),
                                      weeklyData[index]['completed'].toDouble(),
                                    );
                                  }),
                                  isCurved: true,
                                  color: Colors.green[600],
                                  barWidth: 3,
                                  isStrokeCapRound: true,
                                  dotData: FlDotData(
                                    show: true,
                                    getDotPainter: (spot, percent, barData, index) {
                                      return FlDotCirclePainter(
                                        radius: 6,
                                        color: Colors.white,
                                        strokeWidth: 3,
                                        strokeColor: Colors.green[600]!,
                                      );
                                    },
                                  ),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    color: Colors.green[600]!.withAlpha(40),
                                  ),
                                ),
                              ],
                              lineTouchData: LineTouchData(
                                enabled: true,
                                touchTooltipData: LineTouchTooltipData(
                                  tooltipBgColor: Colors.grey[800]!,
                                  getTooltipItems: (touchedSpots) {
                                    return touchedSpots.map((spot) {
                                      final date = weeklyData[spot.x.toInt()]['date'] as DateTime;
                                      final isTotal = spot.barIndex == 0;
                                      return LineTooltipItem(
                                        '${DateFormat('EEE, MMM d').format(date)}\n${isTotal ? 'Total' : 'Completed'}: ${spot.y.toInt()}',
                                        TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      );
                                    }).toList();
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: Colors.blue[600],
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Total Tasks',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 20),
                            Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: Colors.green[600],
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Completed Tasks',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Monthly Progress Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Monthly Progress',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 250,
                          child: LineChart(
                            LineChartData(
                              minX: 0,
                              maxX: 29,
                              minY: 0,
                              maxY: maxMonthlyTasks + 2,
                              clipData: FlClipData.all(),
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: true,
                                horizontalInterval: 1,
                                verticalInterval: 5,
                                getDrawingHorizontalLine: (value) {
                                  return FlLine(
                                    color: Colors.grey[300],
                                    strokeWidth: 1,
                                    dashArray: [5, 5],
                                  );
                                },
                                getDrawingVerticalLine: (value) {
                                  return FlLine(
                                    color: Colors.grey[300],
                                    strokeWidth: 1,
                                    dashArray: [5, 5],
                                  );
                                },
                              ),
                              titlesData: FlTitlesData(
                                show: true,
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 30,
                                    interval: 5,
                                    getTitlesWidget: (value, meta) {
                                      if (value >= 0 && value <= 29 && value % 5 == 0) {
                                        final date = monthlyData[value.toInt()]['date'] as DateTime;
                                        return Padding(
                                          padding: const EdgeInsets.only(top: 8),
                                          child: Text(
                                            DateFormat('MMM d').format(date),
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        );
                                      }
                                      return const Text('');
                                    },
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 30,
                                    getTitlesWidget: (value, meta) {
                                      if (value == value.roundToDouble()) {
                                        return Text(
                                          value.toInt().toString(),
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        );
                                      }
                                      return const Text('');
                                    },
                                  ),
                                ),
                                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              ),
                              borderData: FlBorderData(show: false),
                              lineBarsData: [
                                // Total Tasks Line
                                LineChartBarData(
                                  spots: List.generate(30, (index) {
                                    return FlSpot(
                                      index.toDouble(),
                                      monthlyData[index]['total'].toDouble(),
                                    );
                                  }),
                                  isCurved: true,
                                  color: Colors.blue[600],
                                  barWidth: 3,
                                  isStrokeCapRound: true,
                                  dotData: FlDotData(
                                    show: false,
                                    getDotPainter: (spot, percent, barData, index) {
                                      return FlDotCirclePainter(
                                        radius: 4,
                                        color: Colors.white,
                                        strokeWidth: 2,
                                        strokeColor: Colors.blue[600]!,
                                      );
                                    },
                                  ),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    color: Colors.blue[600]!.withAlpha(40),
                                  ),
                                ),
                                // Completed Tasks Line
                                LineChartBarData(
                                  spots: List.generate(30, (index) {
                                    return FlSpot(
                                      index.toDouble(),
                                      monthlyData[index]['completed'].toDouble(),
                                    );
                                  }),
                                  isCurved: true,
                                  color: Colors.green[600],
                                  barWidth: 3,
                                  isStrokeCapRound: true,
                                  dotData: FlDotData(
                                    show: false,
                                    getDotPainter: (spot, percent, barData, index) {
                                      return FlDotCirclePainter(
                                        radius: 4,
                                        color: Colors.white,
                                        strokeWidth: 2,
                                        strokeColor: Colors.green[600]!,
                                      );
                                    },
                                  ),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    color: Colors.green[600]!.withAlpha(40),
                                  ),
                                ),
                              ],
                              lineTouchData: LineTouchData(
                                enabled: true,
                                touchTooltipData: LineTouchTooltipData(
                                  tooltipBgColor: Colors.grey[800]!,
                                  getTooltipItems: (List<LineBarSpot> touchedSpots) {
                                    return touchedSpots.map((LineBarSpot touchedSpot) {
                                      final date = monthlyData[touchedSpot.x.toInt()]['date'] as DateTime;
                                      final isTotal = touchedSpot.barIndex == 0;
                                      return LineTooltipItem(
                                        '${DateFormat('MMM d').format(date)}\n${touchedSpot.y.toInt()} ${isTotal ? 'total' : 'completed'}',
                                        const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      );
                                    }).toList();
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Detailed Stats Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Detailed Stats',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _StatItem(
                          icon: Iconsax.task_square,
                          label: 'Total Tasks',
                          value: totalTasks.toString(),
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const Divider(height: 24),
                        _StatItem(
                          icon: Iconsax.tick_square,
                          label: 'Completed',
                          value: completedTasks.toString(),
                          color: Colors.green,
                        ),
                        const Divider(height: 24),
                        _StatItem(
                          icon: Icons.pending_actions,
                          label: 'Pending',
                          value: pendingTasks.toString(),
                          color: Colors.orange,
                        ),
                        const Divider(height: 24),
                        _StatItem(
                          icon: Iconsax.chart_success,
                          label: 'Completion Rate',
                          value: '$completionRate%',
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CircularProgressIndicator extends StatelessWidget {
  final int value;
  final int total;
  final String label;

  const _CircularProgressIndicator({
    required this.value,
    required this.total,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = total > 0 ? value / total : 0.0;
    return Column(
      children: [
        SizedBox(
          width: 120,
          height: 120,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: CircularProgressIndicator(
                  value: percentage,
                  strokeWidth: 8,
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$value/$total',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${(percentage * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
