import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:darrt/app/notification/notification_service.dart';
import 'package:darrt/app/ui/settings_page/settings_page.dart';
import 'package:darrt/helpers/consts.dart';
import 'package:darrt/helpers/globals.dart' as g;
import 'package:darrt/app/services/mini_box.dart';
import 'package:darrt/helpers/mini_logger.dart';
import 'package:darrt/app/services/object_box.dart';
import 'package:darrt/main.dart';
import 'package:darrt/task/models/task.dart';
import 'package:darrt/task/ui/add_task_page.dart';
import 'package:darrt/helpers/utils.dart';

@pragma("vm:entry-point")
Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {
  try {
    final appState = SchedulerBinding.instance.lifecycleState;
    final appTerminated = appState == AppLifecycleState.detached;
    if (appTerminated) {
      await ObjectBox().init();
    }
    Task? task;
    if (receivedAction.payload != null) {
      task = ObjectBox().taskBox.get(int.parse(receivedAction.payload!['id']!))!;
    }

    switch (receivedAction.buttonKeyPressed) {
      case finishedActionKey:
        g.taskVm.toggleStatus(task!, true, DateTime.now());
        break;
      case snoozeActionKey:
        final now = DateTime.now();
        final minutes = MiniBox().read(mSnoozeMinutes);
        final nextTime = TimeOfDay.fromDateTime(now.add(Duration(minutes: minutes)));
        AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: now.millisecondsSinceEpoch.remainder(1000000),
            title: 'Task due at ${formatTime(nextTime)}',
            body: task!.title,
            actionType: ActionType.Default,
            channelKey: receivedAction.channelKey!,
            payload: receivedAction.payload,
            category: receivedAction.category,
            notificationLayout: NotificationLayout.Default,
          ),
          schedule: NotificationInterval(
            interval: Duration(minutes: minutes),
            repeats: false,
            allowWhileIdle: true,
          ),
          actionButtons: [
            finishedActionButton,
            snoozeActionButton,
          ],
        );
        break;
      case quickSnoozeActionKey:
        final minutes = MiniBox().read(mSnoozeMinutes);
        await NotificationService.scheduleQuickReminder(receivedAction.body ?? '', minutes);
        break;
      case openAppKey:
        Darrt.navigatorKey.currentState?.push(MaterialPageRoute(builder: (_) => const SettingsPage()));
        break;
      case timerPlayPauseKey:
        if(appTerminated) return;
        if(g.timerController.isRunning){
          g.timerController.pauseTimer();
        }else{
          g.timerController.startTimer();
        }
        break;
      case timerStopKey:
        if(appTerminated) return;
        g.timerController.stopTimer();
        break;
      default:
        if (task != null) {
          Darrt.navigatorKey.currentState?.push(
            MaterialPageRoute(builder: (_) => AddTaskPage(edit: true, task: task)),
          );
        }
        break;
    }
  } catch (e, t) {
    MiniLogger.dp(
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
const String signInAndBackupActionKey = 'SIGN_IN_AND_BACKUP';
const String openAppKey = 'OPEN_APP';

const String timerPlayPauseKey = 'timer_play_pause';
const String timerStopKey = 'timer_stop';
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


final quickSnoozeActionButton = NotificationActionButton(
key: quickSnoozeActionKey,
label: snoozeActionLabel,
actionType: ActionType.SilentAction,
);