import 'dart:convert';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:minimaltodo/data_models/category_model.dart';
import 'package:minimaltodo/data_models/task.dart';
import 'package:minimaltodo/helpers/mini_utils.dart';
import 'package:minimaltodo/services/category_service.dart';
import 'package:minimaltodo/services/notification_service.dart';
import 'package:minimaltodo/services/stats_service.dart';
import 'package:minimaltodo/services/task_service.dart';

class TaskViewModel extends ChangeNotifier {
  //------------------------ INITIALIZATION ------------------------//
  TaskViewModel() {
    _refreshTasks();
    filterTasks(0);
  }

  void initNewTask() {
    currentTask = Task(
      dueDate: DateTime.now().add(const Duration(minutes: 2)),
      category: CategoryModel(id: 1, name: 'General'),
      priority: "Low",
      notifType: "notif",
      startDate: DateTime.now(),
      isRepeating: false,
      isNotifyEnabled: false,
    );

    selectedMinutes = 0;
    titleController.clear();

    // No need to reset these as they're now handled through currentTask
    currentTask.repeatConfig = null;
    currentTask.reminderTimes = null;
  }

  void resetTask(Task task) {
    task = taskBeforeEdit;
    currentTask = taskBeforeEdit;
    notifyListeners();
  }

  Task taskBeforeEdit = Task();
  void initEditTask(Task task) {
    taskBeforeEdit = task;
    currentTask = task;
    titleController.text = task.title ?? '';

    // No need to initialize these separately as they're now handled through getters
  }

  //------------------------ PROPERTIES & CONTROLLERS ------------------------//
  List<Task> _tasks = [];
  List<Task> get tasks => _tasks;
  Task currentTask = Task();
  TextEditingController titleController = TextEditingController();
  FocusNode titleTextFieldNode = FocusNode();
  bool isNewTaskAdded = false;
  List<Task> finishedTasks = [];
  List<Task> pendingTasks = [];
  List<String> priorities = ["Urgent", "High", "Medium", "Low"];
  int currentValue = 3; // Default to Low Priority
  int selectedMinutes = 0;

