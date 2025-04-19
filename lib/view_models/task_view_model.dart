import 'dart:convert';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:minimaltodo/data_models/category_model.dart';
import 'package:minimaltodo/data_models/task.dart';
import 'package:minimaltodo/helpers/miniutils.dart';
import 'package:minimaltodo/helpers/messages.dart';
import 'package:minimaltodo/helpers/mini_box.dart';
import 'package:minimaltodo/helpers/mini_consts.dart';
import 'package:minimaltodo/helpers/mini_logger.dart';
import 'package:minimaltodo/services/database_service.dart';
import 'package:minimaltodo/services/notification_service.dart';
import 'package:minimaltodo/services/task_service.dart';
import 'package:minimaltodo/view_models/calendar_view_model.dart';
import 'package:sqflite/sqflite.dart';

class TaskViewModel extends ChangeNotifier {
  //------------------------ INITIALIZATION ------------------------//
  TaskViewModel() {
    loadTasks();
    // filterTasks(0);
  }
  void testRefreshTasks() async {
    _tasks = await TaskService.getRecurringTasks();
    // MiniLogger.info('---------------PRINTING ALL TASKS-----------------');
    // // _tasks.forEach((t) => t.printTask());
    // MiniLogger.info('---------------/PRINTING ALL TASKS/-----------------');
    notifyListeners();
  }

  void loadTasks() async {
    _tasks = await TaskService.getTasks();
    final db = await DatabaseService.openDb();
    final List<Map<String, dynamic>> singleTasks =
        await db.query('tasks', where: 'isRepeating = 0');
    singleTaskCompletion.clear();
    for (var task in singleTasks) {
      singleTaskCompletion[task['id']] = task['isDone'] == 1;
    }

    final List<Map<String, dynamic>> recurringTasks = await db.query('task_completion');
    recurringTaskCompletion.clear();
    for (var entry in recurringTasks) {
      int taskId = entry['task_id'];
      int date = entry['date'];

      recurringTaskCompletion.putIfAbsent(taskId, () => {}).add(date);
    }

    notifyListeners();
  }

  List<Task> tasksForTab = [];
  void setTasksForTab(int currentTab, List<Task> tasksForSelectedDate) {
    if (currentTab == 0) {
      tasksForTab = tasksForSelectedDate;
    } else if (currentTab == 1) {
      tasksForTab = tasksForSelectedDate.where((t) => !t.isRepeating!).toList();
    } else {
      tasksForTab = tasksForSelectedDate.where((t) => !t.isRepeating!).toList();
    }
    notifyListeners();
  }

  void initNewTask() {
    currentTask = Task(
      dueDate: DateTime.now().add(const Duration(minutes: 1)),
      priority: "Low",
      notifType: "notif",
      startDate: DateTime.now(),
      isRepeating: false,
      isNotifyEnabled: MiniBox.read(mIsNotificationsGloballyEnabled),
      repeatConfig: '{"repeatType":"weekly","selectedDays":[1,2,3,4,5,6,7]}',
    );
    debugPrint('Selected Weekdays in initNewTask: ${currentTask.repeatConfig}');
    titleController.clear();
    currentTask.reminders = null;
  }

  void resetTask(Task task) {
    task = taskBeforeEdit;
    currentTask = taskBeforeEdit;
    notifyListeners();
  }

  ///[taskBeforeEdit] is for detecting whether a task is actually edited or not
  Task taskBeforeEdit = Task();
  void initEditTask(Task task) {
    taskBeforeEdit = task.copyWith();
    currentTask = task.copyWith();
    titleController.text = task.title ?? '';
  }

  //------------------------ PROPERTIES & CONTROLLERS ------------------------//
  List<Task> _tasks = [];
  List<Task> get tasks => _tasks;
  List<Task> singleTasks = [];
  List<Task> recurringTasks = [];
  Map<int, bool> singleTaskCompletion = {}; // taskId -> isCompleted (for single tasks)
  Map<int, Set<int>> recurringTaskCompletion = {}; // taskId -> completed dates (for recurring tasks)

