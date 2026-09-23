import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_collections.dart';
import '../../core/services/booking_availability_service.dart';
import '../../core/utils/app_logger.dart';
import '../../domain/entities/quotation.dart';
import '../../domain/repositories/admin_booking_repository.dart';
import '../models/quotation_model.dart';

class AdminBookingRepositoryImpl implements AdminBookingRepository {
  final FirebaseFirestore _firestore;

  AdminBookingRepositoryImpl([FirebaseFirestore? firestore])
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<Quotation>> streamAllBookings() {
    return _firestore
        .collection(AppCollections.quotations)
        .snapshots()
        .map((snap) {
      final list = snap.docs.map((doc) {
        try {
          return QuotationModel.fromJson(doc.data(), doc.id);
        } catch (e) {
          AppLogger.warning("Error parsing quotation ${doc.id}: $e");
          return null;
        }
      }).whereType<Quotation>().toList();

      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  @override
  Future<Quotation?> getBookingById(String id) async {
    try {
      final doc = await _firestore.collection(AppCollections.quotations).doc(id).get();
      if (!doc.exists || doc.data() == null) return null;
      return QuotationModel.fromJson(doc.data()!, doc.id);
    } catch (e) {
      AppLogger.warning("Error fetching booking $id: $e");
      return null;
    }
  }

  Future<void> _recordAuditActivity({
    required String bookingId,
    required String publicId,
    required String action,
    required String adminId,
    required String adminName,
    String? note,
  }) async {
    try {
      await _firestore
          .collection(AppCollections.quotations)
          .doc(bookingId)
          .collection('admin_activity')
          .add({
        'action': action,
        'publicId': publicId,
        'adminId': adminId,
        'adminName': adminName,
        'note': note ?? '',
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      AppLogger.warning("Unable to write audit activity: $e");
    }
  }

  Future<void> _sendCustomerNotification({
    required String customerId,
    required String publicBookingId,
    required String bookingId,
    required String title,
    required String body,
    required String type,
  }) async {
    if (customerId.isEmpty) return;
    try {
      await _firestore.collection(AppCollections.customerNotifications).add({
        'customerId': customerId,
        'customer_id': customerId,
        'title': title,
        'body': body,
        'type': type,
        'reference_id': publicBookingId,
        'publicBookingId': publicBookingId,
        'bookingId': bookingId,
        'isRead': false,
        'is_read': false,
        'createdAt': FieldValue.serverTimestamp(),
        'created_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      AppLogger.warning("Unable to create customer notification: $e");
    }
  }

  @override
  Future<bool> acceptBooking({
    required String bookingId,
    required String adminId,
    required String adminName,
  }) async {
    return _firestore.runTransaction<bool>((tx) async {
      final docRef = _firestore.collection(AppCollections.quotations).doc(bookingId);
      final snapshot = await tx.get(docRef);
      if (!snapshot.exists) throw Exception("Booking does not exist.");

      final data = snapshot.data() ?? {};
      final currentStatus = (data['status'] ?? '').toString().toLowerCase();

      // Check current status
      if (currentStatus == 'cancelled' || currentStatus == 'rejectedbyclient') {
        throw Exception("Cannot accept a cancelled or rejected booking.");
      }

      // Re-verify date availability
      final eventDateRaw = data['eventDate'];
      DateTime? eventDate;
      if (eventDateRaw is Timestamp) {
        eventDate = eventDateRaw.toDate();
      } else if (eventDateRaw is String) {
        eventDate = DateTime.tryParse(eventDateRaw);
      }

      if (eventDate != null) {
        final availResult = await BookingAvailabilityService.to.checkDateAvailability(eventDate);
        if (!availResult.isAvailable && availResult.reason != null && !availResult.reason!.contains(bookingId)) {
          AppLogger.warning("Booking date conflict warning: ${availResult.reason}");
        }
      }

      tx.update(docRef, {
        'status': QuotationStatus.acceptedByClient.nameStr,
        'acceptedAt': FieldValue.serverTimestamp(),
        'acceptedBy': adminName,
        'acceptedByAdminId': adminId,
        'updated_at': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    }).then((success) async {
      final quote = await getBookingById(bookingId);
      if (quote != null) {
        await _recordAuditActivity(
          bookingId: bookingId,
          publicId: quote.publicId,
          action: 'booking_accepted',
          adminId: adminId,
          adminName: adminName,
        );
        await _sendCustomerNotification(
          customerId: quote.customerId,
          publicBookingId: quote.publicId,
          bookingId: bookingId,
          title: "Booking Accepted",
          body: "Your booking request for ${quote.publicId} has been accepted by our team.",
          type: "booking_accepted",
        );
      }
      return success;
    });
  }

  @override
  Future<bool> rejectBooking({
    required String bookingId,
    required String adminId,
    required String adminName,
    required String reason,
    String? note,
  }) async {
    return _firestore.runTransaction<bool>((tx) async {
      final docRef = _firestore.collection(AppCollections.quotations).doc(bookingId);
      final snapshot = await tx.get(docRef);
      if (!snapshot.exists) throw Exception("Booking not found.");

      tx.update(docRef, {
        'status': QuotationStatus.rejectedByClient.nameStr,
        'rejectionReason': reason,
        'rejectionNote': note ?? '',
        'rejectedAt': FieldValue.serverTimestamp(),
        'rejectedBy': adminName,
        'rejectedByAdminId': adminId,
        'updated_at': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    }).then((success) async {
      final quote = await getBookingById(bookingId);
      if (quote != null) {
        await _recordAuditActivity(
          bookingId: bookingId,
          publicId: quote.publicId,
          action: 'booking_rejected',
          adminId: adminId,
          adminName: adminName,
          note: "Reason: $reason. ${note ?? ''}",
        );
        await _sendCustomerNotification(
          customerId: quote.customerId,
          publicBookingId: quote.publicId,
          bookingId: bookingId,
          title: "Booking Request Update",
          body: "Your booking request ${quote.publicId} could not be confirmed: $reason",
          type: "booking_rejected",
        );
      }
      return success;
    });
  }

  @override
  Future<bool> confirmBooking({
    required String bookingId,
    required String adminId,
    required String adminName,
  }) async {
    return _firestore.runTransaction<bool>((tx) async {
      final docRef = _firestore.collection(AppCollections.quotations).doc(bookingId);
      final snapshot = await tx.get(docRef);
      if (!snapshot.exists) throw Exception("Booking not found.");

      tx.update(docRef, {
        'status': QuotationStatus.bookingConfirmed.nameStr,
        'confirmedAt': FieldValue.serverTimestamp(),
        'confirmedBy': adminName,
        'confirmedByAdminId': adminId,
        'updated_at': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    }).then((success) async {
      final quote = await getBookingById(bookingId);
      if (quote != null) {
        await _recordAuditActivity(
          bookingId: bookingId,
          publicId: quote.publicId,
          action: 'booking_confirmed',
          adminId: adminId,
          adminName: adminName,
        );
        await _sendCustomerNotification(
          customerId: quote.customerId,
          publicBookingId: quote.publicId,
          bookingId: bookingId,
          title: "Booking Confirmed! 🌟",
          body: "Your celebration ${quote.publicId} is locked and confirmed with OM Events.",
          type: "booking_confirmed",
        );
      }
      return success;
    });
  }

  @override
  Future<bool> completeBooking({
    required String bookingId,
    required String adminId,
    required String adminName,
  }) async {
    return _firestore.runTransaction<bool>((tx) async {
      final docRef = _firestore.collection(AppCollections.quotations).doc(bookingId);
      final snapshot = await tx.get(docRef);
      if (!snapshot.exists) throw Exception("Booking not found.");

      tx.update(docRef, {
        'status': QuotationStatus.completed.nameStr,
        'completedAt': FieldValue.serverTimestamp(),
        'completedBy': adminName,
        'completedByAdminId': adminId,
        'updated_at': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    }).then((success) async {
      final quote = await getBookingById(bookingId);
      if (quote != null) {
        await _recordAuditActivity(
          bookingId: bookingId,
          publicId: quote.publicId,
          action: 'booking_completed',
          adminId: adminId,
          adminName: adminName,
        );
        await _sendCustomerNotification(
          customerId: quote.customerId,
          publicBookingId: quote.publicId,
          bookingId: bookingId,
          title: "Event Completed — We'd Love Your Review!",
          body: "Thank you for celebrating with us! Please share your experience by leaving a verified review.",
          type: "booking_completed",
        );
      }
      return success;
    });
  }

  @override
  Future<bool> approveCancellation({
    required String bookingId,
    required String adminId,
    required String adminName,
  }) async {
    return _firestore.runTransaction<bool>((tx) async {
      final docRef = _firestore.collection(AppCollections.quotations).doc(bookingId);
      final snapshot = await tx.get(docRef);
      if (!snapshot.exists) throw Exception("Booking not found.");

      tx.update(docRef, {
        'status': QuotationStatus.cancelled.nameStr,
        'cancellation_status': 'approved',
        'cancellationStatus': 'approved',
        'cancellationApprovedAt': FieldValue.serverTimestamp(),
        'cancellationApprovedBy': adminName,
        'updated_at': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    }).then((success) async {
      final quote = await getBookingById(bookingId);
      if (quote != null) {
        await _recordAuditActivity(
          bookingId: bookingId,
          publicId: quote.publicId,
          action: 'cancellation_approved',
          adminId: adminId,
          adminName: adminName,
        );
        await _sendCustomerNotification(
          customerId: quote.customerId,
          publicBookingId: quote.publicId,
          bookingId: bookingId,
          title: "Cancellation Request Approved",
          body: "Your cancellation request for ${quote.publicId} has been approved in accordance with our policy.",
          type: "cancellation_approved",
        );
      }
      return success;
    });
  }

  @override
  Future<bool> rejectCancellation({
    required String bookingId,
    required String adminId,
    required String adminName,
    required String reason,
  }) async {
    return _firestore.runTransaction<bool>((tx) async {
      final docRef = _firestore.collection(AppCollections.quotations).doc(bookingId);
      final snapshot = await tx.get(docRef);
      if (!snapshot.exists) throw Exception("Booking not found.");

      tx.update(docRef, {
        'cancellation_status': 'rejected',
        'cancellationStatus': 'rejected',
        'cancellationRejectionReason': reason,
        'cancellationRejectedAt': FieldValue.serverTimestamp(),
        'cancellationRejectedBy': adminName,
        'updated_at': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    }).then((success) async {
      final quote = await getBookingById(bookingId);
      if (quote != null) {
        await _recordAuditActivity(
          bookingId: bookingId,
          publicId: quote.publicId,
          action: 'cancellation_rejected',
          adminId: adminId,
          adminName: adminName,
          note: "Rejection Reason: $reason",
        );
        await _sendCustomerNotification(
          customerId: quote.customerId,
          publicBookingId: quote.publicId,
          bookingId: bookingId,
          title: "Cancellation Request Rejected",
          body: "Your cancellation request for ${quote.publicId} was not approved: $reason",
          type: "cancellation_rejected",
        );
      }
      return success;
    });
  }
}
