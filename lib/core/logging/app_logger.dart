import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

final appLoggerProvider = Provider<AppLogger>((_) => AppLogger());

class AppLogger {
  AppLogger()
    : _logger = Logger(
        printer: PrettyPrinter(methodCount: 0, printEmojis: false),
      );

  final Logger _logger;

  void debug(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  void info(String message) => _logger.i(message);

  void warning(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  void error(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }
}
