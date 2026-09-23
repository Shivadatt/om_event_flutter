import '../entities/quotation.dart';

abstract class AdminBookingRepository {
  Stream<List<Quotation>> streamAllBookings();
  Future<Quotation?> getBookingById(String id);
  Future<bool> acceptBooking({
    required String bookingId,
    required String adminId,
    required String adminName,
  });
  Future<bool> rejectBooking({
    required String bookingId,
    required String adminId,
    required String adminName,
    required String reason,
    String? note,
  });
  Future<bool> confirmBooking({
    required String bookingId,
    required String adminId,
    required String adminName,
  });
  Future<bool> completeBooking({
    required String bookingId,
    required String adminId,
    required String adminName,
  });
  Future<bool> approveCancellation({
    required String bookingId,
    required String adminId,
    required String adminName,
  });
  Future<bool> rejectCancellation({
    required String bookingId,
    required String adminId,
    required String adminName,
    required String reason,
  });
}
