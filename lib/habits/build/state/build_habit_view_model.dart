import 'package:darrt/app/services/object_box.dart';
import 'package:darrt/app/services/toast_service.dart';
import 'package:darrt/app/state/viewmodels/view_model.dart';
import 'package:darrt/habits/build/models/build_habit.dart';
import 'package:darrt/habits/build/models/build_habit_target.dart';
import 'package:darrt/habits/build/models/habit_completion.dart';
import 'package:darrt/habits/build/models/target_completion.dart';
import 'package:darrt/habits/habit_notification_service.dart';
import 'package:darrt/helpers/globals.dart' as g;
import 'package:darrt/helpers/messages.dart';
import 'package:darrt/helpers/mini_logger.dart';
import 'package:darrt/helpers/utils.dart';
import 'package:darrt/objectbox.g.dart';
import 'package:darrt/task/statistics/achievement_dialog.dart';
import 'package:darrt/task/statistics/achievements.dart';
import 'package:darrt/task/statistics/task_stats.dart';
import 'package:flutter/material.dart';

class BuildHabitViewModel extends ViewModel<BuildHabit> {
  final _completionBox = ObjectBox().habitCompletionBox;

  @override
  void initializeItems() {
    super.initializeItems();

    habitCompletions.clear();
    for (var completion in _completionBox.getAll()) {
      int id = completion.habit.targetId;
      int date = completion.date.millisecondsSinceEpoch;
      habitCompletions.putIfAbsent(id, () => {}).add(date);
    }
  }

  final Map<int, Set<int>> habitCompletions = {};

  List<BuildHabit> get habits => items;

  List<BuildHabit> get activeHabits =>
      habits.where((habit) => habit.isActiveOn(g.habitCalMan.selectedDate)).toList();
  @override
  String putItem(BuildHabit item, {required bool edit}) {
    final habit = item;
    final name = habit.name.trim();

    if (name.isEmpty) return Messages.mHabitEmpty;
    habit.name = name;

    final message = super.putItem(habit, edit: edit);

    HabitNotificationService.removeAllHabitNotifications(habit).then((_) {
      HabitNotificationService.createHabitNotifications(habit);
    });

    return message;
  }

  void toggleStatus(BuildHabit habit, bool value, DateTime d, [BuildContext? context]) async {
    final dateOnly = DateUtils.dateOnly(d);
    //Can't mark finished if it's tomorrow or later
    if (!dateOnly.isAfter(DateUtils.dateOnly(DateTime.now()))) {
      final date = dateOnly.millisecondsSinceEpoch;
      if (value) {
        final completion = HabitCompletion(date: DateUtils.dateOnly(d), isDone: value);
        completion.habit.target = habit;
        completion.habitUuid = completion.habit.target!.uuid;
        // here we need to merge completion uuid with its task's uuid, because, only giving date as uuid causes problem, that problem is that more than one completions can have same date, hence same uuid, so they will be considered duplicate in backup and restore, while in reality they are not duplicate.
        completion.uuid = '${completion.uuid}${completion.habitUuid}';
        MiniLogger.dp('Completion uuid: ${completion.uuid!}');
        MiniLogger.dp('Completion task uuid: ${completion.habitUuid!}');
        _completionBox.put(completion);
        habitCompletions.putIfAbsent(habit.id, () => {}).add(date);
        performHabitStatsLogicAfterHabitFinish(habit, dateOnly, context);
        // g.audioController.playSoundOnly('assets/sounds/bell_sound.mp3');
      } else {
        final query = _completionBox
            .query(HabitCompletion_.habit.equals(habit.id).and(HabitCompletion_.date.equals(date)))
            .build();
        final removed = query.remove();
        query.close();
        MiniLogger.d('removed $removed completions for task ${habit.id}');
        habitCompletions[habit.id]?.remove(date);
        performHabitStatsLogicAfterHabitUnfinish(habit, dateOnly);
      }
    }

    notifyListeners();
  }

  BuildHabitStats? currentHabitStats = BuildHabitStats();

