import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:minimaltodo/helpers/consts.dart';
import 'package:shared_preferences/shared_preferences.dart';
//ignore_for_file: curly_braces_in_flow_control_structures

class MiniBox{
  static final _instance = MiniBox._internal();
  MiniBox._internal();
  factory MiniBox() => _instance;


  late final SharedPreferencesWithCache _prefs;

  Future<void> write(String key, dynamic value)async{
    if(value is bool) await _prefs.setBool(key, value);
    else if(value is int) await _prefs.setInt(key, value);
    else if(value is double) await _prefs.setDouble(key, value);
    else if(value is String) await _prefs.setString(key, value);
    else if(value is List<String>) await _prefs.setStringList(key, value);
  }

  T? read<T>(String key){
    if(T == bool) return _prefs.getBool(key) as T?;
    else if(T == int) return _prefs.getInt(key) as T?;
    else if(T == double) return _prefs.getDouble(key) as T?;
    else if(T == String) return _prefs.getString(key) as T?;
    else if(T == List<String>) return _prefs.getStringList(key) as T?;
    return null;
  }

  void remove(String key)async{
    await _prefs.remove(key);
  }

  Future<void> reload()async{
    await _prefs.reloadCache();
  }
  ///Necessary method for writing only when the app first time installed.if it is null then it means the app was never installed or the developer has explicitly set it to [null] in some part of the code
  Future<void> writeIfNull(String key,dynamic value)async{
    if(read(key) == null) await write(key, value);
  }
  ///Set global preferences and other settings like first time install date etc.
   Future<void> initStorage()async {
    _prefs = await SharedPreferencesWithCache.create(cacheOptions: const SharedPreferencesWithCacheOptions());
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