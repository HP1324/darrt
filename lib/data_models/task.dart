import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:minimaltodo/data_models/category_model.dart';
import 'package:minimaltodo/helpers/mini_logger.dart';

class Task {
  Task({
    this.id,
    this.title,
    this.isDone = false,
    this.createdAt,
    this.dueDate,
    this.finishedAt,
    this.isNotifyEnabled = false,
    this.notifyTime,
    this.notifType = 'notif',
    this.priority = 'Low',
    this.isRepeating = false,
    DateTime? startDate,
    this.endDate,
    this.repeatConfig,
    this.reminderTimes,
  }) : startDate = startDate ?? DateTime.now();

  int? id;
  String? title;
  bool? isDone;
  DateTime? createdAt;
  DateTime? dueDate;
  DateTime? finishedAt;
  bool? isNotifyEnabled;
  DateTime? notifyTime;
  String? notifType;
  String? priority;
  bool? isRepeating;

  // NEW FIELDS – For repeating tasks only. If task is not repeating these may be ignored.
  DateTime startDate; // defaults to now if not provided
  DateTime? endDate; // null means repeat indefinitely
  String? repeatConfig; // JSON string, e.g. {"repeatType": "weekly", "selectedDays": [1,3,5]}
  String? reminderTimes;

  Task copyWith({
    int? id,
    String? title,
    bool? isDone,
    DateTime? createdAt,
    DateTime? dueDate,
    DateTime? finishedAt,
    bool? isNotifyEnabled,
    DateTime? notifyTime,
    String? notifType,
    String? priority,
    bool? isRepeating,
    DateTime? startDate,
    DateTime? endDate,
    String? repeatConfig,
    String? reminderTimes,
  }) =>
      Task(
        id: id ?? this.id,
        title: title ?? this.title,
        isDone: isDone ?? this.isDone,
        createdAt: createdAt ?? this.createdAt,
        dueDate: dueDate ?? this.dueDate,
        finishedAt: finishedAt ?? this.finishedAt,
        isNotifyEnabled: isNotifyEnabled ?? this.isNotifyEnabled,
        notifyTime: notifyTime ?? this.notifyTime,
        notifType: notifType ?? this.notifType,
        priority: priority ?? this.priority,
        isRepeating: isRepeating ?? this.isRepeating,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        repeatConfig: repeatConfig ?? this.repeatConfig,
      );

  void printTask() {
    if (kDebugMode) {
      MiniLogger.debug("""
          Task{
           'id': $id,
           'title': $title,
           'isDone': $isDone,
           'createdAt': $createdAt,
           'dueDate': $dueDate,
           'finishedAt': $finishedAt,
           'isNotifyEnabled': $isNotifyEnabled,
           'notifyTime': $notifyTime,
           'notifType': $notifType,
           'priority': $priority,
           'isRepeating': $isRepeating,
           'startDate': ${startDate.toIso8601String()},
           'endDate': ${endDate?.toIso8601String()},
           'repeatConfig': $repeatConfig,
           'reminderTimes': $reminderTimes,
          }
          """);
    }
  }

  @override
  bool operator ==(Object other) {
    return other is Task &&
        id == other.id &&
        title == other.title &&
        isDone == other.isDone &&
        createdAt == other.createdAt &&
        dueDate == other.dueDate &&
        finishedAt == other.finishedAt &&
        isNotifyEnabled == other.isNotifyEnabled &&
        notifyTime == other.notifyTime &&
        notifType == other.notifType &&
        priority == other.priority &&
        isRepeating == other.isRepeating &&
        startDate == other.startDate &&
        endDate == other.endDate &&
        repeatConfig == other.repeatConfig &&
        reminderTimes == other.reminderTimes;
  }

  @override
  int get hashCode => Object.hash(
        id,
        title,
        isDone,
        createdAt,
        dueDate,
        finishedAt,
        isNotifyEnabled,
        notifyTime,
        notifType,
        priority,
        isRepeating,
        startDate,
        endDate,
        repeatConfig,
        reminderTimes,
      );

  bool isValid() {
    return title != null && title!.trim().isNotEmpty;
  }

  bool isOverdue() {
    if (dueDate != null && dueDate!.isBefore(DateTime.now()) && (isDone == false)) {
      return true;
    }
    return false;
  }

  // Convert Task to JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'createdAt': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
        'dueDate': dueDate?.toIso8601String(),
        'finishedAt': finishedAt?.toIso8601String(),
        'isDone': isDone! ? 1 : 0,
        'isNotifyEnabled': isNotifyEnabled! ? 1 : 0,
        'notifyTime': notifyTime?.toIso8601String(),
        'notifType': notifType,
        'priority': priority,
        'isRepeating': isRepeating! ? 1 : 0,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
        'repeatConfig': repeatConfig,
        'reminderTimes': reminderTimes,
      };

  // Create a Task from JSON
  factory Task.fromJson(Map<String, dynamic> json) {
    try {
      return Task(
        id: json['id'],
        title: json['title'] ?? '',
        isDone: json['isDone'] == 1,
        createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
        dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
        finishedAt: json['finishedAt'] != null ? DateTime.parse(json['finishedAt']) : null,
        isNotifyEnabled: json['isNotifyEnabled'] == 1,
        notifyTime: json['notifyTime'] != null ? DateTime.parse(json['notifyTime']) : null,
        notifType: json['notifType'],
        priority: json['priority'],
        isRepeating: json['isRepeating'] == 1,
        startDate: json['startDate'] != null ? DateTime.parse(json['startDate']) : DateTime.now(),
        endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
        repeatConfig: json['repeatConfig'],
        reminderTimes: json['reminderTimes'],
      );
    } catch (e) {
      MiniLogger.error('Error parsing task from JSON: $e');
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
