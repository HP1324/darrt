import 'dart:convert';

class TaskStats {
  List<DateTime> completions;
  DateTime? currentStreakStart;
  int currentStreakLength;

  TaskStats({
    this.completions = const [],
    this.currentStreakLength = 0,
    this.currentStreakStart,
  });

  TaskStats copyWith({
    List<DateTime>? completions,
    DateTime? currentStreakStart,
    int? currentStreakLength,
  }) {
    return TaskStats(
      completions: completions ?? this.completions,
      currentStreakStart: currentStreakStart ?? this.currentStreakStart,
      currentStreakLength: currentStreakLength ?? this.currentStreakLength,
    );
  }

  /// Convert the object to a JSON string
  String toJsonString() {
    final map = {
      'completions': completions.map((d) => d.millisecondsSinceEpoch).toList(),
      'currentStreakStart': currentStreakStart?.millisecondsSinceEpoch,
      'currentStreakLength': currentStreakLength,
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
    );
  }
}
