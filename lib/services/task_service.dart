import 'package:flutter/material.dart';
import 'package:minimaltodo/data_models/category_model.dart';
import 'package:minimaltodo/data_models/task.dart';
import 'package:minimaltodo/global_utils.dart';
import 'package:minimaltodo/services/database_service.dart';
import 'package:sqflite/sqflite.dart';

class TaskService {
  static Future<List<Task>> getTasks() async {
    final database = await DatabaseService.openDb();
    final List<Map<String, dynamic>> taskMaps = await database.query('tasks');
    return List.generate(taskMaps.length, (index) {
      return Task.fromJson(taskMaps[index]);
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
    final database = await DatabaseService.openDb();
    final data = task.toJson();
    debugPrint('Task adding to database ->-> $data');
    final id = await database.insert('tasks', data, conflictAlgorithm: ConflictAlgorithm.replace);
    return id;
  }

  static Future<int> toggleDone(int id, bool updatedStatus, DateTime? finishedAt) async {
    final database = await DatabaseService.openDb();
    int isDone = updatedStatus ? 1 : 0;

    var changes = 0;
    try {
      changes = await database.update(
          'tasks', {'isDone': isDone, 'finishedAt': finishedAt?.toIso8601String()},
          where: 'id = ?', whereArgs: [id]);
      logger.d('Successfully updated task status: current status: $isDone');
    } catch (exception, stacktrace) {
      logger.e(
          'Something went wrong when updating task status: ${exception.toString()}, Error type: ${exception.runtimeType}');
      logger.t('This is stacktrace\n: ${stacktrace.toString()}');
    }
    return changes;
  }

  static Future<int> editTask({required Map<String, dynamic> newTask}) async {
    final database = await DatabaseService.openDb();
    final result =
        await database.update('tasks', newTask, where: 'id = ?', whereArgs: [newTask['id']]);
    return result;
  }

  static Future<List<bool>> editTaskListAfterEdit(List<Task> tasks, CategoryModel list) async {
    final database = await DatabaseService.openDb();
    List<bool> results= [];
    try {
      await database.transaction((txn) async {
        for (var task in tasks) {
          final listMap = {'list_name' : list.name,
            'list_icon_code' : list.iconCode,
            'list_color' : list.color };
          final changes = await txn.update(
              'tasks', listMap, where: 'id = ? AND list_id = ?',
              whereArgs: [task.id, list.id]);
          changes > 0 ? results.add(true) : results.add(false);
        }
      });
    }catch(e){
      logger.e('An Exception or Error occurred while editing task list colors in database: ${e.toString()}');
    }
    return results;
  }

  static Future<int> deleteTask(int id) async {
    final database = await DatabaseService.openDb();
    int rowsAffected = 0;
    try {
      rowsAffected = await database.delete('tasks', where: 'id = ?', whereArgs: [id]);
    } on Exception catch (exception) {
      debugPrint('Something went wrong when deleting the task: $exception');
    }
    return rowsAffected;
  }

  static Future<int> toggleNotifPrefs(int id, bool newValue, [Batch? batch]) async {
    final db = await DatabaseService.openDb();
    int isNotifyEnabled = newValue ? 1 : 0;
    int changes = 0;
    try {
      changes = await db.update('tasks', {'isNotifyEnabled': isNotifyEnabled},
          where: 'id = ?', whereArgs: [id]);
      return changes;
    } catch (e, stacktrace) {
      logger.e('Failed to update notification status: ${e.toString()}');
      logger.t('This is stacktrace: $stacktrace');
    }
    return changes;
  }

  static Future<List<Task>> filterTasks(int filterFlag) async {
    final db = await DatabaseService.openDb();
    var taskMaps = await db.query('tasks', where: 'isDone = ?', whereArgs: [filterFlag]);
    return List.generate(taskMaps.length, (index) {
      return Task.fromJson(taskMaps[index]);
    });
  }
}
