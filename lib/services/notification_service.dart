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
        MiniLogger.debug(
            'Notifications disabled - continuing without notification support');
      }
    } catch (e) {
      MiniLogger.error(
          'Failed to initialize notification service: ${e.toString()}');
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
            channelDescription:
                'Channel used to notify users about their tasks with simple notification',
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
            channelDescription:
                'Channel used to notify users about their tasks with alarm',
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
      MiniLogger.error(
          'Failed to initialize notification channels: ${e.toString()}');
      rethrow;
    }
  }

  static Future<void> createTaskNotification(Task task) async {
    if (task.notifyTime == null || task.notifyTime!.isBefore(DateTime.now())) {
      return;
    }
    if (!await isNotificationsEnabled()) {
      MiniLogger.debug(
          'Skipping notification creation - notifications are disabled');
      return;
    }
    MiniLogger.debug('Creating one-off task notification');
    Map<String, dynamic> taskJson = task.toJson();
    String taskPayload = jsonEncode(taskJson);
    MiniLogger.debug(
        'Is notification allowed? ${await _notif.isNotificationAllowed()}');

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
    if (!await isNotificationsEnabled()) {
      logger.d('Notifications disabled; skipping repeating notifications.');
      return;
    }

    try {
      // Parse repeat configuration
      final repeatConfig = jsonDecode(task.repeatConfig ?? '{}');
      final repeatType = repeatConfig['repeatType'] as String?;
      final selectedDays = repeatConfig['selectedDays'] as List<dynamic>?;

      // Parse reminder times
      List<TimeOfDay> reminderTimes = [];
      if (task.reminderTimes != null) {
        final times = jsonDecode(task.reminderTimes!) as List;
        reminderTimes = times.map((timeStr) {
          final parts = (timeStr as String).split(':');
          return TimeOfDay(
              hour: int.parse(parts[0]), minute: int.parse(parts[1]));
        }).toList();
      }

      // Calculate notification schedule based on repeat type
      for (var reminderTime in reminderTimes) {
        final baseDateTime = DateTime(
          task.startDate.year,
          task.startDate.month,
          task.startDate.day,
          reminderTime.hour,
          reminderTime.minute,
        );

        switch (repeatType) {
          case 'weekly':
            if (selectedDays != null) {
              for (final weekday in selectedDays) {
                await _scheduleWeeklyNotification(
                  task,
                  weekday,
                  reminderTime,
                  baseDateTime,
                );
              }
            }
            break;

          case 'monthly':
            await _scheduleMonthlyNotification(
              task,
              reminderTime,
              baseDateTime,
            );
            break;

          case 'yearly':
            await _scheduleYearlyNotification(
              task,
              reminderTime,
              baseDateTime,
            );
            break;
        }
      }
    } catch (e) {
      logger.e('Error scheduling repeating notifications: $e');
    }
  }

  static int generateNotificationId(Task task, DateTime date, TimeOfDay time) {
    return task.id! * 1000000 +
        (date.month * 100 + date.day) * 100 +
        (time.hour * 60 + time.minute);
  }

  static Future<void> _scheduleWeeklyNotification(
    Task task,
    int weekday,
    TimeOfDay reminderTime,
    DateTime baseDateTime,
  ) async {
    try {
      var notifyDate = baseDateTime;
      while (notifyDate.weekday != weekday) {
        notifyDate = notifyDate.add(const Duration(days: 1));
      }

      if (task.endDate != null && notifyDate.isAfter(task.endDate!)) {
        return;
      }

      final notificationId =
          generateNotificationId(task, notifyDate, reminderTime);

      await _notif.createNotification(
        content: NotificationContent(
          id: notificationId,
          groupKey: task.id!.toString(),
          channelKey: task.notifType == 'alarm' ? 'task_alarm' : 'task_notif',
          title: 'Repeating Task Reminder',
          body: task.title,
          notificationLayout: NotificationLayout.Default,
          category: NotificationCategory.Reminder,
          wakeUpScreen: true,
          criticalAlert: true,
        ),
        schedule: NotificationCalendar(
          weekday: weekday,
          hour: reminderTime.hour,
          minute: reminderTime.minute,
          second: 0,
          millisecond: 0,
          repeats: true,
          preciseAlarm: true,
        ),
        actionButtons: [
          NotificationActionButton(
            key: 'MARK_DONE',
            label: 'Mark Done',
            actionType: ActionType.SilentBackgroundAction,
          ),
          NotificationActionButton(
            key: 'SNOOZE',
            label: 'Snooze',
            actionType: ActionType.Default,
          ),
        ],
      );
    } catch (e) {
      logger.e('Error scheduling weekly notification: $e');
    }
  }

  static Future<void> _scheduleMonthlyNotification(
    Task task,
    TimeOfDay reminderTime,
    DateTime baseDateTime,
  ) async {
    try {
      final notificationId =
          generateNotificationId(task, baseDateTime, reminderTime);

      await _notif.createNotification(
        content: NotificationContent(
          id: notificationId,
          groupKey: task.id!.toString(),
          channelKey: task.notifType == 'alarm' ? 'task_alarm' : 'task_notif',
          title: 'Monthly Task Reminder',
          body: task.title,
          notificationLayout: NotificationLayout.Default,
          category: NotificationCategory.Reminder,
          wakeUpScreen: true,
          criticalAlert: true,
        ),
        schedule: NotificationCalendar(
          day: baseDateTime.day,
          hour: reminderTime.hour,
          minute: reminderTime.minute,
          second: 0,
          millisecond: 0,
          repeats: true,
          preciseAlarm: true,
        ),
        actionButtons: [
          NotificationActionButton(
            key: 'MARK_DONE',
            label: 'Mark Done',
            actionType: ActionType.SilentBackgroundAction,
          ),
          NotificationActionButton(
            key: 'SNOOZE',
            label: 'Snooze',
            actionType: ActionType.Default,
          ),
        ],
      );
    } catch (e) {
      logger.e('Error scheduling monthly notification: $e');
    }
  }

  static Future<void> _scheduleYearlyNotification(
    Task task,
    TimeOfDay reminderTime,
    DateTime baseDateTime,
  ) async {
    try {
      final notificationId =
          generateNotificationId(task, baseDateTime, reminderTime);

      await _notif.createNotification(
        content: NotificationContent(
          id: notificationId,
          groupKey: task.id!.toString(),
          channelKey: task.notifType == 'alarm' ? 'task_alarm' : 'task_notif',
          title: 'Yearly Task Reminder',
          body: task.title,
          notificationLayout: NotificationLayout.Default,
          category: NotificationCategory.Reminder,
          wakeUpScreen: true,
          criticalAlert: true,
        ),
        schedule: NotificationCalendar(
          month: baseDateTime.month,
          day: baseDateTime.day,
          hour: reminderTime.hour,
          minute: reminderTime.minute,
          second: 0,
          millisecond: 0,
          repeats: true,
          preciseAlarm: true,
        ),
        actionButtons: [
          NotificationActionButton(
            key: 'MARK_DONE',
            label: 'Mark Done',
            actionType: ActionType.SilentBackgroundAction,
          ),
          NotificationActionButton(
            key: 'SNOOZE',
            label: 'Snooze',
            actionType: ActionType.Default,
          ),
        ],
      );
    } catch (e) {
      logger.e('Error scheduling yearly notification: $e');
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

  static Future<void> removeRepeatingTaskNotifications(Task task) async {
    if (task.id == null) return;

    try {
      // Cancel all notifications for this task using the group key
      await AwesomeNotifications()
          .cancelNotificationsByGroupKey(task.id!.toString());

      // Log the cancellation for debugging
      logger.d('Cancelled all notifications for task ${task.id}');
    } catch (e) {
      logger.e('Error removing recurring notifications: $e');
    }
  }
}
