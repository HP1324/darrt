import 'dart:convert' show jsonEncode,jsonDecode;

import 'package:flutter/material.dart';

class Reminder{
  int id;
  TimeOfDay time;
  String type;

  Reminder({this.id = 0,required this.time, this.type = 'notif'});


  String toJsonString(){
    return jsonEncode({'time' : timeToString(), 'type' : type});
  }

  factory Reminder.fromJsonString(String json){
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
    List<Map<String, dynamic>> reminderMapList = reminders.map((r) => {
      'id' : r.id,
      'time': r.timeToString(),
      'type': r.type,
    }).toList();
    return jsonEncode(reminderMapList);
  }
}