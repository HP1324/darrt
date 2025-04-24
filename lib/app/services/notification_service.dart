import 'dart:convert';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:minimaltodo/helpers/mini_box.dart';
import 'package:minimaltodo/helpers/consts.dart';
import 'package:minimaltodo/task/reminder.dart';
import 'package:minimaltodo/task/task.dart';
import 'package:minimaltodo/helpers/utils.dart';
import 'package:minimaltodo/helpers/mini_logger.dart';

class NotificationService {
  static final _notif = AwesomeNotifications();

  static Future<void> initNotifications() async {
    try {
      bool permissionGranted = await _notif.isNotificationAllowed();

      if (!permissionGranted && (MiniBox.read(mFirstTimeNotifPermission) ?? true)) {
        permissionGranted = await _notif.requestPermissionToSendNotifications();
        await MiniBox.write(mFirstTimeNotifPermission, false);
        await MiniBox.write(mNotificationsEnabled, permissionGranted);
        MiniLogger.d('First time permission request: $permissionGranted');
      }

      if (permissionGranted) {
        await initializeNotificationChannels();
        MiniLogger.d('Notification service initialized successfully');
      } else {
        await MiniBox.write(mNotificationsEnabled, false);
        MiniLogger.d('Notifications disabled - continuing without notification support');
      }
    } catch (e) {
      MiniLogger.e('Failed to initialize notification service: ${e.toString()}');
      await MiniBox.write(mNotificationsEnabled, false);
    }
  }

  static Future<bool> isNotificationsEnabled() async {
    try {
      return MiniBox.read(mNotificationsEnabled) ?? false;
    } catch (e) {
      MiniLogger.e('Error checking notification status: ${e.toString()}');
      return false;
    }
  }

  static Future<void> initializeNotificationChannels() async {
    try {
      MiniLogger.d('Initializing notification channels');
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
      MiniLogger.d('Channels initialized: $isInitialized');
    } catch (e) {
      MiniLogger.e('Failed to initialize notification channels: ${e.toString()}');
      rethrow;
    }
  }

  static Future<void> createTaskNotification(Task task) async {
    if (task.reminders == null || task.reminderObjects.isEmpty) {
      return;
    }
    if (!await isNotificationsEnabled()) {
      MiniLogger.d('Skipping notification creation - notifications are disabled');
      return;
    }
    MiniLogger.d('Creating one-off task notification');
    MiniLogger.d('Is notification allowed? ${await _notif.isNotificationAllowed()}');

    try {
      for (var reminder in task.reminderObjects) {
        final notificationId = reminder.id;
        final time = reminder.time;
        final isAlarm = reminder.type.toLowerCase() == 'alarm';

        await _notif.createNotification(
            content: NotificationContent(
              id: notificationId,
              groupKey: task.id.toString(),
              channelKey: isAlarm ? 'task_alarm' : 'task_notif',
              title: 'Task Due at ${Utils.formatTime(time)}',
              body: task.title,
              actionType: ActionType.Default,
              payload: task.toNotificationPayload(),
              notificationLayout: NotificationLayout.Default,
              category: isAlarm ? NotificationCategory.Alarm : NotificationCategory.Reminder,
              wakeUpScreen: true,
              criticalAlert: true,
            ),
            schedule: NotificationCalendar(
              day: task.dueDate.day,
              month: task.dueDate.month,
              year: task.dueDate.year,
              hour: time.hour,
              minute: time.minute,
              second: 0,
              millisecond: 0,
              repeats: false,
              allowWhileIdle: true,
              preciseAlarm: true,
              timeZone: await _notif.getLocalTimeZoneIdentifier(),
            ),
            actionButtons: [
              NotificationActionButton(
                key: 'FINISHED',
                label: 'Finished',
                actionType: ActionType.SilentBackgroundAction,
              ),
            ]
        );
      }
    } catch (e) {
      MiniLogger.e('Failed to create task notification: ${e.toString()}');
      rethrow;
    }
  }

  static Future<void> createRepeatingTaskNotifications(Task task) async {
    if (!await isNotificationsEnabled()) {
      MiniLogger.d('Notifications disabled; skipping repeating notifications.');
      return;
    }
    if(task.endDate != null && task.endDate!.difference(task.startDate) > Duration(days: 365)) {
      compute(scheduleRepeatNotifications, task);
    } else {
      scheduleRepeatNotifications(task);
    }
  }

  static void scheduleRepeatNotifications(Task task) async {
    try {
      // Parse repeat configuration
      final repeatConfig = jsonDecode(task.repeatConfig ?? '{}');
      final repeatType = repeatConfig['repeatType'] as String?;
      final selectedDays = repeatConfig['selectedDays'] as List<dynamic>?;

      // Get reminders directly from task
      List<Reminder> reminders = task.reminderObjects;

      // Calculate notification schedule based on repeat type
      for (var reminder in reminders) {
        final baseDateTime = DateTime(
          task.startDate.year,
          task.startDate.month,
          task.startDate.day,
          reminder.time.hour,
          reminder.time.minute,
        );

        switch (repeatType) {
          case 'weekly':
            if (selectedDays != null) {
              for (final weekday in selectedDays) {
                await _scheduleWeeklyNotification(
                  task,
                  weekday,
                  reminder.time,
                  baseDateTime,
                  reminder.type,
                );
              }
            }
            break;

          case 'monthly':
            await _scheduleMonthlyNotification(
              task,
              reminder.time,
              baseDateTime,
              reminder.type,
            );
            break;

          case 'yearly':
            await _scheduleYearlyNotification(
              task,
              reminder.time,
              baseDateTime,
              reminder.type,
            );
            break;
        }
      }
    } catch (e) {
      MiniLogger.e('Error scheduling repeating notifications: $e');
    }
  }

