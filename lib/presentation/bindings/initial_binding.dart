import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/datasources/local_storage_source.dart';
import '../../data/datasources/supabase_storage_source.dart';
import '../../data/datasources/supabase_upload_service.dart';
import '../../data/datasources/supabase_seeder_service.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/admin_repository.dart';
import '../../data/repositories/supabase_settings_repository.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/repositories/contact_number_repository.dart';
import '../../core/services/app_config_service.dart';
import '../../core/services/enterprise_verification_service.dart';
import '../controllers/seeder_controller.dart';
import '../controllers/auth_controller.dart';

import 'package:om_event/presentation/controllers/settings_controller.dart';
import '../../data/datasources/supabase_business_details_remote_data_source.dart';
import '../../data/repositories/business_details_repository_impl.dart';
import '../../domain/repositories/business_details_repository.dart';
import '../../data/repositories/supabase_contact_number_repository.dart';
import '../../core/services/fcm_notification_service.dart';
import '../../core/services/notification_gateway_service.dart';
import '../../core/services/local_notification_trigger_service.dart';
import '../../core/services/business_details_cache_service.dart';
import '../../core/services/business_details_service.dart';
import '../../core/services/token_service.dart';
import '../../core/services/notification_handler_service.dart';
// FCM module — clean architecture sub-services
import '../../core/services/fcm/fcm_module.dart';
import '../../domain/repositories/customer_auth_repository.dart';
import '../../data/repositories/customer_auth_repository_impl.dart';
import '../controllers/customer_auth_controller.dart';
import '../../domain/repositories/customer_portal_repository.dart';
import '../../data/repositories/supabase_customer_portal_repository.dart';
import '../controllers/customer_dashboard_controller.dart';
import '../controllers/admin_customer_portal_controller.dart';
import '../../domain/repositories/customer_repository.dart';
import '../../data/repositories/customer_repository_impl.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // SharedPreferences is registered synchronously in main.dart

    // Settings Repository, AppConfigService & Controller
    Get.lazyPut<SettingsRepository>(
      () => SupabaseSettingsRepository(),
      fenix: true,
    );
    Get.lazyPut<ContactNumberRepository>(
      () => SupabaseContactNumberRepository(),
      fenix: true,
    );
    // AppConfigService deferred — opens 30 listeners; only needed in admin / after home paints
    Get.lazyPut<AppConfigService>(() => AppConfigService(), fenix: true);
    
    // Centralized Business Details DI — these are needed on home, keep eager
    final businessDetailsRemote = SupabaseBusinessDetailsRemoteDataSourceImpl();
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

    // ─── FCM Module (clean architecture sub-services) ──────────────────────
    // All deferred — initialized only post-login, never at cold start.
    Get.lazyPut<NotificationPermissionService>(
      () => NotificationPermissionService(), fenix: true);
    Get.lazyPut<NotificationTokenService>(
      () => NotificationTokenService(), fenix: true);
    Get.lazyPut<NotificationLocalService>(
      () => NotificationLocalService(), fenix: true);
    Get.lazyPut<NotificationHandler>(
      () => NotificationHandler(), fenix: true);
    Get.lazyPut<FcmService>(() => FcmService(), fenix: true);

    // ─── Legacy notification services (kept for backwards compatibility) ───
    Get.lazyPut<TokenService>(() => TokenService(), fenix: true);
    Get.lazyPut<NotificationHandlerService>(() => NotificationHandlerService(), fenix: true);
    Get.lazyPut<FcmNotificationService>(() => FcmNotificationService(), fenix: true);
    Get.lazyPut<NotificationGatewayService>(() => NotificationGatewayService(), fenix: true);
    Get.lazyPut<LocalNotificationTriggerService>(() => LocalNotificationTriggerService(), fenix: true);

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

    // Supabase Seeder Service
    Get.lazyPut<SupabaseSeederService>(
      () => SupabaseSeederService(),
      fenix: true,
    );

    // Seeder Controller
    Get.lazyPut<SeederController>(() => SeederController(), fenix: true);

    // Enterprise Verification Service
    Get.put<EnterpriseVerificationService>(EnterpriseVerificationService(), permanent: true);

    // Admin Repository
    Get.lazyPut<AdminRepository>(
      () => AdminRepository(),
      fenix: true,
    );

    // Customer Repository (CRM contacts check)
    Get.lazyPut<CustomerRepository>(
      () => CustomerRepositoryImpl(),
      fenix: true,
    );

    // Auth Repository
    Get.lazyPut<AuthRepository>(
      () => AuthRepositoryImpl(
        Get.find<FirebaseAuth>(),
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
      ),
      fenix: true,
    );

    Get.lazyPut<CustomerAuthController>(
      () => CustomerAuthController(Get.find<CustomerAuthRepository>()),
      fenix: true,
    );

    Get.lazyPut<CustomerPortalRepository>(
      () => SupabaseCustomerPortalRepository(),
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
