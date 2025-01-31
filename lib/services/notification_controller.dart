import 'dart:convert';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:minimaltodo/data_models/task.dart';
import 'package:minimaltodo/main.dart';
import 'package:minimaltodo/views/pages/single_task_view.dart';

class NotificationActionController{

  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {
    final payload = receivedAction.payload ?? {};
    String taskJsonString = payload['task']!;
    Map<String, dynamic> taskJson = jsonDecode(taskJsonString);
    Task taskObject = Task.fromJson(taskJson);

    MinimalTodo.navigatorKey.currentState?.push(MaterialPageRoute(builder: (_) => TaskView(task: taskObject)));
  }

}