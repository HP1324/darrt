import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart' show QuillController;
import 'package:flutter_quill_to_pdf/flutter_quill_to_pdf.dart';
import 'package:intl/intl.dart';
import 'package:darrt/app/ui/icon_color_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'consts.dart';
import 'package:pdf/widgets.dart' as pw;

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

DateTime getFirstDate() => mInitialDate;

DateTime getMaxDate() {
  return DateTime.now().add(Duration(days: maxExtentDateDays));
}

Future<List<pw.Font>> loadAllFonts() async {
  final fontPaths = [
    "assets/fonts/DejaVuSans-Bold.ttf",
    "assets/fonts/DejaVuSans-BoldOblique.ttf",
    "assets/fonts/DejaVuSans-ExtraLight.ttf",
    "assets/fonts/DejaVuSans-Oblique.ttf",
    "assets/fonts/DejaVuSans.ttf",
    "assets/fonts/DejaVuSansCondensed-Bold.ttf",
    "assets/fonts/DejaVuSansCondensed-BoldOblique.ttf",
    "assets/fonts/DejaVuSansCondensed-Oblique.ttf",
    "assets/fonts/DejaVuSansCondensed.ttf",
    "assets/fonts/Gabarito-Black.ttf",
    "assets/fonts/Gabarito-Bold.ttf",
    "assets/fonts/Gabarito-ExtraBold.ttf",
    "assets/fonts/Gabarito-Medium.ttf",
    "assets/fonts/Gabarito-Regular.ttf",
    "assets/fonts/Gabarito-SemiBold.ttf",
    "assets/fonts/Gabarito-VariableFont_wght.ttf",
    "assets/fonts/MonomaniacOne-Regular.ttf",
    "assets/fonts/NotoNaskhArabic-Bold.ttf",
    "assets/fonts/NotoNaskhArabic-Medium.ttf",
    "assets/fonts/NotoNaskhArabic-Regular.ttf",
    "assets/fonts/NotoNaskhArabic-SemiBold.ttf",
    "assets/fonts/NotoNaskhArabic-VariableFont_wght.ttf",
    "assets/fonts/NotoSans-Black.ttf",
    "assets/fonts/NotoSans-BlackItalic.ttf",
    "assets/fonts/NotoSans-Bold.ttf",
    "assets/fonts/NotoSans-BoldItalic.ttf",
    "assets/fonts/NotoSans-ExtraBold.ttf",
    "assets/fonts/NotoSans-ExtraBoldItalic.ttf",
    "assets/fonts/NotoSans-ExtraLight.ttf",
    "assets/fonts/NotoSans-ExtraLightItalic.ttf",
    "assets/fonts/NotoSans-Italic-VariableFont_wdth,wght.ttf",
    "assets/fonts/NotoSans-Italic.ttf",
    "assets/fonts/NotoSans-Light.ttf",
    "assets/fonts/NotoSans-LightItalic.ttf",
    "assets/fonts/NotoSans-Medium.ttf",
    "assets/fonts/NotoSans-MediumItalic.ttf",
    "assets/fonts/NotoSans-Regular.ttf",
    "assets/fonts/NotoSans-SemiBold.ttf",
    "assets/fonts/NotoSans-SemiBoldItalic.ttf",
    "assets/fonts/NotoSans-Thin.ttf",
    "assets/fonts/NotoSans-ThinItalic.ttf",
    "assets/fonts/NotoSans-VariableFont_wdth,wght.ttf",
    "assets/fonts/NotoSans_Condensed-Black.ttf",
    "assets/fonts/NotoSans_Condensed-BlackItalic.ttf",
    "assets/fonts/NotoSans_Condensed-Bold.ttf",
    "assets/fonts/NotoSans_Condensed-BoldItalic.ttf",
    "assets/fonts/NotoSans_Condensed-ExtraBold.ttf",
    "assets/fonts/NotoSans_Condensed-ExtraBoldItalic.ttf",
    "assets/fonts/NotoSans_Condensed-ExtraLight.ttf",
    "assets/fonts/NotoSans_Condensed-ExtraLightItalic.ttf",
    "assets/fonts/NotoSans_Condensed-Italic.ttf",
    "assets/fonts/NotoSans_Condensed-Light.ttf",
    "assets/fonts/NotoSans_Condensed-LightItalic.ttf",
    "assets/fonts/NotoSans_Condensed-Medium.ttf",
    "assets/fonts/NotoSans_Condensed-MediumItalic.ttf",
    "assets/fonts/NotoSans_Condensed-Regular.ttf",
    "assets/fonts/NotoSans_Condensed-SemiBold.ttf",
    "assets/fonts/NotoSans_Condensed-SemiBoldItalic.ttf",
    "assets/fonts/NotoSans_Condensed-Thin.ttf",
    "assets/fonts/NotoSans_Condensed-ThinItalic.ttf",
    "assets/fonts/NotoSans_ExtraCondensed-Black.ttf",
    "assets/fonts/NotoSans_ExtraCondensed-BlackItalic.ttf",
    "assets/fonts/NotoSans_ExtraCondensed-Bold.ttf",
    "assets/fonts/NotoSans_ExtraCondensed-BoldItalic.ttf",
    "assets/fonts/NotoSans_ExtraCondensed-ExtraBold.ttf",
    "assets/fonts/NotoSans_ExtraCondensed-ExtraBoldItalic.ttf",
    "assets/fonts/NotoSans_ExtraCondensed-ExtraLight.ttf",
    "assets/fonts/NotoSans_ExtraCondensed-ExtraLightItalic.ttf",
    "assets/fonts/NotoSans_ExtraCondensed-Italic.ttf",
    "assets/fonts/NotoSans_ExtraCondensed-Light.ttf",
    "assets/fonts/NotoSans_ExtraCondensed-LightItalic.ttf",
    "assets/fonts/NotoSans_ExtraCondensed-Medium.ttf",
    "assets/fonts/NotoSans_ExtraCondensed-MediumItalic.ttf",
    "assets/fonts/NotoSans_ExtraCondensed-Regular.ttf",
    "assets/fonts/NotoSans_ExtraCondensed-SemiBold.ttf",
    "assets/fonts/NotoSans_ExtraCondensed-SemiBoldItalic.ttf",
    "assets/fonts/NotoSans_ExtraCondensed-Thin.ttf",
    "assets/fonts/NotoSans_ExtraCondensed-ThinItalic.ttf",
    "assets/fonts/NotoSans_SemiCondensed-Black.ttf",
    "assets/fonts/NotoSans_SemiCondensed-BlackItalic.ttf",
    "assets/fonts/NotoSans_SemiCondensed-Bold.ttf",
    "assets/fonts/NotoSans_SemiCondensed-BoldItalic.ttf",
    "assets/fonts/NotoSans_SemiCondensed-ExtraBold.ttf",
    "assets/fonts/NotoSans_SemiCondensed-ExtraBoldItalic.ttf",
    "assets/fonts/NotoSans_SemiCondensed-ExtraLight.ttf",
    "assets/fonts/NotoSans_SemiCondensed-ExtraLightItalic.ttf",
    "assets/fonts/NotoSans_SemiCondensed-Italic.ttf",
    "assets/fonts/NotoSans_SemiCondensed-Light.ttf",
    "assets/fonts/NotoSans_SemiCondensed-LightItalic.ttf",
    "assets/fonts/NotoSans_SemiCondensed-Medium.ttf",
    "assets/fonts/NotoSans_SemiCondensed-MediumItalic.ttf",
    "assets/fonts/NotoSans_SemiCondensed-Regular.ttf",
    "assets/fonts/NotoSans_SemiCondensed-SemiBold.ttf",
    "assets/fonts/NotoSans_SemiCondensed-SemiBoldItalic.ttf",
    "assets/fonts/NotoSans_SemiCondensed-Thin.ttf",
    "assets/fonts/NotoSans_SemiCondensed-ThinItalic.ttf",
    "assets/fonts/NotoSerif-Black.ttf",
    "assets/fonts/NotoSerif-BlackItalic.ttf",
    "assets/fonts/NotoSerif-Bold.ttf",
    "assets/fonts/NotoSerif-BoldItalic.ttf",
    "assets/fonts/NotoSerif-ExtraBold.ttf",
    "assets/fonts/NotoSerif-ExtraBoldItalic.ttf",
    "assets/fonts/NotoSerif-ExtraLight.ttf",
    "assets/fonts/NotoSerif-ExtraLightItalic.ttf",
    "assets/fonts/NotoSerif-Italic-VariableFont_wdth,wght.ttf",
    "assets/fonts/NotoSerif-Italic.ttf",
    "assets/fonts/NotoSerif-Light.ttf",
    "assets/fonts/NotoSerif-LightItalic.ttf",
    "assets/fonts/NotoSerif-Medium.ttf",
    "assets/fonts/NotoSerif-MediumItalic.ttf",
    "assets/fonts/NotoSerif-Regular.ttf",
    "assets/fonts/NotoSerif-SemiBold.ttf",
    "assets/fonts/NotoSerif-SemiBoldItalic.ttf",
    "assets/fonts/NotoSerif-Thin.ttf",
    "assets/fonts/NotoSerif-ThinItalic.ttf",
    "assets/fonts/NotoSerif-VariableFont_wdth,wght.ttf",
    "assets/fonts/NotoSerif_Condensed-Black.ttf",
    "assets/fonts/NotoSerif_Condensed-BlackItalic.ttf",
    "assets/fonts/NotoSerif_Condensed-Bold.ttf",
    "assets/fonts/NotoSerif_Condensed-BoldItalic.ttf",
    "assets/fonts/NotoSerif_Condensed-ExtraBold.ttf",
    "assets/fonts/NotoSerif_Condensed-ExtraBoldItalic.ttf",
    "assets/fonts/NotoSerif_Condensed-ExtraLight.ttf",
    "assets/fonts/NotoSerif_Condensed-ExtraLightItalic.ttf",
    "assets/fonts/NotoSerif_Condensed-Italic.ttf",
    "assets/fonts/NotoSerif_Condensed-Light.ttf",
    "assets/fonts/NotoSerif_Condensed-LightItalic.ttf",
    "assets/fonts/NotoSerif_Condensed-Medium.ttf",
    "assets/fonts/NotoSerif_Condensed-MediumItalic.ttf",
    "assets/fonts/NotoSerif_Condensed-Regular.ttf",
    "assets/fonts/NotoSerif_Condensed-SemiBold.ttf",
    "assets/fonts/NotoSerif_Condensed-SemiBoldItalic.ttf",
    "assets/fonts/NotoSerif_Condensed-Thin.ttf",
    "assets/fonts/NotoSerif_Condensed-ThinItalic.ttf",
    "assets/fonts/NotoSerif_ExtraCondensed-Black.ttf",
    "assets/fonts/NotoSerif_ExtraCondensed-BlackItalic.ttf",
    "assets/fonts/NotoSerif_ExtraCondensed-Bold.ttf",
    "assets/fonts/NotoSerif_ExtraCondensed-BoldItalic.ttf",
    "assets/fonts/NotoSerif_ExtraCondensed-ExtraBold.ttf",
    "assets/fonts/NotoSerif_ExtraCondensed-ExtraBoldItalic.ttf",
    "assets/fonts/NotoSerif_ExtraCondensed-ExtraLight.ttf",
    "assets/fonts/NotoSerif_ExtraCondensed-ExtraLightItalic.ttf",
    "assets/fonts/NotoSerif_ExtraCondensed-Italic.ttf",
    "assets/fonts/NotoSerif_ExtraCondensed-Light.ttf",
    "assets/fonts/NotoSerif_ExtraCondensed-LightItalic.ttf",
    "assets/fonts/NotoSerif_ExtraCondensed-Medium.ttf",
    "assets/fonts/NotoSerif_ExtraCondensed-MediumItalic.ttf",
    "assets/fonts/NotoSerif_ExtraCondensed-Regular.ttf",
    "assets/fonts/NotoSerif_ExtraCondensed-SemiBold.ttf",
    "assets/fonts/NotoSerif_ExtraCondensed-SemiBoldItalic.ttf",
    "assets/fonts/NotoSerif_ExtraCondensed-Thin.ttf",
    "assets/fonts/NotoSerif_ExtraCondensed-ThinItalic.ttf",
    "assets/fonts/NotoSerif_SemiCondensed-Black.ttf",
    "assets/fonts/NotoSerif_SemiCondensed-BlackItalic.ttf",
    "assets/fonts/NotoSerif_SemiCondensed-Bold.ttf",
    "assets/fonts/NotoSerif_SemiCondensed-BoldItalic.ttf",
    "assets/fonts/NotoSerif_SemiCondensed-ExtraBold.ttf",
    "assets/fonts/NotoSerif_SemiCondensed-ExtraBoldItalic.ttf",
    "assets/fonts/NotoSerif_SemiCondensed-ExtraLight.ttf",
    "assets/fonts/NotoSerif_SemiCondensed-ExtraLightItalic.ttf",
    "assets/fonts/NotoSerif_SemiCondensed-Italic.ttf",
    "assets/fonts/NotoSerif_SemiCondensed-Light.ttf",
    "assets/fonts/NotoSerif_SemiCondensed-LightItalic.ttf",
    "assets/fonts/NotoSerif_SemiCondensed-Medium.ttf",
    "assets/fonts/NotoSerif_SemiCondensed-MediumItalic.ttf",
    "assets/fonts/NotoSerif_SemiCondensed-Regular.ttf",
    "assets/fonts/NotoSerif_SemiCondensed-SemiBold.ttf",
    "assets/fonts/NotoSerif_SemiCondensed-SemiBoldItalic.ttf",
    "assets/fonts/Roboto-Black.ttf",
    "assets/fonts/Roboto-BlackItalic.ttf",
    "assets/fonts/Roboto-Bold.ttf",
    "assets/fonts/Roboto-BoldItalic.ttf",
    "assets/fonts/Roboto-ExtraBold.ttf",
    "assets/fonts/Roboto-ExtraBoldItalic.ttf",
    "assets/fonts/Roboto-ExtraLight.ttf",
    "assets/fonts/Roboto-ExtraLightItalic.ttf",
    "assets/fonts/Roboto-Italic-VariableFont_wdth,wght.ttf",
    "assets/fonts/Roboto-Italic.ttf",
    "assets/fonts/Roboto-Light.ttf",
    "assets/fonts/Roboto-LightItalic.ttf",
    "assets/fonts/Roboto-Medium.ttf",
    "assets/fonts/Roboto-MediumItalic.ttf",
    "assets/fonts/Roboto-Regular.ttf",
    "assets/fonts/Roboto-SemiBold.ttf",
    "assets/fonts/Roboto-SemiBoldItalic.ttf",
    "assets/fonts/Roboto-Thin.ttf",
    "assets/fonts/Roboto-ThinItalic.ttf",
    "assets/fonts/Roboto-VariableFont_wdth,wght.ttf",
    "assets/fonts/Roboto_Condensed-Black.ttf",
    "assets/fonts/Roboto_Condensed-BlackItalic.ttf",
    "assets/fonts/Roboto_Condensed-Bold.ttf",
    "assets/fonts/Roboto_Condensed-BoldItalic.ttf",
    "assets/fonts/Roboto_Condensed-ExtraBold.ttf",
    "assets/fonts/Roboto_Condensed-ExtraBoldItalic.ttf",
    "assets/fonts/Roboto_Condensed-ExtraLight.ttf",
    "assets/fonts/Roboto_Condensed-ExtraLightItalic.ttf",
    "assets/fonts/Roboto_Condensed-Italic.ttf",
    "assets/fonts/Roboto_Condensed-Light.ttf",
    "assets/fonts/Roboto_Condensed-LightItalic.ttf",
    "assets/fonts/Roboto_Condensed-Medium.ttf",
    "assets/fonts/Roboto_Condensed-MediumItalic.ttf",
    "assets/fonts/Roboto_Condensed-Regular.ttf",
    "assets/fonts/Roboto_Condensed-SemiBold.ttf",
    "assets/fonts/Roboto_Condensed-SemiBoldItalic.ttf",
    "assets/fonts/Roboto_Condensed-Thin.ttf",
    "assets/fonts/Roboto_Condensed-ThinItalic.ttf",
    "assets/fonts/Roboto_SemiCondensed-Black.ttf",
    "assets/fonts/Roboto_SemiCondensed-BlackItalic.ttf",
    "assets/fonts/Roboto_SemiCondensed-Bold.ttf",
    "assets/fonts/Roboto_SemiCondensed-BoldItalic.ttf",
    "assets/fonts/Roboto_SemiCondensed-ExtraBold.ttf",
    "assets/fonts/Roboto_SemiCondensed-ExtraBoldItalic.ttf",
    "assets/fonts/Roboto_SemiCondensed-ExtraLight.ttf",
    "assets/fonts/Roboto_SemiCondensed-ExtraLightItalic.ttf",
    "assets/fonts/Roboto_SemiCondensed-Italic.ttf",
    "assets/fonts/Roboto_SemiCondensed-Light.ttf",
    "assets/fonts/Roboto_SemiCondensed-LightItalic.ttf",
    "assets/fonts/Roboto_SemiCondensed-Medium.ttf",
    "assets/fonts/Roboto_SemiCondensed-MediumItalic.ttf",
    "assets/fonts/Roboto_SemiCondensed-Regular.ttf",
    "assets/fonts/Roboto_SemiCondensed-SemiBold.ttf",
    "assets/fonts/Roboto_SemiCondensed-SemiBoldItalic.ttf",
    "assets/fonts/Roboto_SemiCondensed-Thin.ttf",
    "assets/fonts/Roboto_SemiCondensed-ThinItalic.ttf",
  ];

  final fontByteDataFutures = fontPaths.map(rootBundle.load);
  final fontByteDatas = await Future.wait(fontByteDataFutures);
  final fonts = fontByteDatas.map((b) => pw.Font.ttf(b)).toList();

  return fonts;
}

