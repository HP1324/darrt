import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:darrt/app/notification/notification_action_controller.dart';
import 'package:darrt/helpers/consts.dart';
import 'package:workmanager/workmanager.dart';


Future<void> createBackupFailureNotification(String body) async {
  await AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: 1,
      channelKey: notifChannelKey,
      title: body,
      body: 'Please open the app and backup manually',
    ),
    actionButtons: [NotificationActionButton(key: openAppKey, label: 'Open Settings')],
  );
}

Future<void> createBackupSuccessNotification() async {
  await AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: 1,
      channelKey: notifChannelKey,
      body: 'Auto Backup successful',
    ),
  );
}

Future<void> registerAutoBackup(
    String uniqueName,
    String taskName, {
      Duration? frequency,
      Duration? flexInterval,
      Map<String, dynamic>? inputData,
      Duration? initialDelay,
      Constraints? constraints,
      ExistingPeriodicWorkPolicy? existingWorkPolicy,
      BackoffPolicy? backoffPolicy,
      Duration? backoffPolicyDelay,
      String? tag,
    }) async {
  await Workmanager().registerPeriodicTask(
    uniqueName,
    taskName,
    frequency: frequency,
    flexInterval: flexInterval,
    inputData: inputData,
    initialDelay: initialDelay,
    constraints: constraints,
    existingWorkPolicy: existingWorkPolicy,
    backoffPolicy: backoffPolicy,
    backoffPolicyDelay: backoffPolicyDelay,
    tag: tag,
  );
}

Future<void> cancelAutoBackup() async {
  await Workmanager().cancelByUniqueName(mAutoBackup);
}
