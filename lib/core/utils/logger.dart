import 'dart:developer' as developer;

/// Structured logging utility with environment-aware log suppression.
/// Debug logs are only emitted in debug/profile builds.
class Logger {
  static const String _prefix = '[Pro_Grocery]';
  static bool _debugEnabled = true;

  /// Enable or disable debug-level logging (call after EnvConfig.init())
  static void setDebugEnabled(bool enabled) {
    _debugEnabled = enabled;
  }

  /// Log info level messages (always emitted)
  static void info(String message, [String? name]) {
    developer.log(message, level: 800, name: name ?? '$_prefix.info');
  }

  /// Log debug level messages (suppressed in release builds by default)
  static void debug(String message, [String? name]) {
    if (!_debugEnabled) return;
    developer.log(message, level: 500, name: name ?? '$_prefix.debug');
  }

  /// Log warning level messages (always emitted)
  static void warning(String message, [String? name]) {
    developer.log(message, level: 900, name: name ?? '$_prefix.warning');
  }

  /// Log error level messages (always emitted, includes stack trace hint)
  static void error(String message,
      [String? name, Object? error, StackTrace? stackTrace]) {
    developer.log(
      '$message${error != null ? ' | error: $error' : ''}',
      level: 1000,
      name: name ?? '$_prefix.error',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
