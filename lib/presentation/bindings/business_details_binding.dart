import 'package:get/get.dart';
import '../../data/datasources/supabase_business_details_remote_data_source.dart';
import '../../data/repositories/business_details_repository_impl.dart';
import '../../domain/repositories/business_details_repository.dart';
import '../controllers/business_details_controller.dart';

class BusinessDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SupabaseBusinessDetailsRemoteDataSourceImpl>(
      () => SupabaseBusinessDetailsRemoteDataSourceImpl(),
    );
    Get.lazyPut<BusinessDetailsRepository>(
      () => BusinessDetailsRepositoryImpl(Get.find<SupabaseBusinessDetailsRemoteDataSourceImpl>()),
    );
    Get.lazyPut<BusinessDetailsController>(
      () => BusinessDetailsController(),
    );
  }
}
