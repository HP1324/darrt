import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/cupertino.dart';
import 'package:minimaltodo/app/exceptions.dart';
import 'package:minimaltodo/app/notification/notification_action_controller.dart';
import 'package:minimaltodo/app/services/backup_service.dart';
import 'package:minimaltodo/app/services/google_sign_in_service.dart';
import 'package:minimaltodo/helpers/consts.dart';
import 'package:minimaltodo/helpers/mini_box.dart';
import 'package:minimaltodo/helpers/mini_logger.dart';
import 'package:minimaltodo/helpers/object_box.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:workmanager/workmanager.dart';

@pragma('vm:entry-point')
void callBackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case mAutoBackup:
        try {
          await MiniBox().initStorage();
          final docsDir = await getApplicationDocumentsDirectory();
          final objectBoxDirPath = path.join(docsDir.path, 'objectbox');
          ObjectBox().initForAnotherIsolate(objectBoxDirPath);

          await GoogleSignInService().restoreGoogleAccount();
          await BackupService().performBackup();
          await createBackupSuccessNotification();
          ObjectBox().close();
        } on InternetOffError {
          debugPrint("internet off");
          await createBackupFailureNotification();
        } on GoogleClientNotAuthenticatedError {
          debugPrint("client not authenticated");
          final restored = await GoogleSignInService().restoreGoogleAccount();
          await createBackupFailureNotification();
          if(restored) await BackupService().performBackup();
        } catch (e, t) {
          MiniLogger.e('${e.toString()}, type: ${e.runtimeType}');
          MiniLogger.t(t.toString());
        }

        break;
    }
    return Future.value(true);
  });
}

Future<void> createBackupFailureNotification() async {
  await AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: 1,
      channelKey: notifChannelKey,
      title: 'Failed to backup data',
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
