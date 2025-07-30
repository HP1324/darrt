import 'package:darrt/habits/build/models/habit_completion.dart';
import 'package:darrt/helpers/globals.dart' as g;
import 'package:objectbox/objectbox.dart';

enum MeasurementType{ boolean, count}

@Entity()
class BuildHabit {
  @Id()
  int id;
  String name, measurementType;
  String? description,color, reminders;
  DateTime startDate;
  DateTime? endDate, startTime, endTime;
  final String uuid;

  @Backlink()
  final completions = ToMany<HabitCompletion>();

  BuildHabit({
    this.id = 0,
    required this.name,
    this.description,
    this.measurementType = 'boolean',
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
}
