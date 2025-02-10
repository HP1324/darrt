import 'package:minimaltodo/data_models/category_model.dart';
import 'package:minimaltodo/data_models/task.dart';
import 'package:minimaltodo/helpers/mini_logger.dart';
import 'package:minimaltodo/helpers/mini_utils.dart';
import 'package:minimaltodo/services/database_service.dart';
import 'package:sqflite/sqflite.dart';

class TaskService {
  static Future<List<Task>> getSingleTasks() async {
    final database = await DatabaseService.openDb();
    final List<Map<String, dynamic>> singleTaskMaps =
        await database.query('tasks', where: 'isRepeating = ?', whereArgs: [0]);
    return List.generate(singleTaskMaps.length, (index) {
      return Task.fromJson(singleTaskMaps[index]);
    });
  }

  static Future<List<Task>> getTasks() async {
    final database = await DatabaseService.openDb();
    final List<Map<String, dynamic>> singleTaskMaps = await database.query('tasks');
    return List.generate(singleTaskMaps.length, (index) {
      return Task.fromJson(singleTaskMaps[index]);
    });
  }

  static Future<List<Task>> getRecurringTasks() async {
    final database = await DatabaseService.openDb();
    final List<Map<String, dynamic>> recurringTaskMaps =
        await database.query('tasks', where: 'isRepeating = ?', whereArgs: [1]);
    return List.generate(recurringTaskMaps.length, (index) {
      return Task.fromJson(recurringTaskMaps[index]);
    });
  }



  static Future<Task?> getTaskById(int id) async {
    final database = await DatabaseService.openDb();
    List<Map<String, dynamic>> results =
        await database.query('tasks', where: 'id = ?', whereArgs: [id]);
    if (results.isNotEmpty) {
      return Task.fromJson(results.first);
    }
    return null;
  }

  static Future<int> addTask(Task task) async {
    try {
      final database = await DatabaseService.openDb();
      final data = task.toJson();
      final id = await database.insert('tasks', data, conflictAlgorithm: ConflictAlgorithm.replace);
      return id;
    } catch (e) {
      MiniLogger.error('Failed to add task to database: ${e.toString()}');
      return -1;
    }
  }

  static Future<int> toggleDone(int id, bool updatedStatus, DateTime? finishedAt) async {
    final database = await DatabaseService.openDb();
    int isDone = updatedStatus ? 1 : 0;

    var changes = 0;
    try {
      changes = await database.update(
          'tasks', {'isDone': isDone, 'finishedAt': finishedAt?.toIso8601String()},
          where: 'id = ?', whereArgs: [id]);
      MiniLogger.debug('Successfully updated task status: current status: $isDone');
    } catch (exception, stacktrace) {
      MiniLogger.error(
          'Something went wrong when updating task status: ${exception.toString()}, Error type: ${exception.runtimeType}');
      MiniLogger.trace('This is stacktrace\n: ${stacktrace.toString()}');
    }
    return changes;
  }

  static Future<int> editTask({required Map<String, dynamic> newTask}) async {
    try {
      final database = await DatabaseService.openDb();
      final result =
          await database.update('tasks', newTask, where: 'id = ?', whereArgs: [newTask['id']]);
      return result;
    } catch (e) {
      MiniLogger.error('Failed to edit task in database: ${e.toString()}');
      return -1;
    }
  }

  static Future<List<bool>> editTaskCategoryAfterEdit(
      List<Task> tasks, CategoryModel category) async {
    final database = await DatabaseService.openDb();
    List<bool> results = [];
    try {
      await database.transaction((txn) async {
        for (var task in tasks) {
          final categoryMap = {
            'categoryName': category.name,
            'catIconCode': category.iconCode,
            'categoryColor': category.color
          };
          final changes = await txn.update('tasks', categoryMap,
              where: 'id = ? AND categoryId = ?', whereArgs: [task.id, category.id]);
          changes > 0 ? results.add(true) : results.add(false);
        }
      });
    } catch (e) {
      logger.e(
          'An Exception or Error occurred while editing task category color in database: ${e.toString()}');
    }
    return results;
  }

  static Future<int> deleteTask(int id) async {
    try {
      int rowsAffected = 0;
      final database = await DatabaseService.openDb();
      rowsAffected = await database.delete('tasks', where: 'id = ?', whereArgs: [id]);
      return rowsAffected;
    } catch (e) {
      MiniLogger.error('Exception occurred while deleting task: ${e.toString()}');
      return 0;
    }
  }
}
