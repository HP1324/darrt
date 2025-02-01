import 'dart:convert';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:minimaltodo/helpers/mini_consts.dart';
import 'package:minimaltodo/data_models/task.dart';
import 'package:minimaltodo/helpers/mini_utils.dart';
import 'package:minimaltodo/helpers/mini_logger.dart';

class NotificationService {
  static final _notif = AwesomeNotifications();

  static Future<void> initNotifications() async {
    try {
      final box = GetStorage();
      bool permissionGranted = await _notif.isNotificationAllowed();

      // Handle first-time permission request
      if (!permissionGranted && (box.read(mFirstTimeNotifPermission) ?? true)) {
        // Request permission but don't block app initialization
        permissionGranted = await _notif.requestPermissionToSendNotifications();
        await box.write(mFirstTimeNotifPermission, false);
        await box.write(mNotificationsEnabled, permissionGranted);
        MiniLogger.debug('First time permission request: $permissionGranted');
      }

      // Initialize channels only if permission is granted
      if (permissionGranted) {
        await initializeNotificationChannels();
        MiniLogger.debug('Notification service initialized successfully');
      } else {
        // Store the permission state but allow app to continue
        await box.write(mNotificationsEnabled, false);
        MiniLogger.debug('Notifications disabled - app continuing without notification support');
      }
    } catch (e) {
      // Log error but don't block app initialization
      MiniLogger.error('Failed to initialize notification service: ${e.toString()}');
      await GetStorage().write(mNotificationsEnabled, false);
    }
  }

  static Future<bool> isNotificationsEnabled() async {
    try {
      final box = GetStorage();
      return box.read(mNotificationsEnabled) ?? false;
    } catch (e) {
      MiniLogger.error('Error checking notification status: ${e.toString()}');
      return false;
    }
  }

  static Future<void> initializeNotificationChannels() async {
    try {
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
      MiniLogger.debug('Channels initialized: $isInitialized');

    } catch (e) {
      MiniLogger.error('Failed to initialize notification channels: ${e.toString()}');
      rethrow;
    }
  }

  static Future<void> createTaskNotification(Task task) async {
    // MiniLogger.debug('${task.id}');
    if (task.notifyTime!.isBefore(DateTime.now())) {
      return;
    }
    if (!await isNotificationsEnabled()) {
      MiniLogger.debug('Skipping notification creation - notifications are disabled');
      return;
    }
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
        schedule:  NotificationCalendar.fromDate(
          date: task.notifyTime!,
          allowWhileIdle: true,
          preciseAlarm: true,
        ),
        actionButtons: [
          NotificationActionButton(key: 'Finished', label: 'Finished', actionType: ActionType.SilentBackgroundAction
          ),
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
}
