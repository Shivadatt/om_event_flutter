import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_web_plugins/url_strategy.dart';
import 'core/config/app_routes.dart';
import 'core/config/app_theme.dart';
import 'core/constants/app_strings.dart';
import 'core/seo/seo_manager.dart';
import 'core/utils/app_logger.dart';
import 'presentation/bindings/initial_binding.dart';

import 'core/services/realtime_manager.dart';

void main() async {
  usePathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences, Firebase & Supabase concurrently — saves ~300-500ms vs sequential await
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
        appId: '1:443981257323:android:a99b824ca6d4a10b64af2e',
      ),
    ).then((_) {
      AppLogger.success('Firebase initialized successfully');
    }).catchError((e) {
      AppLogger.error('Firebase initialization failed', e);
    }),
    Supabase.initialize(
      url: 'https://kwegyvbgdaednljyhcgm.supabase.co',
      publishableKey: 'sb_publishable_bN91Or0DGzltjdDFB3b4zw_oosYJUa8',
    ).then((_) {
      AppLogger.success('Supabase initialized successfully');
    }).catchError((e) {
      AppLogger.error('Supabase initialization failed', e);
    }),
  ]);

  // Synchronize Firebase Auth changes with Supabase Client headers for RLS verification
  FirebaseAuth.instance.idTokenChanges().listen((user) {
    if (user != null) {
      Supabase.instance.client.rest.headers['x-firebase-uid'] = user.uid;
      AppLogger.info('Supabase client headers synced with Firebase UID: ${user.uid}');
      RealtimeManager.instance.markReady();
    } else {
      Supabase.instance.client.rest.headers.remove('x-firebase-uid');
      AppLogger.info('Supabase client headers cleared (no Firebase User)');
      RealtimeManager.instance.markNotReady();
    }
  });

  // Await the first Firebase token recovery event (up to 1.5s) to guarantee header synchronization is ready (Task 4)
  try {
    final initialUser = await FirebaseAuth.instance.idTokenChanges().first.timeout(
          const Duration(milliseconds: 1500),
          onTimeout: () => null,
        );
    if (initialUser != null) {
      Supabase.instance.client.rest.headers['x-firebase-uid'] = initialUser.uid;
      RealtimeManager.instance.markReady();
    }
  } catch (e) {
    AppLogger.error('Firebase initial user token synchronization failed: $e');
  }

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
