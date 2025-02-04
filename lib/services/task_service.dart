import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:minimaltodo/data_models/category_model.dart';
import 'package:minimaltodo/data_models/task.dart';
import 'package:minimaltodo/helpers/mini_logger.dart';
import 'package:minimaltodo/helpers/mini_utils.dart';
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
    List<Map<String, dynamic>> results = await database.query('tasks', where: 'id = ?', whereArgs: [id]);
    if (results.isNotEmpty) {
      return Task.fromJson(results.first);
    }
    return null;
  }

  static Future<int> addTask(Task task) async {
    final database = await DatabaseService.openDb();
    if(task.isRepeating!) {
      Map<String, dynamic> finishDates = {};
      var startDate = task.startDate;
      final endDate = task.endDate;
      final lastDate = endDate == null ? DateTime.now().add(Duration(days: 3650)) : endDate.add(Duration(days: 1));
      MiniLogger.debug('Start Date: $startDate, Last Date: $lastDate');

        while (startDate.isBefore(lastDate)) {
          final dateOnly = DateTime(startDate.year,startDate.month,startDate.day);
          finishDates[dateOnly.toIso8601String()] = false;
          startDate = startDate.add(Duration(days: 1,hours: 0,minutes: 0,seconds: 0,milliseconds: 0,microseconds: 0));
          MiniLogger.debug('Start date in loop: $startDate');
        }
        MiniLogger.debug('Task Finish Dates: ${task.finishDates}');
        task.finishDates = jsonEncode(finishDates);


    }
    MiniLogger.debug('Task finish dates before adding to database: ${task.finishDates}');
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
      changes = await database.update('tasks', {'isDone': isDone, 'finishedAt': finishedAt?.toIso8601String()}, where: 'id = ?', whereArgs: [id]);
      MiniLogger.debug('Successfully updated task status: current status: $isDone');
    } catch (exception, stacktrace) {
      MiniLogger.error('Something went wrong when updating task status: ${exception.toString()}, Error type: ${exception.runtimeType}');
      MiniLogger.trace('This is stacktrace\n: ${stacktrace.toString()}');
    }
    return changes;
  }

  static Future<int> editTask({required Map<String, dynamic> newTask}) async {
    final database = await DatabaseService.openDb();
    final result = await database.update('tasks', newTask, where: 'id = ?', whereArgs: [newTask['id']]);
    return result;
  }

  static Future<List<bool>> editTaskCategoryAfterEdit(List<Task> tasks, CategoryModel category) async {
    final database = await DatabaseService.openDb();
    List<bool> results = [];
    try {
      await database.transaction((txn) async {
        for (var task in tasks) {
          final categoryMap = {'categoryName': category.name, 'catIconCode': category.iconCode, 'categoryColor': category.color};
          final changes = await txn.update('tasks', categoryMap, where: 'id = ? AND categoryId = ?', whereArgs: [task.id, category.id]);
          changes > 0 ? results.add(true) : results.add(false);
        }
      });
    } catch (e) {
      logger.e('An Exception or Error occurred while editing task category color in database: ${e.toString()}');
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
      changes = await db.update('tasks', {'isNotifyEnabled': isNotifyEnabled}, where: 'id = ?', whereArgs: [id]);
      return changes;
    } catch (e, stacktrace) {
      MiniLogger.error('Failed to update notification status: ${e.toString()}');
      MiniLogger.trace(stacktrace.toString());
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
