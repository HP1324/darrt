import 'package:darrt/category/models/task_category.dart';
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
}

extension TaskExtension on Task{
  bool containsCategory(TaskCategory category){
    return categories.any((cat) => cat.uuid == category.uuid);
  }
}