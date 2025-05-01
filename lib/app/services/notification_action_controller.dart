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
    final appState = SchedulerBinding.instance.lifecycleState;
    if (appState == AppLifecycleState.detached) {
      await ObjectBox.init();
      getIt.registerSingleton<TaskViewModel>(TaskViewModel());
    }
    Task task = ObjectBox.store.box<Task>().get(int.parse(receivedAction.payload!['id']!))!;
    if (receivedAction.buttonKeyPressed == 'FINISHED') {
      getIt<TaskViewModel>().toggleStatus(task, true, DateTime.now());
    } else {
      MinimalTodo.navigatorKey.currentState
          ?.push(MaterialPageRoute(builder: (_) => AddTaskPage(edit: true, task: task)));
    }
  } catch (e, t) {
    MiniLogger.e(
        'Error was thrown by onActionReceivedMethod: ${e.toString()}\nStacktrace: ${t.toString()}\n Error type: ${e.runtimeType}');
  }
}
