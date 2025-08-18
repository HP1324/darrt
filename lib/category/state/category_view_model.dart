import 'package:darrt/app/extensions/extensions.dart';
import 'package:darrt/app/state/viewmodels/view_model.dart';
import 'package:darrt/category/models/task_category.dart';
import 'package:darrt/helpers/globals.dart' as g;
import 'package:darrt/helpers/messages.dart';
import 'package:darrt/helpers/mini_logger.dart';
import 'package:darrt/task/models/task.dart';
import 'package:flutter/material.dart';

class CategoryViewModel extends ViewModel<TaskCategory> {
  final ScrollController scrollController = ScrollController();

  List<TaskCategory> get categories => items;

  @override
  String putItem(
    TaskCategory item, {
    required bool edit,
    bool scrollToBottom = true,
  }) {
    final category = item;
    if (!edit && items.indexWhere((c) => c.name == category.name) != -1) {
      return Messages.mCategoryExists;
    }
    if (category.name.trim().isEmpty) return Messages.mCategoryEmpty;
    final message = super.putItem(category, edit: edit);

    if (scrollToBottom && !edit) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }

    return message;
  }

  @override
  String deleteItem(int id, {bool? deleteTasks}) {
    final tasksForCategory = g.taskVm.tasks.forCategoryById(id);
    for (final task in tasksForCategory) {
      task.categories.removeWhere((cat) => cat.id == id);
      MiniLogger.dp('task categories length:  ${task.categories.length}');
      if (task.categories.isEmpty) {
        MiniLogger.dp('task categories empty');
        task.categories.add(g.catVm.categories.first);
      }
      g.taskVm.updateTaskFromAppWideStateChanges(task, notify: true);
    }
    if (deleteTasks!) g.taskVm.deleteTasksForCategory(tasksForCategory, id);
    return super.deleteItem(id);
  }

  @override
  int getItemId(TaskCategory item) => item.id;

  @override
  String getCreateSuccessMessage() => Messages.mCategoryAdded;

  @override
  String getUpdateSuccessMessage() => Messages.mCategoryEdited;

  @override
  String getDeleteSuccessMessage(int length) => length == 1
      ? '1 ${Messages.mCategoryDeleted}'
      : '$length ${Messages.mCategoriesDeleted}';

  @override
  void setItemId(TaskCategory item, int id) {
    item.id = id;
  }

  @override
  void putManyForRestore(
    List<TaskCategory> restoredItems, {
    List<Task>? tasks,
  }) {
    box.putMany(restoredItems);
    reassignTaskCategories(restoredItems, tasks: tasks!);
    initializeItems();
    notifyListeners();
  }

  void reassignTaskCategories(
    List<TaskCategory> restoredCategories, {
    required List<Task> tasks,
  }) {
    final categoryByUuid = {
      for (final cat in restoredCategories) cat.uuid: cat,
    };

    for (final task in tasks) {
      // Optional: depends on your restore design
      final List<String> categoryUuids = task.categoryUuids;

      task.categories.clear();

      for (final uuid in categoryUuids) {
        final category = categoryByUuid[uuid];
        if (category != null) {
          task.categories.add(category);
        } else {
          MiniLogger.dp(
            'Category with UUID $uuid not found for task ${task.title}',
          );
        }
      }
    }
  }

  @override
  String getItemUuid(TaskCategory item) => item.uuid;
}