  //------------------------ BASIC SETTERS ------------------------//
  set category(CategoryModel category) {
    currentTask.category = category;
    notifyListeners();
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

  set title(String title) => currentTask.title = title;

  //--------------------------------------------------------------//

  //------------------------ DATE & TIME HANDLING ------------------------//
  set dueDate(DateTime dueDate) {
    final existingTime = currentTask.dueDate;
    currentTask.dueDate = DateTime(
      dueDate.year,
      dueDate.month,
      dueDate.day,
      existingTime?.hour ?? DateTime.now().hour,
      existingTime?.minute ?? DateTime.now().minute,
    );
    if (currentTask.dueDate != null && currentTask.isNotifyEnabled!) {
      currentTask.notifyTime =
          currentTask.dueDate!.subtract(Duration(minutes: selectedMinutes));
    }
    updateNotifLogicAfterDueDateUpdate();
  }

  set time(TimeOfDay time) {
    final existingDate = currentTask.dueDate ?? DateTime.now();
    currentTask.dueDate = DateTime(
      existingDate.year,
      existingDate.month,
      existingDate.day,
      time.hour,
      time.minute,
    );
    if (currentTask.dueDate != null && currentTask.isNotifyEnabled!) {
      currentTask.notifyTime =
          currentTask.dueDate!.subtract(Duration(minutes: selectedMinutes));
    }
    updateNotifLogicAfterDueDateUpdate();
  }

  void removeDueDate() {
    if (currentTask.dueDate != null) {
      final currentDueDate = currentTask.dueDate!;
      final now = DateTime.now();
      currentTask.dueDate = DateTime(
        now.year,
        now.month,
        now.day,
        currentDueDate.hour,
        currentDueDate.minute,
      );
      notifyListeners();
    }
  }

  void removeTime() {
    if (currentTask.dueDate != null) {
      final currentDueDate = currentTask.dueDate!;
      final now = DateTime.now().add(Duration(minutes: 2));
      currentTask.dueDate = DateTime(
        currentDueDate.year,
        currentDueDate.month,
        currentDueDate.day,
        now.hour,
        now.minute,
      );
      notifyListeners();
    }
  }

  //----------------------------------------------------------------------//

  //------------------------ NOTIFICATION HANDLING ------------------------//
  void updateNotifLogicAfterDueDateUpdate() {
    if (currentTask.isNotifyEnabled!) {
      if (currentTask.dueDate != null &&
          currentTask.dueDate!.isBefore(DateTime.now())) {
        currentTask.isNotifyEnabled = false;
        if (currentTask.id != null) {
          NotificationService.removeTaskNotification(currentTask);
        }
      }
      if (currentTask.notifyTime != null &&
          !currentTask.notifyTime!.isAfter(DateTime.now())) {
        selectedMinutes = 0;
      }
      notifyListeners();
    }
  }

  void toggleNotifSwitch(bool value) async {
    await NotificationService.initializeNotificationChannels();
    currentTask.isNotifyEnabled = value;
    if (currentTask.isNotifyEnabled! && currentTask.dueDate != null) {
      currentTask.notifyTime =
          currentTask.dueDate!.subtract(Duration(minutes: selectedMinutes));
    }
    notifyListeners();
  }

  bool updateNotifyTime(int minutes) {
    selectedMinutes = minutes;
    if (currentTask.dueDate != null) {
      final notifTime =
          currentTask.dueDate!.subtract(Duration(minutes: selectedMinutes));
      if (notifTime.isAfter(DateTime.now())) {
        currentTask.notifyTime = notifTime;
        notifyListeners();
        return true;
      }
    }
    selectedMinutes = 0;
    notifyListeners();
    return false;
  }

  void updateNotificationType(String type) {
    currentTask.notifType = type;
    notifyListeners();
  }
  //-----------------------------------------------------------------------//

  //------------------------ REPEAT & REMINDER HANDLING ------------------------//
  bool isWeekdayValid(int weekday) {
    if (currentTask.endDate == null) return true;

    // Calculate the next occurrence of this weekday
    var date = currentTask.startDate;
    while (date.weekday != weekday) {
      date = date.add(const Duration(days: 1));
    }

    // Check if this weekday occurs between start and end dates
    return date.isBefore(currentTask.endDate!) ||
        date.isAtSameMomentAs(currentTask.endDate!);
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
          : <String, dynamic>{};

      config['repeatType'] = type;
      if (type == 'weekly') {
        config['selectedDays'] = <int>[];
      } else {
        config.remove('selectedDays');
      }

      currentTask.repeatConfig = jsonEncode(config);
      notifyListeners();
    } catch (e) {
      logger.e('Error setting repeat type: $e');
    }
  }

  void toggleWeekday(int weekday) {
    if (currentTask.repeatConfig == null) return;

    try {
      final config =
          jsonDecode(currentTask.repeatConfig!) as Map<String, dynamic>;
      if (config['repeatType'] != 'weekly') return;

      var days = List.from(config['selectedDays'] ?? []);

      if (days.contains(weekday)) {
        days.remove(weekday);
      } else {
        days.add(weekday);
      }

      config['selectedDays'] = days;
      currentTask.repeatConfig = jsonEncode(config);
      notifyListeners();
    } catch (e) {
      logger.e('Error toggling weekday: $e');
    }
  }

  void addReminderTime(TimeOfDay time) {
    final times = jsonDecode(currentTask.reminderTimes ?? '[]') as List;
    if (times.length >= 7) return;

    times.add(time);
    currentTask.reminderTimes = jsonEncode(times
        .map((t) =>
            '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}')
        .toList());
    notifyListeners();
  }

  void removeReminderTime(TimeOfDay time) {
    final times = jsonDecode(currentTask.reminderTimes ?? '[]') as List;
    times.removeWhere((t) => t.hour == time.hour && t.minute == time.minute);

    currentTask.reminderTimes = jsonEncode(times
        .map((t) =>
            '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}')
        .toList());
    notifyListeners();
  }

  void updateReminderTime(TimeOfDay oldTime, TimeOfDay newTime) {
    if (currentTask.reminderTimes == null) return;

    final times = jsonDecode(currentTask.reminderTimes!);
    final index = times.indexOf(oldTime);
    if (index != -1) {
      times[index] = newTime;
      currentTask.reminderTimes = jsonEncode(times);
      notifyListeners();
    }
  }
  //-----------------------------------------------------------------------//

