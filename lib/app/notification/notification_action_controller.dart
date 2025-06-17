import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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
    Task task = ObjectBox.taskBox.get(int.parse(receivedAction.payload!['id']!))!;

    switch (receivedAction.buttonKeyPressed) {
      case finishedActionKey:
        g.taskVm.toggleStatus(task, true, DateTime.now());
        break;
      case snoozeActionKey:
        final now = DateTime.now();
        final nextDuration = MiniBox.read(mSnoozeMinutes);
        final nextTime = TimeOfDay.fromDateTime(now.add(Duration(minutes: nextDuration)));
        final scheduleDate = now.add(Duration(minutes: nextDuration));
        AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: now.millisecondsSinceEpoch.remainder(1000000),
            title: 'Task due at ${formatTime(nextTime)}',
            body: task.title,
            actionType: ActionType.Default,
            channelKey: receivedAction.channelKey!,
            payload: receivedAction.payload,
            category: receivedAction.category,
            notificationLayout: NotificationLayout.Default,
          ),
          schedule: NotificationCalendar.fromDate(date: scheduleDate),
          actionButtons: [
            finishedActionButton,
            snoozeActionButton,
          ],
        );
        break;
      default:
        MiniTodo.navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (_) => AddTaskPage(edit: true, task: task)),
        );
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
