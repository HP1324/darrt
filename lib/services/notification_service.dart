import 'dart:convert';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:minimaltodo/data_models/task.dart';
import 'package:minimaltodo/global_utils.dart';
import 'package:minimaltodo/main.dart';
import 'package:minimaltodo/theme/app_theme.dart';
import 'package:minimaltodo/views/pages/single_task_view.dart';

class NotificationService {
  static final _notif = AwesomeNotifications();

  static Future<void> initNotifications() async {
    final allowed = await _notif.requestPermissionToSendNotifications();
    if(allowed) {
      _notif.initialize(null, [
        NotificationChannel(
          channelKey: 'task_notif',
          channelName: 'task_notifications',
          channelDescription: 'Channel used to notify users about their tasks with simple notification',
          importance: NotificationImportance.Max,
          playSound: true,
          defaultRingtoneType: DefaultRingtoneType.Notification,
          enableLights: true,
          channelShowBadge: true,
          criticalAlerts: true,
        ),
        NotificationChannel(
          channelKey: 'task_alarm',
          channelName: 'task_alarms',
          channelDescription: 'Channel used to notify users about their tasks with alarm',
          importance: NotificationImportance.Max,
          playSound: true,
          defaultRingtoneType: DefaultRingtoneType.Alarm,
          enableLights: true,
          channelShowBadge: true,
          criticalAlerts: true,
        ),
      ]);

      await _notif.setListeners(onActionReceivedMethod: onActionReceivedMethod);
    }else{
      showToast(title: 'Notification permission is required to send notifications',bgColor: Colors.red,fgColor: Colors.white, alignment: Alignment.center);
    }
  }

  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {
    debugPrint('onActionReceivedMethod() started.....');
    final payload = receivedAction.payload ?? {};
    String taskJsonString = payload['task']!;
    Map<String, dynamic> taskJson = jsonDecode(taskJsonString);
    Task taskObject = Task.fromJson(taskJson);
    taskObject.printTask();
    SimpleTodo.navigatorKey.currentState
        ?.push(MaterialPageRoute(builder: (_) => TaskView(task: taskObject)));
    debugPrint('onActionReceivedMethod() ended.....');
  }

  static Future<void> createTaskNotification(Task task) async {
    logger.i('createTaskNotification() Started...');

      Map<String, dynamic> taskJson = task.toJson();
      String taskPayload = jsonEncode(taskJson);
      logger.d('is notification allowed ${await _notif.isNotificationAllowed()}');
      await _notif.createNotification(
        content: task.notifType!.toLowerCase() == 'notif' ?
        NotificationContent(
          id: task.id!,
          channelKey: 'task_notif',
          title: 'Task Due at ${formatTime(task.dueDate!)}',
          body: task.title,
          actionType: ActionType.Default,
          payload: {
            'task': taskPayload,
          },
          notificationLayout: NotificationLayout.Default,
          category: NotificationCategory.Reminder,
          wakeUpScreen: true,
          criticalAlert: true,
        ) : NotificationContent(
          id: task.id!,
          channelKey: 'task_alarm',
          title: 'Task Due at ${formatTime(task.dueDate!)}',
          body: task.title,
          actionType: ActionType.Default,
          payload: {
            'task': taskPayload,
          },
          notificationLayout: NotificationLayout.Default,
          category: NotificationCategory.Alarm,
          wakeUpScreen: true,
          criticalAlert: true,
        ),
        schedule: NotificationCalendar.fromDate(
          date: task.notifyTime!,
          allowWhileIdle: true,
          preciseAlarm: true,
        ),
        actionButtons: [
          NotificationActionButton(key: 'Finished', label: 'Finished', actionType: ActionType.SilentBackgroundAction),
          NotificationActionButton(key: 'Skip', label: 'Skip'),
        ],
      ).then((isNotifCreated) {
        logger.d('isNotifCreated: $isNotifCreated');
        if (isNotifCreated) {
          logger.d('Notification created for task ${task.id} at ${task.dueDate}');
        } else {
          logger.e('Failed to create notification for ${task.id} at ${task.dueDate}');
        }
        logger.d('Task ID: ${task.id}');
        logger.d('Task due date: ${task.dueDate}');
        _notif.isNotificationAllowed().then((allowed) {
          logger.d('Notification permission allowed: $allowed');
        });
      }).onError((e, st) {
        logger.e('Error setting notification: ${e.toString()}');
        logger.t('Stacktrace: ${st.toString()}');
      });

  }

  static Future<void> removeTaskNotification(Task task) async {
    if (task.isNotifyEnabled!) {
      await _notif.cancel(task.id!);
      logger.d('Notification ${task.id} canceled');
    }
  }

  static Future<bool> managePermission(BuildContext context) async {
    bool isAllowed = await _notif.isNotificationAllowed();
    List<NotificationPermission> lockedPermissions =
        await _notif.shouldShowRationaleToRequest(channelKey: 'task_notif');

    if (isAllowed) {
      return true;
    } else {
      isAllowed = await showAdaptiveDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
            title: const Text('Permission required'),
            content: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.yellow.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                  'Please allow the application to send notifications, otherwise we won\'t be able to remind you about your important tasks.'),
            ),
            actions: [
              InkWell(
                onTap: () async {
                  final navigator = Navigator.of(context);
                  isAllowed = await _notif.requestPermissionToSendNotifications(
                      channelKey: 'task_notif', permissions: lockedPermissions);
                  navigator.pop();
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  child: const Row(
                    children: [
                      Text('Go to notification settings'),
                      Icon(CupertinoIcons.chevron_right),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      );
    }

    return isAllowed;
  }
}
