import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:darrt/app/exceptions.dart';
import 'package:darrt/app/notification/notification_action_controller.dart';
import 'package:darrt/app/services/backup_service.dart';
import 'package:darrt/app/services/google_sign_in_service.dart';
import 'package:darrt/helpers/consts.dart';
import 'package:darrt/app/services/mini_box.dart';
import 'package:darrt/app/services/object_box.dart';
import 'package:darrt/helpers/mini_logger.dart';
import 'package:workmanager/workmanager.dart';

@pragma('vm:entry-point')
void callBackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case mAutoBackup:
        try {
          await ObjectBox().init();
          MiniBox().initStorage();

          final isSignedIn = await GoogleSignInService().restoreGoogleAccount();
          if (!isSignedIn) throw GoogleClientNotAuthenticatedError();
          await BackupService().performBackup();
          await createBackupSuccessNotification();
          MiniBox().write(mLastBackupDate, DateTime.now());
          ObjectBox().close();
        } on InternetOffError catch (e) {
          MiniLogger.dp("internet off");
          await createBackupFailureNotification(e.userMessage!);
        } on GoogleClientNotAuthenticatedError catch (e) {
          MiniLogger.dp("client not authenticated");
          await createBackupFailureNotification(e.userMessage!);
        } catch (e, t) {
          MiniLogger.dp('${e.toString()}, type: ${e.runtimeType}');
          MiniLogger.dp(t.toString());
          await createBackupFailureNotification('Something went wrong');
        }

        break;
    }
    return Future.value(true);
  });
}

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
  ExistingWorkPolicy? existingWorkPolicy,
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
