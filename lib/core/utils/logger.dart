import 'dart:developer' as developer;

/// Simple logging utility to replace print() statements
/// Uses dart:developer.log for production-safe logging
class Logger {
  static const String _prefix = '[Pro_Grocery]';

  /// Log info level messages
  static void info(String message, [String? name]) {
    developer.log(message, level: 800, name: name ?? '$_prefix.info');
  }

  /// Log debug level messages
  static void debug(String message, [String? name]) {
    developer.log(message, level: 500, name: name ?? '$_prefix.debug');
  }

  /// Log warning level messages
  static void warning(String message, [String? name]) {
    developer.log(message, level: 900, name: name ?? '$_prefix.warning');
  }

  /// Log error level messages
  static void error(String message, [String? name]) {
    developer.log(message, level: 1000, name: name ?? '$_prefix.error');
  }
}
