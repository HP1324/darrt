import 'package:darrt/task/statistics/achievement_dialog.dart';
import 'package:darrt/task/statistics/achievements.dart';
import 'package:darrt/task/statistics/task_stats.dart';
import 'package:flutter/material.dart';
import 'package:darrt/app/notification/notification_service.dart';
import 'package:darrt/helpers/globals.dart' as g;
import 'package:darrt/helpers/messages.dart';
import 'package:darrt/app/services/mini_box.dart';
import 'package:darrt/helpers/mini_logger.dart';
import 'package:darrt/app/services/object_box.dart';
import 'package:darrt/helpers/typedefs.dart';
import 'package:darrt/objectbox.g.dart';
import 'package:darrt/app/state/viewmodels/view_model.dart';
import 'package:darrt/task/models/task.dart';
import 'package:darrt/task/models/task_completion.dart';

import '../../note/models/note.dart' show Note;

class TaskViewModel extends ViewModel<Task> {
  @override
  void initializeItems() {
    super.initializeItems();
    onetimeTaskCompletions.clear();
    for (var task in tasks.where((t) => !t.isRepeating).toList()) {
      onetimeTaskCompletions[task.id] = task.isDone;
    }
    repeatingTaskCompletions.clear();
    for (var completion in _completionBox.getAll()) {
      int id = completion.task.targetId;
      int date = completion.date.millisecondsSinceEpoch;
      repeatingTaskCompletions.putIfAbsent(id, () => {}).add(date);
    }
  }

  final _completionBox = ObjectBox().completionBox;
  Set<int> get selectedTaskIds => selectedItemIds;
  final Map<int, bool> onetimeTaskCompletions = {};
  final Map<int, Set<int>> repeatingTaskCompletions = {};

  final OneTimeCompletions oneTimeCompletions = ValueNotifier({});
  final RepeatingCompletions repeatingCompletions = ValueNotifier({});
  List<Task> get tasks => items;
  @override
  String putItem(Task item, {required bool edit}) {
    final task = item;
    final title = task.title.trim();

    if (title.isEmpty) return Messages.mTaskEmpty;
    task.title = title;

    final message = super.putItem(task, edit: edit);

    NotificationService.removeAllTaskNotifications(task).then((_) async {
      if (task.isRepeating) {
        await NotificationService.createRepeatingTaskNotifications(task);
      } else {
        await NotificationService.createTaskNotification(task);
      }
    });

    return message;
  }

  @override
  String deleteItem(int id) {
    NotificationService.removeAllTaskNotifications(tasks.firstWhere((t) => t.id == id));
    final message = super.deleteItem(id);
    notifyListeners();
    return message;
  }

  @override
  String deleteMultipleItems() {
    for (int id in selectedTaskIds) {
      NotificationService.removeAllTaskNotifications(tasks.firstWhere((t) => t.id == id));
    }

    // Delete ALL completions for each task
    for (var id in selectedTaskIds) {
      final query = _completionBox.query(TaskCompletion_.task.equals(id)).build();
      final removed = query.remove();
      query.close();
      MiniLogger.d('Removed $removed completions for task $id');
      repeatingTaskCompletions[id]?.clear();
    }

    final message = super.deleteMultipleItems();
    return message;
  }

  void deleteTasksByCategory(int categoryId) {
    final toDelete = items.where((t) => t.categories.any((c) => c.id == categoryId)).toList();
    box.removeMany(toDelete.map((t) => t.id).toList());
    items.removeWhere((t) => t.categories.any((c) => c.id == categoryId));
    notifyListeners();
  }

  void toggleStatus(Task task, bool value, DateTime d, [BuildContext? context]) async {
    if (task.isRepeating) {
      final dateOnly = DateUtils.dateOnly(d);
      //Can't mark finished if it's tomorrow or later
      if (!dateOnly.isAfter(DateUtils.dateOnly(DateTime.now()))) {
        final date = dateOnly.millisecondsSinceEpoch;
        if (value) {
          final completion = TaskCompletion(date: DateUtils.dateOnly(d), isDone: value);
          completion.task.target = task;
          completion.taskUuid = completion.task.target!.uuid;
          // here we need to merge completion uuid with its task's uuid, because, only giving date as uuid causes problem, that problem is that more than one completions can have same date, hence same uuid, so they will be considered duplicate in backup and restore, while in reality they are not duplicate.
          completion.uuid = '${completion.uuid}${completion.taskUuid}';
          MiniLogger.dp('Completion uuid: ${completion.uuid!}');
          MiniLogger.dp('Completion task uuid: ${completion.taskUuid!}');
          _completionBox.put(completion);
          repeatingTaskCompletions.putIfAbsent(task.id, () => {}).add(date);
          performTaskStatsLogicAfterTaskFinish(task, dateOnly, context);
          g.audioController.playSoundOnly('assets/sounds/bell_sound.mp3');
        } else {
          final query = _completionBox
              .query(TaskCompletion_.task.equals(task.id).and(TaskCompletion_.date.equals(date)))
              .build();
          final removed = query.remove();
          query.close();
          MiniLogger.d('removed $removed completions for task ${task.id}');
          repeatingTaskCompletions[task.id]?.remove(date);
          performTaskStatsLogicAfterTaskUnfinish(task, dateOnly);
        }
      }
    } else {
      task.isDone = value;
      box.put(task);
      onetimeTaskCompletions[task.id] = value;
      if (value) {
        g.audioController.playSoundOnly('assets/sounds/bell_sound.mp3');
      }
    }

    notifyListeners();
  }

