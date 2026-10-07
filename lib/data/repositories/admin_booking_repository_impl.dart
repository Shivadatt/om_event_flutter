import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_collections.dart';
import '../../core/services/booking_availability_service.dart';
import '../../core/utils/app_logger.dart';
import '../../core/utils/date_parser.dart';
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
    // Early return: Notifications temporarily disabled
    return;
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
    try {
      final docRef = _firestore.collection(AppCollections.quotations).doc(bookingId);
      final snapshot = await docRef.get();
      if (!snapshot.exists) throw Exception("Booking does not exist.");

      final data = snapshot.data() ?? {};
      final currentStatus = (data['status'] ?? '').toString().toLowerCase();

      // Check current status
      if (currentStatus == 'cancelled' || currentStatus == 'rejectedbyclient') {
        throw Exception("Cannot accept a cancelled or rejected booking.");
      }

      // Re-verify date availability
      final eventDateRaw = data['event_date'] ?? data['eventDate'];
      final eventDate = DateParser.parseNullable(eventDateRaw);

      if (eventDate != null) {
        final availResult = await BookingAvailabilityService.to.checkDateAvailability(
          eventDate,
          excludeBookingId: bookingId,
        );
        if (!availResult.isAvailable) {
          throw Exception("Cannot accept booking: ${availResult.reason ?? 'This event date already has another active booking.'}");
        }
      }

      await docRef.update({
        'status': QuotationStatus.acceptedByClient.nameStr,
        'acceptedAt': FieldValue.serverTimestamp(),
        'acceptedBy': adminName,
        'acceptedByAdminId': adminId,
        'updated_at': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

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
      return true;
    } catch (e, stack) {
      AppLogger.errorDetailed(
        "Failed to accept booking $bookingId",
        layer: LogLayer.repository,
        className: "AdminBookingRepositoryImpl",
        methodName: "acceptBooking",
        error: e,
        stack: stack,
      );
      rethrow;
    }
  }

  @override
  Future<bool> rejectBooking({
    required String bookingId,
    required String adminId,
    required String adminName,
    required String reason,
    String? note,
  }) async {
    try {
      final docRef = _firestore.collection(AppCollections.quotations).doc(bookingId);
      final snapshot = await docRef.get();
      if (!snapshot.exists) throw Exception("Booking not found.");

      await docRef.update({
        'status': QuotationStatus.rejectedByClient.nameStr,
        'rejectionReason': reason,
        'rejectionNote': note ?? '',
        'rejectedAt': FieldValue.serverTimestamp(),
        'rejectedBy': adminName,
        'rejectedByAdminId': adminId,
        'updated_at': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

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
      return true;
    } catch (e, stack) {
      AppLogger.errorDetailed(
        "Failed to reject booking $bookingId",
        layer: LogLayer.repository,
        className: "AdminBookingRepositoryImpl",
        methodName: "rejectBooking",
        error: e,
        stack: stack,
      );
      rethrow;
    }
  }

  @override
  Future<bool> confirmBooking({
    required String bookingId,
    required String adminId,
    required String adminName,
  }) async {
    try {
      debugPrint("[REPO_CONFIRM] Step 1: Querying quotation doc: quotations/$bookingId");
      final docRef = _firestore.collection(AppCollections.quotations).doc(bookingId);
      final snapshot = await docRef.get();
      if (!snapshot.exists) {
        debugPrint("[REPO_CONFIRM] ERROR: quotations/$bookingId does not exist!");
        throw Exception("Booking not found.");
      }
      debugPrint("[REPO_CONFIRM] Step 1 OK: Quotation doc found.");

      final data = snapshot.data() ?? {};
      final eventDateRaw = data['event_date'] ?? data['eventDate'];
      final eventDate = DateParser.parseNullable(eventDateRaw);
      debugPrint("[REPO_CONFIRM] Step 2: Parsed eventDate: $eventDate (raw: $eventDateRaw)");

      if (eventDate == null) {
        debugPrint("[REPO_CONFIRM] ERROR: eventDate is null!");
        throw Exception("Cannot confirm booking: Event date is missing.");
      }

      // P2: Check date availability using canonical service (safely handles booked_dates and quotations)
      final dateStr = BookingAvailabilityService.normalizeDateString(eventDate);
      debugPrint("[REPO_CONFIRM] Step 3: Checking date availability for date: $dateStr...");
      final availResult = await BookingAvailabilityService.to.checkDateAvailability(
        eventDate,
        excludeBookingId: bookingId,
      );
      debugPrint("[REPO_CONFIRM] Step 3 result: isAvailable=${availResult.isAvailable}, reason=${availResult.reason}");

      if (!availResult.isAvailable) {
        debugPrint("[REPO_CONFIRM] ERROR: Date $dateStr is already booked!");
        throw Exception(
            "Cannot confirm booking: ${availResult.reason ?? 'This event date ($dateStr) is already locked by another confirmed booking.'}");
      }

      // Step 4: Authoritatively update quotation to confirmed status
      debugPrint("[REPO_CONFIRM] Step 4: Updating quotation doc: quotations/$bookingId to bookingConfirmed...");
      await docRef.update({
        'status': QuotationStatus.bookingConfirmed.nameStr,
        'confirmedAt': FieldValue.serverTimestamp(),
        'confirmedBy': adminName,
        'confirmedByAdminId': adminId,
        'normalized_event_date': dateStr,
        'updated_at': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint("[REPO_CONFIRM] Step 4 OK: Quotation status updated to bookingConfirmed!");

      // Step 4b: Best-effort atomic date lock document creation (booked_dates/{YYYY-MM-DD})
      final lockRef = _firestore.collection('booked_dates').doc(dateStr);
      try {
        debugPrint("[REPO_CONFIRM] Step 4b: Writing booked_dates/$dateStr lock document...");
        await lockRef.set({
          'date': dateStr,
          'bookingId': bookingId,
          'publicId': data['publicId'] ?? data['public_id'] ?? '',
          'confirmedAt': FieldValue.serverTimestamp(),
          'confirmedBy': adminName,
          'confirmedByAdminId': adminId,
        });
        debugPrint("[REPO_CONFIRM] Step 4b OK: booked_dates/$dateStr created successfully!");
      } catch (lockErr) {
        debugPrint("[REPO_CONFIRM] Step 4b notice (booked_dates permission/network): $lockErr");
      }

      debugPrint("[REPO_CONFIRM] Step 5: Post-confirmation actions (timeline, notifications, audit)...");
      final quote = await getBookingById(bookingId);
      if (quote != null) {
        // Update public booking timeline projection if present
        try {
          if (quote.publicId.isNotEmpty) {
            await _firestore.collection('booking_timelines').doc(quote.publicId).set({
              'status': QuotationStatus.bookingConfirmed.nameStr,
              'updatedAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
            debugPrint("[REPO_CONFIRM] Step 5a OK: booking_timelines updated");
          }
        } catch (tlErr) {
          debugPrint("[REPO_CONFIRM] Step 5a notice (timeline): $tlErr");
        }

        await _recordAuditActivity(
          bookingId: bookingId,
          publicId: quote.publicId,
          action: 'booking_confirmed',
          adminId: adminId,
          adminName: adminName,
        );
        debugPrint("[REPO_CONFIRM] Step 5b OK: audit activity recorded");

        await _sendCustomerNotification(
          customerId: quote.customerId,
          publicBookingId: quote.publicId,
          bookingId: bookingId,
          title: "Booking Confirmed! 🌟",
          body: "Your celebration ${quote.publicId} is locked and confirmed with OM Events.",
          type: "booking_confirmed",
        );
        debugPrint("[REPO_CONFIRM] Step 5c OK: customer notification sent");
      }
      debugPrint("[REPO_CONFIRM] >>> confirmBooking FINISHED SUCCESSFULLY! <<<");
      return true;
    } catch (e, stack) {
      AppLogger.errorDetailed(
        "Failed to confirm booking $bookingId",
        layer: LogLayer.repository,
        className: "AdminBookingRepositoryImpl",
        methodName: "confirmBooking",
        error: e,
        stack: stack,
      );
      rethrow;
    }
  }

  @override
  Future<bool> completeBooking({
    required String bookingId,
    required String adminId,
    required String adminName,
  }) async {
    try {
      final docRef = _firestore.collection(AppCollections.quotations).doc(bookingId);
      final snapshot = await docRef.get();
      if (!snapshot.exists) throw Exception("Booking not found.");

      await docRef.update({
        'status': QuotationStatus.completed.nameStr,
        'completedAt': FieldValue.serverTimestamp(),
        'completedBy': adminName,
        'completedByAdminId': adminId,
        'updated_at': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

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
      return true;
    } catch (e, stack) {
      AppLogger.errorDetailed(
        "Failed to complete booking $bookingId",
        layer: LogLayer.repository,
        className: "AdminBookingRepositoryImpl",
        methodName: "completeBooking",
        error: e,
        stack: stack,
      );
      rethrow;
    }
  }

  @override
  Future<bool> approveCancellation({
    required String bookingId,
    required String adminId,
    required String adminName,
  }) async {
    try {
      final docRef = _firestore.collection(AppCollections.quotations).doc(bookingId);
      final snapshot = await docRef.get();
      if (!snapshot.exists) throw Exception("Booking not found.");

      final data = snapshot.data() ?? {};
      final eventDateRaw = data['event_date'] ?? data['eventDate'];
      final eventDate = DateParser.parseNullable(eventDateRaw);

      // P2 FIX: Release the confirmed-date lock when admin approves cancellation
      if (eventDate != null) {
        try {
          final dateStr = BookingAvailabilityService.normalizeDateString(eventDate);
          final lockRef = _firestore.collection('booked_dates').doc(dateStr);
          final lockSnapshot = await lockRef.get();
          if (lockSnapshot.exists) {
            final lockData = lockSnapshot.data() ?? {};
            final existingBookingId = lockData['bookingId'] ?? lockData['booking_id'];
            if (existingBookingId == bookingId) {
              await lockRef.delete();
            }
          }
        } catch (_) {}
      }

      await docRef.update({
        'status': QuotationStatus.cancelled.nameStr,
        'cancellation_status': 'approved',
        'cancellationStatus': 'approved',
        'cancellationApprovedAt': FieldValue.serverTimestamp(),
        'cancellationApprovedBy': adminName,
        'updated_at': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final quote = await getBookingById(bookingId);
      if (quote != null) {
        // Sync public booking timeline projection if present
        try {
          if (quote.publicId.isNotEmpty) {
            await _firestore.collection('booking_timelines').doc(quote.publicId).set({
              'status': QuotationStatus.cancelled.nameStr,
              'updatedAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
          }
        } catch (_) {}
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
      return true;
    } catch (e, stack) {
      AppLogger.errorDetailed(
        "Failed to approve cancellation for booking $bookingId",
        layer: LogLayer.repository,
        className: "AdminBookingRepositoryImpl",
        methodName: "approveCancellation",
        error: e,
        stack: stack,
      );
      rethrow;
    }
  }

  @override
  Future<bool> rejectCancellation({
    required String bookingId,
    required String adminId,
    required String adminName,
    required String reason,
  }) async {
    try {
      final docRef = _firestore.collection(AppCollections.quotations).doc(bookingId);
      final snapshot = await docRef.get();
      if (!snapshot.exists) throw Exception("Booking not found.");

      await docRef.update({
        'cancellation_status': 'rejected',
        'cancellationStatus': 'rejected',
        'cancellationRejectionReason': reason,
        'cancellationRejectedAt': FieldValue.serverTimestamp(),
        'cancellationRejectedBy': adminName,
        'updated_at': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

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
      return true;
    } catch (e, stack) {
      AppLogger.errorDetailed(
        "Failed to reject cancellation for booking $bookingId",
        layer: LogLayer.repository,
        className: "AdminBookingRepositoryImpl",
        methodName: "rejectCancellation",
        error: e,
        stack: stack,
      );
      rethrow;
    }
  }
}
