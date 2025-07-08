import 'package:flutter/material.dart';
import 'package:minimaltodo/helpers/consts.dart';
import 'package:minimaltodo/app/services/mini_box.dart';

class SettingsStateController {


  final ValueNotifier<DateTime?> lastBackupDate = ValueNotifier(
    MiniBox().read(mLastBackupDate) != null
        ? DateTime.fromMillisecondsSinceEpoch(MiniBox().read(mLastBackupDate))
        : null,
  );

  void updateLastBackupDate(DateTime value) async {
    lastBackupDate.value = value;
    await MiniBox().write(mLastBackupDate, value.millisecondsSinceEpoch);
  }

  // final ValueNotifier<bool> canPop = ValueNotifier(MiniBox().read(mCanPop) ?? false);
  //
  // void updateCanPop(bool? value) async {
  //   canPop.value = value ?? false;
  //   await MiniBox().write(mCanPop, value);
  // }
}
