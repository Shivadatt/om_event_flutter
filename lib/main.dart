import 'package:flutter/material.dart';
import 'package:get/get.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_web_plugins/url_strategy.dart';
import 'core/config/app_routes.dart';
import 'core/config/app_theme.dart';
import 'core/constants/app_strings.dart';
import 'dart:ui';
import 'core/seo/seo_manager.dart';
import 'core/services/app_bootstrap_service.dart';
import 'presentation/widgets/app_bootstrap_gate.dart';
import 'presentation/bindings/initial_binding.dart';

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

  // Await core platform services initialization before routing to prevent race conditions
  await AppBootstrapService.ensureInitialized();

  // Render initial Flutter frame
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
      initialRoute: AppRoutes.home,
      initialBinding: InitialBinding(),
      getPages: AppRouter.pages,
      navigatorObservers: [SeoManager()],
      builder: (context, child) => AppBootstrapGate(child: child),
    );
  }
}
