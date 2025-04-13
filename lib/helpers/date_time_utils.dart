import 'package:intl/intl.dart' show DateFormat;

class DateTimeUtils{
  String formatDateWith(DateTime dateTime, String format) {
    return DateFormat(format).format(dateTime);
  }
}