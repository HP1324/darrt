import 'package:audioplayers/audioplayers.dart' show ReleaseMode;
import 'package:flutter/material.dart';
import 'package:minimaltodo/app/notification/notification_service.dart';
import 'package:minimaltodo/helpers/globals.dart' as g;
import 'package:minimaltodo/helpers/messages.dart';
import 'package:minimaltodo/app/services/mini_box.dart';
import 'package:minimaltodo/helpers/mini_logger.dart';
import 'package:minimaltodo/app/services/object_box.dart';
import 'package:minimaltodo/helpers/typedefs.dart';
import 'package:minimaltodo/objectbox.g.dart';
import 'package:minimaltodo/app/state/viewmodels/view_model.dart';
import 'package:minimaltodo/task/models/task.dart';
import 'package:minimaltodo/task/models/task_completion.dart';

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

  void toggleStatus(Task task, bool value, DateTime d) async {
    if (value) {
      g.soundController.playSoundOnly('assets/sounds/bell_sound.mp3');
    }
    if (task.isRepeating) {
      final date = DateUtils.dateOnly(d).millisecondsSinceEpoch;
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
      } else {
        final removed =
            _completionBox
                .query(TaskCompletion_.task.equals(task.id).and(TaskCompletion_.date.equals(date)))
                .build()
              ..remove()
              ..close();
        MiniLogger.d('removed $removed completions for task ${task.id}');
        repeatingTaskCompletions[task.id]?.remove(date);
      }
    } else {
      task.isDone = value;
      box.put(task);
      onetimeTaskCompletions[task.id] = value;
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

  // @override
  // void putManyForRestore(List<Task> restoredItems, {List<TaskCompletion>? completions}) {
  //   box.putMany(restoredItems);
  //   restoreCompletionRelations(tasks: restoredItems, completions: completions!);
  //   for (var task in restoredItems) {
  //     NotificationService.removeAllTaskNotifications(task).then((_) async {
  //       if (task.isRepeating) {
  //         await NotificationService.createRepeatingTaskNotifications(task);
  //       } else {
  //         await NotificationService.createTaskNotification(task);
  //       }
  //     });
  //   }
  //   _completionBox.putMany(completions);
  //   initializeItems();
  //   notifyListeners();
  // }

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
    final tasksWithTime = tasks.where((task) => task.time != null).toList();
    final tasksWithoutTime = tasks.where((task) => task.time == null).toList();

    // Sort tasks with time by their time
    tasksWithTime.sort((a, b) {
      final timeA = a.time!;
      final timeB = b.time!;
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
    final id = box.put(task);
    int taskIndex = tasks.indexWhere((i) => getItemId(i) == id);
    if (taskIndex != -1) {
      tasks[taskIndex] = task;
    }
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
    final id = box.put(task);
    int index = tasks.indexWhere((i) => getItemId(i) == id);
    if (index != -1) {
      tasks[index] = task;
    }
    // Step 4: Notify listeners to update UI
    notifyListeners();
  }

  void initTaskNotesState(Task task) {
    taskTimerNotes = Note.notesFromJsonString(task.notes);
  }
}
