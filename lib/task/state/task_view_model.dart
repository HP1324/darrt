import 'package:flutter/material.dart';
import 'package:minimaltodo/app/notification/notification_service.dart';
import 'package:minimaltodo/helpers/messages.dart';
import 'package:minimaltodo/helpers/mini_logger.dart';
import 'package:minimaltodo/helpers/object_box.dart';
import 'package:minimaltodo/helpers/typedefs.dart';
import 'package:minimaltodo/objectbox.g.dart';
import 'package:minimaltodo/app/state/viewmodels/view_model.dart';
import 'package:minimaltodo/task/models/task.dart';
import 'package:minimaltodo/task/models/task_completion.dart';

class TaskViewModel extends ViewModel<Task> {

  @override
  void initializeItems() {
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
      final query = _completionBox.query(TaskCompletion_.task.equals(id)).build();
      final removed = query.remove();
      query.close();
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
        completion.taskUuid = completion.task.target!.uuid;
        MiniLogger.dp('Completion uuid: ${completion.uuid!}');
        MiniLogger.dp('Completion task uuid: ${completion.taskUuid!}');
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
    box.putMany(restoredItems);
    reassignTaskRelations(tasks: restoredItems, completions: completions!);

    _completionBox.putMany(completions);
    initializeItems();
    notifyListeners();
  }

  void reassignTaskRelations({
    required List<Task> tasks,
    required List<TaskCompletion> completions,
  }) {
    // Build UUID → Task map
    final taskByUuid = {for (var task in tasks) task.uuid: task};

    for (var completion in completions) {
      final matchingTask = taskByUuid[completion.taskUuid];
      if (matchingTask != null) {
        completion.task.target = matchingTask;
      } else {
        MiniLogger.dp('No matching task found for completion UUID: ${completion.taskUuid}');
      }
    }
  }

  @override
  String getItemUuid(Task item) => item.uuid;

  // @override
  // void mergeItems(Map<String,dynamic><Task> oldItems, Map<String,dynamic><Task> newItems) {}

  @override
  List<Task> convertJsonListToObjectList(List<Map<String, dynamic>> jsonList) {
    return jsonList.map(Task.fromJson).toList();
  }

  @override
  List<Map<String, dynamic>> convertObjectsListToJsonList(List<Task> objectList) {
    return objectList.map((task) => task.toJson()).toList();
  }
}
