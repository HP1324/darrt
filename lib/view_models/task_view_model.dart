
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:minimaltodo/data_models/category_model.dart';
import 'package:minimaltodo/data_models/task.dart';
import 'package:minimaltodo/global_utils.dart';
import 'package:minimaltodo/services/category_service.dart';
import 'package:minimaltodo/services/notification_service.dart';
import 'package:minimaltodo/services/stats_service.dart';
import 'package:minimaltodo/services/task_service.dart';

class TaskViewModel extends ChangeNotifier {
  TaskViewModel() {
    _refreshTasks();
    filterTasks(0);
  }
// In TaskViewModel
  void initNewTask() {
    currentTask = Task(
        dueDate: DateTime.now(),
        category: CategoryModel(id: 1, name: 'General'),
        // isNotifyEnabled: GetStorage().read('notifications') ? true: false,
        priority: "Low",
        notifType: "notif",
    );
    selectedMinutes = 0;
    titleController.clear();
  }

  void initEditTask(Task task) {
    currentTask = task;
    titleController.text = task.title ?? '';
    selectedMinutes = task.dueDate != null && task.notifyTime != null
        ? task.dueDate!.difference(task.notifyTime!).inMinutes
        : 0;
  }
  List<Task> _tasks = [];
  List<Task> get tasks => _tasks;
  Task currentTask = Task();

  set list(CategoryModel list) {
    logger.i('current task list icon code: ${list.iconCode}');
    currentTask.category = list;
    notifyListeners();
  }

  set priority(String priority) {
    currentTask.priority = priority;
    notifyListeners();
  }

  set title(String title) => currentTask.title = title;
  set dueDate(DateTime? dueDate) {
    currentTask.dueDate = dueDate;
    //Changing notifyTime here to avoid null issues and also when user returns back from notification settings page, there is a chance to change the dueDate back, so to update the notify time according to the new dueDate, we have to add the following line:
    currentTask.notifyTime = currentTask.dueDate!.subtract(Duration(minutes: selectedMinutes));
    updateNotifLogicAfterDueDateUpdate();
  }
  TextEditingController titleController = TextEditingController();
  set time(TimeOfDay time) {
    final DateTime now = currentTask.dueDate ?? DateTime.now();

    dueDate = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    currentTask.notifyTime = currentTask.dueDate!.subtract(Duration(minutes: selectedMinutes));
   updateNotifLogicAfterDueDateUpdate();
  }
  void updateNotifLogicAfterDueDateUpdate(){
    if(currentTask.dueDate!.isBefore(DateTime.now())){
      currentTask.isNotifyEnabled = false;
      if(currentTask.id != null) {
        currentTask.isNotifyEnabled = false;
        NotificationService.removeTaskNotification(currentTask);
      }
    }
    if(!currentTask.notifyTime!.isAfter(DateTime.now())){
      selectedMinutes = 0;
    }
    notifyListeners();
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
    final now = DateTime.now();
    currentTask.dueDate = DateTime(
      currentDueDate.year,
      currentDueDate.month,
      currentDueDate.day,
      now.hour,
      now.minute,
    );
    notifyListeners();
  }
  bool updateDueDate(DateTime date, TimeOfDay time) {
    final taskDueDate = DateTime(date.year, date.month, date.day, time.hour, time.minute, 0 //seconds
        );
    if (isValidDateTime(taskDueDate)) {
      currentTask.dueDate = taskDueDate;
      currentTask.notifyTime = currentTask.dueDate!.subtract(Duration(minutes: selectedMinutes));
      notifyListeners();
      return true;
    }
    return false;
  }

  _refreshTasks() async {
    _tasks = await TaskService.getTasks();
    notifyListeners();
  }

  bool isNewTaskAdded = false;
  Future<bool> addNewTask() async {
    currentTask.category ??= await CategoryService.getGeneralCategory();
    logger.t('Adding task list icon: ${currentTask.category!.iconCode}');
    if (currentTask.isValid()) {
      final id = await TaskService.addTask(currentTask);
      currentTask.id = id;
      _refreshTasks();

      // Update stats for new task
      if (currentTask.dueDate != null) {
        await _updateStats(currentTask);
      }

      isNewTaskAdded = true;
      return true;
    }
    showToast(title: 'Please enter a task first', alignment: Alignment.center);
    return false;
  }

  Future<int> editTask() async {

    int changes = 0;
    if(currentTask.isValid()) {
      changes = await TaskService.editTask(newTask: currentTask.toJson());
    }
    _refreshTasks();
    return changes;
  }

