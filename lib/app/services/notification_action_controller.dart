import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:minimaltodo/helpers/mini_logger.dart';
import 'package:minimaltodo/helpers/object_box.dart';
import 'package:minimaltodo/helpers/utils.dart';
import 'package:minimaltodo/main.dart';
import 'package:minimaltodo/task/logic/task_view_model.dart';
import 'package:minimaltodo/task/task.dart';
import 'package:minimaltodo/task/task_completion.dart';
import 'package:minimaltodo/task/ui/add_task_page.dart';

@pragma("vm:entry-point")
Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {
  try {
    Task task = TaskUtilities.fromNotificationPayload(receivedAction.payload ?? {});
    final appState = SchedulerBinding.instance.lifecycleState;
    debugPrint('App state right now: $appState');
    if (receivedAction.buttonKeyPressed == 'FINISHED') {
      if (appState == AppLifecycleState.resumed) {
            getIt<TaskViewModel>().toggleStatus(task, true, DateTime.now());
      } else {
        if (task.isRepeating) {
          final cbox = ObjectBox.store.box<TaskCompletion>();
          final now = DateTime.now();
          final completion = TaskCompletion(date: now, isDone: true);
          completion.task.target = task;
          cbox.put(completion);
        } else {
          task.isDone = true;
          ObjectBox.store.box<Task>().put(task);
        }
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
