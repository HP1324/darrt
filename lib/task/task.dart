import 'dart:convert';

import 'package:minimaltodo/category/category_model.dart';
import 'package:minimaltodo/helpers/mini_logger.dart';
import 'package:minimaltodo/task/reminder.dart';
import 'package:minimaltodo/task/repeat_config.dart';
import 'package:minimaltodo/task/task_completion.dart';
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
    this.repeatConfig = '{"type" : "weekly","days" : [1,2,3,4,5,6,7]}',
    this.reminders = "{}",
  })  : dueDate = dueDate ?? DateTime.now(),
        startDate = startDate ?? DateTime.now();
  @Id()
  int id;
  String title;
  DateTime? createdAt;
  DateTime dueDate;
  bool isDone;
  String priority;
  bool isRepeating;
  DateTime startDate;
  DateTime? endDate;
  String? reminders;
  String? repeatConfig;

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
      if(!(isInRange && isBeforeEnd)) return false;
      final config = RepeatConfig.fromJsonString(repeatConfig ?? '{}');
      if(config.type == 'weekly'){
        return config.days.contains(d.weekday);
      }else if(config.type == 'monthly'){
        return d.day == start.day;
      }else{
        return d.day == start.day && d.month == start.month;
      }
    }
  }

  List<Reminder> get reminderObjects {
    if(reminders == null || reminders == "{}"){
      return [];
    }
    final List<dynamic>  decodedReminders = jsonDecode(reminders!);

    return decodedReminders.map((reminder){
      final timeString = reminder['time'];
      final type = reminder['type'] ?? 'notif';

      return Reminder(time: Reminder.stringToTime(timeString),type: type);
    }).toList();
  }

  // Convert Task to JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'createdAt': createdAt?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch,
        'dueDate': dueDate.millisecondsSinceEpoch,
        'isDone': isDone ? 1 : 0,
        'isRepeating': isRepeating ? 1 : 0,
        'startDate': startDate.millisecondsSinceEpoch,
        'endDate': endDate?.millisecondsSinceEpoch,
        'repeatConfig': repeatConfig,
        'reminderTimes': reminders,
      };

  // Create a Task from JSON
  factory Task.fromJson(Map<String, dynamic> json) {
    try {
      return Task(
        id: json['id'],
        title: json['title'] ?? '',
        isDone: json['isDone'] == 1,
        createdAt: json['createdAt'] != null ? DateTime.fromMillisecondsSinceEpoch(json['createdAt']) : null,
        dueDate: json['dueDate'] != null ? DateTime.fromMillisecondsSinceEpoch(json['dueDate']) : null,
        priority: json['priority'],
        isRepeating: json['isRepeating'] == 1,
        startDate: json['startDate'] != null ? DateTime.fromMillisecondsSinceEpoch(json['startDate']) : DateTime.now(),
        endDate: json['endDate'] != null ? DateTime.fromMillisecondsSinceEpoch(json['endDate']) : null,
        repeatConfig: json['repeatConfig'],
        reminders: json['reminderTimes'],
      );
    } catch (e) {
      MiniLogger.e('Error parsing task from JSON: $e');
      rethrow;
    }
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
    Map<String, dynamic> taskJson = toJson();
    return {'task': jsonEncode(taskJson)};
  }

  ///Converting a notification payload object [Map<String,String?>?] to a [Task] object.
  static Task fromNotificationPayload(Map<String, String?>? payload) {
    return Task.fromJson(jsonDecode(payload!['task']!));
  }

}
