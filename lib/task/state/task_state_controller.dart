import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:minimaltodo/category/models/category_model.dart';
import 'package:minimaltodo/helpers/mini_logger.dart';
import 'package:minimaltodo/helpers/object_box.dart';
import 'package:minimaltodo/app/state/controllers/state_controller.dart';
import 'package:minimaltodo/task/models/reminder.dart';
import 'package:minimaltodo/task/models/repeat_config.dart';
import 'package:minimaltodo/task/models/task.dart';
import 'package:minimaltodo/helpers/globals.dart' as g;
part 'task_state_controller.freezed.dart';

///Immutable data-class to store the temporary state of the task add page
@freezed
abstract class TaskState with _$TaskState {
  const factory TaskState({
    required Map<CategoryModel, bool> categorySelection,
    required DateTime dueDate,
    required bool isRepeating,
    required DateTime startDate,
    DateTime? endDate,
    required RepeatConfig repeatConfig,
    required List<Reminder> reminders,
    required String priority,
    required int currentPriority,
  }) = _TaskState;
  const TaskState._();
}

///Controls the temporary state of the task add page when task is being added or updated
class TaskStateController extends StateController<TaskState, Task> {
  @override
  void initState(bool edit, [Task? task]) {

    textController.text = edit ? task!.title : '';
    final categories = g.catVm.categories;
    state = TaskState(
      categorySelection: edit
          ? {for (var cat in categories) cat: task!.categories.contains(cat)}
          : {CategoryModel(id: 1, name: 'General'): true},
      priority: edit ? task!.priority : priorities[3],
      dueDate: edit ? task!.dueDate : g.calMan.selectedDate,
      isRepeating: edit ? task!.isRepeating : g.navMan.currentTab.value == 2 ? true : false,
      startDate: edit ? task!.startDate : DateTime.now(),
      endDate: edit ? task!.endDate : null,
      repeatConfig: edit && task!.isRepeating
          ? RepeatConfig.fromJsonString(task.repeatConfig!)
          : RepeatConfig(),
      reminders: edit ? task!.reminderObjects : [],
      currentPriority: 3,
    );

  }

  @override
  void clearState() {
    state = state.copyWith(
      categorySelection: {CategoryModel(id: 1, name: 'General'): true},
      dueDate: DateTime.now(),
      isRepeating: false,
      startDate: DateTime.now(),
      endDate: null,
      repeatConfig: RepeatConfig(),
      reminders: [],
      priority: priorities[3],
    );
    textController.clear();
  }

  @override
  Task buildModel({required bool edit, Task? model}) {

    Task task;

    if (edit) {
      // Use the existing task object to preserve relationships
      task = model!;
      // Update the fields
      task.title = textController.text;
      task.dueDate = dueDate;
      task.priority = priority;
      task.startDate = startDate;
      task.endDate = endDate;
      task.isRepeating = isRepeating;
      task.repeatConfig = isRepeating ? repeatConfig.toJsonString() : null;
      task.reminders = Reminder.remindersToJsonString(reminders);
    } else {
      // Create new task
      task = Task(
        id: 0,
        title: textController.text,
        dueDate: dueDate,
        priority: priority,
        startDate: startDate,
        endDate: endDate,
        isRepeating: isRepeating,
        repeatConfig: isRepeating ? repeatConfig.toJsonString() : null,
        reminders: Reminder.remindersToJsonString(reminders),
      );
    }
    final categories = g.catVm.categories.where((c) => g.taskSc.categorySelection[c] == true).toList();
    task.categories.clear();
    if (categories.isEmpty) {
      final generalCategory = ObjectBox.categoryBox.get(1) ?? CategoryModel(id: 1, name: 'General');
      task.categories.add(generalCategory);
      task.categoryUuids = [generalCategory.uuid];
    } else {
      task.categories.addAll(categories);
      task.categoryUuids = categories.map((c) => c.uuid).toList();
    }

    return task;
  }

  void setCategory(CategoryModel category, bool value) {
    state = state.copyWith(categorySelection: {...categorySelection, category: value});
    notifyListeners();
  }

  void setDueDate(DateTime date) {
    state = state.copyWith(dueDate: date);
    notifyListeners();
  }

  void resetDueDate() {
    state = state.copyWith(dueDate: DateTime.now());
    notifyListeners();
  }

  String setStartDate(DateTime date) {
    if (endDate == null || !(date.isAfter(endDate!) || DateUtils.isSameDay(endDate, date))) {
      state = state.copyWith(startDate: date);
      updateWeekdayValidity();
      notifyListeners();
      return 'Start date set';
    }
    return "Start date must be before or equal to end date";
  }

  void resetStartDate() {
    state = state.copyWith(startDate: DateTime.now());
    notifyListeners();
  }