  static Future<void> _scheduleWeeklyNotification(
      Task task,
      int weekday,
      TimeOfDay reminderTime,
      DateTime baseDateTime,
      String notificationType,
      ) async {
    try {
      var notifyDate = baseDateTime;
      while (notifyDate.weekday != weekday) {
        notifyDate = notifyDate.add(const Duration(days: 1));
      }

      if (task.endDate != null && notifyDate.isAfter(task.endDate!)) {
        return;
      }

      final notificationId = DateTime.now().millisecondsSinceEpoch.remainder(1000000000);
      final isAlarm = notificationType.toLowerCase() == 'alarm';

      await _notif.createNotification(
        content: NotificationContent(
          id: notificationId,
          groupKey: task.id!.toString(),
          channelKey: isAlarm ? 'task_alarm' : 'task_notif',
          title: 'Task due at ${Utils.formatTime(reminderTime)}',
          body: task.title,
          payload: task.toNotificationPayload(),
          notificationLayout: NotificationLayout.Default,
          category: isAlarm ? NotificationCategory.Alarm : NotificationCategory.Reminder,
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
      MiniLogger.e('Error scheduling weekly notification: $e');
    }
  }

  static Future<void> _scheduleMonthlyNotification(
      Task task,
      TimeOfDay reminderTime,
      DateTime baseDateTime,
      String notificationType,
      ) async {
    try {
      // Calculate the next notification date
      final now = DateTime.now();
      DateTime nextNotificationDate =
      DateTime(now.year, now.month, baseDateTime.day, reminderTime.hour, reminderTime.minute);

      // If the day has already passed this month, move to next month
      if (nextNotificationDate.isBefore(now)) {
        nextNotificationDate = DateTime(
          now.month == 12 ? now.year + 1 : now.year,
          now.month == 12 ? 1 : now.month + 1,
          baseDateTime.day,
          reminderTime.hour,
          reminderTime.minute,
        );
      }

      // Skip if endDate is before next notification
      if (task.endDate != null && nextNotificationDate.isAfter(task.endDate!)) {
        return;
      }

      final notificationId = DateTime.now().millisecondsSinceEpoch.remainder(1000000000);
      final isAlarm = notificationType.toLowerCase() == 'alarm';

      await _notif.createNotification(
        content: NotificationContent(
          id: notificationId,
          groupKey: task.id!.toString(),
          channelKey: isAlarm ? 'task_alarm' : 'task_notif',
          title: 'Monthly Task Due at ${Utils.formatTime(reminderTime)}',
          body: task.title,
          payload: task.toNotificationPayload(),
          notificationLayout: NotificationLayout.Default,
          category: isAlarm ? NotificationCategory.Alarm : NotificationCategory.Reminder,
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
      MiniLogger.e('Error scheduling monthly notification: $e');
    }
  }

  static Future<void> _scheduleYearlyNotification(
      Task task,
      TimeOfDay reminderTime,
      DateTime baseDateTime,
      String notificationType,
      ) async {
    try {
      // Calculate the next notification date
      final now = DateTime.now();
      DateTime nextNotificationDate = DateTime(
          now.year, baseDateTime.month, baseDateTime.day, reminderTime.hour, reminderTime.minute);

      // If date has passed this year, move to next year
      if (nextNotificationDate.isBefore(now)) {
        nextNotificationDate = DateTime(
          now.year + 1,
          baseDateTime.month,
          baseDateTime.day,
          reminderTime.hour,
          reminderTime.minute,
        );
      }

      // Skip if endDate is before next notification
      if (task.endDate != null && nextNotificationDate.isAfter(task.endDate!)) {
        return;
      }

      final notificationId = DateTime.now().millisecondsSinceEpoch.remainder(1000000000);
      final isAlarm = notificationType.toLowerCase() == 'alarm';

      await _notif.createNotification(
        content: NotificationContent(
          id: notificationId,
          groupKey: task.id!.toString(),
          channelKey: isAlarm ? 'task_alarm' : 'task_notif',
          title: 'Yearly Task Due at ${Utils.formatTime(reminderTime)}',
          body: task.title,
          payload: task.toNotificationPayload(),
          notificationLayout: NotificationLayout.Default,
          category: isAlarm ? NotificationCategory.Alarm : NotificationCategory.Reminder,
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
      MiniLogger.e('Error scheduling yearly notification: $e');
    }
  }
  static Future<void> removeAllTaskNotifications(Task task) async {
    try {
      if (task.reminders == null) {
        return;
      } else {
        await _notif.cancelNotificationsByGroupKey(task.id.toString());
      }
    } catch (e, stacktrace) {
      MiniLogger.e('Error removing notification: ${e.toString()}\n$stacktrace');
    }
  }

  static Future<void> removeSingleNotification(int id) async {
    try {
      await _notif.cancel(id);
    } catch (e, stacktrace) {
      MiniLogger.e('Error removing notification: ${e.toString()}');
      MiniLogger.t('$stacktrace');
    }
  }
  static int generateNotificationId(Task task, DateTime date, TimeOfDay time) {
    return task.id! * 1000000 +
        (date.month * 100 + date.day) * 100 +
        (time.hour * 60 + time.minute);
  }
  static Future<void> removeNotificationWithTime() async {}
  static Future<void> removeRepeatingTaskNotifications(Task task) async {
    if (task.id == null) return;

    try {
      // Cancel all notifications for this task using the group key
      await AwesomeNotifications().cancelNotificationsByGroupKey(task.id!.toString());

      // Log the cancellation for debugging
      MiniLogger.d('Cancelled all notifications for task ${task.id}');
    } catch (e) {
      MiniLogger.e('Error removing recurring notifications: $e');
    }
  }
}
