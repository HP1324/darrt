import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:minimaltodo/category/category_model.dart';
import 'package:minimaltodo/helpers/object_box.dart';
import 'package:minimaltodo/task/reminder.dart';
import 'package:minimaltodo/task/repeat_config.dart';
import 'package:minimaltodo/task/task.dart';

class TaskState {
  final TextEditingController titleController;
  final Map<CategoryModel, bool> categorySelection;
  final DateTime dueDate;
  final bool isRepeating;
  final DateTime startDate;
  final DateTime? endDate;
  final RepeatConfig repeatConfig;
  final List<Reminder> reminders;
  final String priority;
  final int currentPriority;

  const TaskState({
    required this.titleController,
    required this.categorySelection,
    required this.dueDate,
    required this.isRepeating,
    required this.startDate,
    this.endDate,
    required this.repeatConfig,
    required this.reminders,
    required this.priority,
    required this.currentPriority,
  });

  TaskState copyWith({
    TextEditingController? titleController,
    Map<CategoryModel, bool>? categorySelection,
    DateTime? dueDate,
    bool? isRepeating,
    DateTime? startDate,
    DateTime? endDate,
    RepeatConfig? repeatConfig,
    List<Reminder>? reminders,
    String? priority,
    int? currentPriority,
  }) {
    return TaskState(
      titleController: titleController ?? this.titleController,
      categorySelection: categorySelection ?? this.categorySelection,
      dueDate: dueDate ?? this.dueDate,
      isRepeating: isRepeating ?? this.isRepeating,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      repeatConfig: repeatConfig ?? this.repeatConfig,
      reminders: reminders ?? this.reminders,
      priority: priority ?? this.priority,
      currentPriority: currentPriority ?? this.currentPriority,
    );
  }
}

///Controls the temporary state of the task add page when task is being added or updated
class TaskStateController extends ChangeNotifier {
  final titleController = TextEditingController();
  Map<CategoryModel, bool> categorySelection = {CategoryModel(id: 1, name: 'General'): true};
  DateTime dueDate = DateTime.now();
  bool isRepeating = false;
  DateTime startDate = DateTime.now();
  DateTime? endDate;
  RepeatConfig repeatConfig = RepeatConfig();
  List<Reminder> reminders = [];
  String priority = 'Low';

  FocusNode textFieldNode = FocusNode();
  void initTaskState(Task task) {
    final categories = ObjectBox.store.box<CategoryModel>().getAll();
    titleController.text = task.title;
    priority = task.priority;
    dueDate = task.dueDate;
    isRepeating = task.isRepeating;
    startDate = task.startDate;
    endDate = task.endDate;
    categorySelection = {for (var cat in categories) cat: task.categories.contains(cat)};
    repeatConfig = RepeatConfig.fromJsonString(task.repeatConfig!);
    reminders = task.reminderObjects;
  }

  void clearTaskState() {
    categorySelection = {CategoryModel(id: 1, name: 'General'): true};
    dueDate = DateTime.now();
    isRepeating = false;
    startDate = DateTime.now();
    endDate = null;
    repeatConfig = RepeatConfig();
    reminders;
    priority = 'Low';
    titleController.clear();
    reminders = [];
  }

  Task buildTask({required bool edit, Task? task}) {
    return Task(
      title: titleController.text,
      dueDate: dueDate,
      priority: priority,
      id: edit ? task!.id : 0,
      startDate: startDate,
      endDate: endDate,
      isRepeating: isRepeating,
      repeatConfig: repeatConfig.toJsonString(),
      reminders: Reminder.remindersToJsonString(reminders),
    );
  }

  void setCategory(CategoryModel category, bool value) {
    categorySelection = {...categorySelection, category: value};
    notifyListeners();
  }

  void setDueDate(DateTime date) {
    dueDate = date;
    notifyListeners();
  }

  void resetDueDate() {
    dueDate = DateTime.now();
    notifyListeners();
  }

  String setStartDate(DateTime date) {
    if (endDate == null || !(date.isAfter(endDate!) || DateUtils.isSameDay(endDate, date))) {
      startDate = date;
      updateWeekdayValidity();
      notifyListeners();
      return 'Start date set';
    }
    return "Start date must be before or equal to end date";
  }

  void resetStartDate() {
    startDate = DateTime.now();
    notifyListeners();
  }

  String setEndDate(DateTime date) {
    if (!DateUtils.isSameDay(startDate, date) && date.isAfter(startDate)) {
      endDate = date;
      updateWeekdayValidity();
      notifyListeners();
      return 'End date set';
    }
    return 'End date must be after start date';
  }

  void resetEndDate() {
    endDate = null;
    notifyListeners();
  }

  void setRepeatType(String type) {
    repeatConfig = RepeatConfig(type: type);
    notifyListeners();
  }

  void updateWeekdayValidity() {
    final config = repeatConfig;
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
    print(updatedDays);
    repeatConfig = RepeatConfig(type: repeatConfig.type, days: updatedDays);
    notifyListeners();
  }

  void toggleRepeat(bool value) {
    if (isRepeating == value) return;
    isRepeating = value;
    if (!value) {
      endDate = null;
      repeatConfig = RepeatConfig();
      startDate = dueDate;
    } else {
      startDate = startDate;
      dueDate = DateTime.now();
    }
    notifyListeners();
  }

  int currentPriority = 3;
  List<String> priorities = ["Urgent", "High", "Medium", "Low"];
  void navigatePriority(bool isNext) {
    if (isNext) {
      currentPriority = (currentPriority + 1) % priorities.length;
    } else {
      currentPriority = (currentPriority - 1 + priorities.length) % priorities.length;
    }
    priority = priorities[currentPriority];
    notifyListeners();
  }

  ///Add or edit a reminder.
  ///[oldReminder] is necessary to provide when editing task to match if this reminder exists
  String putReminder({bool edit = false, required Reminder reminder, Reminder? oldReminder}) {
    if (kDebugMode) {
      debugPrint('All reminders');
      for (var reminder in reminders) {
        debugPrint('Reminder: ${reminder.time.hour}:${reminder.time.minute}');
      }
      debugPrint('All reminders');
    }
    if (edit) {
      final index = reminders.indexWhere(
          (r) => r.time.hour == oldReminder!.time.hour && r.time.minute == oldReminder.time.minute);
      print('this is index: $index');
      if (index != -1) {
        reminders[index] = reminder;
      }
    } else {
      final exists = reminders.any((r) => r.time.isAtSameTimeAs(reminder.time));
      if (exists) return 'Time already added';
      reminders.add(reminder);
    }
    reminders = List.from(reminders);
    notifyListeners();
    return 'Reminder saved';
  }

  void removeReminder(Reminder reminder) {
    reminders.remove(reminder);
    notifyListeners();
  }
}