  void initHabitStats(BuildHabit habit) {
    currentHabitStats = BuildHabitStats.fromJsonString(habit.stats);
  }

  void updateHabitFromAppWideStateChanges(BuildHabit habit) {
    final id = box.put(habit);
    int index = getIndexOf(habit);
    if (index != -1) {
      habits[index] = habit;
    }
  }

  void performHabitStatsLogicAfterHabitFinish(
    BuildHabit habit,
    DateTime dateOnly, [
    BuildContext? context,
  ]) {
    MiniLogger.dp('finish stats function called');
    var stats = BuildHabitStats.fromJsonString(habit.stats);
    final List<DateTime> updatedCompletions = List<DateTime>.from(stats.completions);
    final today = DateTime.now().dateOnly;
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

      for (int i = 0; i <= 5000; i++) {
        // Max look-back range (e.g., 1 year or whatever)
        final date = today.subtract(Duration(days: i));

        if (!habit.isActiveOn(date)) continue; // skip if task wasn't supposed to run

        if (updatedCompletions.any((d) => isSameDay(d, date))) {
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
    checkAndHandleAchievements(habit, stats, context);
    habit.stats = stats.toJsonString();
    currentHabitStats = stats.copyWith();
    updateHabitFromAppWideStateChanges(habit);
  }

  void performHabitStatsLogicAfterHabitUnfinish(BuildHabit habit, DateTime dateOnly) {
    final stats = BuildHabitStats.fromJsonString(habit.stats);
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

        if (!habit.isActiveOn(date)) continue; // skip if task wasn't supposed to run

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
    removeInvalidAchievements(habit, stats);
    MiniLogger.dp('Current streak length: ${stats.currentStreakLength}');
    MiniLogger.dp('Current streak start: ${stats.currentStreakStart}');
    habit.stats = stats.toJsonString();
    currentHabitStats = stats.copyWith();
    updateHabitFromAppWideStateChanges(habit);
  }

  void removeInvalidAchievements(BuildHabit habit, BuildHabitStats stats) {
    MiniLogger.dp('remove invalid achievements called');
    final completions = List<DateTime>.from(stats.completions)..sort();
    final unlocked = stats.achievementUnlocks;
    final validKeys = <String>{};

    List<List<DateTime>> streakSegments = [];
    List<DateTime> currentSegment = [];

    for (final date in completions) {
      final d = DateUtils.dateOnly(date);
      if (!habit.isActiveOn(d)) continue;

      if (currentSegment.isEmpty) {
        currentSegment.add(d);
      } else {
        DateTime last = currentSegment.last;
        DateTime expected = last;
        do {
          expected = expected.add(const Duration(days: 1));
        } while (!habit.isActiveOn(expected));

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
    BuildHabit habit,
    BuildHabitStats stats, [
    BuildContext? context,
  ]) async {
    Map<String, DateTime> unlocked = Map.from(stats.achievementUnlocks);
    final templates = Achievement.getAchievementTemplates();

    final sortedCompletions = List<DateTime>.from(stats.completions)..sort();

    List<List<DateTime>> streakSegments = [];
    List<DateTime> currentSegment = [];

    for (final date in sortedCompletions) {
      final d = DateUtils.dateOnly(date);
      if (!habit.isActiveOn(d)) continue;

      if (currentSegment.isEmpty) {
        currentSegment.add(d);
      } else {
        DateTime last = currentSegment.last;
        DateTime expected = last;
        do {
          expected = expected.add(const Duration(days: 1));
        } while (!habit.isActiveOn(expected));

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
          habit.stats = stats.toJsonString();
          stats.achievementUnlocks = unlocked;
          currentHabitStats = stats;
          updateHabitFromAppWideStateChanges(habit);
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

  int getIndexOf(BuildHabit habit) => habits.indexWhere((h) => h.id == habit.id);

  void modifyTarget(BuildHabit habit) {
    final index = getIndexOf(habit);
    if (index != -1) {
      final newTarget = BuildHabitTarget.fromJsonString(habit.completedTarget);
      habit.completedTarget = newTarget.toJsonString();
      habits[index] = habit;
      updateHabitFromAppWideStateChanges(habit);
      notifyListeners();
    }
  }

  List<TargetCompletion>? currentTargetCompletions;
  void incrementDailyTargetCompletion(BuildHabit habit, [BuildContext? context]) {
    final selectedDate = g.habitCalMan.selectedDate.dateOnly;
    if (selectedDate.isAfter(DateTime.now().dateOnly)) {
      showWarningToast(context!, "Can't record progress in future");
      return;
    }

    final completions = TargetCompletion.fromJsonStringList(habit.targetCompletions) ?? [];
    final completionIndex = completions.indexWhere((c) => c.date == selectedDate);
    TargetCompletion newCompletion;
    if (completionIndex != -1) {
      // Update existing completion
      final oldCompletion = completions[completionIndex];
      newCompletion = oldCompletion.copyWith(daily: oldCompletion.daily + 1);
      completions[completionIndex] = newCompletion;
    } else {
      newCompletion = TargetCompletion(date: selectedDate, daily: 1);
      completions.add(newCompletion);
    }

    // Don't forget to save the updated completions back to the habit
    habit.targetCompletions = TargetCompletion.toJsonStringList(completions);
    final habitTarget = BuildHabitTarget.fromJsonString(habit.target);
    if(newCompletion.daily == habitTarget.daily){
      toggleStatus(habit, true, selectedDate, context);
    }else{
      updateHabitFromAppWideStateChanges(habit);
      notifyListeners();
    }
  }

  void decrementDailyTargetCompletion(BuildHabit habit, [BuildContext? context]) {
    final selectedDate = g.habitCalMan.selectedDate.dateOnly;
    if (selectedDate.isAfter(DateTime.now().dateOnly)) {
      showWarningToast(context!, "Can't record progress in future");
      return;
    }

    final completions = TargetCompletion.fromJsonStringList(habit.targetCompletions) ?? [];
    final completionIndex = completions.indexWhere((c) => c.date == selectedDate);
    TargetCompletion newCompletion;
    if (completionIndex != -1) {
      // Update existing completion
      final oldCompletion = completions[completionIndex];
      newCompletion = oldCompletion.copyWith(daily: oldCompletion.daily - 1);
      completions[completionIndex] = newCompletion;
    } else {
      newCompletion = TargetCompletion(date: selectedDate, daily: 1);
      completions.add(newCompletion);
    }

    // Don't forget to save the updated completions back to the habit
    habit.targetCompletions = TargetCompletion.toJsonStringList(completions);
    final habitTarget = BuildHabitTarget.fromJsonString(habit.target);
    if(newCompletion.daily < habitTarget.daily){
      toggleStatus(habit, false, selectedDate, context);
    }else{
      updateHabitFromAppWideStateChanges(habit);
      notifyListeners();
    }
  }

  @override
  List<BuildHabit> convertJsonListToObjectList(List<Map<String, dynamic>> jsonList) {
    return jsonList.map(BuildHabit.fromJson).toList();
  }

  @override
  List<Map<String, dynamic>> convertObjectsListToJsonList(List<BuildHabit> objectList) {
    // TODO: implement convertObjectsListToJsonList
    throw UnimplementedError();
  }

  @override
  String getCreateSuccessMessage() => Messages.mHabitCreated;

  @override
  String getDeleteSuccessMessage(int length) {
    return length == 1 ? Messages.mHabitDeleted : Messages.mHabitsDeleted;
  }

  @override
  int getItemId(BuildHabit item) => item.id;

  @override
  String getItemUuid(BuildHabit item) => item.uuid;

  @override
  String getUpdateSuccessMessage() => Messages.mHabitEdited;

  @override
  void putManyForRestore(List<BuildHabit> restoredItems) {
    // TODO: implement putManyForRestore
  }

  @override
  void setItemId(BuildHabit item, int id) => item.id = id;
}
