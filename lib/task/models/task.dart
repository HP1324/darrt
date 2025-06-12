import 'dart:convert';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
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
  })  : dueDate = dueDate ?? DateTime.now(),
        startDate = startDate ?? DateTime.now();
  @Id()
  int id;
  String title,priority;
  DateTime? createdAt, endDate;
  DateTime dueDate,startDate;
  bool isDone,isRepeating;
  String? reminders,repeatConfig;

  final categories = ToMany<CategoryModel>();
  @Backlink()
  final completions = ToMany<TaskCompletion>();

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
        'categoryIds' : categories.map((c)=>c.id).toList(),
      };

  // Create a Task from JSON
  factory Task.fromJson(Map<String, dynamic> json) {
    try {
      final task =  Task(
        id: json['id'],
        title: json['title'],
        isDone: json['isDone'] == 1,
        dueDate: DateTime.fromMillisecondsSinceEpoch(json['dueDate']),
        priority: json['priority'],
        isRepeating: json['isRepeating'] == 1,
        startDate: DateTime.fromMillisecondsSinceEpoch(json['startDate']),
        endDate:json['endDate'] != null ? DateTime.fromMillisecondsSinceEpoch(json['endDate']) : null,
        repeatConfig: json['repeatConfig'],
        reminders: json['reminders'],
      );
      debugPrint('Current Isolate in fromJson ${Isolate.current.debugName}');
      final ids = (json['categoryIds'] as List?)?.cast<int>() ?? [];
      final fetched = ObjectBox.store.box<CategoryModel>().getMany(ids);
      task.categories.addAll(fetched.whereType<CategoryModel>());
      if(kDebugMode){
        debugPrint('Task categories in notification payload: ${task.categories.length}');
      }
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
