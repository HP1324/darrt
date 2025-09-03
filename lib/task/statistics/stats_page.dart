import 'package:darrt/helpers/mini_router.dart';
import 'package:darrt/helpers/utils.dart';
import 'package:darrt/task/models/task.dart';
import 'package:darrt/task/statistics/achievements.dart';
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
      backgroundColor: getSurfaceColor(context),
      appBar: AppBar(
        backgroundColor: getSurfaceColor(context),
        title: Text(widget.task.title.replaceAll('\n', ' ')),
        actions: [
          IconButton(
            onPressed: () => MiniRouter.to(context, AddTaskPage(edit: true, task: widget.task)),
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
            SeeChartsWidget(task: widget.task),
            SafeArea(child: _AchievementsSection()),
          ],
        ),
      ),
    );
  }
}

class SeeChartsWidget extends StatelessWidget {
  const SeeChartsWidget({
    super.key,
    required this.task,
  });

  final Task task;

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.of(context);
    final textTheme = TextTheme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => _showChartsBottomSheet(context),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: scheme.outline.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.bar_chart,
                    color: scheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'View Charts',
                        style: textTheme.titleMedium?.copyWith(
                          color: scheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Weekly, monthly & yearly completion data',
                        style: textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: scheme.onSurfaceVariant,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showChartsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ChartsBottomSheet(task: task),
    );
  }
}

class ChartsBottomSheet extends StatelessWidget {
  const ChartsBottomSheet({
    super.key,
    required this.task,
  });

  final Task task;

