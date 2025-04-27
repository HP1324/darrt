import 'dart:isolate';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:minimaltodo/helpers/mini_logger.dart';
import 'package:minimaltodo/helpers/object_box.dart';
import 'package:minimaltodo/helpers/utils.dart';
import 'package:minimaltodo/main.dart';
import 'package:minimaltodo/task/logic/task_view_model.dart';
import 'package:minimaltodo/task/task.dart';
import 'package:minimaltodo/task/ui/add_task_page.dart';

@pragma("vm:entry-point")
Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {
  try {
    Task task = TaskUtilities.fromNotificationPayload(receivedAction.payload ?? {});
    debugPrint('Isolate in notification action: ${Isolate.current.debugName}');
    final appState = SchedulerBinding.instance.lifecycleState;
    final widgetAppState = WidgetsBinding.instance.lifecycleState;
    debugPrint('App state right now: $appState');
    debugPrint('Widgets app state right now: $widgetAppState');
    if (receivedAction.buttonKeyPressed == 'FINISHED') {
      if (appState == AppLifecycleState.resumed || appState == AppLifecycleState.paused) {
        getIt<TaskViewModel>().toggleStatus(task, true, DateTime.now());
      }
    } else {
      MinimalTodo.navigatorKey.currentState
          ?.push(MaterialPageRoute(builder: (_) => AddTaskPage(edit: true, task: task)));
    }
  } catch (e, t) {
    MiniLogger.e(
        'Error was thrown by onActionReceivedMethod: ${e.toString()}\nStacktrace: ${t.toString()}\n Error type: ${e.runtimeType}');
  }
}
