import 'dart:ui';

import 'package:darrt/app/workmanger/workmanager_tasks.dart';
import 'package:darrt/helpers/consts.dart';
import 'package:flutter/cupertino.dart';
import 'package:workmanager/workmanager.dart';

@pragma('vm:entry-point')
void callBackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();
    switch (task) {
      case mAutoBackup:
        await WorkmanagerTasks.autoBackup();
        break;
      case mDailyQuoteNotif:
        await WorkmanagerTasks.dailyQuoteNotif();
        break;
    }
    return Future.value(true);
  });
}
