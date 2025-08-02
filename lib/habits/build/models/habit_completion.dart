import 'package:darrt/habits/build/models/build_habit.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class HabitCompletion{
  @Id()
  int id;
  DateTime date;
  String? habitUuid;
  String? uuid;
  bool isDone;
  final habit = ToOne<BuildHabit>();
  HabitCompletion({this.id = 0, required this.date, this.isDone = false,String? habitUuid, String? uuid}) : habitUuid = habitUuid ?? '', uuid = uuid ?? '';
}