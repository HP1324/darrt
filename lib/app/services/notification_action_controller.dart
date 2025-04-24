import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:minimaltodo/main.dart';
import 'package:minimaltodo/task/task.dart';
import 'package:minimaltodo/task/ui/add_task_page.dart';

typedef FinishedActionCallback = Future<int> Function(Task, bool, DateTime);

@pragma("vm:entry-point")
class NotificationActionController {
  static FinishedActionCallback? finishedAction;
  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {
    //Get Task object from notification payload
    Task taskObject = TaskUtilities.fromNotificationPayload(receivedAction.payload ?? {});

    MinimalTodo.navigatorKey.currentState
        ?.push(MaterialPageRoute(builder: (_) => AddTaskPage(edit: true, task: taskObject)));
  }
}
