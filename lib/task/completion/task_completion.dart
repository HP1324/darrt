import 'package:darrt/task/models/task.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class TaskCompletion {
  @Id()
  int id;
  @Property(type:PropertyType.date)
  DateTime date;
  String? taskUuid;
  String? uuid;
  final task = ToOne<Task>();

  TaskCompletion({this.id = 0, required this.date, String? taskUuid, String? uuid}) : taskUuid = taskUuid ?? '', uuid = uuid ?? '${date.year}${date.month}${date.day}';

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.millisecondsSinceEpoch,
    'taskId': task.targetId,
    'taskUuid': taskUuid!,
    'uuid' : uuid!,
  };

  factory TaskCompletion.fromJson(Map<String, dynamic> json) {
    final completion = TaskCompletion(
      date: DateTime.fromMillisecondsSinceEpoch(json['date']),
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