  @override
  int getItemId(task) => task.id;

  @override
  String getCreateSuccessMessage() => Messages.mTaskAdded;

  @override
  String getUpdateSuccessMessage() => Messages.mTaskEdited;

  @override
  String getDeleteSuccessMessage(int length) =>
      length == 1 ? '1 ${Messages.mTaskDeleted}' : '$length ${Messages.mTasksDeleted}';

  @override
  void setItemId(Task item, int id) {
    item.id = id;
  }

  @override
  void putManyForRestore(List<Task> restoredItems, {List<TaskCompletion>? completions}) {
    // First, restore the relations before persisting
    restoreCompletionRelations(tasks: restoredItems, completions: completions!);

    // Now persist the objects with their relations set up
    _completionBox.putMany(completions);
    box.putMany(restoredItems);

    // Handle notifications after persistence
    for (var task in restoredItems) {
      NotificationService.removeAllTaskNotifications(task).then((_) async {
        if (task.isRepeating) {
          await NotificationService.createRepeatingTaskNotifications(task);
        } else {
          await NotificationService.createTaskNotification(task);
        }
      });
    }

    initializeItems();
    notifyListeners();
  }

  void restoreCompletionRelations({
    required List<Task> tasks,
    required List<TaskCompletion> completions,
  }) {
    // Build UUID → Task map
    final taskByUuid = {for (var task in tasks) task.uuid: task};

    // Restore Task ↔ TaskCompletion relations
    for (var completion in completions) {
      final matchingTask = taskByUuid[completion.taskUuid];
      if (matchingTask != null) {
        completion.task.target = matchingTask;
      } else {
        MiniLogger.dp('No matching task found for completion UUID: ${completion.taskUuid}');
      }
    }
  }

  @override
  String getItemUuid(Task item) => item.uuid;

  // @override
  // void mergeItems(Map<String,dynamic><Task> oldItems, Map<String,dynamic><Task> newItems) {}

  @override
  List<Task> convertJsonListToObjectList(List<Map<String, dynamic>> jsonList) {
    return jsonList.map(Task.fromJson).toList();
  }

  @override
  List<Map<String, dynamic>> convertObjectsListToJsonList(List<Task> objectList) {
    return objectList.map((task) => task.toJson()).toList();
  }

  bool _isTimelineView = MiniBox().read('isTimeLine') ?? true;
  bool get isTimelineView => _isTimelineView;

  // Toggle between timeline and normal view
  void toggleViewMode() async {
    _isTimelineView = !_isTimelineView;
    notifyListeners();
    MiniBox().write('isTimeLine', _isTimelineView);
  }

  // Set view mode explicitly
  void setViewMode(bool isTimeline) async {
    if (_isTimelineView != isTimeline) {
      _isTimelineView = isTimeline;
      notifyListeners();
      MiniBox().write('isTimeLine', _isTimelineView);
    }
  }

  // Get tasks sorted by time for timeline view
  List<Task> getTasksSortedByTime(List<Task> tasks) {
    final tasksWithTime = tasks.where((task) => task.startTime != null).toList();
    final tasksWithoutTime = tasks.where((task) => task.startTime == null).toList();

    // Sort tasks with time by their time
    tasksWithTime.sort((a, b) {
      final timeA = a.startTime!;
      final timeB = b.startTime!;
      return timeA.compareTo(timeB);
    });

    // Return tasks with time first, then tasks without time
    return [...tasksWithTime, ...tasksWithoutTime];
  }

