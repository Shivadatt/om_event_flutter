import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/datasources/local_storage_source.dart';
import '../../data/datasources/supabase_storage_source.dart';
import '../../data/datasources/supabase_upload_service.dart';
import '../../data/datasources/seeder_service.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../controllers/seeder_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // SharedPreferences
    Get.putAsync<SharedPreferences>(() async => await SharedPreferences.getInstance(), permanent: true);

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
        projectUrl: 'https://placeholder-project.supabase.co',
        apiKey: 'placeholder-anon-key',
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
      () => SeederService(Get.find<FirebaseFirestore>(), Get.find<SupabaseUploadService>()),
      fenix: true,
    );

    // Seeder Controller
    Get.lazyPut<SeederController>(
      () => SeederController(),
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
  }
}
