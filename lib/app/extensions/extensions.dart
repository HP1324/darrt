import 'package:darrt/category/models/task_category.dart';
import 'package:darrt/note/models/folder.dart';
import 'package:darrt/note/models/note.dart';
import 'package:darrt/task/models/task.dart';

extension TaskListExtension on List<Task> {

    /// Returns tasks that contains [category], compares using [TaskCategory.uuid]
    List<Task> forCategory(TaskCategory category){
      return where((task) => task.categories.any((cat) => cat.uuid == category.uuid)).toList();
    }

    /// Returns tasks that contains [category], compares using [categoryId]
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
}