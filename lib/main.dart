import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_web_plugins/url_strategy.dart';
import 'core/config/app_routes.dart';
import 'core/config/app_theme.dart';
import 'core/constants/app_strings.dart';
import 'dart:ui';
import 'core/seo/seo_manager.dart';
import 'core/utils/app_logger.dart';
import 'presentation/bindings/initial_binding.dart';

void main() async {
  usePathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();

  // Suppress benign Flutter Web CanvasKit WebGL hot-restart context-lost race & disposed EngineFlutterView
  FlutterError.onError = (details) {
    final msg = details.exceptionAsString();
    if (msg.contains('_handledContextLostEvent') ||
        msg.contains('window.dart:99:12') ||
        msg.contains('EngineFlutterView') ||
        msg.contains('Trying to render a disposed')) {
      return;
    }
    FlutterError.presentError(details);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    final errStr = error.toString();
    if (errStr.contains('_handledContextLostEvent') ||
        errStr.contains('window.dart:99:12') ||
        errStr.contains('EngineFlutterView') ||
        errStr.contains('Trying to render a disposed')) {
      return true; // handled
    }
    return false;
  };

  // Initialize SharedPreferences & Firebase concurrently — saves ~300-500ms vs sequential await
  await Future.wait([
    SharedPreferences.getInstance().then((prefs) {
      Get.put<SharedPreferences>(prefs, permanent: true);
    }).catchError((e) {
      AppLogger.error('SharedPreferences initialization failed', e);
    }),
    Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyDFpKAUXwIDnoQBrt5Id-xJjn-h5WVv1pc',
        authDomain: 'om-event.firebaseapp.com',
        projectId: 'om-event',
        storageBucket: 'om-event.firebasestorage.app',
        messagingSenderId: '443981257323',
        // ✅ Web app ID (not the Android ID) — required for correct Flutter Web SDK routing
        appId: '1:443981257323:web:845ec22c4774094264af2e',
      ),
    ).then((_) {
      AppLogger.success('Firebase initialized successfully');
    }).catchError((e) {
      AppLogger.error('Firebase initialization failed', e);
    }),
  ]);

  runApp(const OmEventsApp());
}

/// Root application widget.
class OmEventsApp extends StatelessWidget {
  const OmEventsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppStrings.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialBinding: InitialBinding(),
      initialRoute: AppRoutes.home,
      getPages: AppRouter.pages,
      navigatorObservers: [SeoManager()],
    );
  }
}