  Task currentTask = Task();
  TextEditingController titleController = TextEditingController();
  FocusNode textFieldNode = FocusNode();
  List<String> priorities = ["Urgent", "High", "Medium", "Low"];
  int currentValue = 3; // Default to Low Priority

  //------------------------ BASIC SETTERS ------------------------//
  Future<void> setCategories(Map<int, bool> selectedCategories) async {
    var categoryIds = selectedCategories.entries.where((e) => e.value).map((e) => e.key).toList();

    final db = await DatabaseService.openDb();
    try {
      // First delete existing categories
      await db.delete('task_categories', where: 'task_id = ?', whereArgs: [currentTask.id]);

      // Then add new categories
      final batch = db.batch();

      for (var id in categoryIds) {
        batch.insert('task_categories', {'task_id': currentTask.id, 'category_id': id});
      }
      await batch.commit();
      selectedCategories.updateAll((key, value) => key != 1 ? false : value);
    } catch (e) {
      MiniLogger.error('Error setting categories: ${e.toString()}');
    }
  }

  void navigatePriority(bool isNext) {
    if (isNext) {
      currentValue = (currentValue + 1) % priorities.length;
    } else {
      currentValue = (currentValue - 1 + priorities.length) % priorities.length;
    }
    currentTask.priority = priorities[currentValue];
    notifyListeners();
  }

  void setTitle() {
    if (titleController.text.trim().isNotEmpty) {
      currentTask.title = titleController.text.trim();
      titleController.clear();
    }
  }

  //--------------------------------------------------------------//

  //------------------------ DATE & TIME HANDLING ------------------------//
  void setDueDate(DateTime dueDate) {
    final existingTime = currentTask.dueDate;
    currentTask.dueDate = DateTime(
      dueDate.year,
      dueDate.month,
      dueDate.day,
      existingTime?.hour ?? DateTime.now().hour,
      existingTime?.minute ?? DateTime.now().minute,
    );
    notifyListeners();
    // updateNotifLogicAfterDueDateUpdate();
  }

  void resetDueDate() {
    if (currentTask.dueDate != null) {
      currentTask.dueDate = DateTime.now();
      notifyListeners();
    }
  }

  //----------------------------------------------------------------------//

  //------------------------ NOTIFICATION HANDLING ------------------------//
  void updateNotifLogicAfterDueDateUpdate() async {
    if (currentTask.reminders != null) {
      await NotificationService.createTaskNotification(currentTask);
    }
  }

  void updateNotificationType(String type) {
    currentTask.notifType = type;
    notifyListeners();
  }
  //-----------------------------------------------------------------------//

  //------------------------ REPEAT & REMINDER HANDLING ------------------------//
  bool isWeekdayValid(int weekday) {
    if (currentTask.endDate == null) return true;

    DateTime date = currentTask.startDate;
    DateTime endDate = currentTask.endDate!;

    // If the start date is already the desired weekday
    if (date.weekday == weekday) {
      return true;
    }

    // Move forward from start date to find the next matching weekday
    while (date.isBefore(endDate)) {
      date = date.add(const Duration(days: 1));
      if (date.weekday == weekday) {
        return true; // found a valid day in the range
      }
    }

    // No matching weekday found in range
    return false;
  }


  void setTaskStartDate(DateTime date) {
    currentTask.startDate = date;
    _updateWeekdayValidity();
    notifyListeners();
  }

  void setTaskEndDate(DateTime? date) {
    currentTask.endDate = date;
    _updateWeekdayValidity();
    notifyListeners();
  }

  void setRepeatType(String type) {
    try {
      final config = currentTask.repeatConfig != null
          ? jsonDecode(currentTask.repeatConfig!) as Map<String, dynamic>
          : {};

      config['repeatType'] = type;

      currentTask.repeatConfig = jsonEncode(config);
      notifyListeners();
    } catch (e) {
      MiniLogger.error('Error setting repeat type: $e');
    }
  }

