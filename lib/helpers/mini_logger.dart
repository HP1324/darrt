import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class MiniLogger {
  static final _logger = Logger(
    printer: PrettyPrinter(methodCount: null, dateTimeFormat: DateTimeFormat.dateAndTime),
  );
  static void e(String message) {
    _logger.e(message);
  }

  static void i(String message) {
    _logger.i(message);
  }

  static void d(String message) {
    _logger.d(message);
  }

  static void t(String stacktrace) {
    _logger.t('[StackTrace: $stacktrace');
  }
  static void w(String message){
    _logger.w(message);
  }

  /// Just [MiniLogger.dp] guarded with [kDebugMode]
  static void dp(String message){
    if(kDebugMode){
      MiniLogger.dp(message);
    }
  }
}
