import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:minimaltodo/helpers/mini_box.dart';
import 'package:toastification/toastification.dart';

import 'consts.dart';


  void showToast(BuildContext context,{required ToastificationType type, required String description}){
    toastification.show(
        context: context,
        description: Text(description),
        type: type,
        autoCloseDuration: Duration(milliseconds: 1800),
        alignment: Alignment.bottomCenter
    );
  }
  (Offset, Size) getPositionAndSize(GlobalKey key) {
    Offset position = Offset.zero;
    Size size = Size.zero;
    if (key.currentContext != null) {
      final RenderBox renderBox = key.currentContext!.findRenderObject() as RenderBox;
      position = renderBox.localToGlobal(Offset.zero);
      size = renderBox.size;
    }
    return (position, size);
  }
String formatTime(TimeOfDay time) {
  final now = DateTime.now();
  final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
  return DateFormat.jm().format(dt); // "5:30 PM" format
}

  String formatDate(DateTime date, String format)=> DateFormat(format).format(date);

  DateTime getFirstDate(){
    return DateTime.fromMillisecondsSinceEpoch(MiniBox.read(mFirstInstallDate))
        .subtract(const Duration(days: 365));
  }

  DateTime getMaxDate(){
    return DateTime.now().add(Duration(days: maxExtentDateDays));
  }


