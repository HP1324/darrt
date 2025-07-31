import 'package:darrt/category/models/entity_category.dart';
import 'package:darrt/habits/build/models/habit_completion.dart';
import 'package:darrt/helpers/globals.dart' as g;
import 'package:darrt/task/models/repeat_config.dart';
import 'package:objectbox/objectbox.dart';

enum MeasurementType { boolean, count }

@Entity()
class BuildHabit {
  @Id()
  int id;
  String name, measurementType, repeatConfig, measurementUnit;
  String? description, color, reminders;
  DateTime startDate;
  DateTime? endDate, startTime, endTime;
  List<String> categoryUuids;
  final String uuid;

  @Backlink()
  final completions = ToMany<HabitCompletion>();

  final categories = ToMany<EntityCategory>();

  BuildHabit({
    this.id = 0,
    required this.name,
    required this.repeatConfig,
    required this.measurementUnit,
    this.description,
    this.measurementType = 'boolean',
    this.endDate,
    this.startTime,
    this.endTime,
    this.reminders,
    this.color = 'primary',
    DateTime? startDate,
    String? uuid,
    List<String>? categoryUuids,
  }) : startDate = startDate ?? DateTime.now(),
       uuid = uuid ?? g.uuid.v4(),
       categoryUuids = categoryUuids ?? [];

  set habitMeasurementType(MeasurementType type) => measurementType = type.name;

  MeasurementType getMeasurementType() =>
      MeasurementType.values.firstWhere((e) => e.name == measurementType);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'measurementType': measurementType,
      'measurementUnit': measurementUnit,
      'repeatConfig': repeatConfig,
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
      repeatConfig: json['repeatConfig'],
      measurementUnit: json['measurementUnit'],
      description: json['description'],
      measurementType: json['measurementType'],
      startDate: DateTime.fromMillisecondsSinceEpoch(json['startDate']),
      endDate: json['endDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['endDate'])
          : null,
      startTime: json['startTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['startTime'])
          : null,
      endTime: json['endTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['endTime'])
          : null,
      reminders: json['reminders'],
      color: json['color'],
      uuid: json['uuid'],
    );
  }

  static List<BuildHabit> convertJsonListToObjectList(List<Map<String, dynamic>> jsonList) {
    return jsonList.map(BuildHabit.fromJson).toList();
  }

  static List<Map<String, dynamic>> convertObjectsListToJsonList(List<BuildHabit> objectList) {
    return objectList.map((habit) => habit.toJson()).toList();
  }

  bool isActiveOn(DateTime targetDate) {
    DateTime onlyDate(DateTime dt) => DateTime(dt.year, dt.month, dt.day);
    final d = onlyDate(targetDate);

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
