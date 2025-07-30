import 'package:objectbox/objectbox.dart';

enum HabitType { build, quit }

@Entity()
class BuildHabit {
  @Id()
  int id;
  String name;
  String? description;
  DateTime startDate;
  DateTime? endDate, startTime, endTime;
  String? color;

  BuildHabit({
    this.id = 0,
    required this.name,
    this.description,
    required this.startDate,
    this.endDate,
    this.startTime,
    this.endTime,
    this.color = 'primary',
  });


}
