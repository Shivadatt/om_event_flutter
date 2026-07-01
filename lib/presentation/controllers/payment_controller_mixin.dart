import 'package:get/get.dart';
import '../../data/models/payment_model.dart';
import '../../data/repositories/admin_repository.dart';

/// Mixin containing Payment management state and logic for AdminController.
mixin PaymentControllerMixin on GetxController {
  final rxPayments = <PaymentModel>[].obs;
  final isLoadingPayments = false.obs;

  /// Loads all payments.
  Future<void> loadPayments() async {
    try {
      isLoadingPayments.value = true;
      final adminRepo = Get.find<AdminRepository>();
      final list = await adminRepo.getPayments();
      rxPayments.assignAll(list);
    } catch (e) {
      Get.snackbar("Payments Error", e.toString());
    } finally {
      isLoadingPayments.value = false;
    }
  }

  /// Saves a payment transaction receipt.
  Future<void> savePayment(PaymentModel payment, {required bool isEdit}) async {
    try {
      isLoadingPayments.value = true;
      final adminRepo = Get.find<AdminRepository>();
      await adminRepo.savePayment(payment, isEdit: isEdit);
      await loadPayments();
      Get.snackbar("Payment Recorded", "Transaction logged successfully.");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoadingPayments.value = false;
    }
  }

  /// Deletes a payment transaction record.
  Future<void> deletePayment(String id) async {
    try {
      isLoadingPayments.value = true;
      final adminRepo = Get.find<AdminRepository>();
      await adminRepo.deletePayment(id);
      await loadPayments();
      Get.snackbar("Payment Deleted", "Transaction record removed.");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoadingPayments.value = false;
    }
  }
}
