import 'package:flutter/foundation.dart';
import '../../domain/repositories/customer_repository.dart';
import '../datasources/firestore_remote_source.dart';
import '../models/customer_model.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final FirestoreRemoteSource firestoreSource;

  CustomerRepositoryImpl(this.firestoreSource);

  @override
  Future<List<CustomerModel>> getCustomers() async {
    final docs = await firestoreSource.fetchCustomers();
    final unique = <String, CustomerModel>{};
    for (final doc in docs) {
      final model = CustomerModel.fromJson(doc.data(), doc.id);
      final key = model.id.isNotEmpty ? model.id : model.phone;
      unique[key] = model;
    }
    final list = unique.values.toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  @override
  Stream<List<CustomerModel>> streamCustomers() {
    debugPrint('[CLIENT_LIST][STREAM_START]');
    return firestoreSource.streamCustomers().map((docs) {
      debugPrint('[CLIENT_LIST][SNAPSHOT] documentCount=${docs.length}');
      final unique = <String, CustomerModel>{};
      for (final doc in docs) {
        final maskedId = doc.id.length > 4 ? '******${doc.id.substring(doc.id.length - 2)}' : doc.id;
        debugPrint('[CLIENT_LIST][DOCUMENT] path=customers/$maskedId');
        final model = CustomerModel.fromJson(doc.data(), doc.id);
        final key = model.id.isNotEmpty ? model.id : model.phone;
        unique[key] = model;
      }
      final list = unique.values.toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  @override
  Future<void> createCustomer(CustomerModel customer) async {
    await firestoreSource.createCustomer(customer.toJson(useServerTimestamps: true));
  }

  @override
  Future<void> updateCustomer(CustomerModel customer) async {
    final targetId = customer.id.isNotEmpty ? customer.id : customer.phone;
    await firestoreSource.updateCustomerDetails(
      targetId,
      customer.toJson(),
    );
  }

  @override
  Future<void> deleteCustomer(String idOrPhone) async {
    await firestoreSource.deleteCustomer(idOrPhone);
  }
}
