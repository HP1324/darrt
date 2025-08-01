import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:darrt/habits/build/models/build_habit.dart';
import 'package:darrt/helpers/mini_logger.dart';
import 'package:darrt/helpers/utils.dart';
import 'package:darrt/task/models/reminder.dart';
import 'package:darrt/task/models/repeat_config.dart';
import 'package:flutter/foundation.dart';

import '../app/notification/notification_action_controller.dart';

class HabitNotificationService{
  static final _notif = AwesomeNotifications();

  static Future<void> createHabitNotifications(BuildHabit habit) async {
    if (habit.reminders == null || Reminder.getReminderObjects(habit.reminders).isEmpty) {
      return;
    }
    if (habit.endDate != null && habit.endDate!.difference(habit.startDate) > Duration(days: 365)) {
      await compute(scheduleRepeatNotifications, habit);
    } else {
      await scheduleRepeatNotifications(habit);
    }
  }

  static Future<void> scheduleRepeatNotifications(BuildHabit habit) async
  {
    try {
      RepeatConfig config = RepeatConfig.fromJsonString(habit.repeatConfig!);
      final type = config.type;
      final days = config.days;
      List<Reminder> reminders = Reminder.getReminderObjects(habit.reminders);

      for (var reminder in reminders) {
        final baseDateTime = DateTime(
          habit.startDate.year,
          habit.startDate.month,
          habit.startDate.day,
          reminder.time.hour,
          reminder.time.minute,
        );

        switch (type) {
          case 'weekly':
            for (final weekday in days) {
              await _scheduleWeeklyNotification(
                habit,
                weekday,
                reminder,
                baseDateTime,
                reminder.type,
              );
            }
            break;

          case 'monthly':
            await _scheduleMonthlyNotification(
              habit,
              reminder,
              baseDateTime,
              reminder.type,
            );
            break;

          case 'yearly':
            await _scheduleYearlyNotification(
              habit,
              reminder,
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
      BuildHabit habit,
      int weekday,
      Reminder reminder,
      DateTime baseDateTime,
      String notificationType,
      ) async {
    try {
      var notifyDate = baseDateTime;
      while (notifyDate.weekday != weekday) {
        notifyDate = notifyDate.add(const Duration(days: 1));
      }
      if (habit.endDate != null && notifyDate.isAfter(habit.endDate!)) {
        return;
      }

      final isAlarm = notificationType.toLowerCase() == 'alarm';

      await _notif.createNotification(
        content: NotificationContent(
          id: notificationId,
          groupKey: habit.id.toString(),
          channelKey: isAlarm ? 'task_alarm' : 'task_notif',
          title: 'Activity scheduled at ${formatTime(reminder.time)}',
          body: 'Get ready for ${habit.name}',
          payload: {'id': habit.id.toString()},
          notificationLayout: NotificationLayout.Default,
          category: isAlarm ? NotificationCategory.Alarm : NotificationCategory.Reminder,
          wakeUpScreen: true,
          criticalAlert: true,
        ),
        schedule: NotificationCalendar(
          weekday: weekday,
          hour: reminder.time.hour,
          minute: reminder.time.minute,
          second: 0,
          millisecond: 0,
          repeats: true,
          preciseAlarm: true,
          timeZone: await _notif.getLocalTimeZoneIdentifier(),
        ),
        actionButtons: [
          finishedActionButton,
          snoozeActionButton,
        ],
      );
    } catch (e) {
      MiniLogger.e('Error scheduling weekly notification: $e');
    }
  }

  static Future<void> _scheduleMonthlyNotification(
      BuildHabit habit,
      Reminder reminder,
      DateTime baseDateTime,
      String notificationType,
      ) async {
    try {
      // Calculate the next notification date
      final now = DateTime.now();
      DateTime nextNotificationDate = DateTime(
        now.year,
        now.month,
        baseDateTime.day,
        reminder.time.hour,
        reminder.time.minute,
      );

      // If the day has already passed this month, move to next month
      if (nextNotificationDate.isBefore(now)) {
        nextNotificationDate = DateTime(
          now.month == 12 ? now.year + 1 : now.year,
          now.month == 12 ? 1 : now.month + 1,
          baseDateTime.day,
          reminder.time.hour,
          reminder.time.minute,
        );
      }

      // Skip if endDate is before next notification
      if (habit.endDate != null && nextNotificationDate.isAfter(habit.endDate!)) {
        return;
      }

      final isAlarm = notificationType.toLowerCase() == 'alarm';

      await _notif.createNotification(
        content: NotificationContent(
          id: notificationId,
          groupKey: habit.id.toString(),
          channelKey: isAlarm ? 'task_alarm' : 'task_notif',
          title: 'Activity scheduled at ${formatTime(reminder.time)}',
          body: 'Get ready for ${habit.name}',
          payload: {'id': habit.id.toString()},
          notificationLayout: NotificationLayout.Default,
          category: isAlarm ? NotificationCategory.Alarm : NotificationCategory.Reminder,
          wakeUpScreen: true,
          criticalAlert: true,
        ),
        schedule: NotificationCalendar(
          day: baseDateTime.day,
          hour: reminder.time.hour,
          minute: reminder.time.minute,
          second: 0,
          millisecond: 0,
          repeats: true,
          preciseAlarm: true,
          timeZone: await _notif.getLocalTimeZoneIdentifier(),
        ),
        actionButtons: [
          finishedActionButton,
          snoozeActionButton,
        ],
      );
    } catch (e) {
      MiniLogger.e('Error scheduling monthly notification: $e');
    }
  }

  static Future<void> _scheduleYearlyNotification(
      BuildHabit habit,
      Reminder reminder,
      DateTime baseDateTime,
      String notificationType,
      ) async {
    try {
      // Calculate the next notification date
      final now = DateTime.now();
      DateTime nextNotificationDate = DateTime(
        now.year,
        baseDateTime.month,
        baseDateTime.day,
        reminder.time.hour,
        reminder.time.minute,
      );

      // If date has passed this year, move to next year
      if (nextNotificationDate.isBefore(now)) {
        nextNotificationDate = DateTime(
          now.year + 1,
          baseDateTime.month,
          baseDateTime.day,
          reminder.time.hour,
          reminder.time.minute,
        );
      }

      // Skip if endDate is before next notification
      if (habit.endDate != null && nextNotificationDate.isAfter(habit.endDate!)) {
        return;
      }

      final isAlarm = notificationType.toLowerCase() == 'alarm';

      await _notif.createNotification(
        content: NotificationContent(
          id: notificationId,
          groupKey: habit.id.toString(),
          channelKey: isAlarm ? 'task_alarm' : 'task_notif',
          title: 'Yearly Activity scheduled at ${formatTime(reminder.time)}',
          body: 'Get ready for ${habit.name}',
          payload: {'id': habit.id.toString()},
          notificationLayout: NotificationLayout.Default,
          category: isAlarm ? NotificationCategory.Alarm : NotificationCategory.Reminder,
          wakeUpScreen: true,
          criticalAlert: true,
        ),
        schedule: NotificationCalendar(
          month: baseDateTime.month,
          day: baseDateTime.day,
          hour: reminder.time.hour,
          minute: reminder.time.minute,
          second: 0,
          millisecond: 0,
          repeats: true,
          preciseAlarm: true,
          timeZone: await _notif.getLocalTimeZoneIdentifier(),
        ),
        actionButtons: [
          finishedActionButton,
          snoozeActionButton,
        ],
      );
    } catch (e) {
      MiniLogger.e('Error scheduling yearly notification: $e');
    }
  }

  static int get notificationId => DateTime.now().millisecondsSinceEpoch.remainder(100000);

}