  String? toggleWeekday(int weekday) {
    if (currentTask.repeatConfig == null) return null;

    try {
      final config = jsonDecode(currentTask.repeatConfig!) as Map<String, dynamic>;
      if (config['repeatType'] != 'weekly') return null;

      var days = List.from(config['selectedDays'] ?? []);

      if (days.contains(weekday)) {
        if (days.length != 1) {
          days.remove(weekday);
        } else {
          return Messages.mAtleastOneDaySelected;
        }
      } else {
        days.add(weekday);
      }
      days.sort();
      config['selectedDays'] = days;
      currentTask.repeatConfig = jsonEncode(config);
      notifyListeners();
    } catch (e) {
      MiniLogger.error('Error toggling weekday: $e');
    }
    return null;
  }

  void addReminderTime(TimeOfDay time) {
    try {
      final List<dynamic> reminders = List.from(
        jsonDecode(currentTask.reminders ?? '[]'),
      );

      if (reminders.length >= 10) return;

      // Convert TimeOfDay to string format
      final timeString = MiniUtils.timeOfDayToTimeString(time);

      if (reminders.any((reminder) => reminder['time'] == timeString)) return;

      final notificationId = DateTime.now().millisecondsSinceEpoch.remainder(1000000000);
      // Check for duplicates
      if (reminders.contains(timeString)) return;
      MiniLogger.debug('Time String: $timeString');
      reminders.add({'time': timeString, 'id': notificationId});
      currentTask.reminders = jsonEncode(reminders);
      MiniLogger.debug('All reminder Times: ${currentTask.reminders}');
      notifyListeners();
    } catch (e) {
      MiniLogger.error('Error adding reminder time: $e');
    }
  }

  void removeReminderTime(TimeOfDay time) async {
    try {
      final List<dynamic> reminders = List.from(
        jsonDecode(currentTask.reminders ?? '[]'),
      );

      // Convert TimeOfDay to string format for comparison
      final timeString =
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

      List remindersToRemove =
          reminders.where((reminder) => reminder['time'] == timeString).toList();

      for (var reminder in remindersToRemove) {
        await NotificationService.removeSingleNotification(reminder['id']);
        reminders.remove(reminder);
      }

      currentTask.reminders = jsonEncode(reminders);
      notifyListeners();
    } catch (e, stacktrace) {
      MiniLogger.error('Error removing reminder time: $e');
      MiniLogger.trace('$stacktrace');
    }
  }

  void updateReminderTime(TimeOfDay oldTime, TimeOfDay newTime) async {
    try {
      final List<dynamic> reminders = List.from(
        jsonDecode(currentTask.reminders ?? '[]'),
      );
      final oldTimeString = MiniUtils.timeOfDayToTimeString(oldTime);
      final newTimeString = MiniUtils.timeOfDayToTimeString(newTime);

      final notificationId = DateTime.now().millisecondsSinceEpoch.remainder(1000000000);

      bool updated = false;
      for (int i = 0; i < reminders.length; ++i) {
        if (reminders[i]['time'] == oldTimeString) {
          await NotificationService.removeSingleNotification(reminders[i]['id']);
          reminders[i] = {'time': newTimeString, 'id': notificationId};
          updated = true;
          break;
        }
      }

      if (updated) {
        currentTask.reminders = jsonEncode(reminders);
        notifyListeners();
      }
    } catch (e) {
      MiniLogger.error('Error updating reminder time: $e');
    }
  }

  List<TimeOfDay> get reminderTimesList {
    if (currentTask.reminders == null) return [];
    try {
      final List<dynamic> reminders = List.from(
        jsonDecode(currentTask.reminders!),
      );
      return reminders.map((reminder) {
        final timeStr = reminder['time'] as String;
        final parts = timeStr.split(':');
        return TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }).toList();
    } catch (e) {
      MiniLogger.error('Error decoding reminderTimes: $e');
      return [];
    }
  }
  //-----------------------------------------------------------------------//

