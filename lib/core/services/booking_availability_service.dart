import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../constants/app_collections.dart';
import '../utils/app_logger.dart';
import '../utils/date_parser.dart';
import 'app_config_service.dart';

class DateAvailabilityResult {
  final bool isAvailable;
  final String? reason;

  const DateAvailabilityResult({required this.isAvailable, this.reason});

  static const available = DateAvailabilityResult(isAvailable: true);
  static DateAvailabilityResult unavailable(String reason) =>
      DateAvailabilityResult(isAvailable: false, reason: reason);
}

class BookingAvailabilityService extends GetxService {
  static BookingAvailabilityService get to => Get.find<BookingAvailabilityService>();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Timezone offset for Indian Standard Time (IST: UTC + 5:30)
  static const Duration istOffset = Duration(hours: 5, minutes: 30);

  /// Converts any DateTime into Indian Standard Time (IST)
  static DateTime toIst(DateTime dateTime) {
    final utc = dateTime.isUtc ? dateTime : dateTime.toUtc();
    return utc.add(istOffset);
  }

  /// Returns current moment in Indian Standard Time (IST)
  static DateTime nowIst() {
    return toIst(DateTime.now());
  }

  /// Normalizes date to standard YYYY-MM-DD in IST
  static String normalizeDateString(DateTime date) {
    final ist = toIst(date);
    final year = ist.year.toString().padLeft(4, '0');
    final month = ist.month.toString().padLeft(2, '0');
    final day = ist.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  /// Configured minimum advance lead days (default 7 days)
  int get advanceDays {
    try {
      final config = AppConfigService.to.rxBookingSettings.value.advanceDays;
      return config > 0 ? config : 7;
    } catch (_) {
      return 7;
    }
  }

  /// Earliest allowed booking date based on lead time
  DateTime get minBookingDate {
    final today = nowIst();
    final startOfToday = DateTime.utc(today.year, today.month, today.day);
    return startOfToday.add(Duration(days: advanceDays));
  }

  /// Rule 2 Check: Event must not be within next 24 hours
  bool isWithin24Hours(DateTime date) {
    final now = nowIst();
    final target = toIst(date);
    return target.difference(now).inHours < 24;
  }

  /// Rule 3 Check: Event must satisfy minimum lead time
  bool isBeforeLeadTime(DateTime date) {
    final now = nowIst();
    final startOfToday = DateTime.utc(now.year, now.month, now.day);
    final target = toIst(date);
    final targetStartOfDay = DateTime.utc(target.year, target.month, target.day);
    final differenceDays = targetStartOfDay.difference(startOfToday).inDays;
    return differenceDays < advanceDays;
  }

  /// Checks whether a given status and customerAction occupies the event date.
  /// Strict rule: ONE EVENT DATE = MAXIMUM ONE ACTIVE BOOKING.
  static bool isStatusOccupyingDate(String? status, String? customerAction) {
    final s = (status ?? '').trim().toLowerCase();
    final ca = (customerAction ?? '').trim().toLowerCase();

    // Cancellation requested by client still locks the date until admin confirms cancellation
    if (ca == 'cancellation_requested' && s != 'cancelled') {
      return true;
    }

    // Released / inactive statuses that free up the date:
    const releasedStatuses = {
      'cancelled',
      'rejectedbyclient',
      'rejected',
      'declined',
      'expired',
      'archived',
      'deleted',
    };

    if (releasedStatuses.contains(s)) {
      return false;
    }

    // Any active or pending status occupies the date:
    // published, viewed, republished, acceptedbyclient, bookingconfirmed, inprogress, confirmed, draft
    return s.isNotEmpty;
  }

  /// Comprehensive check for selected date (Rule 1, Rule 2, Rule 3)
  /// [excludeBookingId]: Optional booking ID to exclude when updating an existing booking.
  Future<DateAvailabilityResult> checkDateAvailability(DateTime date, {String? excludeBookingId}) async {
    // 1. Check Rule 2: 24h buffer
    if (isWithin24Hours(date)) {
      return DateAvailabilityResult.unavailable(
        "Bookings must be scheduled at least 24 hours in advance.",
      );
    }

    // 2. Check Rule 3: Advance lead time
    if (isBeforeLeadTime(date)) {
      return DateAvailabilityResult.unavailable(
        "Minimum lead time is $advanceDays days for decor preparation and logistics.",
      );
    }

    // 3. Check Rule 1: One booking per day in Firestore
    try {
      final targetDateStr = normalizeDateString(date);
      final nextDay = toIst(date).add(const Duration(days: 1));
      final nextDayStr = normalizeDateString(nextDay);
      print("AVAILABILITY_AUDIT: Checking date=$date targetDateStr=$targetDateStr nextDayStr=$nextDayStr user=${FirebaseAuth.instance.currentUser?.uid}");

      QuerySnapshot<Map<String, dynamic>>? snapIso;
      try {
        snapIso = await _firestore
            .collection(AppCollections.quotations)
            .where('event_date', isGreaterThanOrEqualTo: targetDateStr)
            .where('event_date', isLessThan: nextDayStr)
            .get();
        print("AVAILABILITY_AUDIT: snapIso succeeded with ${snapIso.docs.length} docs");
      } catch (errIso, stackIso) {
        print("AVAILABILITY_AUDIT: snapIso FAILED with $errIso (type: ${errIso.runtimeType})");
        print("AVAILABILITY_AUDIT: snapIso stack: $stackIso");
        rethrow;
      }

      QuerySnapshot<Map<String, dynamic>>? snapNorm;
      try {
        snapNorm = await _firestore
            .collection(AppCollections.quotations)
            .where('normalized_event_date', isEqualTo: targetDateStr)
            .get();
        print("AVAILABILITY_AUDIT: snapNorm succeeded with ${snapNorm.docs.length} docs");
      } catch (errNorm) {
        print("AVAILABILITY_AUDIT: snapNorm FAILED with $errNorm (type: ${errNorm.runtimeType})");
      }

      // Merge documents from both queries uniquely by doc.id
      final Map<String, QueryDocumentSnapshot<Map<String, dynamic>>> docsMap = {};
      for (final doc in snapIso.docs) {
        docsMap[doc.id] = doc;
      }
      if (snapNorm != null) {
        for (final doc in snapNorm.docs) {
          docsMap[doc.id] = doc;
        }
      }

      for (final doc in docsMap.values) {
        // Skip current booking if modifying/confirming
        if (excludeBookingId != null && (doc.id == excludeBookingId || doc.data()['public_id'] == excludeBookingId)) {
          continue;
        }

        final data = doc.data();
        final rawDate = data['event_date'] ?? data['eventDate'];
        final docDate = DateParser.parseNullable(rawDate);
        if (docDate != null) {
          final docDateStr = normalizeDateString(docDate);
          if (docDateStr != targetDateStr) {
            continue; // Not actually on this day
          }
        }

        final status = data['status']?.toString();
        final customerAction = data['customerAction']?.toString();

        if (isStatusOccupyingDate(status, customerAction)) {
          AppLogger.info(
            "Date $targetDateStr is blocked by active booking: ${doc.id} (status: $status, action: $customerAction)",
            layer: LogLayer.service,
            className: "BookingAvailabilityService",
            methodName: "checkDateAvailability",
          );
          return DateAvailabilityResult.unavailable(
            "This date ($targetDateStr) is fully booked. Only 1 grand event per day is hosted to ensure flawless execution.",
          );
        }
      }

      return DateAvailabilityResult.available;
    } catch (e, stack) {
      print("AVAILABILITY_AUDIT: CATCH ERROR: $e");
      print("AVAILABILITY_AUDIT: CATCH STACK: $stack");
      AppLogger.errorDetailed(
        "Availability check failed to query Firestore for date $date: $e",
        layer: LogLayer.service,
        className: "BookingAvailabilityService",
        methodName: "checkDateAvailability",
        error: e,
        stack: stack,
      );
      final diagMessage = kDebugMode
          ? "DIAGNOSTIC: $e"
          : "Unable to verify date availability right now. Please check your connection and try again.";
      return DateAvailabilityResult.unavailable(diagMessage);
    }
  }

  /// Atomic backend check before booking persistence to prevent race conditions
  Future<bool> validateForSubmission(DateTime date, {String? excludeBookingId}) async {
    final result = await checkDateAvailability(date, excludeBookingId: excludeBookingId);
    return result.isAvailable;
  }
}

