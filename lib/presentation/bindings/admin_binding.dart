import 'package:get/get.dart';
import '../../data/datasources/firestore_remote_source.dart';
import '../../data/repositories/lead_repository_impl.dart';
import '../../data/repositories/quotation_repository_impl.dart';
import '../../domain/repositories/lead_repository.dart';
import '../../domain/repositories/quotation_repository.dart';
import '../controllers/admin_controller.dart';

class AdminBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FirestoreRemoteSource>(
      () => FirestoreRemoteSource(Get.find()),
      fenix: true,
    );

    Get.lazyPut<LeadRepository>(
      () => LeadRepositoryImpl(Get.find()),
      fenix: true,
    );

    Get.lazyPut<QuotationRepository>(
      () => QuotationRepositoryImpl(
        firestoreSource: Get.find(),
        supabaseSource: Get.find(),
      ),
      fenix: true,
    );

    Get.lazyPut<AdminController>(
      () => AdminController(
        leadRepository: Get.find<LeadRepository>(),
        quotationRepository: Get.find<QuotationRepository>(),
      ),
    );
  }
}
