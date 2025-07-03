import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart' show QuillController;
import 'package:flutter_quill_to_pdf/flutter_quill_to_pdf.dart';
import 'package:intl/intl.dart';
import 'package:minimaltodo/app/ui/icon_color_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:toastification/toastification.dart';
import 'consts.dart';

void showToast(
  BuildContext context, {
  required ToastificationType type,
  required String description,
  Duration? duration,
  Alignment? alignment,
}) {
  toastification.show(
    context: context,
    description: Text(description),
    type: type,
    autoCloseDuration: duration ?? const Duration(milliseconds: 1500),
    alignment: alignment ?? Alignment.bottomCenter,
  );
}

(Offset, Size) getOffsetAndSize(GlobalKey key) {
  Offset offset = Offset.zero;
  Size size = Size.zero;
  if (key.currentContext != null) {
    final RenderBox renderBox = key.currentContext!.findRenderObject() as RenderBox;
    offset = renderBox.localToGlobal(Offset.zero);
    size = renderBox.size;
  }
  return (offset, size);
}

RelativeRect getRelativeRectFromOffsetAndSize(Offset offset, Size size) {
  return RelativeRect.fromLTRB(
    offset.dx,
    offset.dy + size.height,
    offset.dx + size.width,
    offset.dy,
  );
}

String formatTime(TimeOfDay time) {
  final now = DateTime.now();
  final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
  return DateFormat.jm().format(dt); // "5:30 PM" format
}

String formatDate(DateTime date, String format) => DateFormat(format).add_jm().format(date);

String formatDateNoJm(DateTime date, String format) => DateFormat(format).format(date);
String formatDateAndTime(DateTime dateTime, String format) {
  return DateFormat(format).add_jm().format(dateTime);
}

DateTime getFirstDate() =>mInitialDate;

DateTime getMaxDate() {
  return DateTime.now().add(Duration(days: maxExtentDateDays));
}

Future<Uint8List> generateNotePdf(QuillController controller) async {
  if (controller.document.isEmpty()) return noteEmptyErrorBytes;

  final pdfPageFormat = PDFPageFormat.a4;
  final pdfConverter = PDFConverter(
    document: controller.document.toDelta(),
    pageFormat: pdfPageFormat,
    fallbacks: [],
  );

  final doc = await pdfConverter.createDocument();
  return doc!.save();
}

Future<void> savePdfToDownloads(Uint8List pdfBytes, String fileName) async {
  if (Platform.isAndroid) {
    const platform = MethodChannel('com.hp.minimaltodo/pdf_saver');
    await platform.invokeMethod('savePdfToDownloads', {
      'filename': fileName,
      'bytes': pdfBytes,
    });
  }
}

void showIconPicker(BuildContext context, {required Function(String) onIconSelected}) {
  showDialog(
    context: context,
    builder: (context) => IconPickerDialog(onIconSelected: onIconSelected),
  );
}

void showColorPicker(BuildContext context, {required Function(String) onColorSelected}) {
  showDialog(
    context: context,
    builder: (context) => ColorPickerDialog(onColorSelected: onColorSelected),
  );
}

void showSettingsDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Permissions Required'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'To use speech-to-text functionality, please allow the following permissions:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 12),
              Text('• Microphone: Required to capture your voice input'),
              SizedBox(height: 8),
              Text(
                '• Nearby devices (Android 12+): Required when using Bluetooth headsets or external microphones',
              ),
              SizedBox(height: 12),
              Text(
                'Go to Settings > Permissions and enable both Microphone and Nearby devices permissions.',
                style: TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await openAppSettings();
            },
            child: Text('Settings'),
          ),
        ],
      );
    },
  );
}
