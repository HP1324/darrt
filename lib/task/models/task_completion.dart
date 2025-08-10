import 'package:darrt/app/services/object_box.dart';
import 'package:darrt/task/models/task.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class TaskCompletion {
  @Id()
  int id;
  DateTime date;
  bool isDone;
  String? taskUuid;
  String? uuid;
  final task = ToOne<Task>();

  TaskCompletion({this.id = 0, required this.date, required this.isDone, String? taskUuid, String? uuid}) : taskUuid = taskUuid ?? '', uuid = uuid ?? '${date.year}${date.month}${date.day}';

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.millisecondsSinceEpoch,
    'isDone': isDone ? 1 : 0,
    'taskId': task.targetId,
    'taskUuid': taskUuid!,
    'uuid' : uuid!,
  };

  factory TaskCompletion.fromJson(Map<String, dynamic> json) {
    final completion = TaskCompletion(
      date: DateTime.fromMillisecondsSinceEpoch(json['date']),
      isDone: json['isDone'] == 1,
      taskUuid: json['taskUuid']!,
      uuid: json['uuid']!,
    );
    completion.id = json['id'];
    completion.task.targetId = json['taskId']; // Relink later
    return completion;
  }

  static List<TaskCompletion> convertJsonListToObjectList(List<Map<String,dynamic>> jsonList) {
    return jsonList.map(TaskCompletion.fromJson).toList();
  }

  static List<Map<String,dynamic>> convertObjectsListToJsonList(List<TaskCompletion> objectList) {
    return objectList.map((completion) => completion.toJson()).toList();
  }
}
