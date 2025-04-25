import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:toastification/toastification.dart';


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

  String formatTime(TimeOfDay time) => DateFormat().add_jm().format(DateTime(time.hour, time.minute));

  String formatDate(DateTime date, String format)=> DateFormat(format).format(date);