  //------------------------ TASK CRUD OPERATIONS ------------------------//
  Future<String?> addNewTask(Map<int, bool> categories) async {
    // currentTask.category ??= await CategoryService.getGeneralCategory();
    if (!currentTask.isValid()) {
      return Messages.mTaskEmpty;
    }
    // Set up repeat configuration if enabled
    if (currentTask.isRepeating!) {
      // Validate repeat configuration
      try {
        if (currentTask.repeatConfig == null) return null;
        final config = jsonDecode(currentTask.repeatConfig!) as Map<String, dynamic>;
        if (config['repeatType'] == 'weekly') {
          final days = List.from(config['selectedDays'] ?? []);
          if (days.isEmpty) return null; // Can't create weekly task without selected days
        }
      } catch (e) {
        MiniLogger.error('Error validating repeat config: $e');
        return null;
      }
    }

    final id = await TaskService.addTask(currentTask);
    currentTask.id = id;
    _tasks.add(currentTask);
    await setCategories(categories);
    notifyListeners();

    // Schedule notifications
    if (currentTask.reminders != null) {
      if (currentTask.isRepeating!) {
        await NotificationService.createRepeatingTaskNotifications(currentTask);
      } else {
        await NotificationService.createTaskNotification(currentTask);
      }
    }
    return Messages.mTaskAdded;
  }

  Future<String?> editTask() async {
    int changes = 0;
    if (currentTask == taskBeforeEdit) {
      MiniLogger.debug('Task is not edited');
      return null;
    }
    if (currentTask.isValid()) {
      MiniLogger.debug('Task is valid');
      changes = await TaskService.editTask(newTask: currentTask.toJson());
      MiniLogger.debug('Changes made: $changes');
      final taskIndex = _tasks.indexWhere((task) => task.id == currentTask.id);
      if (taskIndex != -1) {
        _tasks[taskIndex] = currentTask;

        notifyListeners();
      }
      // Reschedule notifications based on repeating flag.
      if (currentTask.isNotifyEnabled!) {
        if (currentTask.isRepeating!) {
          await NotificationService.createRepeatingTaskNotifications(currentTask);
        } else {
          await NotificationService.createTaskNotification(currentTask);
        }
      } else {
        if (currentTask.isRepeating!) {
          await NotificationService.removeRepeatingTaskNotifications(currentTask);
        } else {
          await NotificationService.removeAllTaskNotifications(currentTask);
        }
      }
      return Messages.mTaskEdited;
    } else {
      MiniLogger.debug('Task is not valid');
      return Messages.mTaskEmpty;
    }
  }

  Future<bool> deleteTask(Task task) async {
    // First remove all notifications for this task
    if (task.reminders != null) {
      if (task.isRepeating!) {
        // Remove all scheduled notifications for recurring task
        await NotificationService.removeRepeatingTaskNotifications(task);
      } else {
        await NotificationService.removeAllTaskNotifications(task);
      }
    }

    await TaskService.deleteTask(task.id!);
    _tasks.remove(task);
    notifyListeners();
    return true;
  }

