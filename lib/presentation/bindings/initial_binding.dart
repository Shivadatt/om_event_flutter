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
import '../../data/repositories/settings_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/repositories/contact_number_repository.dart';
import '../../data/repositories/contact_number_repository_impl.dart';
import '../../core/services/app_config_service.dart';
import '../controllers/seeder_controller.dart';
import '../controllers/auth_controller.dart';

import 'package:om_event/presentation/controllers/settings_controller.dart';
import '../../data/datasources/business_details_remote_data_source.dart';
import '../../data/repositories/business_details_repository_impl.dart';
import '../../domain/repositories/business_details_repository.dart';
import '../../core/services/business_details_cache_service.dart';
import '../../core/services/business_details_service.dart';
import '../../domain/repositories/customer_auth_repository.dart';
import '../../data/repositories/customer_auth_repository_impl.dart';
import '../controllers/customer_auth_controller.dart';
import '../../domain/repositories/customer_portal_repository.dart';
import '../../data/repositories/customer_portal_repository_impl.dart';
import '../controllers/customer_dashboard_controller.dart';
import '../controllers/admin_customer_portal_controller.dart';
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // SharedPreferences is registered synchronously in main.dart

    // Settings Repository, AppConfigService & Controller
    Get.lazyPut<SettingsRepository>(
      () => SettingsRepositoryImpl(),
      fenix: true,
    );
    Get.lazyPut<ContactNumberRepository>(
      () => ContactNumberRepositoryImpl(),
      fenix: true,
    );
    Get.put<AppConfigService>(AppConfigService(), permanent: true);
    
    // Centralized Business Details DI
    final businessDetailsRemote = BusinessDetailsRemoteDataSourceImpl();
    final businessDetailsRepo = BusinessDetailsRepositoryImpl(businessDetailsRemote);
    Get.put<BusinessDetailsRepository>(businessDetailsRepo, permanent: true);
    Get.put<BusinessDetailsCacheService>(BusinessDetailsCacheService(), permanent: true);
    Get.put<BusinessDetailsService>(BusinessDetailsService(), permanent: true);

    Get.lazyPut<SettingsController>(() => SettingsController(), fenix: true);

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

    // ==========================================
    // CUSTOMER PORTAL DI
    // ==========================================
    Get.lazyPut<CustomerAuthRepository>(
      () => CustomerAuthRepositoryImpl(
        Get.find<FirebaseAuth>(),
        Get.find<FirebaseFirestore>(),
      ),
      fenix: true,
    );

    Get.lazyPut<CustomerAuthController>(
      () => CustomerAuthController(Get.find<CustomerAuthRepository>()),
      fenix: true,
    );

    Get.lazyPut<CustomerPortalRepository>(
      () => CustomerPortalRepositoryImpl(Get.find<FirebaseFirestore>()),
      fenix: true,
    );

    Get.lazyPut<CustomerDashboardController>(
      () => CustomerDashboardController(
        Get.find<CustomerPortalRepository>(),
        Get.find<CustomerAuthRepository>(),
        Get.find<CustomerAuthController>(),
      ),
      fenix: true,
    );

    Get.lazyPut<AdminCustomerPortalController>(
      () => AdminCustomerPortalController(),
      fenix: true,
    );
  }
}
