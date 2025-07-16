import 'dart:convert';

import 'package:darrt/category/models/task_category.dart';
import 'package:darrt/helpers/globals.dart' as g;
import 'package:darrt/helpers/mini_logger.dart';
import 'package:darrt/app/services/object_box.dart';
import 'package:darrt/objectbox.g.dart';
import 'package:darrt/task/models/reminder.dart';
import 'package:darrt/task/models/repeat_config.dart';
import 'package:darrt/task/models/task_completion.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class Task {
  Task({
    this.id = 0,
    required this.title,
    this.createdAt,
    DateTime? dueDate,
    DateTime? startDate,
    this.endDate,
    this.time,
    this.isRepeating = false,
    this.isDone = false,
    this.priority = 'Low',
    this.repeatConfig,
    this.reminders,
    this.notes,
    this.stats,
    String? uuid,
    List<String>? categoryUuids,
  }) : dueDate = dueDate ?? DateTime.now(),
       startDate = startDate ?? DateTime.now(),
       uuid = uuid ?? g.uuid.v4(),
       categoryUuids = categoryUuids ?? [];
  @Id()
  int id;
  String title, priority;
  DateTime? createdAt, endDate, time;
  DateTime dueDate, startDate;
  bool isDone, isRepeating;
  String? reminders, repeatConfig,notes,stats;
  final String uuid;
  List<String> categoryUuids;
  final categories = ToMany<TaskCategory>();
  @Backlink()
  final completions = ToMany<TaskCompletion>();

  ///Whether this task comes under this date
  bool isActiveOn(DateTime targetDate) {
    DateTime onlyDate(DateTime dt) => DateTime(dt.year, dt.month, dt.day);
    final d = onlyDate(targetDate);

    if (!isRepeating) {
      // Single task
      return d.isAtSameMomentAs(onlyDate(dueDate));
    } else {
      // Repeating task
      final start = onlyDate(startDate);
      final end = endDate != null ? onlyDate(endDate!) : null;

      final isInRange = d.isAtSameMomentAs(start) || d.isAfter(start);
      final isBeforeEnd = end == null || d.isAtSameMomentAs(end) || d.isBefore(end);
      if (!(isInRange && isBeforeEnd)) return false;
      final config = RepeatConfig.fromJsonString(repeatConfig ?? '{}');
      if (config.type == 'weekly') {
        return config.days.contains(d.weekday);
      } else if (config.type == 'monthly') {
        return d.day == start.day;
      } else {
        return d.day == start.day && d.month == start.month;
      }
    }
  }

  List<Reminder> get reminderObjects {
    if (reminders == null || reminders == "{}") {
      return [];
    }
    final List<dynamic> decodedReminders = jsonDecode(reminders!);

    return decodedReminders.map((reminder) {
      final id = reminder['id'];
      final timeString = reminder['time'];
      final type = reminder['type'] ?? 'notif';

      return Reminder(id: id, time: Reminder.stringToTime(timeString), type: type);
    }).toList();
  }

  // Convert Task to JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'dueDate': dueDate.millisecondsSinceEpoch,
    'isDone': isDone ? 1 : 0,
    'isRepeating': isRepeating ? 1 : 0,
    'startDate': startDate.millisecondsSinceEpoch,
    'endDate': endDate?.millisecondsSinceEpoch,
    'time' : time?.millisecondsSinceEpoch,
    'repeatConfig': repeatConfig,
    'reminders': reminders,
    'priority': priority,
    'categoryIds': categories.map((c) => c.id).toList(),
    'categoryUuids': categories.map((c) => c.uuid).toList(),
    'uuid': uuid,
    'notes': notes,
  };

  // Create a Task from JSON
  factory Task.fromJson(Map<String, dynamic> json) {
    try {
      final task = Task(
        id: json['id'],
        title: json['title'],
        isDone: json['isDone'] == 1,
        dueDate: DateTime.fromMillisecondsSinceEpoch(json['dueDate']),
        priority: json['priority'],
        isRepeating: json['isRepeating'] == 1,
        startDate: DateTime.fromMillisecondsSinceEpoch(json['startDate']),
        endDate: json['endDate'] != null
            ? DateTime.fromMillisecondsSinceEpoch(json['endDate'])
            : null,
        time: json['time'] != null
            ? DateTime.fromMillisecondsSinceEpoch(json['time'])
            : null,
        repeatConfig: json['repeatConfig'],
        reminders: json['reminders'],
        uuid: json['uuid'],
        categoryUuids: List<String>.from(json['categoryUuids'] ?? []),
        notes: json['notes'],
      );
      // Restore category relations

      final ids = List<int>.from(json['categoryIds'] ?? []);
      //The following won't work and give a TypeError: type List<dynamic> is not a subtype of type List<int> in type cast, the above line works well and got this solution from [https://stackoverflow.com/a/68079173/28525347]
      // final ids = (json['categoryIds'] as List<int>?)?.cast<int>() ?? [];
      final fetched = ObjectBox().categoryBox.getMany(ids);

      final validCategories = <TaskCategory>[];
      final missingIds = <int>[];

      for (int i = 0; i < ids.length; i++) {
        final cat = fetched[i];
        if (cat != null) {
          validCategories.add(cat);
        } else {
          missingIds.add(ids[i]);
        }
      }

      if (missingIds.isNotEmpty) {
        MiniLogger.w('Task "${task.title}" has missing categories: $missingIds. Skipping these.');
      }

      task.categories.addAll(validCategories);

      return task;
    } catch (e) {
      MiniLogger.e('Error parsing task from JSON: ${e.toString()}\nError type: ${e.runtimeType}');
      rethrow;
    }
  }

  Task copyWith({
    int? id,
    String? title,
    String? priority,
    DateTime? createdAt,
    DateTime? endDate,
    DateTime? time,
    DateTime? dueDate,
    DateTime? startDate,
    bool? isDone,
    bool? isRepeating,
    String? reminders,
    String? repeatConfig,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      endDate: endDate ?? this.endDate,
      time: time ?? this.time,
      dueDate: dueDate ?? this.dueDate,
      startDate: startDate ?? this.startDate,
      isDone: isDone ?? this.isDone,
      isRepeating: isRepeating ?? this.isRepeating,
      reminders: reminders ?? this.reminders,
      repeatConfig: repeatConfig ?? this.repeatConfig,
    );
  }

  /// Compares this [Task] with another [Task] to determine equality.
  ///
  /// This method performs a deep comparison between two [Task] objects,
  /// including all primitive fields, nullable [DateTime] fields,
  /// and [ToMany] relations such as [categories] and [completions].
  ///
  /// The [checkIdEquality] parameter allows control over whether the `id`
  /// field is included in the equality check:
  ///
  /// - If `checkIdEquality` is `true`, the `id` values of both tasks
  ///   must match for them to be considered equal.
  /// - If `false` (default), the `id` is ignored, and only the content
  ///   of the task is compared.
  ///
  /// Two [Task]s are considered equal if:
  /// - Their primitive fields (e.g., `title`, `priority`, `isDone`) are equal,
  /// - Their [DateTime] fields (e.g., `createdAt`, `startDate`, `dueDate`) match by value,
  /// - Their [categories] lists contain the same elements (matched by their own `.equals()`),
  /// - Their [completions] lists contain the same elements (also matched by `.equals()`),
  /// - And optionally, their `id` values match (when `checkIdEquality` is `true`).
  ///
  /// Returns `true` if all comparisons match, `false` otherwise.
  bool equals(Task other, {bool? checkIdEquality = false}) {
    if (checkIdEquality! && id != other.id) {
      return false;
    }
    return contentHash() == other.contentHash();
  }

  String contentHash() {
    // Basic fields
    final basicFields = '$title|$priority|$isDone|$isRepeating';

    // DateTime fields (handle nulls for createdAt and endDate, non-null for dueDate and startDate)
    final dateFields =
        '${createdAt?.millisecondsSinceEpoch ?? 'null'}|'
        '${dueDate.millisecondsSinceEpoch}|'
        '${startDate.millisecondsSinceEpoch}|'
        '${endDate?.millisecondsSinceEpoch ?? 'null'}';

    // String fields (handle nulls)
    final stringFields = '${reminders ?? 'null'}|${repeatConfig ?? 'null'}';

    // Categories (sort by name for consistency)
    final catNames = categories.map((c) => c.name).toList()..sort();
    final categoriesStr = catNames.join(',');

    // Completions (sort by date for consistency)
    final completionDates = completions.map((c) => c.date.millisecondsSinceEpoch).toList()..sort();
    final completionsStr = completionDates.join(',');

    return '$basicFields|$dateFields|$stringFields|$categoriesStr|$completionsStr';
  }

  @override
  bool operator ==(Object other) {
    return other is Task && uuid == other.uuid;
  }

  @override
  // TODO: implement hashCode
  int get hashCode => uuid.hashCode;

}

extension TaskUtilities on Task {
  Task toLightweightEntity() {
    return Task(
      id: id,
      title: title,
      isDone: isDone,
      isRepeating: isRepeating,
      dueDate: dueDate,
      priority: priority,
    );
  }

  ///Converting a [Task] object to notification payload object [Map<String,String?>?]
  Map<String, String?>? toNotificationPayload() {
    return {'task': jsonEncode(toJson())};
  }

  ///Converting a notification payload object [Map<String,String?>?] to a [Task] object.
  static Task fromNotificationPayload(Map<String, String?>? payload) {
    return Task.fromJson(jsonDecode(payload!['task']!));
  }
}
