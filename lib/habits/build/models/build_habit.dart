import 'dart:convert';

import 'package:darrt/category/models/entity_category.dart';
import 'package:darrt/habits/build/models/habit_completion.dart';
import 'package:darrt/helpers/globals.dart' as g;
import 'package:darrt/task/models/reminder.dart';
import 'package:objectbox/objectbox.dart';

enum MeasurementType{ boolean, count}

@Entity()
class BuildHabit {
  @Id()
  int id;
  String name, measurementType, measurementUnit;
  String? description,color, reminders;
  DateTime startDate;
  DateTime? endDate, startTime, endTime;
  final String uuid;

  @Backlink()
  final completions = ToMany<HabitCompletion>();

  final categories = ToMany<EntityCategory>();

  BuildHabit({
    this.id = 0,
    required this.name,
    this.description,
    this.measurementType = 'boolean',
    required this.measurementUnit,
    this.endDate,
    this.startTime,
    this.endTime,
    this.reminders,
    this.color = 'primary',
    DateTime? startDate,
    String? uuid,
  }) : startDate = startDate ?? DateTime.now(),
       uuid = uuid ?? g.uuid.v4();

  set habitMeasurementType(MeasurementType type) => measurementType = type.name;

  MeasurementType getMeasurementType() => MeasurementType.values.firstWhere((e) => e.name == measurementType);

  Map<String,dynamic> toJson(){
    return {
      'id': id,
      'name': name,
      'description': description,
      'measurementType': measurementType,
      'measurementUnit': measurementUnit,
      'startDate': startDate.millisecondsSinceEpoch,
      'endDate': endDate?.millisecondsSinceEpoch,
      'startTime': startTime?.millisecondsSinceEpoch,
      'endTime': endTime?.millisecondsSinceEpoch,
      'reminders': reminders,
      'color': color,
      'uuid': uuid,
    };
  }

  factory BuildHabit.fromJson(Map<String, dynamic> json) {
    return BuildHabit(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      measurementType: json['measurementType'],
      startDate: DateTime.fromMillisecondsSinceEpoch(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.fromMillisecondsSinceEpoch(json['endDate']) : null,
      startTime: json['startTime'] != null ? DateTime.fromMillisecondsSinceEpoch(json['startTime']) : null,
      endTime: json['endTime'] != null ? DateTime.fromMillisecondsSinceEpoch(json['endTime']) : null,
      reminders: json['reminders'],
      color: json['color'],
      uuid: json['uuid'],
      measurementUnit: json['measurementUnit']
    );

  }

  static List<BuildHabit> convertJsonListToObjectList(List<Map<String, dynamic>> jsonList) {
    return jsonList.map(BuildHabit.fromJson).toList();
  }

  static List<Map<String, dynamic>> convertObjectsListToJsonList(List<BuildHabit> objectList) {
    return objectList.map((habit) => habit.toJson()).toList();
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
}
