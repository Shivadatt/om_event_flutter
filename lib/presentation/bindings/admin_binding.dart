import 'package:get/get.dart';
import '../../data/repositories/supabase_lead_repository.dart';
import '../../data/repositories/supabase_quotation_repository.dart';
import '../../data/repositories/supabase_catalog_repository.dart';
import '../../data/repositories/customer_repository_impl.dart';
import '../../domain/repositories/lead_repository.dart';
import '../../domain/repositories/quotation_repository.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../../domain/repositories/customer_repository.dart';
import '../../domain/repositories/auth_repository.dart';
import '../controllers/admin_controller.dart';

class AdminBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LeadRepository>(
      () => SupabaseLeadRepository(),
      fenix: true,
    );

    Get.lazyPut<QuotationRepository>(
      () => SupabaseQuotationRepository(),
      fenix: true,
    );

    Get.lazyPut<CatalogRepository>(
      () => SupabaseCatalogRepository(),
      fenix: true,
    );

    Get.lazyPut<CustomerRepository>(
      () => CustomerRepositoryImpl(),
      fenix: true,
    );

    Get.lazyPut<AdminController>(
      () => AdminController(
        leadRepository: Get.find<LeadRepository>(),
        quotationRepository: Get.find<QuotationRepository>(),
        catalogRepository: Get.find<CatalogRepository>(),
        customerRepository: Get.find<CustomerRepository>(),
        authRepository: Get.find<AuthRepository>(),
      ),
    );
  }
}
