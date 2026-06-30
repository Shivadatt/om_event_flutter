import '../../data/models/customer_model.dart';

abstract class CustomerRepository {
  Future<List<CustomerModel>> getCustomers();
  Future<void> updateCustomer(CustomerModel customer);
  Future<void> deleteCustomer(String phone);
}
