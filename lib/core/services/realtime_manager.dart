import 'package:flutter/foundation.dart';

class RealtimeManager {
  static final RealtimeManager instance = RealtimeManager._();
  RealtimeManager._();

  final ValueNotifier<bool> _isReady = ValueNotifier<bool>(false);

  ValueNotifier<bool> get isReadyNotifier => _isReady;

  bool get isReady => _isReady.value;

  void markReady() {
    if (!_isReady.value) {
      _isReady.value = true;
      if (kDebugMode) {
        print('RealtimeManager: Auth and header sync is verified ready');
      }
    }
  }

  void markNotReady() {
    if (_isReady.value) {
      _isReady.value = false;
      if (kDebugMode) {
        print('RealtimeManager: Auth sessions cleared. Realtime connection paused');
      }
    }
  }
}
