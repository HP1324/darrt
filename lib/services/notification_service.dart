import 'dart:convert';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:minimaltodo/helpers/mini_enums.dart';
import 'package:minimaltodo/helpers/miniutils.dart';
import 'package:minimaltodo/helpers/mini_box.dart';
import 'package:minimaltodo/helpers/mini_consts.dart';
import 'package:minimaltodo/data_models/task.dart';
import 'package:minimaltodo/helpers/mini_utils.dart';
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
        MiniLogger.debug('First time permission request: $permissionGranted');
      }

      if (permissionGranted) {
        await initializeNotificationChannels();
        MiniLogger.debug('Notification service initialized successfully');
      } else {
        await MiniBox.write(mNotificationsEnabled, false);
        MiniLogger.debug('Notifications disabled - continuing without notification support');
      }
    } catch (e) {
      MiniLogger.error('Failed to initialize notification service: ${e.toString()}');
      await GetStorage().write(mNotificationsEnabled, false);
    }
  }

  static Future<bool> isNotificationsEnabled() async {
    try {
      return MiniBox.read(mNotificationsEnabled) ?? false;
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
    if (task.reminders == null) {
      return;
    }
    if (!await isNotificationsEnabled()) {
      MiniLogger.debug('Skipping notification creation - notifications are disabled');
      return;
    }
    MiniLogger.debug('Creating one-off task notification');
    MiniLogger.debug('Is notification allowed? ${await _notif.isNotificationAllowed()}');

    MiniLogger.debug('notification type:${task.notifType}, time: ${task.notifyTime}');
    try {
      final reminders = MiniUtils.getReminders(task.reminders!);
      final notifType = task.notifType!.toLowerCase();
      final isAlarm = notifType == 'alarm';
      for (var reminder in reminders) {
        final notificationId = reminder['id'];
        final time = MiniUtils.getTimeOfDayFromMap(reminder);
        await _notif.createNotification(
          content: NotificationContent(
            id: notificationId,
            groupKey: task.id!.toString(),
            channelKey: isAlarm ? 'task_alarm' : 'task_notif',
            title: 'Task Due at ${formatTimeOfDay(time)}',
            body: task.title,
            actionType: ActionType.Default,
            payload: task.toNotificationPayload(),
            notificationLayout: NotificationLayout.Default,
            category: isAlarm ? NotificationCategory.Alarm : NotificationCategory.Reminder,
            wakeUpScreen: true,
            criticalAlert: true,
          ),
          schedule: NotificationCalendar(
            day: task.dueDate!.day,
            month: task.dueDate!.month,
            year: task.dueDate!.year,
            hour: time.hour,
            minute: time.minute,
            second: 0,
            millisecond: 0,
            repeats: false,
            allowWhileIdle: true,
            preciseAlarm: true,
            timeZone: await _notif.getLocalTimeZoneIdentifier(),
          ),
        );
      }
    } catch (e) {
      MiniLogger.error('Failed to create task notification: ${e.toString()}');
      rethrow;
    }
  }

  static Future<void> createRepeatingTaskNotifications(Task task) async {
    if (!await isNotificationsEnabled()) {
      MiniLogger.debug('Notifications disabled; skipping repeating notifications.');
      return;
    }
    Future.delayed(Duration.zero, () async {
      try {
        // Parse repeat configuration
        final repeatConfig = jsonDecode(task.repeatConfig ?? '{}');
        final repeatType = repeatConfig['repeatType'] as String?;
        final selectedDays = repeatConfig['selectedDays'] as List<dynamic>?;

        ///Removing the reminder ids stored in [Task.reminders], because they are just useful for single tasks, not for recurring tasks.
        final taskReminders = jsonDecode(task.reminders!) as List<dynamic>;
        for (var reminder in taskReminders) {
          reminder.remove('id');
        }

        List<TimeOfDay> reminderTimes = task.getReminderTimeOfDaysList;
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
        MiniLogger.error('Error scheduling repeating notifications: $e');
      }
    });
  }

  // static Future<void> createRecurringNotifications(Task task) async {
  //   if (!await isNotificationsEnabled()) {
  //     MiniLogger.debug('Notifications disabled; skipping repeating notifications.');
  //     return;
  //   }
  //   final repeatConfig = jsonDecode(task.repeatConfig ?? '{}');
  //   final repeatType = repeatConfig['repeatType'];
  //   final weekdays = repeatConfig['selectedDays'];
  //   if (task.endDate == null && (repeatType == 'monthly' || repeatType == 'yearly')) {
  //     await _notif.createNotification(
  //       content: NotificationContent(
  //         id: notificationId,
  //         groupKey: task.id!.toString(),
  //         channelKey: task.notifType == 'alarm' ? 'task_alarm' : 'task_notif',
  //         title: 'Task due at ${formatTimeOfDay(reminderTime)}',
  //         body: task.title,
  //         payload: task.toNotificationPayload(),
  //         notificationLayout: NotificationLayout.Default,
  //         category: task.notifType == 'alarm'
  //             ? NotificationCategory.Alarm
  //             : NotificationCategory.Reminder,
  //         wakeUpScreen: true,
  //         criticalAlert: true,
  //       ),
  //       schedule: NotificationCalendar(
  //
  //       ),
  //     );
  //   }
  // }

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

      final notificationId = DateTime.now().millisecondsSinceEpoch.remainder(1000000000);

      await _notif.createNotification(
        content: NotificationContent(
          id: notificationId,
          groupKey: task.id!.toString(),
          channelKey: task.notifType == 'alarm' ? 'task_alarm' : 'task_notif',
          title: 'Task due at ${formatTimeOfDay(reminderTime)}',
          body: task.title,
          payload: task.toNotificationPayload(),
          notificationLayout: NotificationLayout.Default,
          category: task.notifType == 'alarm'
              ? NotificationCategory.Alarm
              : NotificationCategory.Reminder,
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
      MiniLogger.error('Error scheduling weekly notification: $e');
    }
  }

  static Future<void> _scheduleMonthlyNotification(
    Task task,
    TimeOfDay reminderTime,
    DateTime baseDateTime,
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

      final notificationId = generateNotificationId(task, baseDateTime, reminderTime);

      await _notif.createNotification(
        content: NotificationContent(
          id: notificationId,
          groupKey: task.id!.toString(),
          channelKey: task.notifType == 'alarm' ? 'task_alarm' : 'task_notif',
          title: 'Monthly Task Reminder',
          body: task.title,
          payload: task.toNotificationPayload(),
          notificationLayout: NotificationLayout.Default,
          category: task.notifType == 'alarm'
              ? NotificationCategory.Alarm
              : NotificationCategory.Reminder,
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
      MiniLogger.error('Error scheduling monthly notification: $e');
    }
  }

  static Future<void> _scheduleYearlyNotification(
    Task task,
    TimeOfDay reminderTime,
    DateTime baseDateTime,
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

      final notificationId = generateNotificationId(task, baseDateTime, reminderTime);

      await _notif.createNotification(
        content: NotificationContent(
          id: notificationId,
          groupKey: task.id!.toString(),
          channelKey: task.notifType == 'alarm' ? 'task_alarm' : 'task_notif',
          title: 'Yearly Task Reminder',
          body: task.title,
          payload: task.toNotificationPayload(),
          notificationLayout: NotificationLayout.Default,
          category: task.notifType == 'alarm'
              ? NotificationCategory.Alarm
              : NotificationCategory.Reminder,
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
      MiniLogger.error('Error scheduling yearly notification: $e');
    }
  }

  static Future<void> removeAllTaskNotifications(Task task) async {
    try {
      if (task.reminders == null) {
        return;
      } else {
        await _notif.cancelNotificationsByGroupKey(task.id!.toString());
      }
    } catch (e, stacktrace) {
      MiniLogger.error('Error removing notification: ${e.toString()}\n$stacktrace');
    }
  }

  static Future<void> removeSingleNotification(int id) async {
    try {
      await _notif.cancel(id);
    } catch (e, stacktrace) {
      MiniLogger.error('Error removing notification: ${e.toString()}');
      MiniLogger.trace('$stacktrace');
    }
  }

  static Future<void> removeNotificationWithTime() async {}
  static Future<void> removeRepeatingTaskNotifications(Task task) async {
    if (task.id == null) return;

    try {
      // Cancel all notifications for this task using the group key
      await AwesomeNotifications().cancelNotificationsByGroupKey(task.id!.toString());

      // Log the cancellation for debugging
      MiniLogger.debug('Cancelled all notifications for task ${task.id}');
    } catch (e) {
      MiniLogger.error('Error removing recurring notifications: $e');
    }
  }
}
