
import 'package:flutter/material.dart';
import 'package:minimaltodo/app/services/notification_service.dart';
import 'package:minimaltodo/category/category_model.dart';
import 'package:minimaltodo/category/logic/category_view_model.dart';
import 'package:minimaltodo/helpers/messages.dart';
import 'package:minimaltodo/helpers/object_box.dart';
import 'package:minimaltodo/helpers/utils.dart';
import 'package:minimaltodo/objectbox.g.dart';
import 'package:minimaltodo/state/view_model.dart';
import 'package:minimaltodo/task/logic/task_state_controller.dart';
import 'package:minimaltodo/task/task.dart';
import 'package:minimaltodo/task/task_completion.dart';

class TaskViewModel extends ViewModel<Task> {
  TaskViewModel() {
    super.initializeItems();
    singleTaskCompletions.clear();
    for (var task in tasks.where((t) => !t.isRepeating).toList()) {
      singleTaskCompletions[task.id] = task.isDone;
    }
    recurringTaskCompletions.clear();
    for (var completion in ObjectBox.store.box<TaskCompletion>().getAll()) {
      int id = completion.task.targetId;
      int date = completion.date.millisecondsSinceEpoch;
      recurringTaskCompletions.putIfAbsent(id, () => {}).add(date);
    }
  }

  final _completionBox = ObjectBox.store.box<TaskCompletion>();
  Set<int> get selectedTaskIds => selectedItemIds;
  final Map<int, bool> singleTaskCompletions = {};
  final Map<int, Set<int>> recurringTaskCompletions = {};

  List<Task> get tasks => items;
  @override
  String putItem(Task item, {required bool edit}) {
    final task = item;
    if (task.title.trim().isEmpty) return Messages.mTaskEmpty;

    final controller = getIt<TaskStateController>();
    final catVm = getIt<CategoryViewModel>();
    final categories = catVm.categories.where((c) => controller.categorySelection[c] == true).toList();
    task.categories.clear();
    if (categories.isEmpty) {
      task.categories.add(CategoryModel(id: 1, name: 'General'));
    } else {
      task.categories.addAll(categories);
    }

    final message = super.putItem(task, edit: edit);

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
        debugPrint('Completion value: ${completion != null}');
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
    debugPrint('notifyListeners() will be called now');

    notifyListeners();
  }



  void toggleSelection(int id) {
    if (selectedTaskIds.contains(id)) {
      selectedTaskIds.remove(id);
    } else {
      selectedTaskIds.add(id);
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
  String getDeleteSuccessMessage(int length) => length == 1 ? '1 ${Messages.mTaskDeleted}' : '$length ${Messages.mTasksDeleted}';
}