  String setEndDate(DateTime date) {
    if (!DateUtils.isSameDay(startDate, date) && date.isAfter(startDate)) {
      state = state.copyWith(endDate: date);
      updateWeekdayValidity();
      notifyListeners();
      return 'End date set';
    }
    return 'End date must be after start date';
  }

  void resetEndDate() {
    state = state.copyWith(endDate: null);
    notifyListeners();
  }

  void setRepeatType(String type) {
    state = state.copyWith(repeatConfig: RepeatConfig(type: type));
    notifyListeners();
  }

  void updateWeekdayValidity() {
    var config = repeatConfig;
    if (config.type != 'weekly') return;

    List<int> validWeekdays = [];

    // Filter out invalid weekdays
    for (var day in config.days) {
      if (isWeekdayValid(day)) {
        validWeekdays.add(day);
      }
    }

    // If nothing valid is left, pick first valid weekday from range
    if (validWeekdays.isEmpty) {
      for (int i = 1; i <= 7; i++) {
        if (isWeekdayValid(i)) {
          validWeekdays.add(i);
          break;
        }
      }
    }
    config.days = validWeekdays;
    // config = config.copyWith(days: validWeekdays);
  }

  bool isWeekdayValid(int weekday) {
    if (endDate == null) return true;

    var date = startDate;
    if (date.weekday == weekday) {
      return true;
    }

    // Move forward from start date to find the next matching weekday
    while (date.isBefore(endDate!)) {
      date = date.add(const Duration(days: 1));
      if (date.weekday == weekday) {
        return true; // found a valid day in the range
      }
    }

    // No matching weekday found in range
    return false;
  }

  void toggleWeekday(int day, bool selected) {
    final updatedDays = List<int>.from(repeatConfig.days);
    if (selected) {
      if (!updatedDays.contains(day)) {
        updatedDays.add(day);
      }
    } else {
      if (updatedDays.length > 1) {
        updatedDays.remove(day);
      }
    }
    updatedDays.sort();
    state = state.copyWith(repeatConfig: RepeatConfig(type: repeatConfig.type, days: updatedDays));
    notifyListeners();
  }

  void toggleRepeat(bool value) {
    if (isRepeating == value) return;
    state = state.copyWith(
      isRepeating: value,
      dueDate: value ? DateTime.now() : dueDate,
      startDate: value ? startDate : dueDate,
      endDate: value ? endDate : null,
      repeatConfig: value ? repeatConfig : RepeatConfig(),
    );
    notifyListeners();
  }

  final List<String> priorities = ["Urgent", "High", "Medium", "Low"];
  void navigatePriority(bool isNext) {
    final len = priorities.length;
    final newP = (currentPriority + (isNext ? 1 : -1) + len) % len;
    state = state.copyWith(currentPriority: newP, priority: priorities[newP]);
    notifyListeners();
  }

  ///Add or edit a reminder.
  ///[oldReminder] is necessary to provide when editing task to match if this reminder exists
  String putReminder({bool edit = false, required Reminder reminder, Reminder? oldReminder}) {
    List<Reminder> updatedReminders = List.from(reminders);
    if (kDebugMode) {
      MiniLogger.dp('All Reminders');
      for (var reminder in updatedReminders) {
        MiniLogger.dp('Reminder: ${reminder.time.hour}:${reminder.time.minute}');
      }
      MiniLogger.dp('All reminders');
    }
    if (edit) {
      final index = updatedReminders.indexWhere((r) => r.time == oldReminder!.time);
      MiniLogger.dp('this is index: $index');
      if (index != -1) {
        updatedReminders[index] = reminder;
      }
    } else {
      final exists = updatedReminders.any((r) => r.time.isAtSameTimeAs(reminder.time));
      if (exists) return 'Time already added';
      updatedReminders.add(reminder);
    }
    state = state.copyWith(reminders: updatedReminders);
    notifyListeners();
    return 'Reminder saved';
  }

  void removeReminder(Reminder reminder) {
    List<Reminder> updatedReminders = List.from(reminders);
    updatedReminders.remove(reminder);
    state = state.copyWith(reminders: updatedReminders);
    notifyListeners();
  }
}

extension AccessState on TaskStateController {
  bool get isRepeating => state.isRepeating;
  DateTime get dueDate => state.dueDate;
  DateTime get startDate => state.startDate;
  DateTime? get endDate => state.endDate;
  RepeatConfig get repeatConfig => state.repeatConfig;
  List<Reminder> get reminders => state.reminders;
  String get priority => state.priority;
  int get currentPriority => state.currentPriority;
  Map<CategoryModel, bool> get categorySelection => state.categorySelection;
}
