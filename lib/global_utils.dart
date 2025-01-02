import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:minimaltodo/theme/app_theme.dart';
import 'package:toastification/toastification.dart';

///Show [Snackbar] when adding tasks, deleting them, marking them as done or undone.

showToast({
  Duration? duration = const Duration(milliseconds: 2000),
  required String title,
  String? description,
  Color? bgColor,
  Color? fgColor,
  AlignmentGeometry? alignment,
  ToastificationType? type,
}) {
  toastification.show(
    autoCloseDuration: duration,
    title: Text(
      title,
      style: const TextStyle(fontSize: 16),
    ),
    showIcon: false,
    description: description != null ?  Text(description) : null,
    backgroundColor: bgColor ?? Colors.white,
    foregroundColor: fgColor ?? AppTheme.primary,
    showProgressBar: false,
    animationDuration: const Duration(milliseconds: 300),
    alignment: alignment,
    type: type,
  );
}

///Validates the [notifyAt] object, if it is in only in future, after this minute.
bool isValidDateTime(DateTime notifyAt) {
  DateTime now = DateTime.now();
  return notifyAt.isAfter(now) &&
      (notifyAt.minute > now.minute ||
          notifyAt.hour > now.hour ||
          notifyAt.day > now.day ||
          notifyAt.month > now.month ||
          notifyAt.year > now.year);
}

///Takes a [DateTime] object and return formatted string as '12 Nov 12:00 AM'
///if the [notifyAt.year] is next year, it will return 12 Nov 2025 12:00 AM, with explicit year
String formatDateTime(DateTime notifyAt) {
  final now = DateTime.now();
  String format = notifyAt.year > now.year ? 'dd MMM yyyy' : 'dd MMM';
  return DateFormat(format).add_jm().format(notifyAt);
}

String formatTime(DateTime notifyAt){
  return DateFormat.jm().format(notifyAt); // This will automatically use system's format
}

String formatDate(DateTime notifyAt){
  return DateFormat('d MMMM').format(notifyAt);
}

const gap = SizedBox(height: 20, width: 10);

final Logger logger = Logger();
