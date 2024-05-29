import 'dart:developer';

import 'package:intl/intl.dart';

class _LogImpl {
  void debug(String message) {
    logImpl(message, 'DEBUG');
  }

  void info(String message) {
    logImpl(message, 'INFO');
  }

  void warn(String message) {
    logImpl(message, 'WARN');
  }

  void error(String message) {
    logImpl(message, 'ERROR');
  }

  void logImpl(String message, String type) {
    DateTime now = DateTime.now();
    String formattedTimestamp = DateFormat('yyyy:HH:mm:ss:SSS').format(now);
    final msg = '$formattedTimestamp [$type] $message';
    log(msg);
  }
}

final logger = _LogImpl();
