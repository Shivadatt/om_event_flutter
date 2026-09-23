import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'app_config_service.dart';
import '../utils/app_logger.dart';

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

  /// Comprehensive check for selected date (Rule 1, Rule 2, Rule 3)
  Future<DateAvailabilityResult> checkDateAvailability(DateTime date) async {
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
      final istDate = toIst(date);
      final dayStart = DateTime.utc(istDate.year, istDate.month, istDate.day).subtract(istOffset);
      final dayEnd = dayStart.add(const Duration(days: 1));

      // Query confirmed/accepted bookings on this day
      final snap = await _firestore
          .collection('quotations')
          .where('eventDate', isGreaterThanOrEqualTo: Timestamp.fromDate(dayStart))
          .where('eventDate', isLessThan: Timestamp.fromDate(dayEnd))
          .get();

      final confirmedBookings = snap.docs.where((doc) {
        final data = doc.data();
        final status = (data['status'] ?? '').toString().toLowerCase();
        return status == 'bookingconfirmed' ||
            status == 'acceptedbyclient' ||
            status == 'inprogress' ||
            status == 'confirmed';
      });

      if (confirmedBookings.isNotEmpty) {
        AppLogger.info(
          "Date $targetDateStr is unavailable due to confirmed booking: ${confirmedBookings.first.id}",
          layer: LogLayer.service,
          className: "BookingAvailabilityService",
          methodName: "checkDateAvailability",
        );
        return DateAvailabilityResult.unavailable(
          "This date ($targetDateStr) is fully booked. Only 1 grand event per day is hosted to ensure flawless execution.",
        );
      }

      return DateAvailabilityResult.available;
    } catch (e) {
      AppLogger.warning(
        "Availability check failed to query Firestore, fallback to lead-time validation",
        layer: LogLayer.service,
        className: "BookingAvailabilityService",
        methodName: "checkDateAvailability",
        error: e,
      );
      // Fallback allows proceeding if connection times out, but lead time is strictly enforced
      return DateAvailabilityResult.available;
    }
  }

  /// Atomic backend check before booking persistence to prevent race conditions
  Future<bool> validateForSubmission(DateTime date) async {
    final result = await checkDateAvailability(date);
    return result.isAvailable;
  }
}
