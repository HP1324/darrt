import 'package:darrt/category/models/task_category.dart';
import 'package:darrt/helpers/utils.dart';
import 'package:darrt/note/models/folder.dart';
import 'package:darrt/note/models/note.dart';
import 'package:darrt/note/ui/notes_page.dart';
import 'package:darrt/task/models/task.dart';
import 'package:flutter/material.dart';

extension TaskListExtension on List<Task> {

    /// Returns tasks that contains [category], compares using [TaskCategory.uuid]
    List<Task> forCategory(TaskCategory category){
      return where((task) => task.categories.any((cat) => cat.uuid == category.uuid)).toList();
    }

    /// Returns tasks that contains [category], compares using [TaskCategory.id]
    List<Task> forCategoryById(int categoryId){
      return where((task) => task.categories.any((cat) => cat.id == categoryId)).toList();
    }

    List<Task> sortByTime() {
      final tasksWithTime = where((task) => task.startTime != null).toList();
      final tasksWithoutTime = where((task) => task.startTime == null).toList();

      // Sort tasks with time by their time
      tasksWithTime.sort((a, b) {
        final timeA = a.startTime!;
        final timeB = b.startTime!;
        return timeA.compareTo(timeB);
      });

      // Return tasks with time first, then tasks without time
      return [...tasksWithTime, ...tasksWithoutTime];
    }
}

extension TaskExtension on Task{
  bool containsCategory(TaskCategory category){
    return categories.any((cat) => cat.uuid == category.uuid);
  }
}

extension NoteListExtension on List<Note>{
  /// Returns notes that contains [folder], compares using [Folder.uuid]
  List<Note> forFolder(Folder folder){
    return where((note) => note.folders.any((f) => f.uuid == folder.uuid)).toList();
  }

  /// Returns notes that contains [folder], compares using [Folder.id]
  List<Note> forFolderById(int folderId){
    return where((note) => note.folders.any((f) => f.id == folderId)).toList();
  }

  Map<String, List<Note>> groupByDate(DateFilterType dateFilterType) {
    Map<String, List<Note>> groupedNotes = {};

    for (var note in this) {
      final dateTime = dateFilterType == DateFilterType.createdAt
          ? note.createdAt
          : note.updatedAt;

      if (dateTime == null) continue;

      final dateKey = formatDateNoJm(dateTime, 'EEE, dd MMM, yyyy');
      if (groupedNotes[dateKey] == null) {
        groupedNotes[dateKey] = [];
      }
      groupedNotes[dateKey]!.add(note);
    }

    // Sort the map by actual date (most recent first)
    var sortedEntries = groupedNotes.entries.toList()
      ..sort((a, b) {
        // Get the first note from each group to compare their actual dates
        final noteA = groupedNotes[a.key]!.first;
        final noteB = groupedNotes[b.key]!.first;

        final dateA = dateFilterType == DateFilterType.createdAt
            ? noteA.createdAt
            : noteA.updatedAt;
        final dateB = dateFilterType == DateFilterType.createdAt
            ? noteB.createdAt
            : noteB.updatedAt;

        // Compare actual DateTime objects (most recent first)
        return dateB?.compareTo(dateA!) as int;
      });

    return Map.fromEntries(sortedEntries);
  }
}

extension NoteExtension on Note{
  bool containsFolder(Folder folder){
    return folders.any((f) => f.uuid == folder.uuid);
  }
}


extension ContextExtension on BuildContext{
  ColorScheme get colorScheme => ColorScheme.of(this);
  TextTheme get textTheme => TextTheme.of(this);
}