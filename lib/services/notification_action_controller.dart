

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:minimaltodo/data_models/task.dart';
import 'package:minimaltodo/helpers/mini_logger.dart';
import 'package:minimaltodo/main.dart';
import 'package:minimaltodo/views/pages/single_task_view.dart';

typedef FinishedActionCallback = Future<int> Function(Task,bool,DateTime);

@pragma("vm:entry-point")
class NotificationActionController{
  static FinishedActionCallback? finishedAction;
  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {
    //Get Task object from notification payload
    Task taskObject = TaskUtilities.fromNotificationPayload(receivedAction.payload ?? {});
    
    if(receivedAction.buttonKeyPressed == 'FINISHED'){
      MiniLogger.debug('Finished pressed');
      await finishedAction?.call(taskObject, true, DateTime.now());
      // await TaskService.toggleDone(taskObject.id!, true, DateTime.now());
    }else {
      MinimalTodo.navigatorKey.currentState?.push(MaterialPageRoute(builder: (_) => TaskView(task: taskObject)));
    }
  }

}