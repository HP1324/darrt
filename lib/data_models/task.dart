import 'package:flutter/foundation.dart';
import 'package:minimaltodo/data_models/list_model.dart';
import 'package:minimaltodo/global_utils.dart';

class Task {
  Task({
    this.id,
    this.title,
    this.isDone = false,
    this.list,
    this.createdAt,
    this.dueDate,
    this.finishedAt,
    this.isNotifyEnabled = false,
    this.notifyTime,
    this.notifType = 'notif',
    this.priority = 'Low',
    this.isRepeating = false,
  });

  int? id;
  String? title;
  ListModel? list;
  bool? isDone;
  DateTime? createdAt;
  DateTime? dueDate;
  DateTime? finishedAt;
  bool? isNotifyEnabled;
  DateTime? notifyTime;
  String? notifType;
  String? priority;
  bool? isRepeating;

  Task copyWith({
    int? id,
    String? title,
    bool? isDone,
    ListModel? list,
    String? listIconCode,
    DateTime? createdAt,
    DateTime? dueDate,
    DateTime? finishedAt,
    bool? isNotifyEnabled,
    DateTime? notifyTime,
    String? notifType,
    String? priority,
    bool? isRepeating,
  }) =>
      Task(
        id: id ?? this.id,
        title: title ?? this.title,
        isDone: isDone ?? this.isDone,
        list: list ?? this.list,
        createdAt: createdAt ?? this.createdAt,
        dueDate: dueDate ?? this.dueDate,
        finishedAt: finishedAt ?? this.finishedAt,
        isNotifyEnabled: isNotifyEnabled ?? this.isNotifyEnabled,
        notifyTime: notifyTime ?? this.notifyTime,
        notifType: notifType ?? this.notifType,
        priority: priority ?? this.priority,
        isRepeating: isRepeating ?? this.isRepeating,
      );

  void printTask() {
    if (kDebugMode) {
      logger.d(""" 
          Task{
           'id': $id,
           'title': $title,
           'isDone': $isDone,
           'list': {
             'listId' : ${list?.id},
             'listName': ${list?.name},
             'icon_code': ${list?.iconCode},
           } ,
           'createdAt': $createdAt,
           'dueDate': $dueDate,
           'finishedAt': $finishedAt,
           'isNotifyEnabled': $isNotifyEnabled,
           'notifyTime': $notifyTime,
           'notifType': $notifType,
           'priority': $priority,
           'isRepeating' : $isRepeating,
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
        list == other.list &&
        createdAt == other.createdAt &&
        dueDate == other.dueDate &&
        finishedAt == other.finishedAt &&
        isNotifyEnabled == other.isNotifyEnabled &&
        notifyTime == other.notifyTime &&
        notifType == other.notifType &&
        priority == other.priority &&
        isRepeating == other.isRepeating;
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    isDone,
    list,
    createdAt,
    dueDate,
    finishedAt,
    isNotifyEnabled,
    notifyTime,
    notifType,
    priority,
    isRepeating,
  );

  bool isValid() {
    try {
      return title != null && title!.trim().isNotEmpty;
    } catch (e, st) {
      logger.e('Error occurred: ${e.toString()}');
      logger.e('Stacktrace: ${st.toString()}');
      return false;
    }
  }
  bool isOverdue(){
    if(dueDate!.isBefore(DateTime.now()) && !isDone!){
      return true;
    }
    return false;
  }
  // Convert Task to JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'list_id': list?.id,
    'list_name': list?.name,
    'list_icon_code': list?.iconCode,
    'list_color' : list?.listColor,
    'createdAt': DateTime.now().toIso8601String(),
    'dueDate': dueDate != null
        ? dueDate!.toIso8601String()
        : DateTime.now().toIso8601String(),
    'finishedAt': finishedAt?.toIso8601String(),
    'isDone': isDone! ? 1 : 0,
    'isNotifyEnabled': isNotifyEnabled! ? 1 : 0,
    'notifyTime': notifyTime?.toIso8601String(),
    'notifType': notifType,
    'priority': priority,
    'isRepeating': isRepeating! ? 1 : 0,
  };

  // Create a Task from JSON
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'] ?? '',
      isDone: json['isDone'] == 1,
      list: ListModel(
        id: json['list_id'],
        name: json['list_name'],
        iconCode: json['list_icon_code'],
        listColor: json['list_color'],
      ),// Parse listIconCode from JSON
      createdAt: DateTime.parse(json['createdAt']),
      dueDate:
      json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      finishedAt: json['finishedAt'] != null
          ? DateTime.parse(json['finishedAt'])
          : null,
      isNotifyEnabled: json['isNotifyEnabled'] == 1,
      notifyTime: json['notifyTime'] != null
          ? DateTime.parse(json['notifyTime'])
          : null,
      notifType: json['notifType'],
      priority: json['priority'],
      isRepeating: json['isRepeating'] == 1,
    );
  }
}
