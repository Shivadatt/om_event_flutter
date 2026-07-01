import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/datasources/local_storage_source.dart';
import '../../data/datasources/supabase_storage_source.dart';
import '../../data/datasources/supabase_upload_service.dart';
import '../../data/datasources/seeder_service.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/admin_repository.dart';
import '../../domain/repositories/auth_repository.dart';
import '../controllers/seeder_controller.dart';
import '../controllers/auth_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // SharedPreferences is registered synchronously in main.dart

    // Local Storage Source
    Get.lazyPut<LocalStorageSource>(
      () => LocalStorageSource(Get.find<SharedPreferences>()),
      fenix: true,
    );

    // Firebase Instances
    Get.put<FirebaseAuth>(FirebaseAuth.instance, permanent: true);
    Get.put<FirebaseFirestore>(FirebaseFirestore.instance, permanent: true);

    // Supabase Storage Source
    // Note: We use placeholder credentials which are replaced by .env values at runtime
    Get.lazyPut<SupabaseStorageSource>(
      () => SupabaseStorageSource(
        projectUrl: 'https://kwegyvbgdaednljyhcgm.supabase.co',
        apiKey: 'sb_publishable_bN91Or0DGzltjdDFB3b4zw_oosYJUa8',
      ),
      fenix: true,
    );

    // Supabase Upload Service
    Get.lazyPut<SupabaseUploadService>(
      () => SupabaseUploadService(Get.find<SupabaseStorageSource>()),
      fenix: true,
    );

    // Seeder Service
    Get.lazyPut<SeederService>(
      () => SeederService(
        Get.find<FirebaseFirestore>(),
        Get.find<SupabaseUploadService>(),
      ),
      fenix: true,
    );

    // Seeder Controller
    Get.lazyPut<SeederController>(() => SeederController(), fenix: true);

    // Admin Repository
    Get.lazyPut<AdminRepository>(
      () => AdminRepository(Get.find<FirebaseFirestore>()),
      fenix: true,
    );

    // Auth Repository
    Get.lazyPut<AuthRepository>(
      () => AuthRepositoryImpl(
        Get.find<FirebaseAuth>(),
        Get.find<FirebaseFirestore>(),
        Get.find<LocalStorageSource>(),
      ),
      fenix: true,
    );

    // Auth Controller
    Get.lazyPut<AuthController>(
      () => AuthController(Get.find<AuthRepository>()),
      fenix: true,
    );
  }
}
