import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:minimaltodo/helpers/consts.dart';

class MiniBox{
  static final _box = GetStorage();

  static Future<void> write(String key, dynamic value)async{
    await _box.write(key, value);
  }

  static T? read<T>(String key){
    return _box.read(key);
  }

  ///Necessary method for writing only when the app first time installed.if it is null then it means the app was never installed or the developer has explicitly set it to [null] in some part of the code
  static Future<void> writeIfNull(String key,dynamic value)async{
    if(read(key) == null){
      await write(key, value);
    }
  }
  ///Set global preferences and other settings like first time install date etc.
  static Future<void> initStorage()async {
    await writeIfNull(mDefaultTaskList, 0);
    await writeIfNull(mFirstTimeInstall, true);
    await writeIfNull(mFirstInstallDate, DateUtils.dateOnly(DateTime.now()).millisecondsSinceEpoch);
  }
}