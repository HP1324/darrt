
import 'package:flutter/material.dart';
import 'package:minimaltodo/helpers/consts.dart';
import 'package:minimaltodo/helpers/mini_box.dart';

class SettingsStateController {

//Default reminder type that user wants, i.e.,Alarm or Notification
  final ValueNotifier<String> defaultReminderType = ValueNotifier(MiniBox.read(mDefaultReminderType));

  void updateDefaultReminder(String value) async {
    await MiniBox.write(mDefaultReminderType, value);
    defaultReminderType.value = value;
  }

  final ValueNotifier<int> snoozeMinutes = ValueNotifier(MiniBox.read(mSnoozeMinutes) ?? 5);

  void updateSnoozeMinutes(int value) async {
    snoozeMinutes.value = value;
    await MiniBox.write(mSnoozeMinutes, value);
  }

  final ValueNotifier<String> pickedAlarmSoundName = ValueNotifier(
      MiniBox.read(mPickedAlarmSoundName) ?? 'System default sound');

  void updateAlarmSound({required String uri, required String name}) async {
    await MiniBox.write(mPickedAlarmSoundResourceUri, uri);
    await MiniBox.write(mPickedAlarmSoundName, name);
    pickedAlarmSoundName.value = name;
  }

  final ValueNotifier<String> notificationSound = ValueNotifier(MiniBox.read(mNotificationSound));

  void updateNotificationSound(String value) async {
    await MiniBox.write(mNotificationSound, value);
    notificationSound.value = value;
  }


  final ValueNotifier<bool> autoBackUp = ValueNotifier(MiniBox.read(mAutoBackup) ?? false);

  void updateAutoBackup(bool value) async {
    autoBackUp.value = value;
    await MiniBox.write(mAutoBackup, value);
  }

  final ValueNotifier<DateTime?> lastBackupDate = ValueNotifier(
    MiniBox.read(mLastBackupDate) != null ? DateTime.fromMillisecondsSinceEpoch(MiniBox.read(mLastBackupDate)) : null,
  );


  void updateLastBackupDate(DateTime value) async {
    lastBackupDate.value = value;
    await MiniBox.write(mLastBackupDate, value.millisecondsSinceEpoch);
  }

  // final ValueNotifier<bool> canPop = ValueNotifier(MiniBox.read(mCanPop) ?? false);
  //
  // void updateCanPop(bool? value) async {
  //   canPop.value = value ?? false;
  //   await MiniBox.write(mCanPop, value);
  // }
}


