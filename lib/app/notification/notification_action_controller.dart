import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:minimaltodo/app/notification/notification_service.dart';
import 'package:minimaltodo/helpers/consts.dart';
import 'package:minimaltodo/helpers/globals.dart' as g;
import 'package:minimaltodo/helpers/mini_box.dart';
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
    Task? task;
    if (receivedAction.payload != null) {
      task = ObjectBox.taskBox.get(int.parse(receivedAction.payload!['id']!))!;
    }

    switch (receivedAction.buttonKeyPressed) {
      case finishedActionKey:
        g.taskVm.toggleStatus(task!, true, DateTime.now());
        break;
      case snoozeActionKey:
        final minutes = MiniBox.read(mSnoozeMinutes);
        await NotificationService.scheduleQuickReminder(receivedAction.body, minutes);
        break;
      case quickSnoozeActionKey:
        final minutes = MiniBox.read(mSnoozeMinutes);
        await NotificationService.scheduleQuickReminder(receivedAction.body, minutes);
      default:
        if (task != null) {
          MiniTodo.navigatorKey.currentState?.push(
            MaterialPageRoute(builder: (_) => AddTaskPage(edit: true, task: task)),
          );
        }
        break;
    }
  } catch (e, t) {
    MiniLogger.e(
      'Error was thrown by onActionReceivedMethod: ${e.toString()}\nStacktrace: ${t.toString()}\n Error type: ${e.runtimeType}',
    );
  }
}

const String finishedActionKey = 'FINISHED';
const String snoozeActionKey = 'SNOOZE';
const String finishedActionLabel = 'Finished';
const String snoozeActionLabel = 'Snooze';
const String quickSnoozeActionKey = 'QUICK_SNOOZE';
const String quickSnoozeActionLabel = 'Quick Snooze';

final finishedActionButton = NotificationActionButton(
  key: finishedActionKey,
  label: finishedActionLabel,
  actionType: ActionType.SilentAction,
);

final snoozeActionButton = NotificationActionButton(
  key: snoozeActionKey,
  label: snoozeActionLabel,
  actionType: ActionType.SilentAction,
);