  List<Note>? taskTimerNotes;
  void putNote({required Task task, required Note note, required bool edit}) {
    final List<Note> updatedNotes = Note.notesFromJsonString(task.notes) ?? [];

    final noteIndex = updatedNotes.indexWhere((n) => n.uuid == note.uuid);
    if (edit) {
      if (noteIndex != -1) {
        updatedNotes[noteIndex] = note;
      } else {
        updatedNotes.add(note); // Optional, depending on your logic
      }
    } else {
      updatedNotes.add(note);
    }

    // Update the task's notes string
    task.notes = Note.notesToJsonString(updatedNotes);

    // Update the global tasks list

    // Update taskTimerNotes with a new list (to trigger UI updates)
    taskTimerNotes = List<Note>.from(updatedNotes);
    updateTaskFromAppWideStateChanges(task);
    notifyListeners();
  }

  void removeNoteFromTask({required Task task, required Note note}) {
    // Step 1: Remove from UI-local taskTimerNotes
    taskTimerNotes = List<Note>.from(taskTimerNotes ?? [])..removeWhere((n) => n.uuid == note.uuid);

    // Step 2: Decode notes and remove from task.notes
    final List<Note> updatedNotes = Note.notesFromJsonString(task.notes) ?? [];
    updatedNotes.removeWhere((n) => n.uuid == note.uuid);
    task.notes = Note.notesToJsonString(updatedNotes);

    // Step 3: Update this task in the global tasks list
    updateTaskFromAppWideStateChanges(task);
    // Step 4: Notify listeners to update UI
    notifyListeners();
  }

  void initTaskNotesState(Task task) {
    taskTimerNotes = Note.notesFromJsonString(task.notes);
  }

  TaskStats? currentTaskStats = TaskStats();

  void initTaskStats(Task task) {
    currentTaskStats = TaskStats.fromJsonString(task.stats);
  }

  void updateTaskFromAppWideStateChanges(Task task) {
    final id = box.put(task);
    int index = tasks.indexWhere((i) => getItemId(i) == id);
    if (index != -1) {
      tasks[index] = task;
    }
  }

  void performTaskStatsLogicAfterTaskFinish(Task task, DateTime dateOnly, [BuildContext? context]) {
    MiniLogger.dp('finish stats function called');
    var stats = TaskStats.fromJsonString(task.stats);
    final List<DateTime> updatedCompletions = List<DateTime>.from(stats.completions);
    final today = DateUtils.dateOnly(DateTime.now());
    if (!updatedCompletions.contains(dateOnly)) {
      updatedCompletions.add(dateOnly);
    }
    updatedCompletions.sort((a, b) => a.compareTo(b));

    // Reset streak
    stats.currentStreakLength = 0;
    stats.currentStreakStart = null;

    // ✅ Only calculate streak if today is completed
    if (updatedCompletions.contains(today)) {
      int streak = 0;
      DateTime? streakStart;

      for (int i = 0; i < 7000; i++) {
        // Max look-back range (e.g., 1 year)
        final date = today.subtract(Duration(days: i));

        if (!task.isActiveOn(date)) continue; // skip if task wasn't supposed to run

        if (updatedCompletions.any((d) => DateUtils.isSameDay(d, date))) {
          streak += 1;
          streakStart = date;
        } else {
          break; // streak broken
        }
      }

      stats.currentStreakLength = streak;
      stats.currentStreakStart = streakStart;
    }

    stats.completions = updatedCompletions;
    MiniLogger.dp('Current streak length: ${stats.currentStreakLength}');
    MiniLogger.dp('Current streak start: ${stats.currentStreakStart}');
    checkAndHandleAchievements(task, stats, context);
    task.stats = stats.toJsonString();
    currentTaskStats = stats.copyWith();
    updateTaskFromAppWideStateChanges(task);
  }

  void performTaskStatsLogicAfterTaskUnfinish(Task task, DateTime dateOnly) {
    final stats = TaskStats.fromJsonString(task.stats);
    final List<DateTime> updatedCompletions = List<DateTime>.from(stats.completions);

    final today = DateUtils.dateOnly(DateTime.now());
    updatedCompletions.removeWhere((d) => DateUtils.isSameDay(d, dateOnly));
    updatedCompletions.sort((a, b) => a.compareTo(b));

    // Reset streak
    stats.currentStreakLength = 0;
    stats.currentStreakStart = null;

    // ✅ Only calculate streak if today is still completed
    if (updatedCompletions.contains(today)) {
      int streak = 0;
      DateTime? streakStart;

      for (int i = 0; i < 365; i++) {
        // Max look-back range (e.g., 1 year)
        final date = today.subtract(Duration(days: i));

        if (!task.isActiveOn(date)) continue; // skip if task wasn't supposed to run

        if (updatedCompletions.any((d) => DateUtils.isSameDay(d, date))) {
          streak += 1;
          streakStart = date;
        } else {
          break; // streak broken
        }
      }

      stats.currentStreakLength = streak;
      stats.currentStreakStart = streakStart;
    }

    stats.completions = updatedCompletions;
    removeInvalidAchievements(task, stats);
    MiniLogger.dp('Current streak length: ${stats.currentStreakLength}');
    MiniLogger.dp('Current streak start: ${stats.currentStreakStart}');
    task.stats = stats.toJsonString();
    currentTaskStats = stats.copyWith();
    updateTaskFromAppWideStateChanges(task);
  }

