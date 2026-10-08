import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_collections.dart';
import '../utils/app_logger.dart';
import '../utils/date_parser.dart';
import '../../domain/entities/quotation.dart';
import 'booking_availability_service.dart';

/// Production service responsible for auto-cancelling past non-confirmed bookings.
///
/// Business Rule:
/// IF eventDate < today (in Asia/Kolkata timezone)
/// AND status is a non-confirmed active/review status (e.g. underRevision, published, etc.)
/// THEN transition status to canonical CANCELLED in Firestore.
///
/// Protected statuses (bookingConfirmed, inProgress, completed) are NEVER auto-cancelled.
class PastBookingCancellationService {
  static bool _isSyncing = false;
  static final Set<String> _inFlightIds = {};

  /// Checks if a status is strictly protected against auto-cancellation.
  static bool isProtectedStatus(QuotationStatus status) {
    switch (status) {
      case QuotationStatus.bookingConfirmed:
      case QuotationStatus.inProgress:
      case QuotationStatus.completed:
        return true;
      default:
        return false;
    }
  }

  /// Checks if a status is a non-confirmed active/review status eligible for auto-cancellation.
  static bool isNonConfirmedStatus(QuotationStatus status) {
    switch (status) {
      case QuotationStatus.underRevision:
      case QuotationStatus.revisionRequested:
      case QuotationStatus.published:
      case QuotationStatus.draft:
      case QuotationStatus.viewed:
      case QuotationStatus.republished:
      case QuotationStatus.acceptedByClient:
        return true;
      default:
        return false;
    }
  }

  /// Determines whether the event calendar date has strictly passed compared to [referenceDate].
  ///
  /// Uses Asia/Kolkata (IST) timezone.
  /// Compares pure calendar dates (ignoring time-of-day).
  /// - Event date strictly before today -> returns true (PAST EVENT).
  /// - Event date equals today -> returns false (CURRENT DAY -> KEEP).
  /// - Event date after today -> returns false (FUTURE EVENT -> KEEP).
  static bool isPastEventDate(DateTime eventDate, {DateTime? referenceDate}) {
    final nowIst = referenceDate != null
        ? BookingAvailabilityService.toIst(referenceDate)
        : BookingAvailabilityService.nowIst();
    final todayCalendar = DateTime.utc(nowIst.year, nowIst.month, nowIst.day);

    final eventIst = BookingAvailabilityService.toIst(eventDate);
    final eventCalendar = DateTime.utc(eventIst.year, eventIst.month, eventIst.day);

    return eventCalendar.isBefore(todayCalendar);
  }

  /// Evaluates whether a quotation is eligible for auto-cancellation.
  static bool isEligibleForAutoCancellation(
    Quotation quote, {
    DateTime? referenceDate,
  }) {
    if (isProtectedStatus(quote.status) || quote.manualStatusOverride) {
      return false;
    }
    if (quote.status == QuotationStatus.cancelled ||
        quote.status == QuotationStatus.expired ||
        quote.status == QuotationStatus.rejectedByClient ||
        quote.status == QuotationStatus.archived) {
      return false;
    }
    if (!isNonConfirmedStatus(quote.status)) {
      return false;
    }
    return isPastEventDate(quote.eventDate, referenceDate: referenceDate);
  }

  /// Evaluates whether a quotation is eligible for auto-restoration.
  ///
  /// Criteria:
  /// - Currently cancelled.
  /// - The event calendar date is NOT past (i.e. today or in the future).
  static bool isEligibleForAutoRestoration(
    Quotation quote, {
    DateTime? referenceDate,
  }) {
    if (quote.status != QuotationStatus.cancelled) {
      return false;
    }
    return !isPastEventDate(quote.eventDate, referenceDate: referenceDate);
  }

