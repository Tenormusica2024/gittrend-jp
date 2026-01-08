import 'package:flutter/foundation.dart';

enum LogLevel { debug, info, warning, error }

class Logger {
  static final Map<LogLevel, String> _levelPrefixes = {
    LogLevel.debug: 'DEBUG',
    LogLevel.info: 'INFO',
    LogLevel.warning: 'WARN',
    LogLevel.error: 'ERROR',
  };

  static void _log(LogLevel level, String tag, String message, [dynamic error, StackTrace? stack]) {
    if (!kDebugMode && level == LogLevel.debug) return;

    final timestamp = DateTime.now().toIso8601String();
    final prefix = _levelPrefixes[level];
    
    print('[$timestamp] $prefix [$tag] $message');
    
    if (error != null) {
      print('  Error: $error');
    }
    
    if (stack != null && (level == LogLevel.error || level == LogLevel.warning)) {
      final stackLines = stack.toString().split('\n').take(5).join('\n  ');
      print('  Stack:\n  $stackLines');
    }
  }

  static void debug(String tag, String message) {
    _log(LogLevel.debug, tag, message);
  }

  static void info(String tag, String message) {
    _log(LogLevel.info, tag, message);
  }

  static void warning(String tag, String message, [dynamic error, StackTrace? stack]) {
    _log(LogLevel.warning, tag, message, error, stack);
  }

  static void error(String tag, String message, [dynamic error, StackTrace? stack]) {
    _log(LogLevel.error, tag, message, error, stack);
  }
}
