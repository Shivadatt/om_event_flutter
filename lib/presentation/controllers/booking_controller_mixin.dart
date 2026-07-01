import 'package:get/get.dart';
import '../../data/models/booking_model.dart';
import '../../data/repositories/admin_repository.dart';

/// Mixin containing Booking management state and logic for AdminController.
mixin BookingControllerMixin on GetxController {
  final rxBookings = <BookingModel>[].obs;
  final isLoadingBookings = false.obs;

  /// Loads all bookings.
  Future<void> loadBookings() async {
    try {
      isLoadingBookings.value = true;
      final adminRepo = Get.find<AdminRepository>();
      final list = await adminRepo.getBookings();
      rxBookings.assignAll(list);
    } catch (e) {
      Get.snackbar("Bookings Error", e.toString());
    } finally {
      isLoadingBookings.value = false;
    }
  }

  /// Saves a booking record.
  Future<void> saveBooking(BookingModel booking, {required bool isEdit}) async {
    try {
      isLoadingBookings.value = true;
      final adminRepo = Get.find<AdminRepository>();
      await adminRepo.saveBooking(booking, isEdit: isEdit);
      await loadBookings();
      Get.snackbar("Booking Saved", "Booking updated successfully.");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoadingBookings.value = false;
    }
  }

  /// Deletes a booking record by ID.
  Future<void> deleteBooking(String id) async {
    try {
      isLoadingBookings.value = true;
      final adminRepo = Get.find<AdminRepository>();
      await adminRepo.deleteBooking(id);
      await loadBookings();
      Get.snackbar("Booking Deleted", "Booking removed successfully.");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoadingBookings.value = false;
    }
  }
}
