import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import '../../firebase_options.dart';
import '../utils/app_logger.dart';

/// Central asynchronous orchestrator for non-essential core platform services.
///
/// Ensures [Firebase] and [SharedPreferences] initialize concurrently in the
/// background WITHOUT blocking the immediate display of the initial Flutter frame
/// or the video splash screen.
class AppBootstrapService {
  AppBootstrapService._();

  static Completer<void>? _initCompleter;
  static bool _isInitialized = false;

  /// Returns whether non-essential core platform services have finished initializing.
  static bool get isInitialized => _isInitialized;

  /// Kicks off background core initialization without awaiting or blocking callers.
  static Future<void> start() {
    if (_initCompleter != null) {
      return _initCompleter!.future;
    }
    _initCompleter = Completer<void>();
    _runAsyncInit();
    return _initCompleter!.future;
  }

  /// Ensures background initialization completes with a safety timeout.
  static Future<void> ensureInitialized({
    Duration timeout = const Duration(seconds: 4),
  }) async {
    try {
      await start().timeout(
        timeout,
        onTimeout: () {
          AppLogger.warning(
            'Core services initialization exceeded ${timeout.inSeconds}s timeout; proceeding gracefully',
            className: 'AppBootstrapService',
            methodName: 'ensureInitialized',
          );
        },
      );
    } catch (e) {
      AppLogger.error(
        'Core services initialization error caught during ensureInitialized: $e',
      );
    }
  }

  static Future<void> _runAsyncInit() async {
    final stopwatch = Stopwatch()..start();
    try {
      AppLogger.info(
        'Starting non-blocking core services initialization',
        className: 'AppBootstrapService',
        methodName: '_runAsyncInit',
      );

      await Future.wait([
        _initSharedPreferences(),
        _initFirebase(),
      ]);

      _isInitialized = true;
      AppLogger.success(
        'Core services initialized in ${stopwatch.elapsedMilliseconds}ms',
        className: 'AppBootstrapService',
        methodName: '_runAsyncInit',
      );
    } catch (e) {
      AppLogger.error(
        'Unexpected error during background core services initialization: $e',
      );
    } finally {
      if (_initCompleter != null && !_initCompleter!.isCompleted) {
        _initCompleter!.complete();
      }
    }
  }

  static Future<void> _initSharedPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!Get.isRegistered<SharedPreferences>()) {
        Get.put<SharedPreferences>(prefs, permanent: true);
      }
    } catch (e) {
      AppLogger.error('SharedPreferences background initialization error: $e');
    }
  }

  static Future<void> _initFirebase() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      AppLogger.success('Firebase initialized in background');
      if (kDebugMode) {
        debugPrint('[QUOTA_AUDIT][FIREBASE_PROJECT]\nprojectId=${Firebase.app().options.projectId}');
      }
    } catch (e) {
      AppLogger.error('Firebase background initialization error: $e');
    }
  }
}
