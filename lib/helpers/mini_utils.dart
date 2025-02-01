import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

///Show [Snackbar] when adding tasks, deleting them, marking them as done or undone.

// showToast({
//   BuildContext? context,
//   Duration? duration = const Duration(milliseconds: 2000),
//   required String title,
//   String? description,
//   AlignmentGeometry? alignment,
//   ToastificationType? type,
// }) {
//   toastification.show(
//     context: context,
//     autoCloseDuration: duration,
//     title: Text(title),
//     showIcon: false,
//     description: description != null ? Text(description) : null,
//     showProgressBar: false,
//     animationDuration: const Duration(milliseconds: 300),
//     alignment: Alignment.bottomCenter,
//     type: type,
//   );
// }

///Validates the [notifyAt] object, if it is in only in future, after this minute.
bool isValidDateTime(DateTime notifyAt) {
  DateTime now = DateTime.now();
  return notifyAt.isAfter(now) &&
      (notifyAt.minute > now.minute || notifyAt.hour > now.hour || notifyAt.day > now.day || notifyAt.month > now.month || notifyAt.year > now.year);
}

///Takes a [DateTime] object and return formatted string as '12 Nov 12:00 AM'
///if the [notifyAt.year] is next year, it will return 12 Nov 2025 12:00 AM, with explicit year
String formatDateTime(DateTime dateTime) {
  final now = DateTime.now();
  logger.d('DateTime $dateTime');
  String format = dateTime.year > now.year ? 'dd MMM yyyy' : 'dd MMM';
  return DateFormat(format).add_jm().format(dateTime);
}

String formatTime(DateTime notifyAt) {
  return DateFormat.jm().format(notifyAt); // This will automatically use system's format
}

String formatDate(DateTime notifyAt) {
  return DateFormat('d MMMM').format(notifyAt);
}

String formatDateWith(DateTime dateTime, String format) {
  return DateFormat(format).format(dateTime);
}

const gap = SizedBox(height: 20, width: 10);

final Logger logger = Logger();

///Had to calculate the InkWell's position because showMenu does not give direct control for placing the popup menu under the button directly. So I calculated the InkWell's position on the screen and passed it as arguments to [RelativeRect.fromLTRB()].
///Using dart records feature to return position and size both
(Offset, Size) getPositionAndSize(GlobalKey key){
  Offset position = Offset.zero;
  Size size = Size.zero;
  if(key.currentContext != null) {
    final RenderBox renderBox = key.currentContext!.findRenderObject() as RenderBox;
    position = renderBox.localToGlobal(Offset.zero);
    size = renderBox.size;
  }
  return (position, size);
}