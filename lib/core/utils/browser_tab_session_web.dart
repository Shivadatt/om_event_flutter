// ignore_for_file: avoid_web_libraries_in_flutter, avoid_web_libraries_in_dart, deprecated_member_use
import 'dart:html' as html;

bool isTabSessionActiveImpl(String key) {
  try {
    return html.window.sessionStorage[key] == 'true';
  } catch (_) {
    return true; // Fallback gracefully if sessionStorage is blocked
  }
}

void setTabSessionActiveImpl(String key) {
  try {
    html.window.sessionStorage[key] = 'true';
  } catch (_) {}
}

void clearTabSessionImpl(String key) {
  try {
    html.window.sessionStorage.remove(key);
  } catch (_) {}
}
