import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';

/// Represents different layers of the application for structured logging.
enum LogLayer { ui, controller, repository, service, core }

/// Centralized logger for consistent logging format and release builds suppression.
class AppLogger {
  static void _log(
    String level,
    LogLayer layer,
    String className,
    String methodName,
    String operation,
    String status, {
    dynamic error,
    StackTrace? stack,
  }) {
    if (kReleaseMode) {
      // In production release builds, suppress standard console logging.
      return;
    }

    final String time = DateTime.now().toIso8601String().substring(11, 23);
    final String layerStr = layer.name.toUpperCase();
    final String location = className.isNotEmpty
        ? (methodName.isNotEmpty ? "$className.$methodName" : className)
        : (methodName.isNotEmpty ? methodName : "System");
    final String errStr = error != null ? " | ERROR: $error" : "";

    final String message = "[$time] [$layerStr] [$location] -> $operation ($status)$errStr";

    dev.log(
      message,
      name: 'OM_EVENT',
      time: DateTime.now(),
      error: error,
      stackTrace: stack,
    );
  }

  /// Logs debug level information.
  static void debug(
    String operation, {
    LogLayer layer = LogLayer.core,
    String className = '',
    String methodName = '',
    String status = 'SUCCESS',
  }) {
    _log('DEBUG', layer, className, methodName, operation, status);
  }

  /// Logs general informational messages.
  static void info(
    String operation, {
    LogLayer layer = LogLayer.core,
    String className = '',
    String methodName = '',
    String status = 'SUCCESS',
  }) {
    _log('INFO', layer, className, methodName, operation, status);
  }

  /// Logs a successful operation.
  static void success(
    String operation, {
    LogLayer layer = LogLayer.core,
    String className = '',
    String methodName = '',
  }) {
    _log('SUCCESS', layer, className, methodName, operation, 'SUCCESS');
  }

  /// Logs warning messages when operations succeed with issues or recovery.
  static void warning(
    String operation, {
    LogLayer layer = LogLayer.core,
    String className = '',
    String methodName = '',
    String status = 'WARNING',
    dynamic error,
    StackTrace? stack,
  }) {
    _log('WARNING', layer, className, methodName, operation, status, error: error, stack: stack);
  }

  /// Logs failures, errors, and uncaught exceptions with positional arguments.
  static void error(
    String operation, [
    dynamic error,
    StackTrace? stack,
  ]) {
    _log('ERROR', LogLayer.core, '', '', operation, 'FAILURE', error: error, stack: stack);
  }

  /// Logs failures, errors, and uncaught exceptions with structured details.
  static void errorDetailed(
    String operation, {
    required LogLayer layer,
    required String className,
    required String methodName,
    dynamic error,
    StackTrace? stack,
    String status = 'FAILURE',
  }) {
    _log('ERROR', layer, className, methodName, operation, status, error: error, stack: stack);
  }
}
