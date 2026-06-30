import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_web_plugins/url_strategy.dart';
import 'core/config/app_routes.dart';
import 'core/config/app_theme.dart';
import 'presentation/bindings/initial_binding.dart';

void main() async {
  usePathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase using the real project credentials
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyDFpKAUXwIDnoQBrt5Id-xJjn-h5WVv1pc",
        authDomain: "om-event.firebaseapp.com",
        projectId: "om-event",
        storageBucket: "om-event.firebasestorage.app",
        messagingSenderId: "443981257323",
        appId: "1:443981257323:android:a99b824ca6d4a10b64af2e",
      ),
    );
  } catch (e) {
    debugPrint("Firebase initialization failed: ${e.toString()}");
  }

  runApp(const OmEventsApp());
}

class OmEventsApp extends StatelessWidget {
  const OmEventsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Om Events',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Syncs automatically with OS settings
      initialBinding: InitialBinding(),
      initialRoute: AppRoutes.home,
      getPages: AppRoutes.pages,
    );
  }
}
