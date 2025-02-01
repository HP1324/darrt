import 'package:flutter/foundation.dart';
import 'package:minimaltodo/data_models/category_model.dart';
import 'package:minimaltodo/helpers/mini_utils.dart';

class Task {
  Task({
    this.id,
    this.title,
    this.isDone = false,
    this.category,
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
  CategoryModel? category;
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
    CategoryModel? category,
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
        category: category ?? this.category,
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
             'categoryId' : ${category?.id},
             'categoryName': ${category?.name},
             'icon_code': ${category?.iconCode},
             'categoryColor': ${category?.color},
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
        category == other.category &&
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
    category,
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
    'categoryId': category?.id,
    'categoryName': category?.name,
    'catIconCode': category?.iconCode,
    'categoryColor' : category?.color,
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
      category: CategoryModel(
        id: json['categoryId'],
        name: json['categoryName'],
        iconCode: json['catIconCode'],
        color: json['categoryColor'],
      ),
      createdAt: DateTime.parse(json['createdAt']),
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      finishedAt: json['finishedAt'] != null ? DateTime.parse(json['finishedAt']) : null,
      isNotifyEnabled: json['isNotifyEnabled'] == 1,
      notifyTime: json['notifyTime'] != null ? DateTime.parse(json['notifyTime']) : null,
      notifType: json['notifType'],
      priority: json['priority'],
      isRepeating: json['isRepeating'] == 1,
    );
  }
}
