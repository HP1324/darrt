import 'dart:convert' show jsonDecode;
import 'package:flutter/material.dart' show TimeOfDay;
import 'package:intl/intl.dart' show DateFormat;

class MiniUtils{
  String formatDateWith(DateTime dateTime, String format) {
    return DateFormat(format).format(dateTime);
  }
  /// returns a [List<TimeOfDay>] from given reminders json string
  static List<dynamic> getReminders(String reminderString){
    final reminders = jsonDecode(reminderString) as List;
    return reminders;
    // final reminders = reminders.map((reminder) {
    //   final timeStr = reminder['time'];
    //   final parts = (timeStr as String).split(':');
    //   return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    // }).toList();
    // return reminders;
  }
  static TimeOfDay getTimeOfDayFromMap(dynamic reminderMap){
    final timeStr = reminderMap['time'];
    final parts = (timeStr as String).split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }
  ///Returns a single [List<TimeOfDay>] from given time string
  static TimeOfDay getSingleReminderObject(String timeString){
    final parts = timeString.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  static String timeOfDayToJsonString(TimeOfDay timeOfDay){
    return '${timeOfDay.hour.toString().padLeft(2, '0')}:${timeOfDay.minute.toString().padLeft(2, '0')}';
  }
}