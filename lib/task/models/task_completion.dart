import 'package:minimaltodo/helpers/object_box.dart';
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

  bool equals(TaskCompletion other, {bool? checkIdEquality = false}) {
    if(checkIdEquality! && id != other.id) return false;
    return contentHash() == other.contentHash();
    // Note: Not comparing task relation to avoid circular reference
  }

  String contentHash() =>
      '${date.millisecondsSinceEpoch}|${isDone ? 1 : 0}';

  static void putManyCompletions(List<TaskCompletion> restored) {
    final box = ObjectBox.completionBox;
    final localAll = box.getAll();

    for (var item in restored) {
      final byId = box.get(item.id);

      // 1️⃣ Same ID & same content → skip
      if (byId != null && item.contentHash() == byId.contentHash()) {
        continue;
      }

      // 2️⃣ Same content, different ID → skip
      if (localAll.any((e) => e.contentHash() == item.contentHash())) {
        continue;
      }

      // 3️⃣ Anything else (either same ID different content, or totally new)
      //    zero the ID so put() will insert rather than update
      item.id = 0;
      box.put(item);
    }
  }
}