import 'dart:convert';

import 'package:darrt/task/statistics/achievements.dart';

class TaskStats {
  List<DateTime> completions;
  DateTime? currentStreakStart;
  int currentStreakLength;
  Map<String, DateTime> achievementUnlocks;

  TaskStats({
    this.completions = const [],
    this.currentStreakLength = 0,
    this.currentStreakStart,
    this.achievementUnlocks = const {},
  });

  TaskStats copyWith({
    List<DateTime>? completions,
    DateTime? currentStreakStart,
    int? currentStreakLength,
    Map<String, DateTime>? achievementUnlocks,
  }) {
    return TaskStats(
      completions: completions ?? this.completions,
      currentStreakStart: currentStreakStart ?? this.currentStreakStart,
      currentStreakLength: currentStreakLength ?? this.currentStreakLength,
      achievementUnlocks: achievementUnlocks ?? this.achievementUnlocks,
    );
  }

  /// Convert the object to a JSON string
  String toJsonString() {
    final map = {
      'completions': completions.map((d) => d.millisecondsSinceEpoch).toList(),
      'currentStreakStart': currentStreakStart?.millisecondsSinceEpoch,
      'currentStreakLength': currentStreakLength,
      'achievementUnlocks': achievementUnlocks.map((k, v) => MapEntry(k, v.millisecondsSinceEpoch)),
    };
    return jsonEncode(map);
  }

  /// Create an object from a JSON string
  static TaskStats fromJsonString(String? jsonString) {
    if (jsonString == null || jsonString.trim().isEmpty) return TaskStats();

    final map = jsonDecode(jsonString);

    return TaskStats(
      completions:
          (map['completions'] as List<dynamic>?)
              ?.map((d) => DateTime.fromMillisecondsSinceEpoch(d as int))
              .toList() ??
          [],
      currentStreakStart: map['currentStreakStart'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['currentStreakStart'])
          : null,
      currentStreakLength: map['currentStreakLength'] ?? 0,
      achievementUnlocks: (map['achievementUnlocks'] as Map?)?.map(
            (key, value) => MapEntry(key as String, DateTime.fromMillisecondsSinceEpoch(value)),
      ) ??
          {},
    );
  }
}
extension AchievementMapper on TaskStats {
  List<Achievement> get achievements {
    final templates = Achievement.getAchievementTemplates();

    return templates.map((template) {
      final unlockedDate = achievementUnlocks[template.id];
      return template.copyWith(
        isUnlocked: unlockedDate != null,
        unlockedDate: unlockedDate,
      );
    }).toList();
  }
}
