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
      isRepeating: false, // Default to single task
      isNotifyEnabled: false,
    );

    selectedMinutes = 0;
    titleController.clear();

    // Reset repeat and reminder properties
    isRepeatEnabled = false; // Default to single task
    taskStartDate = DateTime.now();
    taskEndDate = null;
    repeatType = null;
    selectedWeekdays = [];
    reminderTimesList = [];
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

    // Initialize repeating task properties from currentTask
    isRepeatEnabled = currentTask.isRepeating ?? false;
    taskStartDate = currentTask.startDate;
    taskEndDate = currentTask.endDate;

    if (currentTask.repeatConfig != null) {
      try {
        Map<String, dynamic> config = jsonDecode(currentTask.repeatConfig!);
        repeatType = config['repeatType'];
        if (repeatType == 'weekly' && config['selectedDays'] is List) {
          selectedWeekdays = List<int>.from(config['selectedDays']);
        }
      } catch (e) {
        logger.e('Error decoding repeatConfig: $e');
      }
    }

    // Initialize reminder times
    reminderTimesList = [];
    if (currentTask.reminderTimes != null) {
      try {
        List<dynamic> times = jsonDecode(currentTask.reminderTimes!);
        reminderTimesList = times.map((timeStr) {
          final parts = (timeStr as String).split(":");
          return TimeOfDay(
              hour: int.parse(parts[0]), minute: int.parse(parts[1]));
        }).toList();
      } catch (e) {
        logger.e('Error decoding reminderTimes: $e');
      }
    }
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

  // NEW: Repeating Task & Reminder Properties
  bool isRepeatEnabled = false;
  DateTime taskStartDate = DateTime.now();
  DateTime? taskEndDate; // null means indefinite
  String? repeatType; // 'weekly', 'monthly', 'yearly'
  List<int> selectedWeekdays =
      []; // for weekly repetition (1=Monday,...,7=Sunday)
  List<TimeOfDay> reminderTimesList = []; // up to 5 reminders

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
    if (taskEndDate == null) return true;

    // Calculate the next occurrence of this weekday
    var date = taskStartDate;
    while (date.weekday != weekday) {
      date = date.add(const Duration(days: 1));
    }

    // Check if this weekday occurs between start and end dates
    return date.isBefore(taskEndDate!) || date.isAtSameMomentAs(taskEndDate!);
  }

  void setTaskStartDate(DateTime date) {
    taskStartDate = date;
    // Clear invalid weekdays
    selectedWeekdays.removeWhere((weekday) => !isWeekdayValid(weekday));
    notifyListeners();
  }

  void setTaskEndDate(DateTime? date) {
    taskEndDate = date;
    currentTask.endDate = date;
    notifyListeners();
  }

  void setRepeatType(String type) {
    repeatType = type;
    // For 'monthly' and 'yearly', selectedWeekdays is not used.
    Map<String, dynamic> config = {
      'repeatType': type,
      'selectedDays': type == 'weekly' ? selectedWeekdays : null,
    };
    currentTask.repeatConfig = jsonEncode(config);
    notifyListeners();
  }

  void toggleWeekday(int weekday) {
    if (selectedWeekdays.contains(weekday)) {
      selectedWeekdays.remove(weekday);
    } else {
      selectedWeekdays.add(weekday);
    }
    if (repeatType == 'weekly') {
      Map<String, dynamic> config = {
        'repeatType': 'weekly',
        'selectedDays': selectedWeekdays,
      };
      currentTask.repeatConfig = jsonEncode(config);
      notifyListeners();
    }
  }

  void addReminderTime(TimeOfDay time) {
    if (reminderTimesList.length < 5) {
      reminderTimesList.add(time);
      // Save as list of strings (using HH:mm format) in currentTask.reminderTimes
      currentTask.reminderTimes = jsonEncode(reminderTimesList
          .map((t) =>
              t.hour.toString().padLeft(2, '0') +
              ':' +
              t.minute.toString().padLeft(2, '0'))
          .toList());
      notifyListeners();
    }
  }

  void removeReminderTime(TimeOfDay time) {
    reminderTimesList.remove(time);
    currentTask.reminderTimes = jsonEncode(reminderTimesList
        .map((t) =>
            t.hour.toString().padLeft(2, '0') +
            ':' +
            t.minute.toString().padLeft(2, '0'))
        .toList());
    notifyListeners();
  }

  void updateReminderTime(TimeOfDay oldTime, TimeOfDay newTime) {
    if (reminderTimesList.contains(newTime)) {
      return; // Don't update if the new time already exists
    }

    final index = reminderTimesList.indexOf(oldTime);
    if (index != -1) {
      reminderTimesList[index] = newTime;
      // Update the stored reminder times
      currentTask.reminderTimes = jsonEncode(reminderTimesList
          .map((t) =>
              '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}')
          .toList());
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
        currentTask.startDate = taskStartDate;
        currentTask.endDate = taskEndDate;

        // Validate repeat configuration
        if (repeatType == 'weekly' && selectedWeekdays.isEmpty) {
          return false; // Can't create weekly task without selected days
        }

        Map<String, dynamic> config = {
          'repeatType': repeatType,
          'selectedDays': repeatType == 'weekly' ? selectedWeekdays : null,
        };
        currentTask.repeatConfig = jsonEncode(config);

        // Handle reminder times
        if (currentTask.isNotifyEnabled! && reminderTimesList.isNotEmpty) {
          currentTask.reminderTimes = jsonEncode(reminderTimesList
              .map((t) =>
                  '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}')
              .toList());
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
    if (isRepeatEnabled == value) return; // No change needed

    isRepeatEnabled = value;
    currentTask.isRepeating = value;

    if (value) {
      // Switching to recurring task
      taskStartDate = currentTask.dueDate ?? DateTime.now();
      taskEndDate = null;
      repeatType = null;
      selectedWeekdays = [];
      reminderTimesList = [];

      // Clear one-time settings
      currentTask.dueDate = null;
      currentTask.notifyTime = null;
    } else {
      // Switching to single task
      currentTask.dueDate = taskStartDate;
      currentTask.notifyTime = null;
      currentTask.isNotifyEnabled = false;
      currentTask.repeatConfig = null;
      currentTask.reminderTimes = null;

      // Reset repeat settings
      taskStartDate = DateTime.now();
      taskEndDate = null;
      repeatType = null;
      selectedWeekdays = [];
      reminderTimesList = [];
    }

    notifyListeners();
  }
}
