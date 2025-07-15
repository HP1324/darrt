import 'package:flutter/material.dart';
import 'package:darrt/helpers/consts.dart';
import 'package:darrt/app/services/mini_box.dart';

class SettingsStateController {


  final ValueNotifier<DateTime?> lastBackupDate = ValueNotifier(
    MiniBox().read(mLastBackupDate) != null
        ? DateTime.fromMillisecondsSinceEpoch(MiniBox().read(mLastBackupDate))
        : null,
  );

  void updateLastBackupDate(DateTime value) async {
    lastBackupDate.value = value;
    MiniBox().write(mLastBackupDate, value.millisecondsSinceEpoch);
  }

  // final ValueNotifier<bool> canPop = ValueNotifier(MiniBox().read(mCanPop) ?? false);
  //
  // void updateCanPop(bool? value) async {
  //   canPop.value = value ?? false;
  //   MiniBox().write(mCanPop, value);
  // }
}
