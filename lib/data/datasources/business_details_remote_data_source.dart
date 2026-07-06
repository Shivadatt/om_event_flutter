import '../../domain/entities/business_details_entity.dart';

abstract class BusinessDetailsRemoteDataSource {
  Stream<BusinessDetailsEntity> streamBusinessDetails();
  Future<void> saveBusinessDetails(BusinessDetailsEntity details);
}