  Future<bool> deleteTask(Task task) async {
    await TaskService.deleteTask(task.id!);
    _tasks.remove(task);
    // Update stats when task is deleted
    if (task.dueDate != null) {
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
    notifyListeners();
    return true;
  }

  Future<int> toggleStatus(Task task, bool updatedStatus) async {
    await Future.delayed(Duration(milliseconds: 900));
    var changesMade = 0;
    task.isDone = updatedStatus;
    changesMade = await TaskService.toggleDone(task.id!, updatedStatus, task.isDone! ? DateTime.now() : null);
    _refreshTasks();
    return changesMade;
  }

  void updateTask(Task oldTask, Task newTask) async {
    await TaskService.editTask(newTask: newTask.toJson());
    final index = _tasks.indexWhere((t) => t.id == oldTask.id);
    if (index != -1) {
      // Update stats for old task date
      if (oldTask.dueDate != null) {
        final oldDateKey = DateFormat('yyyy-MM-dd').format(oldTask.dueDate!);
        final oldStats = await StatsService.getStats(oldDateKey);

        oldStats['total'] = (oldStats['total'] as int) - 1;
        if (oldTask.isDone!) {
          oldStats['completed'] = (oldStats['completed'] as int) - 1;
        }

        final oldPriorities = oldStats['priorities'] as Map<String, dynamic>;
        oldPriorities[oldTask.priority!] = (oldPriorities[oldTask.priority] as int) - 1;

        await StatsService.updateStats(oldDateKey, oldStats);
      }

      // Update stats for new task date
      if (newTask.dueDate != null) {
        final newDateKey = DateFormat('yyyy-MM-dd').format(newTask.dueDate!);
        final newStats = await StatsService.getStats(newDateKey);

        newStats['total'] = (newStats['total'] as int) + 1;
        if (newTask.isDone!) {
          newStats['completed'] = (newStats['completed'] as int) + 1;
        }

        final newPriorities = newStats['priorities'] as Map<String, dynamic>;
        newPriorities[newTask.priority!] = (newPriorities[newTask.priority] as int) + 1;

        await StatsService.updateStats(newDateKey, newStats);
      }

      _tasks[index] = newTask;
      notifyListeners();
    }
  }

  // Stats related methods
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

    // Update stats based on task changes
    stats['total'] = (stats['total'] as int) + 1;
    if (task.isDone!) {
      stats['completed'] = (stats['completed'] as int) + 1;
    }

    final priorities = stats['priorities'] as Map<String, dynamic>;
    priorities[task.priority!] = (priorities[task.priority] as int) + 1;

    // Save updated stats
    await StatsService.updateStats(dateKey, stats);
  }

  List<Task> finishedTasks = [];
  List<Task> pendingTasks = [];
  void filterTasks(int filterFlag) async {
    finishedTasks = await TaskService.filterTasks(0);
    notifyListeners();
  }

  // Handle tasks when their list is deleted
  void updateTasksAfterListDeletion(int listId) {
    // Update all tasks in the deleted list to have no list
    for (var task in _tasks) {
      if (task.category?.id == listId) {
        task.category = CategoryModel(id: 1, name: 'General');
      }
    }
    notifyListeners();
  }

  void toggleNotifSwitch(bool value) {
    currentTask.isNotifyEnabled = value;
    if(currentTask.isNotifyEnabled!){
      currentTask.notifyTime = currentTask.dueDate!.subtract( Duration(minutes:selectedMinutes ));
    }
    notifyListeners();
  }

  int selectedMinutes = 0;

  bool updateNotifyTime(int minutes) {
    selectedMinutes = minutes;
    var notifTime = currentTask.dueDate!.subtract(Duration(minutes: selectedMinutes));
    logger.d('task due date: ${currentTask.dueDate}, notifyTime: $notifTime');
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

  void updateTaskListAfterEdit(CategoryModel list) async {
    final tasksForCurrentList = tasks.where((t) => t.category!.id == list.id).toList();
    final results = await TaskService.editTaskListAfterEdit(tasksForCurrentList, list);
    _refreshTasks();
  }

  List<String> priorities = ["Urgent", "High", "Medium", "Low"];
  int currentValue = 3; // Default to Low

  void navigatePriority(bool isNext) {
    if (isNext) {
      currentValue = (currentValue + 1) % priorities.length;
    } else {
      currentValue = (currentValue - 1 + priorities.length) % priorities.length;
    }
    currentTask.priority = priorities[currentValue];
    notifyListeners();
  }

}