Future<Uint8List> generateNotePdf(QuillController controller) async {
  if (controller.document.isEmpty()) return noteEmptyErrorBytes;

  final pdfPageFormat = PDFPageFormat.a4;
  final fontFallBacks = await loadAllFonts();
  final pdfConverter = PDFConverter(
    document: controller.document.toDelta(),
    pageFormat: pdfPageFormat,
    fallbacks: fontFallBacks,
  );

  final doc = await pdfConverter.createDocument();
  return doc!.save();
}

Future<void> savePdfToDownloads(Uint8List pdfBytes, String fileName) async {
  if (Platform.isAndroid) {
    const platform = MethodChannel('com.hp.darrt/pdf_saver');
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

Color getSurfaceColor(BuildContext context) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;
  Color backgroundColorHSV = isDark
      ? Color(0xFF1E1E1E)
      : theme.colorScheme.surface;
  return backgroundColorHSV;
}

Color getLerpedSurfaceColor(BuildContext context) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;
  final scheme = theme.colorScheme;
  Color backgroundColorHSV = isDark
      ? HSVColor.fromColor(Color.lerp(scheme.surface, scheme.primary, 0.07)!).toColor()
      : HSVColor.fromColor(Color.lerp(Colors.white, scheme.primary, 0.05)!).toColor();
  return backgroundColorHSV;
}
