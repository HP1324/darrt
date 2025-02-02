import 'dart:convert';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:minimaltodo/helpers/mini_consts.dart';
import 'package:minimaltodo/data_models/task.dart';
import 'package:minimaltodo/helpers/mini_utils.dart';
import 'package:minimaltodo/helpers/mini_logger.dart';
import 'package:intl/intl.dart';



class NotificationService {
  static final _notif = AwesomeNotifications();

  static Future<void> initNotifications() async {
    try {
      final box = GetStorage();
      bool permissionGranted = await _notif.isNotificationAllowed();

      if (!permissionGranted && (box.read(mFirstTimeNotifPermission) ?? true)) {
        permissionGranted = await _notif.requestPermissionToSendNotifications();
        await box.write(mFirstTimeNotifPermission, false);
        await box.write(mNotificationsEnabled, permissionGranted);
        MiniLogger.debug('First time permission request: $permissionGranted');
      }

      if (permissionGranted) {
        await initializeNotificationChannels();
        MiniLogger.debug('Notification service initialized successfully');
      } else {
        await box.write(mNotificationsEnabled, false);
        MiniLogger.debug('Notifications disabled - continuing without notification support');
      }
    } catch (e) {
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
    if (task.notifyTime == null || task.notifyTime!.isBefore(DateTime.now())) {
      return;
    }
    if (!await isNotificationsEnabled()) {
      MiniLogger.debug('Skipping notification creation - notifications are disabled');
      return;
    }
    MiniLogger.debug('Creating one-off task notification');
    Map<String, dynamic> taskJson = task.toJson();
    String taskPayload = jsonEncode(taskJson);
    MiniLogger.debug('Is notification allowed? ${await _notif.isNotificationAllowed()}');

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
            actionType: ActionType.SilentBackgroundAction,
          ),
          NotificationActionButton(key: 'Skip', label: 'Skip'),
        ],
      );
      MiniLogger.debug('One-off notification created: $isCreated');
    } catch (e) {
      MiniLogger.error('Failed to create task notification: ${e.toString()}');
      rethrow;
    }
  }

  static Future<void> createRepeatingTaskNotifications(Task task) async {
    if (task.notifyTime == null || task.notifyTime!.isBefore(DateTime.now())) {
      return;
    }
    if (!await isNotificationsEnabled()) {
      MiniLogger.debug('Notifications disabled; skipping repeating notifications.');
      return;
    }
    // Parse reminderTimes from JSON; if none provided, use the default notifyTime
    List<String> reminderTimes = [];
    if (task.reminderTimes != null) {
      try {
        reminderTimes = List<String>.from(jsonDecode(task.reminderTimes!));
      } catch (e) {
        logger.e('Error decoding reminderTimes: $e');
      }
    }
    // If no reminders are set, schedule one notification at notifyTime.
    if (reminderTimes.isEmpty) {
      reminderTimes.add(formatTime(task.notifyTime!));
    }
    // Schedule a notification for each reminder
    for (int i = 0; i < reminderTimes.length; i++) {
      // For demonstration, we simply schedule each notification at task.notifyTime
      // In a real scenario, you might parse the reminder time offset and compute an exact time.
      final scheduledTime = task.notifyTime!.subtract(Duration(minutes: i * 5));
      try {
        final isCreated = await _notif.createNotification(
          content: task.notifType!.toLowerCase() == 'notif'
              ? NotificationContent(
            id: (task.id! * 10) + i, // generate unique id per reminder
            channelKey: 'task_notif',
            title: 'Repeating Task Reminder at ${formatTime(task.dueDate!)}',
            body: task.title,
            actionType: ActionType.Default,
            payload: {'task': jsonEncode(task.toJson())},
            notificationLayout: NotificationLayout.Default,
            category: NotificationCategory.Reminder,
            wakeUpScreen: true,
            criticalAlert: true,
          )
              : NotificationContent(
            id: (task.id! * 10) + i,
            channelKey: 'task_alarm',
            title: 'Repeating Task Alarm at ${formatTime(task.dueDate!)}',
            body: task.title,
            actionType: ActionType.Default,
            payload: {'task': jsonEncode(task.toJson())},
            notificationLayout: NotificationLayout.Default,
            category: NotificationCategory.Alarm,
            wakeUpScreen: true,
            criticalAlert: true,
          ),
          schedule: NotificationCalendar.fromDate(
            date: scheduledTime,
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
        MiniLogger.debug('Repeating notification created: $isCreated for reminder index $i');
      } catch (e) {
        MiniLogger.error('Failed to create repeating notification: ${e.toString()}');
      }
    }
  }

  static Future<void> removeTaskNotification(Task task) async {
    try {
      if (task.isNotifyEnabled!) {
        await _notif.cancel(task.id!);
        // Optionally cancel all repeating notifications if using composite id scheme.
        MiniLogger.debug('Notification ${task.id} canceled');
      }
    } catch (e) {
      MiniLogger.error('Failed to remove task notification: ${e.toString()}');
      rethrow;
    }
  }
}
