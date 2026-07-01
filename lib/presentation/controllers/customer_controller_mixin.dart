import 'package:get/get.dart';
import '../../data/models/customer_model.dart';
import '../../domain/repositories/customer_repository.dart';

/// Mixin containing Customer management state and logic for AdminController.
mixin CustomerControllerMixin on GetxController {
  final rxCustomers = <CustomerModel>[].obs;
  final isLoadingCustomers = false.obs;

  /// Loads all customer records.
  Future<void> loadCustomers() async {
    try {
      isLoadingCustomers.value = true;
      final customerRepository = Get.find<CustomerRepository>();
      final list = await customerRepository.getCustomers();
      rxCustomers.assignAll(list);
    } catch (e) {
      Get.snackbar("Customers Error", e.toString());
    } finally {
      isLoadingCustomers.value = false;
    }
  }

  /// Saves a customer record.
  Future<void> saveCustomer(CustomerModel customer) async {
    try {
      isLoadingCustomers.value = true;
      final customerRepository = Get.find<CustomerRepository>();
      await customerRepository.updateCustomer(customer);
      await loadCustomers();
      Get.snackbar("Customer Saved", "Customer profile updated successfully.");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoadingCustomers.value = false;
    }
  }

  /// Deletes a customer record by phone.
  Future<void> deleteCustomer(String phone) async {
    try {
      isLoadingCustomers.value = true;
      final customerRepository = Get.find<CustomerRepository>();
      await customerRepository.deleteCustomer(phone);
      await loadCustomers();
      Get.snackbar(
        "Customer Deleted",
        "Customer profile deleted successfully.",
      );
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoadingCustomers.value = false;
    }
  }
}
