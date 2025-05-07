import 'package:minimaltodo/task/models/task.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class TaskCompletion{
  @Id()
  int id = 0;
  DateTime date;
  bool isDone;
  final task = ToOne<Task>();

  TaskCompletion({required this.date, required this.isDone});
}