import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:minimaltodo/data_models/category_model.dart';
import 'package:minimaltodo/data_models/task.dart';
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
      isNotifyEnabled:MiniBox.read(mIsNotificationsGloballyEnabled),
      repeatConfig: '{"repeatType":"weekly","selectedDays":[1,2,3,4,5,6]}',
    );

    selectedMinutes = 0;
    titleController.clear();

    // No need to reset these as they're now handled through currentTask
    // currentTask.repeatConfig = null;
    currentTask.reminderTimes = null;
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
  Map<int, Set<int>> recurringTaskCompletion =
      {}; // taskId -> completed dates (for recurring tasks)

  Task currentTask = Task();
  TextEditingController titleController = TextEditingController();
  FocusNode textFieldNode = FocusNode();
  List<String> priorities = ["Urgent", "High", "Medium", "Low"];
  int currentValue = 3; // Default to Low Priority
  int selectedMinutes = 0;

  //------------------------ BASIC SETTERS ------------------------//
  Future<void> setCategories(Map<int, bool> selectedCategories) async{
    var categoryIds = selectedCategories.entries.where((e) => e.value).map((e) => e.key).toList();

    final db = await DatabaseService.openDb();
    try {
      // First delete existing categories
      await db.delete('task_categories', where: 'task_id = ?', whereArgs: [currentTask.id]);
      
      // Then add new categories
      final batch = db.batch();

      for(var id in categoryIds){
        batch.insert('task_categories', {'task_id' : currentTask.id, 'category_id':id});
      }
      await batch.commit();
      selectedCategories.updateAll((key, value) => key != 1 ? false : value);
    }catch(e){
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
      notifyListeners();
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
    if (currentTask.dueDate != null && currentTask.isNotifyEnabled!) {
      currentTask.notifyTime = currentTask.dueDate!.subtract(Duration(minutes: selectedMinutes));
    }
    updateNotifLogicAfterDueDateUpdate();
  }

   void setTime(TimeOfDay time) {
    final existingDate = currentTask.dueDate ?? DateTime.now();
    currentTask.dueDate = DateTime(
      existingDate.year,
      existingDate.month,
      existingDate.day,
      time.hour,
      time.minute,
    );
    notifyListeners();
    if (currentTask.dueDate != null && currentTask.isNotifyEnabled!) {
      currentTask.notifyTime = currentTask.dueDate!.subtract(Duration(minutes: selectedMinutes));
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
      if (currentTask.dueDate != null && currentTask.dueDate!.isBefore(DateTime.now())) {
        currentTask.isNotifyEnabled = false;
        if (currentTask.id != null) {
          NotificationService.removeTaskNotification(currentTask);
        }
      }
      if (currentTask.notifyTime != null && !currentTask.notifyTime!.isAfter(DateTime.now())) {
        selectedMinutes = 0;
      }
      notifyListeners();
    }
  }

  void toggleNotifSwitch(bool value) async {
    await NotificationService.initializeNotificationChannels();
    currentTask.isNotifyEnabled = value;
    if (currentTask.isNotifyEnabled! && currentTask.dueDate != null) {
      currentTask.notifyTime = currentTask.dueDate!.subtract(Duration(minutes: selectedMinutes));
    }
    notifyListeners();
  }

  bool updateNotifyTime(int minutes) {
    selectedMinutes = minutes;
    if (currentTask.dueDate != null) {
      final notifTime = currentTask.dueDate!.subtract(Duration(minutes: selectedMinutes));
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
    var endDate = currentTask.endDate;

    return (date.year == endDate!.year && date.month == endDate.month && date.day == endDate.day) ||
        date.isBefore(currentTask.endDate!);
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
      if (type == 'weekly') {
        config['selectedDays'] = [1, 2, 3, 4, 5,6];
      } else {
        config.remove('selectedDays');
      }

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
        }
        else{
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
      final List<String> times = List.from(
        jsonDecode(currentTask.reminderTimes ?? '[]'),
      );

      if (times.length >= 7) return;

      // Convert TimeOfDay to string format
      final timeString='${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

      // Check for duplicates
      if (times.contains(timeString)) return;
      MiniLogger.debug('Time String: $timeString');
      times.add(timeString);
      currentTask.reminderTimes = jsonEncode(times);
      MiniLogger.debug('All reminder Times: ${currentTask.reminderTimes}');
      notifyListeners();
    } catch (e) {
      MiniLogger.error('Error adding reminder time: $e');
    }
  }

  void removeReminderTime(TimeOfDay time) {
    try {
      final List<String> times = List.from(
        jsonDecode(currentTask.reminderTimes ?? '[]'),
      );

      // Convert TimeOfDay to string format for comparison
      final timeString = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

      times.remove(timeString);
      currentTask.reminderTimes = jsonEncode(times);
      notifyListeners();
    } catch (e) {
      MiniLogger.error('Error removing reminder time: $e');
    }
  }

  void updateReminderTime(TimeOfDay oldTime, TimeOfDay newTime) {
    try {
      final List<String> times = List.from(
        jsonDecode(currentTask.reminderTimes ?? '[]'),
      );

      final oldTimeString = '${oldTime.hour.toString().padLeft(2, '0')}:${oldTime.minute.toString().padLeft(2, '0')}';
      final newTimeString = '${newTime.hour.toString().padLeft(2, '0')}:${newTime.minute.toString().padLeft(2, '0')}';

      final index = times.indexOf(oldTimeString);
      if (index != -1) {
        times[index] = newTimeString;
        currentTask.reminderTimes = jsonEncode(times);
        notifyListeners();
      }
    } catch (e) {
      MiniLogger.error('Error updating reminder time: $e');
    }
  }

  List<TimeOfDay> get reminderTimesList {
    if (currentTask.reminderTimes == null) return [];
    try {
      final List<String> times = List.from(
        jsonDecode(currentTask.reminderTimes!),
      );
      return times.map((timeStr) {
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
  Future<String?> addNewTask(Map<int,bool> categories) async {
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
    if (currentTask.isNotifyEnabled!) {
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
          await NotificationService.removeTaskNotification(currentTask);
        }
      }
      return Messages.mTaskEdited;
    }else{
      MiniLogger.debug('Task is not valid');
      return Messages.mTaskEmpty;
    }
  }

  Future<bool> deleteTask(Task task) async {
    // First remove all notifications for this task
    if (task.isNotifyEnabled!) {
      if (task.isRepeating!) {
        // Remove all scheduled notifications for recurring task
        await NotificationService.removeRepeatingTaskNotifications(task);
      } else {
        await NotificationService.removeTaskNotification(task);
      }
    }

    await TaskService.deleteTask(task.id!);
    _tasks.remove(task);
    notifyListeners();
    return true;
  }

  Future<int> toggleStatus(Task task, bool updatedStatus, CalendarViewModel calendarVM) async {
    final db = await DatabaseService.openDb();
    var changes = 0;
    try {
      if (task.isRepeating!) {
        final date = DateTime(calendarVM.selectedDate.year, calendarVM.selectedDate.month,
            calendarVM.selectedDate.day)
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
          {'isDone': updatedStatus ? 1 : 0},
          where: 'id = ?',
          whereArgs: [task.id],
        );
        singleTaskCompletion[task.id!] = updatedStatus;
      }
      notifyListeners();
      return changes;
    }catch(e){
      MiniLogger.error('Error toggling status: $e');
      return 0;
    }
  }

  //----------------------------------------------------------------------//

  //------------------------ TASK LIST MANAGEMENT ------------------------//

  // void updateTasksAfterListDeletion(int listId) {
  //   for (var task in _tasks) {
  //     if (task.category?.id == listId) {
  //       task.category = CategoryModel(id: 1, name: 'General');
  //     }
  //   }
  //   notifyListeners();
  // }

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
        'selectedDays': [1, 2, 3, 4, 5,6],
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
    if (currentTask.repeatConfig == null) return [1, 2, 3, 4, 5, 6];
    try {
      final config = jsonDecode(currentTask.repeatConfig!) as Map<String, dynamic>;
      if (config['repeatType'] == 'weekly' && config['selectedDays'] is List) {
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
      days.removeWhere((weekday) => !isWeekdayValid(weekday));

      config['selectedDays'] = days;
      currentTask.repeatConfig = jsonEncode(config);
    } catch (e) {
      MiniLogger.error('Error updating weekday validity: $e');
    }
  }
}
