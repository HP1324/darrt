//ignore_for_file: curly_braces_in_flow_control_structures
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:minimaltodo/app/services/boxpref.dart';
import 'package:minimaltodo/app/services/object_box.dart';
import 'package:minimaltodo/helpers/consts.dart';
import 'package:minimaltodo/objectbox.g.dart';

class MiniBox{
  static final _instance = MiniBox._internal();
  MiniBox._internal();
  factory MiniBox() => _instance;

  Future<void> write(String key, dynamic value)async{
    String type = '';
    String serializedValue = '';

    if(value is bool) {
      type = 'bool';
      serializedValue = value.toString();
    } else if(value is int) {
      type = 'int';
      serializedValue = value.toString();
    } else if(value is double) {
      type = 'double';
      serializedValue = value.toString();
    } else if(value is String) {
      type = 'string';
      serializedValue = value;
    } else if(value is List<String>) {
      type = 'stringList';
      serializedValue = jsonEncode(value);
    } else if(value is DateTime) {
      type = 'datetime';
      serializedValue = value.millisecondsSinceEpoch.toString();
    } else {
      return; // unsupported type
    }

    final existingPref = ObjectBox().prefsBox.query(BoxPref_.key.equals(key)).build().findFirst();

    if (existingPref != null) {
      existingPref.value = serializedValue;
      existingPref.type = type;
      ObjectBox().prefsBox.put(existingPref);
    } else {
      final newPref = BoxPref(
        key: key,
        value: serializedValue,
        type: type,
      );
      ObjectBox().prefsBox.put(newPref);
    }
  }

  T? read<T>(String key){
    final pref = ObjectBox().prefsBox.query(BoxPref_.key.equals(key)).build().findFirst();

    if (pref == null) return null;

    try {
      switch (pref.type) {
        case 'bool':
          return (pref.value == 'true') as T?;
        case 'int':
          return int.parse(pref.value) as T?;
        case 'double':
          return double.parse(pref.value) as T?;
        case 'string':
          return pref.value as T?;
        case 'stringList':
          return (jsonDecode(pref.value) as List<dynamic>).cast<String>() as T?;
        case 'datetime':
          return DateTime.fromMillisecondsSinceEpoch(int.parse(pref.value)) as T?;
        default:
          return null;
      }
    } catch (e) {
      return null;
    }
  }

  void remove(String key)async{
    final pref = ObjectBox().prefsBox.query(BoxPref_.key.equals(key)).build().findFirst();
    if (pref != null) {
      ObjectBox().prefsBox.remove(pref.id);
    }
  }

  Future<void> reload()async{
    // No-op for ObjectBox
  }

  Future<void> writeIfNull(String key,dynamic value)async{
    if(read(key) == null) await write(key, value);
  }

  Future<void> initStorage()async {
    await Future.wait([
      writeIfNull(mDefaultTaskList, 0),
      writeIfNull(mFirstInstallDate, DateUtils.dateOnly(DateTime.now()).millisecondsSinceEpoch),
      writeIfNull(firstTimeMicTap, true),
      writeIfNull(micPermissionDeniedAgain, false),
      writeIfNull(mSnoozeMinutes, 5),
      writeIfNull(mDefaultReminderType, notifReminderType),
      writeIfNull(mPickedAlarmSoundResourceUri, 'System alarm sound'),
      writeIfNull(mNotificationSound, 'System notification sound'),
    ]);
  }
}