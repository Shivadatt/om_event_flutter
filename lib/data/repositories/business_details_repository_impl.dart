import '../../domain/entities/business_details_entity.dart';
import '../../domain/repositories/business_details_repository.dart';
import '../datasources/business_details_remote_data_source.dart';

class BusinessDetailsRepositoryImpl implements BusinessDetailsRepository {
  final BusinessDetailsRemoteDataSource _remoteDataSource;

  BusinessDetailsRepositoryImpl(this._remoteDataSource);

  @override
  Stream<BusinessDetailsEntity> streamBusinessDetails() {
    return _remoteDataSource.streamBusinessDetails();
  }

  @override
  Future<void> saveBusinessDetails(BusinessDetailsEntity details) {
    return _remoteDataSource.saveBusinessDetails(details);
  }
}
