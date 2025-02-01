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
      dueDate: DateTime.now().add(Duration(minutes: 2)),
      category: CategoryModel(id: 1, name: 'General'),
      priority: "Low",
      notifType: "notif",
    );
    selectedMinutes = 0;
    titleController.clear();
  }

  void initEditTask(Task task) {
    currentTask = task;
    titleController.text = task.title ?? '';
    selectedMinutes = task.dueDate != null && task.notifyTime != null ? task.dueDate!.difference(task.notifyTime!).inMinutes : 0;
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

  //-------------------------------------------------------------------------//

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
      currentTask.notifyTime = currentTask.dueDate!.subtract(Duration(minutes: selectedMinutes));
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
    if(currentTask.dueDate != null && currentTask.isNotifyEnabled!) {
      currentTask.notifyTime = currentTask.dueDate!.subtract(Duration(minutes: selectedMinutes));
    }
    updateNotifLogicAfterDueDateUpdate();
  }

  void removeDueDate() {
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

  void removeTime() {
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

  //----------------------------------------------------------------------//

  //------------------------ NOTIFICATION HANDLING ------------------------//
  void updateNotifLogicAfterDueDateUpdate() {
    if(currentTask.isNotifyEnabled!) {
      if (currentTask.dueDate!.isBefore(DateTime.now())) {
        currentTask.isNotifyEnabled = false;
        if (currentTask.id != null) {
          NotificationService.removeTaskNotification(currentTask);
        }
      }
      if (!currentTask.notifyTime!.isAfter(DateTime.now())) {
        selectedMinutes = 0;
      }
      notifyListeners();
    }
  }

  void toggleNotifSwitch(bool value) async {
    await NotificationService.initializeNotificationChannels();
    currentTask.isNotifyEnabled = value;
    if (currentTask.isNotifyEnabled!) {
      currentTask.notifyTime = currentTask.dueDate!.subtract(Duration(minutes: selectedMinutes));
    }
    notifyListeners();
  }

  bool updateNotifyTime(int minutes) {
    selectedMinutes = minutes;
    var notifTime = currentTask.dueDate!.subtract(Duration(minutes: selectedMinutes));
    if (notifTime.isAfter(DateTime.now())) {
      currentTask.notifyTime = currentTask.dueDate!.subtract(Duration(minutes: selectedMinutes));
      notifyListeners();
      return true;
    } else {
      selectedMinutes = 0;
      notifyListeners();
      return false;
    }
  }

  void updateNotificationType(String type) {
    currentTask.notifType = type;
    notifyListeners();
  }
  //-----------------------------------------------------------------------//

  //------------------------ TASK CRUD OPERATIONS ------------------------//
  Future<bool> addNewTask() async {
    currentTask.category ??= await CategoryService.getGeneralCategory();
    logger.t('Adding task list icon: ${currentTask.category!.iconCode}');
    if (currentTask.isValid()) {
      final id = await TaskService.addTask(currentTask);
      currentTask.id = id;
      _refreshTasks();
      if (currentTask.dueDate != null) {
        await _updateStats(currentTask);
      }
      isNewTaskAdded = true;
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
    var changesMade = 0;
    task.isDone = updatedStatus;
    changesMade = await TaskService.toggleDone(task.id!, updatedStatus, task.isDone! ? DateTime.now() : null);
    if(task.isDone!){
      await AwesomeNotifications().cancel(task.id!);
    }else if(task.isNotifyEnabled!){
      await NotificationService.createTaskNotification(task);
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
    finishedTasks = await TaskService.filterTasks(0);
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
    final tasksForCurrentList = tasks.where((t) => t.category!.id == list.id).toList();
    final results = await TaskService.editTaskListAfterEdit(tasksForCurrentList, list);
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
}
