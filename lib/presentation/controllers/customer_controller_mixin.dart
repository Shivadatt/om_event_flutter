import 'package:get/get.dart';
import '../../data/models/customer_model.dart';
import '../../domain/repositories/customer_repository.dart';

/// Mixin containing Customer management state and logic for AdminController.
mixin CustomerControllerMixin on GetxController {
  final rxCustomers = <CustomerModel>[].obs;
  final isLoadingCustomers = false.obs;
  final customerLoadError = ''.obs;

  /// Loads all customer records.
  Future<void> loadCustomers() async {
    try {
      isLoadingCustomers.value = true;
      customerLoadError.value = '';
      final customerRepository = Get.find<CustomerRepository>();
      final list = await customerRepository.getCustomers();
      rxCustomers.assignAll(list);
    } catch (e) {
      customerLoadError.value = e.toString();
      Get.snackbar("Customers Error", e.toString());
    } finally {
      isLoadingCustomers.value = false;
    }
  }

  /// Creates a new customer record with optimistic updates.
  Future<bool> createCustomer(CustomerModel customer) async {
    final key = customer.id.isNotEmpty ? customer.id : customer.phone;
    final existingIdx = rxCustomers.indexWhere((c) => c.id == key || c.phone == key);
    if (existingIdx != -1) {
      Get.snackbar("Duplicate Client", "A client with phone/ID '$key' already exists.");
      return false;
    }

    rxCustomers.insert(0, customer);
    try {
      final customerRepository = Get.find<CustomerRepository>();
      await customerRepository.createCustomer(customer);
      return true;
    } catch (e) {
      rxCustomers.removeWhere((c) => c.id == key || c.phone == key);
      Get.snackbar("Error", "Could not create client: $e");
      return false;
    }
  }

  /// Saves / updates an existing customer record.
  Future<bool> saveCustomer(CustomerModel customer) async {
    final key = customer.id.isNotEmpty ? customer.id : customer.phone;
    final idx = rxCustomers.indexWhere((c) => c.id == key || c.phone == key);
    final previous = idx != -1 ? rxCustomers[idx] : null;

    if (idx != -1) {
      rxCustomers[idx] = customer;
    } else {
      rxCustomers.insert(0, customer);
    }

    try {
      final customerRepository = Get.find<CustomerRepository>();
      await customerRepository.updateCustomer(customer);
      return true;
    } catch (e) {
      if (idx != -1 && previous != null) {
        rxCustomers[idx] = previous;
      }
      Get.snackbar("Error", "Could not update client: $e");
      return false;
    }
  }

  /// Deletes a customer record by ID or phone with optimistic removal.
  Future<bool> deleteCustomer(String idOrPhone) async {
    final idx = rxCustomers.indexWhere((c) => c.id == idOrPhone || c.phone == idOrPhone);
    final removed = idx != -1 ? rxCustomers[idx] : null;
    if (idx != -1) {
      rxCustomers.removeAt(idx);
    }

    try {
      final customerRepository = Get.find<CustomerRepository>();
      await customerRepository.deleteCustomer(idOrPhone);
      return true;
    } catch (e) {
      if (removed != null && idx != -1) {
        rxCustomers.insert(idx, removed);
      }
      Get.snackbar("Error", "Could not delete client: $e");
      return false;
    }
  }
}