  //------------------------ TASK CRUD OPERATIONS ------------------------//
  Future<bool> addNewTask() async {
    currentTask.category ??= await CategoryService.getGeneralCategory();

    if (currentTask.isValid()) {
      // Set up repeat configuration if enabled
      if (currentTask.isRepeating!) {
        // Validate repeat configuration
        try {
          if (currentTask.repeatConfig == null) return false;
          final config =
              jsonDecode(currentTask.repeatConfig!) as Map<String, dynamic>;
          if (config['repeatType'] == 'weekly') {
            final days = List<int>.from(config['selectedDays'] ?? []);
            if (days.isEmpty)
              return false; // Can't create weekly task without selected days
          }
        } catch (e) {
          logger.e('Error validating repeat config: $e');
          return false;
        }
      }

      final id = await TaskService.addTask(currentTask);
      currentTask.id = id;
      _refreshTasks();

      // Schedule notifications
      if (currentTask.isNotifyEnabled!) {
        if (currentTask.isRepeating!) {
          await NotificationService.createRepeatingTaskNotifications(
              currentTask);
        } else {
          await NotificationService.createTaskNotification(currentTask);
        }
      }

      return true;
    }
    return false;
  }

  Future<int> editTask() async {
    int changes = 0;
    if (currentTask.isValid()) {
      changes = await TaskService.editTask(newTask: currentTask.toJson());
    }
    _refreshTasks();
    // Reschedule notifications based on repeating flag.
    if (currentTask.isRepeating! && currentTask.isNotifyEnabled!) {
      await NotificationService.createRepeatingTaskNotifications(currentTask);
    } else if (currentTask.isNotifyEnabled!) {
      await NotificationService.createTaskNotification(currentTask);
    }
    return changes;
  }

  Future<bool> deleteTask(Task task) async {
    await TaskService.deleteTask(task.id!);
    _tasks.remove(task);
    if (task.dueDate != null) {
      await _updateStatsForDeletedTask(task);
    }
    notifyListeners();
    return true;
  }

  Future<int> toggleStatus(Task task, bool updatedStatus) async {
    await Future.delayed(Duration(milliseconds: 600));
    int changesMade = 0;
    task.isDone = updatedStatus;
    changesMade = await TaskService.toggleDone(
        task.id!, updatedStatus, task.isDone! ? DateTime.now() : null);
    if (task.isDone!) {
      await AwesomeNotifications().cancel(task.id!);
    } else if (task.isNotifyEnabled!) {
      if (task.isRepeating!) {
        await NotificationService.createRepeatingTaskNotifications(task);
      } else {
        await NotificationService.createTaskNotification(task);
      }
    }
    _refreshTasks();
    return changesMade;
  }

  //----------------------------------------------------------------------//

  //------------------------ TASK LIST MANAGEMENT ------------------------//
  void _refreshTasks() async {
    _tasks = await TaskService.getTasks();
    notifyListeners();
  }

  void filterTasks(int filterFlag) async {
    finishedTasks = await TaskService.filterTasks(filterFlag);
    notifyListeners();
  }

  void updateTasksAfterListDeletion(int listId) {
    for (var task in _tasks) {
      if (task.category?.id == listId) {
        task.category = CategoryModel(id: 1, name: 'General');
      }
    }
    notifyListeners();
  }

  void updateTaskListAfterEdit(CategoryModel list) async {
    final tasksForCurrentList =
        tasks.where((t) => t.category!.id == list.id).toList();
    await TaskService.editTaskListAfterEdit(tasksForCurrentList, list);
    _refreshTasks();
  }
  //--------------------------------------------------------------------------//

  //------------------------ STATISTICS MANAGEMENT ------------------------//
  Future<Map<String, dynamic>> getProductivityStats() async {
    final today = DateTime.now();
    final todayKey = DateFormat('yyyy-MM-dd').format(today);
    return await StatsService.getStats(todayKey);
  }

