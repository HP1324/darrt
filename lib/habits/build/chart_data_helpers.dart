// ────────────────────────────────────────────────────────────────
// lib/chart_data_helpers.dart
// ────────────────────────────────────────────────────────────────
import 'package:darrt/habits/build/models/build_habit.dart';
import 'package:darrt/task/statistics/task_stats.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';

/// ----------------  compute() argument wrapper  ----------------
class _ChartArgs {
  final BuildHabit habit;
  final BuildHabitStats stats;
  const _ChartArgs(this.habit, this.stats);
}

/// ----------------  PUBLIC FACTORY FUNCTIONS  -----------------
Future<List<Map<String, dynamic>>> buildWeeklyData(
    BuildHabit habit,
    BuildHabitStats stats,
    ) =>
    compute(_weeklyWorker, _ChartArgs(habit, stats));

Future<List<Map<String, dynamic>>> buildMonthlyData(
    BuildHabit habit,
    BuildHabitStats stats,
    ) =>
    compute(_monthlyWorker, _ChartArgs(habit, stats));

Future<List<Map<String, dynamic>>> buildYearlyData(
    BuildHabit habit,
    BuildHabitStats stats,
    ) =>
    compute(_yearlyWorker, _ChartArgs(habit, stats));

/// -----------------------  WORKERS  ----------------------------
List<Map<String, dynamic>> _weeklyWorker(_ChartArgs a) {
  final h = a.habit, s = a.stats;
  final start = h.startDate;
  final end   = h.endDate ?? DateTime.now();
  final out   = <Map<String, dynamic>>[];

  DateTime week = _startOfWeek(start);
  while (!week.isAfter(end)) {
    final weekEnd = week.add(const Duration(days: 6));
    final count   = s.completions.where((d) =>
    !d.isBefore(week) && !d.isAfter(weekEnd)).length;

    out.add({
      'label': DateFormat('MMM dd').format(week),
      'count': count,
      'week' : week,
    });
    week = week.add(const Duration(days: 7));
  }
  return out;
}

List<Map<String, dynamic>> _monthlyWorker(_ChartArgs a) {
  final h = a.habit, s = a.stats;
  final start = DateTime(h.startDate.year, h.startDate.month, 1);
  final end   = h.endDate ?? DateTime.now();
  final out   = <Map<String, dynamic>>[];

  DateTime m = start;
  while (!m.isAfter(end)) {
    final count = s.completions
        .where((d) => d.year == m.year && d.month == m.month)
        .length;

    out.add({
      'label': DateFormat('MMM yy').format(m),
      'count': count,
      'month': m,
    });
    m = DateTime(m.year, m.month + 1, 1);
  }
  return out;
}

List<Map<String, dynamic>> _yearlyWorker(_ChartArgs a) {
  final h = a.habit, s = a.stats;
  final startY = h.startDate.year;
  final endY   = (h.endDate ?? DateTime.now()).year;
  final out = <Map<String, dynamic>>[];

  for (var y = startY; y <= endY; y++) {
    final count = s.completions.where((d) => d.year == y).length;
    out.add({'label': '$y', 'count': count, 'year': y});
  }
  return out;
}

/// -----------------------  HELPERS  ----------------------------
DateTime _startOfWeek(DateTime d) =>
    DateTime(d.year, d.month, d.day - (d.weekday - 1));
