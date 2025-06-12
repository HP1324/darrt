import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart' show TimeOfDay;
import 'package:minimaltodo/task/models/reminder.dart';
import 'package:minimaltodo/task/models/task.dart';

class MSingleNotificationContent extends NotificationContent{
  MSingleNotificationContent({
    required super.channelKey,
    required super.id,
    required this.task,
    required this.isAlarm,
    required this.time,
    required this.reminder,
  });

  final Task task;
  final bool isAlarm;
  final TimeOfDay time;
  final Reminder reminder;
}
