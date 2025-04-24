import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:toastification/toastification.dart';


class Utils{
  static void showToast(BuildContext context,{required ToastificationType type, required String description}){
    toastification.show(
        context: context,
        description: Text(description),
        type: type,
        autoCloseDuration: Duration(milliseconds: 1800),
        alignment: Alignment.bottomCenter
    );
  }
  static (Offset, Size) getPositionAndSize(GlobalKey key) {
    Offset position = Offset.zero;
    Size size = Size.zero;
    if (key.currentContext != null) {
      final RenderBox renderBox = key.currentContext!.findRenderObject() as RenderBox;
      position = renderBox.localToGlobal(Offset.zero);
      size = renderBox.size;
    }
    return (position, size);
  }

  static formatTime(TimeOfDay time){
    final date = DateTime(2023, 1, 1, time.hour, time.minute);
    return DateFormat().add_jm().format(date);
  }
  static formatDate(DateTime date, String format){
    return DateFormat(format).format(date);
  }
}

