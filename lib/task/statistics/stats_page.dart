import 'package:darrt/helpers/mini_router.dart';
import 'package:darrt/helpers/utils.dart';
import 'package:darrt/task/models/task.dart';
import 'package:darrt/task/statistics/stats_calendar_widget.dart';
import 'package:darrt/task/statistics/task_stats.dart';
import 'package:darrt/task/ui/add_task_page.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

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
      backgroundColor: getScaffoldBackgroundColor(context),
      appBar: AppBar(
        backgroundColor: getScaffoldBackgroundColor(context),
        title: Text(widget.task.title.replaceAll('\n', ' ')),
        actions: [
          IconButton(
            onPressed: () => MiniRouter.to(context, AddTaskPage(edit: true,task: widget.task)),
            icon: const Icon(Iconsax.edit),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            StatsCalendarWidget(task: widget.task),
            const SizedBox(height: 16),
            const StreakDisplayWidget(),
            const SizedBox(height: 16),
            ListenableBuilder(
              listenable: g.taskVm,
              builder: (context, child) {
                final stats = g.taskVm.currentTaskStats;
                if (stats == null) {
                  return const Center(child: CircularProgressIndicator());
                }
                return ChartToggleWidget(
                  task: widget.task,
                  stats: stats,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class StreakDisplayWidget extends StatelessWidget {
  const StreakDisplayWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.of(context);
    final textTheme = TextTheme.of(context);

    return ListenableBuilder(
      listenable: g.taskVm,
      builder: (context, child) {
        final stats = g.taskVm.currentTaskStats;
        if (stats == null) return const SizedBox();

        final currentStreak = stats.currentStreakLength;
        final totalCompletions = stats.completions.length;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                scheme.primary.withValues(alpha: 0.1),
                scheme.primary.withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: scheme.primary.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.local_fire_department,
                        color: scheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Current Streak',
                        style: textTheme.labelLarge?.copyWith(
                          color: scheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    '$currentStreak ${currentStreak > 1 ? 'days' : 'day'}',
                    style: textTheme.headlineSmall?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.emoji_events,
                        color: scheme.secondary,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Total Completions',
                        style: textTheme.labelLarge?.copyWith(
                          color: scheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    '$totalCompletions',
                    style: textTheme.titleLarge?.copyWith(
                      color: scheme.tertiary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class ChartToggleWidget extends StatefulWidget {
  const ChartToggleWidget({
    super.key,
    required this.task,
    required this.stats,
  });

  final Task task;
  final TaskStats stats;

  @override
  State<ChartToggleWidget> createState() => _ChartToggleWidgetState();
}

class _ChartToggleWidgetState extends State<ChartToggleWidget> {
  int selectedIndex = 0;
  final List<String> chartTypes = ['Weekly', 'Monthly', 'Yearly'];

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.of(context);
    final textTheme = TextTheme.of(context);

    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: chartTypes.asMap().entries.map((entry) {
                final index = entry.key;
                final type = entry.value;
                final isSelected = selectedIndex == index;

                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => selectedIndex = index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? scheme.surface : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: scheme.shadow.withValues(alpha: 0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
                        type,
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium?.copyWith(
                          color: isSelected ? scheme.primary : scheme.onSurfaceVariant,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 280,
            child: _getSelectedChart(),
          ),
        ],
      ),
    );
  }

  Widget _getSelectedChart() {
    switch (selectedIndex) {
      case 0:
        return WeeklyChart(task: widget.task, stats: widget.stats);
      case 1:
        return MonthlyChart(task: widget.task, stats: widget.stats);
      case 2:
        return YearlyChart(task: widget.task, stats: widget.stats);
      default:
        return WeeklyChart(task: widget.task, stats: widget.stats);
    }
  }
}

class WeeklyChart extends StatelessWidget {
  const WeeklyChart({
    super.key,
    required this.task,
    required this.stats,
  });

  final Task task;
  final TaskStats stats;

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.of(context);
    final textTheme = TextTheme.of(context);
    final data = _getWeeklyData();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_view_week,
                color: scheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Completions per week',
                style: textTheme.titleMedium?.copyWith(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: data.length * 50.0,
                child: BarChart(
                  BarChartData(
                    barTouchData: BarTouchData(enabled: false),
                    barGroups: data.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      final count = item['count'] as int;

                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: count > 0 ? count.toDouble() : 0.1,
                            color: count > 0
                                ? scheme.primary
                                : scheme.outline.withValues(alpha: 0.3),
                            width: count > 0 ? 16 : 3,
                            borderRadius: BorderRadius.circular(count > 0 ? 6 : 1.5),
                          ),
                        ],
                      );
                    }).toList(),
                    gridData: FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index >= 0 && index < data.length) {
                              final count = data[index]['count'] as int;
                              if (count > 0) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Text(
                                    count.toString(),
                                    style: textTheme.labelSmall?.copyWith(
                                      color: scheme.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                );
                              }
                            }
                            return const SizedBox();
                          },
                        ),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index >= 0 && index < data.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  data[index]['label'],
                                  style: textTheme.labelSmall?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                              );
                            }
                            return const SizedBox();
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getWeeklyData() {
    final startDate = task.startDate;
    final endDate = task.endDate ?? getMaxDate();
    final weeks = <Map<String, dynamic>>[];
    DateTime currentWeek = _getStartOfWeek(startDate);

    while (currentWeek.isBefore(endDate) || currentWeek.isAtSameMomentAs(endDate)) {
      final weekEnd = currentWeek.add(const Duration(days: 6));
      final completionsInWeek = stats.completions.where((completion) {
        return completion.isAfter(currentWeek.subtract(const Duration(days: 1))) &&
            completion.isBefore(weekEnd.add(const Duration(days: 1)));
      }).length;

      weeks.add({
        'label': DateFormat('MMM dd').format(currentWeek),
        'count': completionsInWeek,
        'week': currentWeek,
      });

      currentWeek = currentWeek.add(const Duration(days: 7));
    }

    return weeks;
  }

  DateTime _getStartOfWeek(DateTime date) {
    final daysFromMonday = date.weekday - 1;
    return DateTime(date.year, date.month, date.day - daysFromMonday);
  }
}

class MonthlyChart extends StatelessWidget {
  const MonthlyChart({
    super.key,
    required this.task,
    required this.stats,
  });

  final Task task;
  final TaskStats stats;

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.of(context);
    final textTheme = TextTheme.of(context);
    final data = _getMonthlyData();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_month,
                color: scheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Completions per month',
                style: textTheme.titleMedium?.copyWith(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: data.length * 60.0,
                child: BarChart(
                  BarChartData(
                    barTouchData: BarTouchData(enabled: false),
                    barGroups: data.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      final count = item['count'] as int;

                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: count > 0 ? count.toDouble() : 0.1,
                            color: count > 0
                                ? scheme.primary
                                : scheme.outline.withValues(alpha: 0.3),
                            width: count > 0 ? 20 : 3,
                            borderRadius: BorderRadius.circular(count > 0 ? 8 : 1.5),
                          ),
                        ],
                      );
                    }).toList(),
                    gridData: FlGridData(show: false),

                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index >= 0 && index < data.length) {
                              final count = data[index]['count'] as int;
                              if (count > 0) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Text(
                                    count.toString(),
                                    style: textTheme.labelSmall?.copyWith(
                                      color: scheme.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                );
                              }
                            }
                            return const SizedBox();
                          },
                        ),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index >= 0 && index < data.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  data[index]['label'],
                                  style: textTheme.labelSmall?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                              );
                            }
                            return const SizedBox();
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getMonthlyData() {
    final startDate = task.startDate;
    final endDate = task.endDate ?? getMaxDate();
    final months = <Map<String, dynamic>>[];
    DateTime currentMonth = DateTime(startDate.year, startDate.month, 1);

    while (currentMonth.isBefore(endDate) || currentMonth.isAtSameMomentAs(endDate)) {
      final completionsInMonth = stats.completions.where((completion) {
        return completion.year == currentMonth.year && completion.month == currentMonth.month;
      }).length;

      months.add({
        'label': DateFormat('MMM yy').format(currentMonth),
        'count': completionsInMonth,
        'month': currentMonth,
      });

      currentMonth = DateTime(currentMonth.year, currentMonth.month + 1, 1);
    }

    return months;
  }
}

