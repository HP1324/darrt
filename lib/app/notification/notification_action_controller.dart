import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:minimaltodo/helpers/globals.dart' as g;
import 'package:minimaltodo/helpers/mini_logger.dart';
import 'package:minimaltodo/helpers/object_box.dart';
import 'package:minimaltodo/helpers/utils.dart';
import 'package:minimaltodo/main.dart';
import 'package:minimaltodo/task/models/task.dart';
import 'package:minimaltodo/task/ui/add_task_page.dart';

@pragma("vm:entry-point")
Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {
  try {
    final appState = SchedulerBinding.instance.lifecycleState;
    if (appState == AppLifecycleState.detached) {
      await ObjectBox.init();
    }
    Task task = ObjectBox.store.box<Task>().get(int.parse(receivedAction.payload!['id']!))!;

    switch (receivedAction.buttonKeyPressed) {
      case 'FINISHED':
        g.taskVm.toggleStatus(task, true, DateTime.now());
        break;
      case 'SNOOZE':
        final now = DateTime.now();
        AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: now.millisecondsSinceEpoch.remainder(1000000),
            title: task.title,
            body: 'Task due at ${formatDateAndTime(now.add(Duration(minutes: 1)),'fHH:mm')}',
            channelKey: receivedAction.channelKey!,
            payload: receivedAction.payload
          ),
          schedule: NotificationCalendar.fromDate(date: now.add(Duration(minutes: 1))),
        );
        break;
      default:
        MiniTodo.navigatorKey.currentState
            ?.push(MaterialPageRoute(builder: (_) => AddTaskPage(edit: true, task: task)));
        break;
    }
  } catch (e, t) {
    MiniLogger.e(
        'Error was thrown by onActionReceivedMethod: ${e.toString()}\nStacktrace: ${t.toString()}\n Error type: ${e.runtimeType}');
  }
}
