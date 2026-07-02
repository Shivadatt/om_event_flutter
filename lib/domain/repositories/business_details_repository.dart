import '../entities/business_details_entity.dart';

abstract class BusinessDetailsRepository {
  Stream<BusinessDetailsEntity> streamBusinessDetails();
  Future<void> saveBusinessDetails(BusinessDetailsEntity details);
}
