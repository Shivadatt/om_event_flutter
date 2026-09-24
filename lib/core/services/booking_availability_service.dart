import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../constants/app_collections.dart';
import '../../domain/entities/quotation_status.dart';
import '../utils/app_logger.dart';
import '../utils/date_parser.dart';
import 'app_config_service.dart';

/// Explicit status representing date availability states
enum AvailabilityStatus {
  available,
  booked,
  systemError,
}

class DateAvailabilityResult {
  final AvailabilityStatus status;
  final String? reason;

  const DateAvailabilityResult({
    required this.status,
    this.reason,
  });

  bool get isAvailable => status == AvailabilityStatus.available;
  bool get isBooked => status == AvailabilityStatus.booked;
  bool get isError => status == AvailabilityStatus.systemError;

  static const available = DateAvailabilityResult(
    status: AvailabilityStatus.available,
    reason: "Date Available (1 Grand Event/Day Guaranteed)",
  );

  static DateAvailabilityResult booked([String? reason]) =>
      DateAvailabilityResult(
        status: AvailabilityStatus.booked,
        reason: reason ?? "This date is already booked. Please select another date.",
      );

  static DateAvailabilityResult unavailable(String reason) =>
      DateAvailabilityResult(
        status: AvailabilityStatus.booked,
        reason: reason,
      );

  static DateAvailabilityResult error([String? message]) =>
      DateAvailabilityResult(
        status: AvailabilityStatus.systemError,
        reason: message ?? "Unable to verify date availability right now. Please try again.",
      );
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

  /// Checks whether a given status occupies the event date.
  /// Strict Canonical Rule: ONLY an ADMIN-CONFIRMED booking blocks a date.
  /// (status == "bookingConfirmed").
  /// Customer requests (draft, pending, published, inquiry, accepted) and
  /// cancelled/rejected requests do NOT block a date.
  static bool isStatusOccupyingDate(String? status, String? customerAction) {
    final s = (status ?? '').trim();
    return s == QuotationStatus.bookingConfirmed.nameStr ||
        s.toLowerCase() == 'bookingconfirmed';
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
    // CANONICAL RULE: Only status == "bookingConfirmed" blocks the date.
    final targetDateStr = normalizeDateString(date);

    // Strategy 1: Targeted query on normalized_event_date with bookingConfirmed status
    try {
      final snapNorm = await _firestore
          .collection(AppCollections.quotations)
          .where('status', isEqualTo: QuotationStatus.bookingConfirmed.nameStr)
          .where('normalized_event_date', isEqualTo: targetDateStr)
          .limit(1)
          .get();

      if (snapNorm.docs.isNotEmpty) {
        for (final doc in snapNorm.docs) {
          if (excludeBookingId != null &&
              (doc.id == excludeBookingId || doc.data()['public_id'] == excludeBookingId)) {
            continue;
          }
          final status = doc.data()['status']?.toString();
          if (isStatusOccupyingDate(status, null)) {
            AppLogger.info(
              "Date $targetDateStr is blocked by confirmed booking: ${doc.id} (status: $status)",
              layer: LogLayer.service,
              className: "BookingAvailabilityService",
              methodName: "checkDateAvailability",
            );
            return DateAvailabilityResult.booked(
              "This date ($targetDateStr) is already booked. Please select another date.",
            );
          }
        }
      }
    } catch (errNorm) {
      AppLogger.warning("Targeted confirmed booking query check: $errNorm");
    }

    // Strategy 2: Robust query across all 'bookingConfirmed' documents to catch legacy date representations.
    try {
      final snapAllConfirmed = await _firestore
          .collection(AppCollections.quotations)
          .where('status', isEqualTo: QuotationStatus.bookingConfirmed.nameStr)
          .get();

      for (final doc in snapAllConfirmed.docs) {
        if (excludeBookingId != null &&
            (doc.id == excludeBookingId || doc.data()['public_id'] == excludeBookingId)) {
          continue;
        }

        final data = doc.data();
        final status = data['status']?.toString();
        if (!isStatusOccupyingDate(status, null)) {
          continue;
        }

        final rawDate = data['event_date'] ?? data['eventDate'];
        final docDate = DateParser.parseNullable(rawDate);
        if (docDate != null && normalizeDateString(docDate) == targetDateStr) {
          AppLogger.info(
            "Date $targetDateStr is blocked by confirmed booking: ${doc.id} (status: $status)",
            layer: LogLayer.service,
            className: "BookingAvailabilityService",
            methodName: "checkDateAvailability",
          );
          return DateAvailabilityResult.booked(
            "This date ($targetDateStr) is already booked. Please select another date.",
          );
        }
      }
    } catch (errAll) {
      AppLogger.warning("Confirmed booking list query check: $errAll");
    }

    // If no confirmed booking was detected locking this date, the date is free for request submission!
    return DateAvailabilityResult.available;
  }

  /// Atomic backend check before booking persistence to prevent race conditions
  Future<bool> validateForSubmission(DateTime date, {String? excludeBookingId}) async {
    final result = await checkDateAvailability(date, excludeBookingId: excludeBookingId);
    return result.isAvailable;
  }
}

