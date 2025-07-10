//ignore_for_file: curly_braces_in_flow_control_structures
import 'dart:ui';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:googleapis/networkservices/v1.dart';
import 'package:minimaltodo/app/exceptions.dart';
import 'package:minimaltodo/app/notification/notification_action_controller.dart';
import 'package:minimaltodo/app/services/backup_service.dart';
import 'package:minimaltodo/app/services/google_sign_in_service.dart';
import 'package:minimaltodo/helpers/consts.dart';
import 'package:minimaltodo/app/services/mini_box.dart';
import 'package:minimaltodo/app/services/object_box.dart';
import 'package:objectbox/objectbox.dart';
import 'package:objectbox_flutter_libs/objectbox_flutter_libs.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:workmanager/workmanager.dart';

@pragma('vm:entry-point')
void callBackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case mAutoBackup:
        try {
          final state = WidgetsBinding.instance.lifecycleState;
          debugPrint("App state right now: $state");

          final docsDir = await getApplicationDocumentsDirectory();
          // final objectBoxDirPath = path.join(docsDir.path, 'objectbox');
          final objectBoxDirPath = (await defaultStoreDirectory()).path;

          final rootIsolateToken = ServicesBinding.rootIsolateToken;
          // await ObjectBox().init();
          // if (!Store.isOpen(objectBoxDirPath)) {
          //   ObjectBox().initForAnotherIsolate(objectBoxDirPath);
          // } else {
          //   loadObjectBoxLibraryAndroidCompat();
          //   ObjectBox().init();
          // }
          // if(Store.)
          // await ObjectBox().initForAnotherIsolate(objectBoxDirPath);
          await ObjectBox().init();
          MiniBox().initStorage();

          final isSignedIn = await GoogleSignInService().restoreGoogleAccount();
          if (!isSignedIn) throw GoogleClientNotAuthenticatedError();
          await BackupService().performBackup();
          await createBackupSuccessNotification();
          MiniBox().write(mLastBackupDate, DateTime.now());
          ObjectBox().close();
        } on InternetOffError catch (e) {
          debugPrint("internet off");
          await createBackupFailureNotification(e.userMessage!);
        } on GoogleClientNotAuthenticatedError catch (e) {
          debugPrint("client not authenticated");
          await createBackupFailureNotification(e.userMessage!);
        } catch (e, t) {
          debugPrint('${e.toString()}, type: ${e.runtimeType}');
          debugPrint(t.toString());
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
