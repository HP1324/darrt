import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:minimaltodo/helpers/consts.dart';

class MiniBox{
  // final _prefs =
  static final _box = GetStorage();

  static Future<void> write(String key, dynamic value)async{
    await _box.write(key, value);
  }

  static T? read<T>(String key){
    return _box.read(key);
  }

  static void remove(String key)async{
    await _box.remove(key);
  }

  ///Necessary method for writing only when the app first time installed.if it is null then it means the app was never installed or the developer has explicitly set it to [null] in some part of the code
  static Future<void> writeIfNull(String key,dynamic value)async{
      await _box.writeIfNull(key, value);
  }
  ///Set global preferences and other settings like first time install date etc.
  static Future<void> initStorage()async {
    await GetStorage.init();
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