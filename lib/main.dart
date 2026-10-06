import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'core/config/app_routes.dart';
import 'core/config/app_theme.dart';
import 'core/constants/app_strings.dart';
import 'dart:ui';
import 'core/seo/seo_manager.dart';
import 'core/utils/app_logger.dart';
import 'presentation/bindings/initial_binding.dart';
import 'presentation/widgets/app_bootstrap_gate.dart';

void main() async {
  usePathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();

  // Suppress benign Flutter Web CanvasKit WebGL hot-restart context-lost race & disposed EngineFlutterView
  FlutterError.onError = (details) {
    try {
      final msg = details.exceptionAsString();
      if (msg.contains('_handledContextLostEvent') ||
          msg.contains('window.dart:99:12') ||
          msg.contains('EngineFlutterView') ||
          msg.contains('LegacyJavaScriptObject') ||
          msg.contains('Trying to render a disposed')) {
        return;
      }
      FlutterError.presentError(details);
    } catch (_) {}
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    final errStr = error.toString();
    if (errStr.contains('_handledContextLostEvent') ||
        errStr.contains('window.dart:99:12') ||
        errStr.contains('EngineFlutterView') ||
        errStr.contains('LegacyJavaScriptObject') ||
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
      options: DefaultFirebaseOptions.currentPlatform,
    ).then((_) {
      AppLogger.success('Firebase initialized successfully');
      debugPrint('[QUOTA_AUDIT][FIREBASE_PROJECT]\nprojectId=${Firebase.app().options.projectId}');
      debugPrint('[QUOTA_AUDIT][FIRESTORE_DATABASE]\ndatabaseId=(default)');
      debugPrint('[CLIENT_CREATE][FIREBASE_PROJECT] projectId: ${Firebase.app().options.projectId}');
      debugPrint('[CLIENT_CREATE][FIREBASE_APP] appId: ${Firebase.app().options.appId}');
      debugPrint('[CLIENT_CREATE][FIRESTORE] target collection: customers');
    }).catchError((e) {
      AppLogger.error('Firebase initialization failed', e);
    }),
  ]);

  // Non-blocking initial Firebase Auth check — BootstrapService handles reactive auth post-mount
  try {
    if (FirebaseAuth.instance.currentUser == null) {
      await FirebaseAuth.instance.authStateChanges().first.timeout(
        const Duration(milliseconds: 100),
        onTimeout: () => FirebaseAuth.instance.currentUser,
      );
    }
  } catch (_) {}

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
      builder: (context, child) => AppBootstrapGate(child: child),
    );
  }
}
