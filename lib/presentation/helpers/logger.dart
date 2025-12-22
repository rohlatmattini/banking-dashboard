
// lib/helpers/logger.dart
class Logger {
  void log(String message) {
    print('[LOG] ${DateTime.now().toIso8601String()}: $message');
  }

  void error(String message) {
    print('[ERROR] ${DateTime.now().toIso8601String()}: $message');
  }

  void info(String message) {
    print('[INFO] ${DateTime.now().toIso8601String()}: $message');
  }

  void debug(String message) {
    print('[DEBUG] ${DateTime.now().toIso8601String()}: $message');
  }

  void warning(String message) {
    print('[WARNING] ${DateTime.now().toIso8601String()}: $message');
  }
}