import 'dart:async';

import 'package:darrt/helpers/mini_logger.dart';
import 'package:darrt/objectbox.g.dart';
import 'package:darrt/task/completion/task_completion.dart';
import 'package:darrt/task/models/task.dart';

class TaskRepository {
  TaskRepository(this._taskBox, this._completionBox);

  final Box<Task> _taskBox;

  final Box<TaskCompletion> _completionBox;

  void putTask(Task task){
    try {
      _taskBox.put(task);
    }catch (e, t){
      MiniLogger.e('Error putting task: ${e.toString()}, Type: ${e.runtimeType}');
      MiniLogger.t(t.toString());
    }
  }

  Future<void> putTaskAsync(Task task)async{
    try {
      await _taskBox.putAsync(task);
    }catch (e, t){
      MiniLogger.e('Error putting task: ${e.toString()}, Type: ${e.runtimeType}');
      MiniLogger.t(t.toString());
    }
  }

  /// Always give date after converting to only date using [DateTime.dateOnly]
  /// This function requires date in that format
  void toggleStatus(Task task, bool newStatus, DateTime date){
    if(newStatus){
      final completion = TaskCompletion(date: date);

      completion.task.target = task;
      completion.taskUuid = task.uuid;

      _completionBox.put(completion);
    }else{
      final condition = TaskCompletion_.task.equals(task.id).and(TaskCompletion_.date.equalsDate(date));

      final query = _completionBox.query(condition).build();

      final removed = query.remove();

      query.close();
      MiniLogger.d('Completions removed: $removed');
    }
  }
}