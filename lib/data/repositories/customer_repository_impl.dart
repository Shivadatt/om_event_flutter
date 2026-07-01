import '../../domain/repositories/customer_repository.dart';
import '../datasources/firestore_remote_source.dart';
import '../models/customer_model.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final FirestoreRemoteSource firestoreSource;

  CustomerRepositoryImpl(this.firestoreSource);

  @override
  Future<List<CustomerModel>> getCustomers() async {
    final docs = await firestoreSource.fetchCustomers();
    return docs
        .map((doc) => CustomerModel.fromJson(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<void> updateCustomer(CustomerModel customer) async {
    await firestoreSource.updateCustomerDetails(
      customer.phone,
      customer.toJson(),
    );
  }

  @override
  Future<void> deleteCustomer(String phone) async {
    await firestoreSource.deleteCustomer(phone);
  }
}
