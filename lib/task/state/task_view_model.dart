
import 'package:flutter/material.dart';
import 'package:minimaltodo/app/notification/notification_service.dart';
import 'package:minimaltodo/helpers/messages.dart';
import 'package:minimaltodo/helpers/object_box.dart';
import 'package:minimaltodo/objectbox.g.dart';
import 'package:minimaltodo/app/state/viewmodels/view_model.dart';
import 'package:minimaltodo/task/models/task.dart';
import 'package:minimaltodo/task/models/task_completion.dart';

class TaskViewModel extends ViewModel<Task> {
  TaskViewModel() {
    super.initializeItems();
    singleTaskCompletions.clear();
    for (var task in tasks.where((t) => !t.isRepeating).toList()) {
      singleTaskCompletions[task.id] = task.isDone;
    }
    recurringTaskCompletions.clear();
    for (var completion in _completionBox.getAll()) {
      int id = completion.task.targetId;
      int date = completion.date.millisecondsSinceEpoch;
      recurringTaskCompletions.putIfAbsent(id, () => {}).add(date);
    }
  }

  final _completionBox = ObjectBox.completionBox;
  Set<int> get selectedTaskIds => selectedItemIds;
  final Map<int, bool> singleTaskCompletions = {};
  final Map<int, Set<int>> recurringTaskCompletions = {};

  List<Task> get tasks => items;
  @override
  String putItem(Task item, {required bool edit}) {
    final task = item;
    final title = task.title.trim();

    if (title.isEmpty) return Messages.mTaskEmpty;
    task.title = title;
    debugPrint('Categories before putting item');
    for (var c in task.categories.toList()) {
      debugPrint(c.name);
    }
    final message = super.putItem(task, edit: edit);

    final dbTask = box.get(getItemId(task)) as Task;
    debugPrint('Categories after putting item');
    for (var c in dbTask.categories.toList()) {
      debugPrint(c.name);
    }
    NotificationService.removeAllTaskNotifications(task).then((_) {
      if (task.isRepeating) {
        NotificationService.createRepeatingTaskNotifications(task);
      } else {
        NotificationService.createTaskNotification(task);
      }
    });

    return message;
  }

  @override
  String deleteItem(int id) {
    NotificationService.removeAllTaskNotifications(tasks.firstWhere((t) => t.id == id));
    final message = super.deleteItem(id);
    notifyListeners();
    return message;
  }

  @override
  String deleteMultipleItems() {
    for (int id in selectedTaskIds) {
      NotificationService.removeAllTaskNotifications(tasks.firstWhere((t) => t.id == id));
    }
    final message = super.deleteMultipleItems();
    return message;
  }

  void toggleStatus(Task task, bool value, DateTime d) async {
    if (task.isRepeating) {
      final date = DateUtils.dateOnly(d).millisecondsSinceEpoch;
      if (value) {
        final completion = TaskCompletion(date: DateUtils.dateOnly(d), isDone: value);
        completion.task.target = task;
        _completionBox.put(completion);
        recurringTaskCompletions.putIfAbsent(task.id, () => {}).add(date);
      } else {
        final completion = _completionBox
            .query(TaskCompletion_.task.equals(task.id).and(TaskCompletion_.date.equals(date)))
            .build()
            .findFirst();
        if (completion != null) {
          _completionBox.remove(completion.id);
          recurringTaskCompletions[task.id]?.remove(date);
        }
      }
    } else {
      task.isDone = value;
      box.put(task);
      singleTaskCompletions[task.id] = value;
    }

    notifyListeners();
  }

  @override
  int getItemId(task) => task.id;

  @override
  String getCreateSuccessMessage() => Messages.mTaskAdded;

  @override
  String getUpdateSuccessMessage() => Messages.mTaskEdited;

  @override
  String getDeleteSuccessMessage(int length) =>
      length == 1 ? '1 ${Messages.mTaskDeleted}' : '$length ${Messages.mTasksDeleted}';
}
