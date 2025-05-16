import 'dart:io' show File, Platform;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart' show QuillController;
import 'package:flutter_quill_to_pdf/flutter_quill_to_pdf.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:minimaltodo/helpers/mini_box.dart';
import 'package:path_provider/path_provider.dart'
    show getApplicationDocumentsDirectory, getExternalStorageDirectory, getTemporaryDirectory;
import 'package:pdf/pdf.dart' show PdfColor, PdfPageFormat;
import 'package:toastification/toastification.dart';
import 'package:pdf/widgets.dart' as pw;

import 'consts.dart';

final getIt = GetIt.instance;

void showToast(BuildContext context,
    {required ToastificationType type, required String description, Duration? duration}) {
  toastification.show(
    context: context,
    description: Text(description),
    type: type,
    autoCloseDuration: duration ?? const Duration(milliseconds: 1800),
    alignment: Alignment.bottomCenter,
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

String formatDate(DateTime date, String format) => DateFormat(format).format(date);

String formatDateAndTime(DateTime dateTime, String format) {
  return DateFormat(format).add_jm().format(dateTime);
}

DateTime getFirstDate() {
  return DateTime.fromMillisecondsSinceEpoch(MiniBox.read(mFirstInstallDate))
      .subtract(const Duration(days: 365));
}

DateTime getMaxDate() {
  return DateTime.now().add(Duration(days: maxExtentDateDays));
}

Future<Uint8List> generateNotePdf(QuillController controller) async {
  final pdfPageFormat = PDFPageFormat.a4;
  final pdfConverter = PDFConverter(
    document: controller.document.toDelta(),
    pageFormat: pdfPageFormat,
    fallbacks: [],
  );

  final doc = await pdfConverter.createDocument();
  final pw.Widget? widget = await pdfConverter.generateWidget(
    maxHeight: pdfPageFormat.height,
    maxWidth: pdfPageFormat.width,
  );
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

PdfColor _hexToPdfColor(String hex) {
  final buffer = StringBuffer();
  if (hex.length == 6 || hex.length == 7) buffer.write('ff');
  buffer.write(hex.replaceFirst('#', ''));
  final colorInt = int.parse(buffer.toString(), radix: 16);
  return PdfColor.fromInt(colorInt);
}
