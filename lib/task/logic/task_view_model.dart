import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:minimaltodo/app/services/notification_service.dart';
import 'package:minimaltodo/category/category_model.dart';
import 'package:minimaltodo/helpers/object_box.dart';
import 'package:minimaltodo/objectbox.g.dart';
import 'package:minimaltodo/task/task.dart';
import 'package:minimaltodo/task/task_completion.dart';

class TaskViewModel extends ChangeNotifier {
  TaskViewModel() {
    _tasks = ObjectBox.store.box<Task>().getAll();
    singleTaskCompletions.clear();
    for (var task in _tasks.where((t) => !t.isRepeating).toList()) {
      singleTaskCompletions[task.id] = task.isDone;
    }
    recurringTaskCompletions.clear();
    for (var completion in ObjectBox.store.box<TaskCompletion>().getAll()) {
      int id = completion.task.targetId;
      int date = completion.date.millisecondsSinceEpoch;
      recurringTaskCompletions.putIfAbsent(id, () => {}).add(date);
    }
  }
  List<Task> _tasks = [];


  final _box = ObjectBox.store.box<Task>();
  final _completionBox = ObjectBox.store.box<TaskCompletion>();
  List<Task> get tasks => _tasks;
  final Set<int> _selectedTaskIds = {};
  Set<int> get selectedTaskIds => _selectedTaskIds;
  Map<int, bool> singleTaskCompletions = {};
  Map<int, Set<int>> recurringTaskCompletions = {};

  ///Adds or updates a task, put means 'Update' when edit is true, 'Add New' otherwise
  String putTask(Task task, {List<CategoryModel>? categories, required bool edit}) {
    if (task.title.trim().isEmpty) {
      return 'Enter a task first';
    }
    if (categories != null) {
      task.categories.clear();
      task.categories.addAll(categories);
      if (categories.isEmpty) {
        task.categories.add(CategoryModel(id: 1, name: 'General'));
      }
    }

    final id = _box.put(task);
    if (edit) {
      int index = _tasks.indexWhere((t) => t.id == id);
      if (index != -1) {
        _tasks[index] = task;
      }
    } else {
      _tasks.add(task);
      //Animating the task addition
    }
    notifyListeners();
    debugPrint('Task added or edited with id: $id');

    NotificationService.removeAllTaskNotifications(task).then((_) {
      if (task.isRepeating) {
        NotificationService.createRepeatingTaskNotifications(task);
      } else {
        NotificationService.createTaskNotification(task);
      }
    });

    return edit ? 'Task edited' : 'Task added';
  }

  String deleteTask(int id) {
    _box.remove(id);
    NotificationService.removeAllTaskNotifications(_tasks.firstWhere((t) => t.id == id));
    final index = _tasks.indexWhere((t) => t.id == id);
    _tasks.removeAt(index);
    notifyListeners();
    return 'Task deleted';
  }

  void toggleStatus(Task task, bool value, DateTime d) async{

    debugPrint('Isolate in toggle status: ${Isolate.current.debugName}');
    debugPrint('Before toggling status: ${toString()}');
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
        _box.put(task);
        singleTaskCompletions[task.id] = value;
      }
    debugPrint('notifyListeners() will be called now');

    notifyListeners();
  }

  String deleteSelectedTasks() {
    _box.removeMany(_selectedTaskIds.toList());
    for (int id in _selectedTaskIds) {
      NotificationService.removeAllTaskNotifications(_tasks.firstWhere((t) => t.id == id));
      _tasks.removeWhere((t) => t.id == id);
    }
    clearSelection();
    return 'Tasks deleted';
  }

  void toggleSelection(int id) {
    if (_selectedTaskIds.contains(id)) {
      _selectedTaskIds.remove(id);
    } else {
      _selectedTaskIds.add(id);
    }
    notifyListeners();
  }

  void clearSelection() {
    _selectedTaskIds.clear();
    notifyListeners();
  }
}