  /// Executes guarded, idempotent synchronization of past non-confirmed bookings.
  ///
  /// Safe against concurrent updates: re-reads the latest document in Firestore
  /// before writing to ensure the status was not confirmed by an administrator.
  ///
  /// Bidirectional sync:
  /// 1. Auto-cancels past non-confirmed bookings.
  /// 2. Auto-restores auto-cancelled bookings when their event date is moved to today or the future.
  static Future<int> syncPastNonConfirmedBookings(
    List<Quotation> quotations, {
    FirebaseFirestore? firestore,
    DateTime? referenceDate,
  }) async {
    if (_isSyncing) return 0;

    final cancelCandidates = quotations.where((q) {
      if (_inFlightIds.contains(q.id)) return false;
      return isEligibleForAutoCancellation(q, referenceDate: referenceDate);
    }).toList();

    final restoreCandidates = quotations.where((q) {
      if (_inFlightIds.contains(q.id)) return false;
      return isEligibleForAutoRestoration(q, referenceDate: referenceDate);
    }).toList();

    if (cancelCandidates.isEmpty && restoreCandidates.isEmpty) return 0;

    _isSyncing = true;
    final db = firestore ?? FirebaseFirestore.instance;
    int modifiedCount = 0;

    try {
      // 1. Process auto-cancellations
      for (final quote in cancelCandidates) {
        _inFlightIds.add(quote.id);
        try {
          final docRef = db.collection(AppCollections.quotations).doc(quote.id);
          final snapshot = await docRef.get();
          if (!snapshot.exists) continue;

          final data = snapshot.data();
          if (data == null) continue;

          // Admin manual override guard
          if (data['manual_status_override'] == true) {
            continue;
          }

          final currentStatusStr = data['status'] as String? ?? '';
          final currentStatus = QuotationStatus.fromString(currentStatusStr);

          // Re-verify protection and terminal/explicit statuses on live document
          if (isProtectedStatus(currentStatus) ||
              currentStatus == QuotationStatus.cancelled ||
              currentStatus == QuotationStatus.expired ||
              currentStatus == QuotationStatus.rejectedByClient ||
              currentStatus == QuotationStatus.archived ||
              !isNonConfirmedStatus(currentStatus)) {
            continue;
          }

          final rawDate = data['event_date'] ?? data['eventDate'];
          final eventDate = DateParser.parseNullable(rawDate);
          if (eventDate == null || !isPastEventDate(eventDate, referenceDate: referenceDate)) {
            continue;
          }

          final existingReason = data['cancellation_reason'] ?? data['cancellationReason'];
          final reason = (existingReason != null && existingReason.toString().trim().isNotEmpty)
              ? existingReason.toString()
              : 'Automatically cancelled because the event date has passed.';

          await docRef.update({
            'status': QuotationStatus.cancelled.nameStr,
            'cancellation_reason': reason,
            'cancellationReason': reason,
            'cancellation_status': 'cancelled',
            'cancellation_type': 'auto_past_event',
            'updated_at': DateTime.now().toIso8601String(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
          modifiedCount++;

          // Release date lock in booked_dates if held
          try {
            final dateStr = BookingAvailabilityService.normalizeDateString(quote.eventDate);
            final lockRef = db.collection('booked_dates').doc(dateStr);
            final lockSnap = await lockRef.get();
            if (lockSnap.exists) {
              final lockData = lockSnap.data() ?? {};
              final existingBookingId = lockData['bookingId'] ?? lockData['booking_id'];
              if (existingBookingId == quote.id || existingBookingId == quote.publicId) {
                await lockRef.delete();
              }
            }
          } catch (_) {}

          // Sync timeline projection if present
          try {
            if (quote.publicId.isNotEmpty) {
              await db.collection('booking_timelines').doc(quote.publicId).set({
                'status': QuotationStatus.cancelled.nameStr,
                'updatedAt': FieldValue.serverTimestamp(),
              }, SetOptions(merge: true));
            }
          } catch (_) {}

          AppLogger.info("PastBookingCancellationService: Auto-cancelled ${quote.publicId} (${quote.id})");
        } catch (e) {
          AppLogger.warning("PastBookingCancellationService: Error cancelling ${quote.id}: $e");
        } finally {
          _inFlightIds.remove(quote.id);
        }
      }

      // 2. Process auto-restorations (when date was rescheduled to today or future)
      for (final quote in restoreCandidates) {
        _inFlightIds.add(quote.id);
        try {
          final docRef = db.collection(AppCollections.quotations).doc(quote.id);
          final snapshot = await docRef.get();
          if (!snapshot.exists) continue;

          final data = snapshot.data();
          if (data == null) continue;

          final currentStatusStr = data['status'] as String? ?? '';
          final currentStatus = QuotationStatus.fromString(currentStatusStr);

          if (currentStatus != QuotationStatus.cancelled) {
            continue;
          }

          final rawDate = data['event_date'] ?? data['eventDate'];
          final eventDate = DateParser.parseNullable(rawDate);
          if (eventDate == null || isPastEventDate(eventDate, referenceDate: referenceDate)) {
            continue;
          }

          final cancellationType = data['cancellation_type'] as String? ?? '';
          final cancellationReason = (data['cancellation_reason'] ?? data['cancellationReason'] ?? '').toString();
          final isAutoCancelled = cancellationType == 'auto_past_event' ||
              cancellationReason.toLowerCase().contains('automatically cancelled because the event date has passed');

          if (!isAutoCancelled) {
            // Manual cancellation: do not auto-restore
            continue;
          }

          final normDateStr = BookingAvailabilityService.normalizeDateString(eventDate);

          await docRef.update({
            'status': QuotationStatus.underRevision.nameStr,
            'cancellation_reason': FieldValue.delete(),
            'cancellationReason': FieldValue.delete(),
            'cancellation_status': FieldValue.delete(),
            'cancellation_type': FieldValue.delete(),
            'normalized_event_date': normDateStr,
            'updated_at': DateTime.now().toIso8601String(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
          modifiedCount++;

          // Sync timeline projection if present
          try {
            if (quote.publicId.isNotEmpty) {
              await db.collection('booking_timelines').doc(quote.publicId).set({
                'status': QuotationStatus.underRevision.nameStr,
                'updatedAt': FieldValue.serverTimestamp(),
              }, SetOptions(merge: true));
            }
          } catch (_) {}

          AppLogger.info("PastBookingCancellationService: Auto-restored ${quote.publicId} (${quote.id}) to underRevision");
        } catch (e) {
          AppLogger.warning("PastBookingCancellationService: Error restoring ${quote.id}: $e");
        } finally {
          _inFlightIds.remove(quote.id);
        }
      }
    } finally {
      _isSyncing = false;
    }

    return modifiedCount;
  }
}