  void removeInvalidAchievements(Task task, TaskStats stats) {
    MiniLogger.dp('remove invalid achievements called');
    final completions = List<DateTime>.from(stats.completions)..sort();
    final unlocked = stats.achievementUnlocks;
    final validKeys = <String>{};

    List<List<DateTime>> streakSegments = [];
    List<DateTime> currentSegment = [];

    for (final date in completions) {
      final d = DateUtils.dateOnly(date);
      if (!task.isActiveOn(d)) continue;

      if (currentSegment.isEmpty) {
        currentSegment.add(d);
      } else {
        DateTime last = currentSegment.last;
        DateTime expected = last;
        do {
          expected = expected.add(const Duration(days: 1));
        } while (!task.isActiveOn(expected));

        if (DateUtils.isSameDay(d, expected)) {
          currentSegment.add(d);
        } else {
          if (currentSegment.isNotEmpty) streakSegments.add(currentSegment);
          currentSegment = [d];
        }
      }
    }

    if (currentSegment.isNotEmpty) {
      streakSegments.add(currentSegment);
    }

    MiniLogger.dp(" All streak segments:");
    for (final s in streakSegments) {
      MiniLogger.dp(" - ${s.first} to ${s.last} (${s.length} days)");
    }

    for (final segment in streakSegments) {
      for (final milestone in streakMilestones) {
        if (segment.length >= milestone) {
          final key = 'streak_$milestone';
          validKeys.add(key);
          MiniLogger.dp("✅ Valid streak: $key in segment ${segment.first} → ${segment.last}");
        }
      }
    }

    final toRemove = unlocked.keys.where((key) => !validKeys.contains(key)).toList();
    for (final key in toRemove) {
      unlocked.remove(key);
      MiniLogger.dp('🧹 Revoked achievement: $key');
    }
  }

  final List<int> streakMilestones = [
    1,
    3,
    5,
    7,
    10,
    14,
    21,
    30,
    60,
    90,
    180,
    365,
    730,
    1095,
    1825,
    3650,
  ];

  Future<void> checkAndHandleAchievements(
    Task task,
    TaskStats stats, [
    BuildContext? context,
  ]) async {
    Map<String,DateTime> unlocked = Map.from(stats.achievementUnlocks);
    final templates = Achievement.getAchievementTemplates();

    final sortedCompletions = List<DateTime>.from(stats.completions)..sort();

    List<List<DateTime>> streakSegments = [];
    List<DateTime> currentSegment = [];

    for (final date in sortedCompletions) {
      final d = DateUtils.dateOnly(date);
      if (!task.isActiveOn(d)) continue;

      if (currentSegment.isEmpty) {
        currentSegment.add(d);
      } else {
        DateTime last = currentSegment.last;
        DateTime expected = last;
        do {
          expected = expected.add(const Duration(days: 1));
        } while (!task.isActiveOn(expected));

        if (DateUtils.isSameDay(d, expected)) {
          currentSegment.add(d);
        } else {
          if (currentSegment.isNotEmpty) streakSegments.add(currentSegment);
          currentSegment = [d];
        }
      }
    }

    if (currentSegment.isNotEmpty) {
      streakSegments.add(currentSegment);
    }

    for (final segment in streakSegments) {
      final len = segment.length;
      for (final template in templates) {
        final key = template.id;
        if (len >= template.daysRequired && !unlocked.containsKey(key)) {
          unlocked[key] = DateTime.now();
          task.stats = stats.toJsonString();
          stats.achievementUnlocks = unlocked;
          currentTaskStats = stats;
          updateTaskFromAppWideStateChanges(task);
          final achieved = template.copyWith(
            isUnlocked: true,
            unlockedDate: unlocked[key],
          );
          MiniLogger.dp('Checking segment of length $len');
          if (len >= template.daysRequired && !unlocked.containsKey(key)) {
            MiniLogger.dp('🔓 Unlocking $key for $len days');
          }
          if (context != null) {
            await showAchievementDialog(context, achieved, stats.currentStreakLength);
          }
        }
      }
    }
  }
}
