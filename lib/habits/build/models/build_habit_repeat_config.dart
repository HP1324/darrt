import 'dart:convert';

enum BuildHabitRepeatType {
  daily,
  weekly,
  monthly,
  interval
}

class BuildHabitRepeatConfig {
  final BuildHabitRepeatType type;
  final List<int> days;
  final int interval;
  final List<int> monthlyDates;
  final bool skipWeekends;

  BuildHabitRepeatConfig({
    this.type = BuildHabitRepeatType.daily,
    List<int>? days,
    this.interval = 1,
    List<int>? monthlyDates,
    this.skipWeekends = false,
  }) : days = days ?? (type == BuildHabitRepeatType.weekly ? [1, 2, 3, 4, 5, 6, 7] : []),
        monthlyDates = monthlyDates ?? [];

  BuildHabitRepeatConfig copyWith({
    BuildHabitRepeatType? type,
    List<int>? days,
    int? interval,
    List<int>? monthlyDates,
    bool? skipWeekends,
  }) {
    return BuildHabitRepeatConfig(
      type: type ?? this.type,
      days: days ?? this.days,
      interval: interval ?? this.interval,
      monthlyDates: monthlyDates ?? this.monthlyDates,
      skipWeekends: skipWeekends ?? this.skipWeekends,
    );
  }

  String get description {
    switch (type) {
      case BuildHabitRepeatType.daily:
        return skipWeekends ? 'Daily (weekdays only)' : 'Daily';
      case BuildHabitRepeatType.weekly:
        if (days.length == 7) return 'Daily';
        if (days.length == 5 && !days.contains(6) && !days.contains(7)) return 'Weekdays only';
        if (days.length == 2 && days.contains(6) && days.contains(7)) return 'Weekends only';
        final dayNames = days.map(_getDayName).join(', ');
        return 'Weekly on $dayNames';
      case BuildHabitRepeatType.monthly:
        return 'Monthly on ${monthlyDates.join(', ')}';
      case BuildHabitRepeatType.interval:
        return interval == 1 ? 'Daily' : 'Every $interval days';
    }
  }

  String _getDayName(int day) {
    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return dayNames[day - 1];
  }

  String toJsonString() {
    return jsonEncode({
      'type': type.name,
      'days': days,
      'interval': interval,
      'monthlyDates': monthlyDates,
      'skipWeekends': skipWeekends,
    });
  }

  factory BuildHabitRepeatConfig.fromJsonString(String json) {
    final Map<String, dynamic> data = jsonDecode(json);
    return BuildHabitRepeatConfig(
      type: BuildHabitRepeatType.values.firstWhere(
            (e) => e.name == data['type'],
        orElse: () => BuildHabitRepeatType.daily,
      ),
      days: List<int>.from(data['days'] ?? []),
      interval: data['interval'] ?? 1,
      monthlyDates: List<int>.from(data['monthlyDates'] ?? []),
      skipWeekends: data['skipWeekends'] ?? false,
    );
  }
}
