import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:minimaltodo/category/models/category_model.dart';
import 'package:minimaltodo/helpers/mini_logger.dart';
import 'package:minimaltodo/helpers/object_box.dart';
import 'package:minimaltodo/objectbox.g.dart';
import 'package:minimaltodo/task/models/reminder.dart';
import 'package:minimaltodo/task/models/repeat_config.dart';
import 'package:minimaltodo/task/models/task_completion.dart';
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
    this.isRepeating = false,
    this.isDone = false,
    this.priority = 'Low',
    this.repeatConfig,
    this.reminders,
  }) : dueDate = dueDate ?? DateTime.now(),
       startDate = startDate ?? DateTime.now();
  @Id()
  int id;
  String title, priority;
  DateTime? createdAt, endDate;
  DateTime dueDate, startDate;
  bool isDone, isRepeating;
  String? reminders, repeatConfig;

  final categories = ToMany<CategoryModel>();
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
    'repeatConfig': repeatConfig,
    'reminders': reminders,
    'priority': priority,
    'categoryIds': categories.map((c) => c.id).toList(),
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
        repeatConfig: json['repeatConfig'],
        reminders: json['reminders'],
      );
      // Restore category relations


      final ids = List<int>.from(json['categoryIds'] ?? []);
      //The following won't work and give a TypeError: type List<dynamic> is not a subtype of type List<int> in type cast, the above line works well and got this solution from [https://stackoverflow.com/a/68079173/28525347]
      // final ids = (json['categoryIds'] as List<int>?)?.cast<int>() ?? [];
      final fetched = ObjectBox.categoryBox.getMany(ids);

      final validCategories = <CategoryModel>[];
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
      dueDate: dueDate ?? this.dueDate,
      startDate: startDate ?? this.startDate,
      isDone: isDone ?? this.isDone,
      isRepeating: isRepeating ?? this.isRepeating,
      reminders: reminders ?? this.reminders,
      repeatConfig: repeatConfig ?? this.repeatConfig,
    );
  }


// Task equals method
  bool equals(Task other) {
    // Compare basic fields
    if (title != other.title ||
        priority != other.priority ||
        isDone != other.isDone ||
        isRepeating != other.isRepeating ||
        reminders != other.reminders ||
        repeatConfig != other.repeatConfig) {
      return false;
    }

    // Compare DateTime fields (handling null values)
    if (createdAt?.millisecondsSinceEpoch != other.createdAt?.millisecondsSinceEpoch ||
        endDate?.millisecondsSinceEpoch != other.endDate?.millisecondsSinceEpoch ||
        dueDate.millisecondsSinceEpoch != other.dueDate.millisecondsSinceEpoch ||
        startDate.millisecondsSinceEpoch != other.startDate.millisecondsSinceEpoch) {
      return false;
    }

    // Compare categories (ToMany relation)
    if (categories.length != other.categories.length) {
      return false;
    }

    final thisCategoriesSorted = categories.toList()..sort((a, b) => a.name.compareTo(b.name));
    final otherCategoriesSorted = other.categories.toList()..sort((a, b) => a.name.compareTo(b.name));

    for (int i = 0; i < thisCategoriesSorted.length; i++) {
      if (!thisCategoriesSorted[i].equals(otherCategoriesSorted[i])) {
        return false;
      }
    }

    // Compare completions (ToMany relation)
    if (completions.length != other.completions.length) {
      return false;
    }

    final thisCompletionsSorted = completions.toList()..sort((a, b) => a.date.compareTo(b.date));
    final otherCompletionsSorted = other.completions.toList()..sort((a, b) => a.date.compareTo(b.date));

    for (int i = 0; i < thisCompletionsSorted.length; i++) {
      if (!thisCompletionsSorted[i].equals(otherCompletionsSorted[i])) {
        return false;
      }
    }

    return true;
  }
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
