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

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.millisecondsSinceEpoch,
    'isDone': isDone ? 1 : 0,
    'taskId': task.targetId,
  };

  factory TaskCompletion.fromJson(Map<String, dynamic> json) {
    final completion = TaskCompletion(
      date: DateTime.fromMillisecondsSinceEpoch(json['date']),
      isDone: json['isDone'] == 1,
    );
    completion.id = json['id'];
    completion.task.targetId = json['taskId']; // Relink later
    return completion;
  }

}