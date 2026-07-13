import 'package:get/get.dart';
import '../../domain/entities/business_details_entity.dart';
import '../../domain/repositories/business_details_repository.dart';
import 'business_details_cache_service.dart';

class BusinessDetailsService extends GetxService {
  static BusinessDetailsService get to => Get.find<BusinessDetailsService>();

  final BusinessDetailsRepository _repository = Get.find<BusinessDetailsRepository>();
  final rxDetails = BusinessDetailsEntity.defaultVal().obs;

  @override
  void onInit() {
    super.onInit();
    // Load from cache first for instantaneous startup
    final cached = BusinessDetailsCacheService.to.getCachedBusinessDetails();
    if (cached != null) {
      rxDetails.value = cached;
    }
    // Bind stream from repository for real-time reactive updates
    rxDetails.bindStream(_repository.streamBusinessDetails().handleError((e, stack) {
      Get.printError(info: "BusinessDetailsService STREAM ERROR: $e\n$stack");
    }));
    // Persist to cache automatically when Firestore reports changes
    ever(rxDetails, (BusinessDetailsEntity details) {
      BusinessDetailsCacheService.to.cacheBusinessDetails(details);
    });
  }
}
