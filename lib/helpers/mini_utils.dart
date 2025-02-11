import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:toastification/toastification.dart';

///Show [Snackbar] when adding tasks, deleting them, marking them as done or undone.

void showToast({
  required BuildContext context,
  required String title,
  String? description,
  Duration duration = const Duration(milliseconds: 1400),
  ToastificationType type = ToastificationType.success,
  AlignmentGeometry alignment = Alignment.bottomCenter,
}) {
  final colorScheme = Theme.of(context).colorScheme;
  final textTheme = Theme.of(context).textTheme;

  toastification.show(
    context: context,
    title: Text(
      title,
      style: textTheme.bodyMedium?.copyWith(
        color: type == ToastificationType.error
            ? colorScheme.error
            : colorScheme.onSurface,
        fontWeight: FontWeight.w500,

      ),
      maxLines: null,
    ),
    description: description != null
        ? Text(
            description,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          )
        : null,
    type: type,
    style: ToastificationStyle.minimal,
    autoCloseDuration: duration,
    showProgressBar: false,
    dragToClose: true,
    closeButtonShowType: CloseButtonShowType.onHover,
    closeOnClick: true,
    alignment: alignment,
    animationDuration: const Duration(milliseconds: 200),
    backgroundColor: colorScheme.surfaceContainerHighest.withAlpha(240),
    borderRadius: BorderRadius.circular(8),
    boxShadow: [
      BoxShadow(
        color: colorScheme.shadow.withAlpha(20),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
    showIcon: true,
    primaryColor: type == ToastificationType.error
        ? colorScheme.error
        : type == ToastificationType.warning
            ? colorScheme.tertiary
            : colorScheme.primary,
  );
}

String formatTime(DateTime notifyAt) {
  return DateFormat.jm()
      .format(notifyAt); // This will automatically use system's format
}

String formatDateWith(DateTime dateTime, String format) {
  return DateFormat(format).format(dateTime);
}


final Logger logger = Logger();

///Had to calculate the InkWell's position because showMenu does not give direct control for placing the popup menu under the button directly. So I calculated the InkWell's position on the screen and passed it as arguments to [RelativeRect.fromLTRB()].
///Using dart records feature to return position and size both
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
