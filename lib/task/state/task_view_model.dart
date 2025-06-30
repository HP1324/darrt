import 'package:flutter/material.dart';
import 'package:minimaltodo/app/notification/notification_service.dart';
import 'package:minimaltodo/app/services/backup_service.dart';
import 'package:minimaltodo/helpers/messages.dart';
import 'package:minimaltodo/helpers/mini_logger.dart';
import 'package:minimaltodo/helpers/object_box.dart';
import 'package:minimaltodo/helpers/typedefs.dart';
import 'package:minimaltodo/objectbox.g.dart';
import 'package:minimaltodo/app/state/viewmodels/view_model.dart';
import 'package:minimaltodo/task/models/task.dart';
import 'package:minimaltodo/task/models/task_completion.dart';

class TaskViewModel extends ViewModel<Task> {
  TaskViewModel() {
    super.initializeItems();
    onetimeTaskCompletions.clear();
    for (var task in tasks.where((t) => !t.isRepeating).toList()) {
      onetimeTaskCompletions[task.id] = task.isDone;
    }
    repeatingTaskCompletions.clear();
    for (var completion in _completionBox.getAll()) {
      int id = completion.task.targetId;
      int date = completion.date.millisecondsSinceEpoch;
      repeatingTaskCompletions.putIfAbsent(id, () => {}).add(date);
    }
  }

  final _completionBox = ObjectBox.completionBox;
  Set<int> get selectedTaskIds => selectedItemIds;
  final Map<int, bool> onetimeTaskCompletions = {};
  final Map<int, Set<int>> repeatingTaskCompletions = {};

  final OneTimeCompletions oneTimeCompletions = ValueNotifier({});
  final RepeatingCompletions repeatingCompletions = ValueNotifier({});
  List<Task> get tasks => items;
  @override
  String putItem(Task item, {required bool edit}) {
    final task = item;
    final title = task.title.trim();

    if (title.isEmpty) return Messages.mTaskEmpty;
    task.title = title;

    final message = super.putItem(task, edit: edit);

    NotificationService.removeAllTaskNotifications(task).then((_) async {
      if (task.isRepeating) {
        await NotificationService.createRepeatingTaskNotifications(task);
      } else {
        await NotificationService.createTaskNotification(task);
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

    // Delete ALL completions for each task
    for (var id in selectedTaskIds) {
      final removed = _completionBox.query(TaskCompletion_.task.equals(id)).build()
        ..remove()
        ..close(); // Remove will delete all the matching objects
      MiniLogger.d('Removed $removed completions for task $id');
      repeatingTaskCompletions[id]?.clear();
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
        completion.uuid = completion.task.target!.uuid;
        _completionBox.put(completion);
        repeatingTaskCompletions.putIfAbsent(task.id, () => {}).add(date);
      } else {
        final removed =
            _completionBox
                .query(TaskCompletion_.task.equals(task.id).and(TaskCompletion_.date.equals(date)))
                .build()
              ..remove()
              ..close();
        MiniLogger.d('removed $removed completions for task ${task.id}');
        repeatingTaskCompletions[task.id]?.remove(date);
      }
    } else {
      task.isDone = value;
      box.put(task);
      onetimeTaskCompletions[task.id] = value;
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

  @override
  void setItemId(Task item, int id) {
    item.id = id;
  }

  @override
  void putManyForRestore(List<Task> restoredItems, {List<TaskCompletion>? completions}) {
    final taskIds = box.putMany(restoredItems);
    final List? oldTasks = BackupMergeService.oldCacheObjects['tasks'];
    final allTasks = box.getMany(taskIds);
    if (oldTasks != null && oldTasks.isNotEmpty) {
      for (var oldTask in oldTasks) {
        // final query = _completionBox.query(TaskCompletion_.task.equals(task.id)).build().find();
        for (var completion in completions!) {
          if (completion.task.targetId == oldTask.id) {
            debugPrint('here came it');
            final newTask = allTasks.firstWhere((t) => t!.equals(oldTask));
            completion.task.target = newTask;
          }
        }
      }
    }
    if (completions != null) {
      _completionBox.putMany(completions);
    }
    initializeItems();
    notifyListeners();
  }

  @override
  String getItemUuid(Task item) => item.uuid;

  // @override
  // void mergeItems(EntityObjectListMap<Task> oldItems, EntityObjectListMap<Task> newItems) {}

  @override
  EntityObjectList<Task> convertJsonListToObjectList(EntityJsonList jsonList) {
    return jsonList.map(Task.fromJson).toList();
  }

  @override
  EntityJsonList convertObjectsListToJsonList(EntityObjectList<Task> objectList) {
    return objectList.map((task) => task.toJson()).toList();
  }
}