class YearlyChart extends StatelessWidget {
  const YearlyChart({
    super.key,
    required this.task,
    required this.stats,
  });

  final Task task;
  final TaskStats stats;

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.of(context);
    final textTheme = TextTheme.of(context);
    final data = _getYearlyData();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: scheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Completions per year',
                style: textTheme.titleMedium?.copyWith(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: data.length * 80.0,
                child: BarChart(
                  BarChartData(
                    barTouchData: BarTouchData(enabled: false),
                    barGroups: data.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      final count = item['count'] as int;

                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: count > 0 ? count.toDouble() : 0.1,
                            color: count > 0
                                ? scheme.primary
                                : scheme.outline.withValues(alpha: 0.3),
                            width: count > 0 ? 28 : 4,
                            borderRadius: BorderRadius.circular(count > 0 ? 10 : 2),
                          ),
                        ],
                      );
                    }).toList(),
                    gridData: FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index >= 0 && index < data.length) {
                              final count = data[index]['count'] as int;
                              if (count > 0) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Text(
                                    count.toString(),
                                    style: textTheme.labelSmall?.copyWith(
                                      color: scheme.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                );
                              }
                            }
                            return const SizedBox();
                          },
                        ),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index >= 0 && index < data.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  data[index]['label'],
                                  style: textTheme.labelSmall?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                              );
                            }
                            return const SizedBox();
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getYearlyData() {
    final startDate = task.startDate;
    final endDate = task.endDate ?? getMaxDate();
    final years = <Map<String, dynamic>>[];
    int currentYear = startDate.year;

    while (currentYear <= endDate.year) {
      final completionsInYear = stats.completions.where((completion) {
        return completion.year == currentYear;
      }).length;

      years.add({
        'label': currentYear.toString(),
        'count': completionsInYear,
        'year': currentYear,
      });

      currentYear++;
    }

    return years;
  }
}
