

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:minimaltodo/data_models/list_model.dart';
import 'package:minimaltodo/data_models/task.dart';
import 'package:minimaltodo/global_utils.dart';
import 'package:minimaltodo/services/list_service.dart';
import 'package:minimaltodo/services/stats_service.dart';
import 'package:minimaltodo/services/task_service.dart';

class TaskViewModel extends ChangeNotifier {
  TaskViewModel() {
    _refreshTasks();
    filterTasks(0);
  }

  List<Task> _tasks = [];
  List<Task> get tasks => _tasks;
  Task currentTask = Task();

  set list(ListModel list) {
    logger.i('current task list icon code: ${list.iconCode}');
    currentTask.list = list;
    notifyListeners();
  }

  set priority(String priority) => currentTask.priority = priority;
  set title(String title) => currentTask.title = title;
  set dueDate(DateTime? dueDate) => currentTask.dueDate = dueDate;
  void removeDueDate() {
    currentTask.dueDate = null;
    notifyListeners();
  }

  _refreshTasks() async {
    _tasks = await TaskService.getTasks();
    notifyListeners();
  }

  bool isNewTaskAdded = false;
  Future<bool> addNewTask() async {
    if(currentTask.list == null) currentTask.list = await ListService.getGeneralList();
    logger.t('Adding task list icon: ${currentTask.list!.iconCode}');
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
    showToast(
        title: 'Please enter a task first',
        bgColor: Colors.red,
        fgColor: Colors.white,
        alignment: Alignment.center);
    return false;
  }

  Future<int> editTask() async {
    final changes = await TaskService.editTask(newTask: currentTask.toJson());
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
    changesMade =
        await TaskService.toggleDone(task.id!, updatedStatus, task.isDone! ? DateTime.now() : null);
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

  // The following part filters tasks done or undone
  Map<String, bool> doneUndone = {
    'Finished': false,
    'Pending': false,
  };

  ///This [filterFlag] variable is managing three states of filtering
  /// 0 = All tasks
  /// 1 = Tasks done
  /// 2 = Tasks not done
  int filterFlag = 0;

  void toggleSelected(String label, bool value) {
    ///This line makes sure that only one of the chips is getting selected. all the ///other selected chips will
    ///be set to false with the use of [updateAll] method
    doneUndone.updateAll((k, v) => k == label ? value : false);
    notifyListeners();
    _setFilterFlag(label);
  }

  ///This function manages the value of [filterFlag] variable based on the value of [label]
  void _setFilterFlag(String label) async {
    ///Checking if no chip is currently selected in order to show all tasks again by setting [filterDone]
    /// to [zero]. For this I have used [every] method from [abstract mixin class Iterable] which checks whether or
    /// not a certain object is set
    /// to a certain value. if all are false then [filterDone] is zero which will show all tasks again.
    bool allFalse = doneUndone.values.every((value) => !value);
    filterFlag = allFalse
        ? 0
        : label == 'Finished'
            ? 1
            : 2;
    debugPrint('filter: $filterFlag');
    _refreshTasks();
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
      if (task.list?.id == listId) {
        task.list = ListModel(id: 1, name: 'General');
      }
    }
    notifyListeners();
  }

  void toggleNotifSwitch(bool value) {
    currentTask.isNotifyEnabled = value;
    notifyListeners();
  }

  int selectedMinutes = 0;

  void updateNotifyTime(int minutes){
      selectedMinutes = minutes;
    var notifTime = currentTask.dueDate!.subtract(Duration(minutes: selectedMinutes));
    logger.d('task due date: ${currentTask.dueDate}, notifyTime: ${notifTime}');
    if(notifTime.isAfter(DateTime.now())) {
      currentTask.notifyTime = currentTask.dueDate!.subtract(Duration(minutes: selectedMinutes, seconds: 35));
    }else{
      selectedMinutes = 0;
      showToast(title: 'This time has gone');
    }
    notifyListeners();
  }
  void resetNotifSettings(){
    currentTask.notifyTime = null;
    currentTask.notifType = null;
    selectedMinutes = 0;
    notifyListeners();
  }
  void resetSelectedMinutes(){
    selectedMinutes = 0;
    notifyListeners();
  }
  void setNotifConfigInUI(){
    if(currentTask.notifyTime != null) {
      selectedMinutes =currentTask.dueDate!.difference(currentTask.notifyTime!).inMinutes;
    }else{
      selectedMinutes = 0;
    }
      notifyListeners();
  }

  void updateTaskListAfterEdit(ListModel list)async{
    final tasksForCurrentList = tasks.where((t)=>t.list!.id == list.id).toList();
    final results = await TaskService.editTaskListAfterEdit(tasksForCurrentList,list);
    _refreshTasks();
  }
}
