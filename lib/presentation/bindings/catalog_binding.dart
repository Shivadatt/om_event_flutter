import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../data/datasources/firestore_remote_source.dart';
import '../../data/datasources/supabase_storage_source.dart';
import '../../data/repositories/catalog_repository_impl.dart';
import '../../data/repositories/lead_repository_impl.dart';
import '../../data/repositories/quotation_repository_impl.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../../domain/repositories/lead_repository.dart';
import '../../domain/repositories/quotation_repository.dart';
import '../../domain/usecases/create_quotation.dart';
import '../../domain/usecases/get_categories.dart';
import '../../domain/usecases/get_experiences.dart';
import '../../domain/usecases/get_reviews.dart';
import '../../domain/usecases/submit_lead.dart';
import '../controllers/cart_controller.dart';
import '../controllers/catalog_controller.dart';
import '../controllers/quotation_controller.dart';

class CatalogBinding extends Bindings {
  @override
  void dependencies() {
    // Sources & Repositories
    if (!Get.isRegistered<FirestoreRemoteSource>()) {
      Get.lazyPut<FirestoreRemoteSource>(
        () => FirestoreRemoteSource(Get.find<FirebaseFirestore>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<CatalogRepository>()) {
      Get.lazyPut<CatalogRepository>(
        () => CatalogRepositoryImpl(Get.find<FirestoreRemoteSource>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<QuotationRepository>()) {
      Get.lazyPut<QuotationRepository>(
        () => QuotationRepositoryImpl(
          firestoreSource: Get.find<FirestoreRemoteSource>(),
          supabaseSource: Get.find<SupabaseStorageSource>(),
        ),
        fenix: true,
      );
    }

    if (!Get.isRegistered<LeadRepository>()) {
      Get.lazyPut<LeadRepository>(
        () => LeadRepositoryImpl(Get.find<FirestoreRemoteSource>()),
        fenix: true,
      );
    }

    // Usecases
    Get.lazyPut<GetCategories>(
      () => GetCategories(Get.find<CatalogRepository>()),
      fenix: true,
    );
    Get.lazyPut<GetExperiences>(
      () => GetExperiences(Get.find<CatalogRepository>()),
      fenix: true,
    );
    Get.lazyPut<GetReviews>(
      () => GetReviews(Get.find<CatalogRepository>()),
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
      fenix: true,
    );

    Get.lazyPut<CartController>(() => CartController(Get.find()), fenix: true);

    Get.lazyPut<QuotationController>(
      () => QuotationController(
        createQuotationUsecase: Get.find<CreateQuotation>(),
        quotationRepository: Get.find<QuotationRepository>(),
        cartController: Get.find<CartController>(),
      ),
      fenix: true,
    );
  }
}
