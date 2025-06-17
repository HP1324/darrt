
import 'package:flutter/material.dart';
import 'package:minimaltodo/helpers/consts.dart';
import 'package:minimaltodo/helpers/mini_box.dart';
//Default reminder type that user wants, i.e.,Alarm or Notification
ValueNotifier<String> defaultReminderType = ValueNotifier(MiniBox.read(mDefaultReminderType));

void updateDefaultReminder(String value)async{
  await MiniBox.write(mDefaultReminderType, value);
  defaultReminderType.value = value;

}
//-----------------------------------------------------------------//

// ValueNotifier<int> currentDestination = ValueNotifier(0);

ValueNotifier<int> snoozeMinutes = ValueNotifier(MiniBox.read(mSnoozeMinutes) ?? 5);

void updateSnoozeMinutes(int value)async{
  debugPrint('$value');
  snoozeMinutes.value = value;
  await MiniBox.write(mSnoozeMinutes, value);
}


ValueNotifier<String> pickedAlarmSoundName = ValueNotifier(MiniBox.read(mPickedAlarmSoundName) ?? 'System default sound');

void updateAlarmSound({required String uri,required String name})async{
  await MiniBox.write(mPickedAlarmSoundResourceUri, uri);
  await MiniBox.write(mPickedAlarmSoundName, name);
  pickedAlarmSoundName.value = name;
}

ValueNotifier<String> notificationSound = ValueNotifier(MiniBox.read(mNotificationSound));

void updateNotificationSound(String value)async{
  await MiniBox.write(mNotificationSound, value);
  notificationSound.value = value;
}