  Future<int> toggleStatus(Task task, bool updatedStatus, DateTime selectedDate) async {
    final db = await DatabaseService.openDb();
    var changes = 0;
    try {
      if (task.isRepeating!) {
        final date = DateTime(selectedDate.year, selectedDate.month,
                selectedDate.day)
            .millisecondsSinceEpoch;
        if (updatedStatus) {
          changes = await db.insert(
            'task_completion',
            {'task_id': task.id, 'date': date, 'isCompleted': 1},
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
          recurringTaskCompletion.putIfAbsent(task.id!, () => {}).add(date);
        } else {
          changes = await db.delete(
            'task_completion',
            where: 'task_id = ? AND date = ?',
            whereArgs: [task.id, date],
          );
          recurringTaskCompletion[task.id]?.remove(date);
        }
      } else {
        changes = await db.update(
          'tasks',
          {'isDone': updatedStatus ? 1 : 0, 'finishedAt': updatedStatus ? DateTime.now().millisecondsSinceEpoch : null},
          where: 'id = ?',
          whereArgs: [task.id],
        );
        singleTaskCompletion[task.id!] = updatedStatus;
      }
      notifyListeners();
      return changes;
    } catch (e) {
      MiniLogger.error('Error toggling status: $e');
      return 0;
    }
  }

  //----------------------------------------------------------------------//

  void updateTaskListAfterEdit(CategoryModel list) async {
    // final tasksForCurrentList = tasks.where((t) => t.category!.id == list.id).toList();
    // await TaskService.editTaskCategoryAfterEdit(tasksForCurrentList, list);
    loadTasks();
  }
  //--------------------------------------------------------------------------//

  void toggleRepeat(bool value) {
    if (currentTask.isRepeating == value) return;

    currentTask.isRepeating = value;
    if (value) {
      // Switching to recurring task
      currentTask.startDate = currentTask.dueDate ?? DateTime.now();
      currentTask.endDate = null;
      currentTask.repeatConfig = jsonEncode({
        'repeatType': 'weekly',
        'selectedDays': [1, 2, 3, 4, 5, 6,7],
      });
      currentTask.reminders = null;

      // Clear one-time settings
      currentTask.dueDate = null;
      currentTask.notifyTime = null;
    } else {
      // Switching to single task
      currentTask.dueDate = currentTask.startDate;
      currentTask.startDate = DateTime.now();
      currentTask.endDate = null;
      currentTask.repeatConfig = null;
      currentTask.reminders = null;
      currentTask.notifyTime = null;
      currentTask.isNotifyEnabled = false;
    }

    notifyListeners();
  }

  // Helper getters/setters for repeat configuration
  bool get isRepeatEnabled => currentTask.isRepeating ?? false;

  bool get isNotifyEnabled => currentTask.isNotifyEnabled ?? false;
  DateTime get taskStartDate => currentTask.startDate;

  DateTime? get taskEndDate => currentTask.endDate;

  // String? get finishDates => currentTask.finishDates;
  String? get repeatType {
    if (currentTask.repeatConfig == null) return 'weekly';
    try {
      final config = jsonDecode(currentTask.repeatConfig!) as Map<String, dynamic>;
      return config['repeatType'] as String?;
    } catch (e) {
      MiniLogger.error('Error decoding repeatType: $e');
      return null;
    }
  }

  List<int> get selectedWeekdays {
    if (currentTask.repeatConfig == null) return [1, 2, 3, 4, 5, 6, 7];
    try {
      final config = jsonDecode(currentTask.repeatConfig!) as Map<String, dynamic>;
      debugPrint('selected days is list: ${config['selectedDays'] is List}');
      if (config['repeatType'] == 'weekly' && config['selectedDays'] is List) {
        debugPrint('Selected Days: ${config['selectedDays']}');
        return List.from(config['selectedDays']);
      }
      return [];
    } catch (e) {
      MiniLogger.error('Error decoding selectedWeekdays: $e');
      return [];
    }
  }

  void _updateWeekdayValidity() {
    if (currentTask.repeatConfig == null) return;

    try {
      final config = jsonDecode(currentTask.repeatConfig!) as Map<String, dynamic>;
      if (config['repeatType'] != 'weekly') return;

      var days = List.from(config['selectedDays'] ?? []);
      List<int> validWeekdays = [];

      // Filter out invalid weekdays and collect valid ones
      for (var day in days) {
        if (isWeekdayValid(day)) {
          validWeekdays.add(day);
        }
      }

      // If nothing valid is left, auto-pick the first valid weekday from range
      if (validWeekdays.isEmpty) {
        for (int i = 1; i <= 7; i++) {
          if (isWeekdayValid(i)) {
            validWeekdays.add(i);
            break; // Only add the first found valid weekday
          }
        }
      }

      // Update the config
      config['selectedDays'] = validWeekdays;
      currentTask.repeatConfig = jsonEncode(config);
    } catch (e) {
      MiniLogger.error('Error updating weekday validity: $e');
    }
  }

}
