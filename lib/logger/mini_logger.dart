import 'package:logger/logger.dart';
import 'package:minimaltodo/global_utils.dart';

class MiniLogger {
  static final _logger = Logger();
  static final _format = 'EEE, dd MMM yyyy HH:mm';
  static void error(String message){
    _logger.e('[${formatDateWith(DateTime.now(), _format)}] $message');
  }
  static void info(String message){
    _logger.i('[${formatDateWith(DateTime.now(), _format)}] $message');
  }
  static void debug(String message){
    _logger.d('[${formatDateWith(DateTime.now(), _format)}] $message');
  }
}