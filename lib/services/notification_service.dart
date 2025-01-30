import 'dart:convert';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:minimaltodo/data_models/task.dart';
import 'package:minimaltodo/global_utils.dart';
import 'package:minimaltodo/logger/mini_logger.dart';

class NotificationService {
  static final _notif = AwesomeNotifications();

  /// Initializes the notification service and ensures proper setup
  static Future<void> initNotifications() async {
    try {
      final box = GetStorage();
      bool permissionGranted = await _notif.isNotificationAllowed();

      // Handle first-time permission request
      if (!permissionGranted && (box.read('first_time') ?? true)) {
        permissionGranted = await _notif.requestPermissionToSendNotifications();
        await box.write('first_time', false);
        MiniLogger.debug('First time permission request: $permissionGranted');
      }

      // Initialize channels if permission granted
      if (permissionGranted) {
        await initializeNotificationChannels();
        MiniLogger.debug('Notification service initialized successfully');
      } else {
        MiniLogger.debug('Notification permissions not granted');
      }
    } catch (e) {
      MiniLogger.error('Failed to initialize notification service: ${e.toString()}');
      rethrow;
    }
  }

  static Future<void> initializeNotificationChannels() async {
    try {
      final box = GetStorage();
      final bool shouldInitializeChannels = box.read('channels_init') == null || !box.read('channels_init');

      if (shouldInitializeChannels) {
        MiniLogger.debug('Initializing notification channels');

        final isInitialized = await _notif.initialize(
          null,
          [
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
          ],
        );

        await box.write('channels_init', isInitialized);
        MiniLogger.debug('Channels initialized: $isInitialized');
      }
    } catch (e) {
      MiniLogger.error('Failed to initialize notification channels: ${e.toString()}');
      rethrow;
    }
  }

  static Future<void> createTaskNotification(Task task) async {
    MiniLogger.debug('create notification started');
    Map<String, dynamic> taskJson = task.toJson();
    String taskPayload = jsonEncode(taskJson);
    MiniLogger.debug('is notification allowed ${await _notif.isNotificationAllowed()}');

    try {
      final isCreated = await _notif.createNotification(
        content: task.notifType!.toLowerCase() == 'notif'
            ? NotificationContent(
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
        )
            : NotificationContent(
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
          NotificationActionButton(
              key: 'Finished',
              label: 'Finished',
              actionType: ActionType.SilentBackgroundAction),
          NotificationActionButton(key: 'Skip', label: 'Skip'),
        ],
      );
      MiniLogger.debug('Notification created: $isCreated');
    } catch (e) {
      MiniLogger.error('Failed to create task notification: ${e.toString()}');
      rethrow;
    }
  }

  static Future<void> removeTaskNotification(Task task) async {
    try {
      if (task.isNotifyEnabled!) {
        await _notif.cancel(task.id!);
        MiniLogger.debug('Notification ${task.id} canceled');
      }
    } catch (e) {
      MiniLogger.error('Failed to remove task notification: ${e.toString()}');
      rethrow;
    }
  }

  static Future<bool> managePermission(BuildContext context) async {
    try {
      bool isAllowed = await _notif.isNotificationAllowed();
      List<NotificationPermission> lockedPermissions =
      await _notif.shouldShowRationaleToRequest(channelKey: 'task_notif');

      if (isAllowed) {
        await initializeNotificationChannels();
        return true;
      }

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
                      channelKey: 'task_notif',
                      permissions: lockedPermissions);
                  navigator.pop(isAllowed);
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
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
      ) ??
          false;

      return isAllowed;
    } catch (e) {
      MiniLogger.error('Failed to manage permissions: ${e.toString()}');
      rethrow;
    }
  }
}