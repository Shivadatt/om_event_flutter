import 'package:get/get.dart';
import '../../data/repositories/supabase_catalog_repository.dart';
import '../../data/repositories/supabase_lead_repository.dart';
import '../../data/repositories/supabase_quotation_repository.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../../domain/repositories/lead_repository.dart';
import '../../domain/repositories/quotation_repository.dart';
import '../../domain/usecases/create_quotation.dart';
import '../../domain/usecases/get_categories.dart';
import '../../domain/usecases/get_experiences.dart';
import '../../domain/usecases/submit_lead.dart';
import '../controllers/cart_controller.dart';
import '../controllers/catalog_controller.dart';
import '../controllers/quotation_controller.dart';

class CatalogBinding extends Bindings {
  @override
  void dependencies() {
    // Sources & Repositories (Supabase-only)
    Get.lazyPut<CatalogRepository>(
      () => SupabaseCatalogRepository(),
      fenix: true,
    );

    Get.lazyPut<QuotationRepository>(
      () => SupabaseQuotationRepository(),
      fenix: true,
    );

    Get.lazyPut<LeadRepository>(
      () => SupabaseLeadRepository(),
      fenix: true,
    );

    // Usecases
    Get.lazyPut<GetCategories>(
      () => GetCategories(Get.find<CatalogRepository>()),
      fenix: true,
    );
    Get.lazyPut<GetExperiences>(
      () => GetExperiences(Get.find<CatalogRepository>()),
      fenix: true,
    );
    Get.lazyPut<CreateQuotation>(
      () => CreateQuotation(Get.find<QuotationRepository>()),
      fenix: true,
    );
    Get.lazyPut<SubmitLead>(
      () => SubmitLead(Get.find<LeadRepository>()),
      fenix: true,
    );

    // Controllers
    Get.lazyPut<CatalogController>(
      () => CatalogController(
        getCategories: Get.find<GetCategories>(),
        getExperiences: Get.find<GetExperiences>(),
        submitLead: Get.find<SubmitLead>(),
      ),
    );

    Get.lazyPut<CartController>(() => CartController(Get.find()));

    Get.lazyPut<QuotationController>(
      () => QuotationController(
        createQuotationUsecase: Get.find<CreateQuotation>(),
        quotationRepository: Get.find<QuotationRepository>(),
        cartController: Get.find<CartController>(),
      ),
    );
  }
}
