import 'dart:convert' show jsonEncode, jsonDecode;

import 'package:flutter/material.dart';


class Reminder {
  final int id;
  final TimeOfDay time;
  final String type;

  const Reminder({this.id = 0, required this.time, this.type = 'notif'});

  Reminder copyWith({int? id, TimeOfDay? time, String? type}) {
    return Reminder(
      id: id ?? this.id,
      time: time ?? this.time,
      type: type ?? this.type,
    );
  }

  @override
  String toString() {
    return 'Reminder(id: $id, time: $time, type: $type)';
  }


  String toJsonString() {
    return jsonEncode({'time': timeToString(), 'type': type});
  }

  factory Reminder.fromJsonString(String json) {
    final Map<String, dynamic> data = jsonDecode(json);
    return Reminder(
      time: stringToTime(data['time']),
      type: data['type'] ?? 'notif',
    );
  }
  String timeToString() {
    final hour = time.hour;
    final minute = time.minute;
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  static TimeOfDay stringToTime(String timeString) {
    final parts = timeString.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return TimeOfDay(hour: hour, minute: minute);
  }

  static String remindersToJsonString(List<Reminder> reminders) {
    List<Map<String, dynamic>> reminderMapList = reminders
        .map((r) => {
              'id': r.id,
              'time': r.timeToString(),
              'type': r.type,
            })
        .toList();
    return jsonEncode(reminderMapList);
  }


  /// Takes a json string of reminders and returns [List<Reminder>]
  static List<Reminder> getReminderObjects(String? reminders) {
    if (reminders == null || reminders == "{}") {
      return [];
    }
    final List<dynamic> decodedReminders = jsonDecode(reminders);

    return decodedReminders.map((reminder) {
      final id = reminder['id'];
      final timeString = reminder['time'];
      final type = reminder['type'] ?? 'notif';

      return Reminder(id: id, time: Reminder.stringToTime(timeString), type: type);
    }).toList();
  }
}