  // Future that delays for 800-900ms before resolving
  Future<bool> _delayedChartLoad() async {
    await Future.delayed(const Duration(milliseconds: 850));
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.of(context);
    final mediaQuery = MediaQuery.of(context);

    return Container(
      height: mediaQuery.size.height * 0.7,
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: scheme.onSurfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  'Task Statistics',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurface,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    Icons.close,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Charts content with FutureBuilder
          Expanded(
            child: FutureBuilder<bool>(
              future: _delayedChartLoad(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingState(context);
                }

                if (snapshot.hasError) {
                  return _buildErrorState(context);
                }

                return _buildChartsContent(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    final scheme = ColorScheme.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(scheme.primary),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Loading charts...',
            style: textTheme.titleMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Analyzing your task completion data',
            style: textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    final scheme = ColorScheme.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: scheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load charts',
            style: textTheme.titleMedium?.copyWith(
              color: scheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please try again',
            style: textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartsContent(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        children: [
          const SizedBox(height: 16),
          ListenableBuilder(
            listenable: g.taskVm,
            builder: (context, child) {
              final stats = g.taskVm.currentTaskStats;
              if (stats == null) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Processing task statistics...',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return AnimatedOpacity(
                opacity: 1.0,
                duration: const Duration(milliseconds: 300),
                child: ChartToggleWidget(
                  task: task,
                  stats: stats,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}


class _AchievementsSection extends StatelessWidget {
  const _AchievementsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Builder(
          builder: (innerContext) {
            final scheme = ColorScheme.of(innerContext);
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.emoji_events,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Achievements',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: scheme.primary,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        ListenableBuilder(
          listenable: g.taskVm,
          builder: (context, child) {
            final achievements = g.taskVm.currentTaskStats!.achievements;

            return Container(
              padding: const EdgeInsets.all(10),
              height: 150,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: achievements.length,
                padding: const EdgeInsets.only(left: 16),
                itemBuilder: (context, index) {
                  final achievement = achievements[index];
                  return AchievementItem(achievement: achievement);
                },
              ),
            );
          },
        ),
      ],
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
            child: _WeeklyChartScrollView(
              data: data,
              scheme: scheme,
              textTheme: textTheme,
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getWeeklyData() {
    final startDate = task.startDate;
    final endDate = task.endDate ?? getLastDate();
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

class _WeeklyChartScrollView extends StatefulWidget {
  const _WeeklyChartScrollView({
    required this.data,
    required this.scheme,
    required this.textTheme,
  });

  final List<Map<String, dynamic>> data;
  final ColorScheme scheme;
  final TextTheme textTheme;

  @override
  State<_WeeklyChartScrollView> createState() => _WeeklyChartScrollViewState();
}

class _WeeklyChartScrollViewState extends State<_WeeklyChartScrollView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentWeek();
    });
  }

  void _scrollToCurrentWeek() {
    final now = DateTime.now();
    final currentWeekStart = _getStartOfWeek(now);

    // Find the index of the current week
    int currentWeekIndex = -1;
    for (int i = 0; i < widget.data.length; i++) {
      final weekData = widget.data[i];
      final weekStart = weekData['week'] as DateTime;
      if (weekStart.isAtSameMomentAs(currentWeekStart) ||
          (weekStart.isBefore(currentWeekStart) &&
              weekStart.add(const Duration(days: 6)).isAfter(currentWeekStart))) {
        currentWeekIndex = i;
        break;
      }
    }

    if (currentWeekIndex != -1 && _scrollController.hasClients) {
      final scrollPosition =
          (currentWeekIndex * 50.0) - (MediaQuery.of(context).size.width / 2) + 25;
      _scrollController.animateTo(
        scrollPosition.clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  DateTime _getStartOfWeek(DateTime date) {
    final daysFromMonday = date.weekday - 1;
    return DateTime(date.year, date.month, date.day - daysFromMonday);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: widget.data.length * 50.0,
        child: BarChart(
          BarChartData(
            barTouchData: BarTouchData(enabled: false),
            barGroups: widget.data.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final count = item['count'] as int;

              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: count > 0 ? count.toDouble() : 0.1,
                    color: count > 0
                        ? widget.scheme.primary
                        : widget.scheme.outline.withValues(alpha: 0.3),
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
                    if (index >= 0 && index < widget.data.length) {
                      final count = widget.data[index]['count'] as int;
                      if (count > 0) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            count.toString(),
                            style: widget.textTheme.labelSmall?.copyWith(
                              color: widget.scheme.primary,
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
                    if (index >= 0 && index < widget.data.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          widget.data[index]['label'],
                          style: widget.textTheme.labelSmall?.copyWith(
                            color: widget.scheme.onSurfaceVariant,
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
    );
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
            child: _MonthlyChartScrollView(
              data: data,
              scheme: scheme,
              textTheme: textTheme,
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getMonthlyData() {
    final startDate = task.startDate;
    final endDate = task.endDate ?? getLastDate();
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

class _MonthlyChartScrollView extends StatefulWidget {
  const _MonthlyChartScrollView({
    required this.data,
    required this.scheme,
    required this.textTheme,
  });

  final List<Map<String, dynamic>> data;
  final ColorScheme scheme;
  final TextTheme textTheme;

  @override
  State<_MonthlyChartScrollView> createState() => _MonthlyChartScrollViewState();
}

class _MonthlyChartScrollViewState extends State<_MonthlyChartScrollView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentMonth();
    });
  }

  void _scrollToCurrentMonth() {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month, 1);

    // Find the index of the current month
    int currentMonthIndex = -1;
    for (int i = 0; i < widget.data.length; i++) {
      final monthData = widget.data[i];
      final month = monthData['month'] as DateTime;
      if (month.year == currentMonth.year && month.month == currentMonth.month) {
        currentMonthIndex = i;
        break;
      }
    }

    if (currentMonthIndex != -1 && _scrollController.hasClients) {
      final scrollPosition =
          (currentMonthIndex * 60.0) - (MediaQuery.of(context).size.width / 2) + 30;
      _scrollController.animateTo(
        scrollPosition.clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: widget.data.length * 60.0,
        child: BarChart(
          BarChartData(
            barTouchData: BarTouchData(enabled: false),
            barGroups: widget.data.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final count = item['count'] as int;

              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: count > 0 ? count.toDouble() : 0.1,
                    color: count > 0
                        ? widget.scheme.primary
                        : widget.scheme.outline.withValues(alpha: 0.3),
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
                    if (index >= 0 && index < widget.data.length) {
                      final count = widget.data[index]['count'] as int;
                      if (count > 0) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            count.toString(),
                            style: widget.textTheme.labelSmall?.copyWith(
                              color: widget.scheme.primary,
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
                    if (index >= 0 && index < widget.data.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          widget.data[index]['label'],
                          style: widget.textTheme.labelSmall?.copyWith(
                            color: widget.scheme.onSurfaceVariant,
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
    );
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
            child: _YearlyChartScrollView(
              data: data,
              scheme: scheme,
              textTheme: textTheme,
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getYearlyData() {
    final startDate = task.startDate;
    final endDate = task.endDate ?? getLastDate();
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

class _YearlyChartScrollView extends StatefulWidget {
  const _YearlyChartScrollView({
    required this.data,
    required this.scheme,
    required this.textTheme,
  });

  final List<Map<String, dynamic>> data;
  final ColorScheme scheme;
  final TextTheme textTheme;

  @override
  State<_YearlyChartScrollView> createState() => _YearlyChartScrollViewState();
}

class _YearlyChartScrollViewState extends State<_YearlyChartScrollView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentYear();
    });
  }

  void _scrollToCurrentYear() {
    final now = DateTime.now();
    final currentYear = now.year;

    // Find the index of the current year
    int currentYearIndex = -1;
    for (int i = 0; i < widget.data.length; i++) {
      final yearData = widget.data[i];
      final year = yearData['year'] as int;
      if (year == currentYear) {
        currentYearIndex = i;
        break;
      }
    }

    if (currentYearIndex != -1 && _scrollController.hasClients) {
      final scrollPosition =
          (currentYearIndex * 80.0) - (MediaQuery.of(context).size.width / 2) + 40;
      _scrollController.animateTo(
        scrollPosition.clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: widget.data.length * 80.0,
        child: BarChart(
          BarChartData(
            barTouchData: BarTouchData(enabled: false),
            barGroups: widget.data.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final count = item['count'] as int;

              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: count > 0 ? count.toDouble() : 0.1,
                    color: count > 0
                        ? widget.scheme.primary
                        : widget.scheme.outline.withValues(alpha: 0.3),
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
                    if (index >= 0 && index < widget.data.length) {
                      final count = widget.data[index]['count'] as int;
                      if (count > 0) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            count.toString(),
                            style: widget.textTheme.labelSmall?.copyWith(
                              color: widget.scheme.primary,
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
                    if (index >= 0 && index < widget.data.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          widget.data[index]['label'],
                          style: widget.textTheme.labelSmall?.copyWith(
                            color: widget.scheme.onSurfaceVariant,
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
    );
  }
}

class AchievementItem extends StatelessWidget {
  final Achievement achievement;

  const AchievementItem({
    super.key,
    required this.achievement,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final isUnlocked = achievement.isUnlocked;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      width: 120,
      decoration: BoxDecoration(
        color: isUnlocked
            ? achievement.color.withValues(alpha: 0.08)
            : colorScheme.surfaceContainerHighest,
        border: Border.all(
          color: isUnlocked ? achievement.color : colorScheme.outline.withValues(alpha: 0.4),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: isUnlocked
            ? [
                BoxShadow(
                  color: achievement.color.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            achievement.icon,
            size: 32,
            color: isUnlocked
                ? achievement.color
                : colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 8),
          Text(
            achievement.title,
            style: textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: isUnlocked
                  ? colorScheme.onSurface
                  : colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Text(
              achievement.description,
              style: textTheme.labelSmall?.copyWith(
                fontSize: 10,
                color: isUnlocked
                    ? colorScheme.onSurface.withValues(alpha: 0.6)
                    : colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