  Future<List<Map<String, dynamic>>> getWeeklyStats() async {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: 6));
    return await StatsService.getStatsRange(weekStart, now);
  }

  Future<void> _updateStats(Task task) async {
    if (task.dueDate == null) return;
    final dateKey = DateFormat('yyyy-MM-dd').format(task.dueDate!);
    final stats = await StatsService.getStats(dateKey);
    stats['total'] = (stats['total'] as int) + 1;
    if (task.isDone!) {
      stats['completed'] = (stats['completed'] as int) + 1;
    }
    final priorities = stats['priorities'] as Map<String, dynamic>;
    priorities[task.priority!] = (priorities[task.priority] as int) + 1;
    await StatsService.updateStats(dateKey, stats);
  }

  Future<void> _updateStatsForDeletedTask(Task task) async {
    final dateKey = DateFormat('yyyy-MM-dd').format(task.dueDate!);
    final stats = await StatsService.getStats(dateKey);
    stats['total'] = (stats['total'] as int) - 1;
    if (task.isDone!) {
      stats['completed'] = (stats['completed'] as int) - 1;
    }
    final priorities = stats['priorities'] as Map<String, dynamic>;
    priorities[task.priority!] = (priorities[task.priority] as int) - 1;
    await StatsService.updateStats(dateKey, stats);
  }
//----------------------------------------------------------------------//

  void toggleRepeat(bool value) {
    if (currentTask.isRepeating == value) return;

    currentTask.isRepeating = value;
    if (value) {
      // Switching to recurring task
      currentTask.startDate = currentTask.dueDate ?? DateTime.now();
      currentTask.endDate = null;
      currentTask.repeatConfig = jsonEncode({
        'repeatType': null,
        'selectedDays': [],
      });
      currentTask.reminderTimes = null;

      // Clear one-time settings
      currentTask.dueDate = null;
      currentTask.notifyTime = null;
    } else {
      // Switching to single task
      currentTask.dueDate = currentTask.startDate;
      currentTask.startDate = DateTime.now();
      currentTask.endDate = null;
      currentTask.repeatConfig = null;
      currentTask.reminderTimes = null;
      currentTask.notifyTime = null;
      currentTask.isNotifyEnabled = false;
    }

    notifyListeners();
  }

  // Helper getters/setters for repeat configuration
  bool get isRepeatEnabled => currentTask.isRepeating ?? false;

  DateTime get taskStartDate => currentTask.startDate;

  DateTime? get taskEndDate => currentTask.endDate;

  String? get repeatType {
    if (currentTask.repeatConfig == null) return null;
    try {
      final config =
          jsonDecode(currentTask.repeatConfig!) as Map<String, dynamic>;
      return config['repeatType'] as String?;
    } catch (e) {
      logger.e('Error decoding repeatType: $e');
      return null;
    }
  }

  List<int> get selectedWeekdays {
    if (currentTask.repeatConfig == null) return [];
    try {
      final config =
          jsonDecode(currentTask.repeatConfig!) as Map<String, dynamic>;
      if (config['repeatType'] == 'weekly' && config['selectedDays'] is List) {
        return List<int>.from(config['selectedDays']);
      }
      return [];
    } catch (e) {
      logger.e('Error decoding selectedWeekdays: $e');
      return [];
    }
  }

  List<TimeOfDay> get reminderTimesList {
    if (currentTask.reminderTimes == null) return [];
    try {
      final times = jsonDecode(currentTask.reminderTimes!) as List;
      return times.map((timeStr) {
        final parts = timeStr.split(':');
        return TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }).toList();
    } catch (e) {
      logger.e('Error decoding reminderTimes: $e');
      return [];
    }
  }

  void _updateWeekdayValidity() {
    if (currentTask.repeatConfig == null) return;

    try {
      final config =
          jsonDecode(currentTask.repeatConfig!) as Map<String, dynamic>;
      if (config['repeatType'] != 'weekly') return;

      var days = List<int>.from(config['selectedDays'] ?? []);
      days.removeWhere((weekday) => !isWeekdayValid(weekday));

      config['selectedDays'] = days;
      currentTask.repeatConfig = jsonEncode(config);
    } catch (e) {
      logger.e('Error updating weekday validity: $e');
    }
  }
}
