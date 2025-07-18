import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

final errorType = ToastificationType.error;
final successType = ToastificationType.success;
final warningType = ToastificationType.warning;
const alignment = Alignment.bottomCenter;
const duration = Duration(milliseconds: 1500);

void showToast(
  BuildContext context,
  ToastificationType type,
  String description, [
  Duration? closeDuration = duration,
  Alignment? alignment = alignment,
]) {
  toastification.show(
    context: context,
    description: Text(description),
    type: type,
    autoCloseDuration: closeDuration,
    alignment: alignment,
  );
}

void showErrorToast(BuildContext context, String message) =>
    showToast(context, errorType, message);

void showSuccessToast(BuildContext context, String message) =>
    showToast(context, successType, message);

void showWarningToast(BuildContext context, String message) =>
    showToast(context, warningType, message);
