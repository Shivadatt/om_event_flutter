import 'package:flutter/material.dart';
import '../../domain/entities/quotation.dart';
import '../services/booking_availability_service.dart';

/// Helper utility for calculating display and effective booking statuses.
///
/// Handles automatic local status resolution for expired pending bookings and
/// completed confirmed/accepted bookings without performing writes to Firestore.
class BookingStatusHelper {
  /// Checks if a status belongs to the "pending" group in the quotation workflow.
  static bool isPendingStatus(QuotationStatus status) {
    switch (status) {
      case QuotationStatus.draft:
      case QuotationStatus.published:
      case QuotationStatus.viewed:
      case QuotationStatus.republished:
      case QuotationStatus.revisionRequested:
      case QuotationStatus.underRevision:
        return true;
      default:
        return false;
    }
  }

  /// Checks if a status belongs to the "confirmed" or "accepted" group.
  static bool isConfirmedOrAcceptedStatus(QuotationStatus status) {
    switch (status) {
      case QuotationStatus.bookingConfirmed:
      case QuotationStatus.inProgress:
      case QuotationStatus.acceptedByClient:
        return true;
      default:
        return false;
    }
  }

  /// Determines whether the event calendar date has strictly passed compared to [referenceDate].
  ///
  /// Uses Indian Standard Time (IST) consistent with the project's booking rules.
  /// Compares pure calendar dates (ignoring time-of-day) to prevent off-by-one errors.
  /// On the event day itself, this returns false (the event is still active today).
  /// Starting from the next calendar day, this returns true (event date has passed).
  static bool isEventDatePassed(DateTime eventDate, {DateTime? referenceDate}) {
    final nowIst = referenceDate != null
        ? BookingAvailabilityService.toIst(referenceDate)
        : BookingAvailabilityService.nowIst();
    final todayCalendar = DateTime.utc(nowIst.year, nowIst.month, nowIst.day);

    final eventIst = BookingAvailabilityService.toIst(eventDate);
    final eventCalendar = DateTime.utc(eventIst.year, eventIst.month, eventIst.day);

    return eventCalendar.isBefore(todayCalendar);
  }

  /// Returns the locally-calculated effective [QuotationStatus] for a booking.
  ///
  /// - If the event date has passed and booking was pending -> [QuotationStatus.expired].
  /// - If the event date has passed and booking was confirmed/accepted -> [QuotationStatus.completed].
  /// - Terminal statuses (cancelled, rejected, completed, expired, archived) are preserved.
  /// - Future and current event dates preserve their original status.
  static QuotationStatus getEffectiveQuotationStatus(
    Quotation booking, {
    DateTime? referenceDate,
  }) {
    // 1. Explicit / terminal statuses preserved
    if (booking.status == QuotationStatus.cancelled) {
      return QuotationStatus.cancelled;
    }
    if (booking.status == QuotationStatus.rejectedByClient) {
      return QuotationStatus.rejectedByClient;
    }
    if (booking.status == QuotationStatus.completed) {
      return QuotationStatus.completed;
    }
    if (booking.status == QuotationStatus.archived) {
      return QuotationStatus.archived;
    }
    if (booking.status == QuotationStatus.expired) {
      return QuotationStatus.expired;
    }

    // 2. Check if event calendar date has passed
    final passed = isEventDatePassed(booking.eventDate, referenceDate: referenceDate);

    if (passed) {
      // Any active / confirmed / pending workflow status on a past date is EXPIRED
      return QuotationStatus.expired;
    }

    return booking.status;
  }

  /// Returns the user-facing display status string.
  ///
  /// Follows the status rules:
  /// 1. Future event date + pending -> "Pending"
  /// 2. Future event date + confirmed/accepted -> "Confirmed" or "Accepted"
  /// 3. Future event date + cancelled -> "Cancelled"
  /// 4. Future event date + rejected -> "Rejected"
  /// 5. Event date has passed + pending -> "Expired"
  /// 6. Event date has passed + confirmed/accepted -> "Completed"
  /// 7. Event date has passed + rejected -> "Rejected"
  /// 8. Event date has passed + cancelled -> "Cancelled"
  static String getDisplayBookingStatus(
    Quotation booking, {
    DateTime? referenceDate,
  }) {
    final effectiveStatus = getEffectiveQuotationStatus(
      booking,
      referenceDate: referenceDate,
    );

    switch (effectiveStatus) {
      case QuotationStatus.expired:
        return "Expired";
      case QuotationStatus.completed:
        return "Completed";
      case QuotationStatus.cancelled:
        return "Cancelled";
      case QuotationStatus.rejectedByClient:
        return "Rejected";
      case QuotationStatus.bookingConfirmed:
      case QuotationStatus.inProgress:
        return "Confirmed";
      case QuotationStatus.acceptedByClient:
        return "Accepted";
      case QuotationStatus.draft:
      case QuotationStatus.published:
      case QuotationStatus.viewed:
      case QuotationStatus.republished:
        return "Pending";
      case QuotationStatus.revisionRequested:
        return "Revision Requested";
      case QuotationStatus.underRevision:
        return "Under Revision";
      case QuotationStatus.archived:
        return "Archived";
    }
  }

  /// Returns the existing theme color token for the booking's display status.
  ///
  /// - Expired, Cancelled, Rejected, or active Cancellation Request: Error Red (0xFFEF4444)
  /// - Confirmed, Accepted, Completed: Success Green (0xFF4EBA7A)
  /// - Pending: Warm Gold (0xFFECC24A)
  static Color getStatusColor(
    Quotation booking, {
    DateTime? referenceDate,
    bool isCancellationRequested = false,
  }) {
    if (isCancellationRequested) {
      return const Color(0xFFEF4444);
    }

    final effectiveStatus = getEffectiveQuotationStatus(
      booking,
      referenceDate: referenceDate,
    );

    switch (effectiveStatus) {
      case QuotationStatus.published:
      case QuotationStatus.draft:
      case QuotationStatus.viewed:
      case QuotationStatus.republished:
      case QuotationStatus.revisionRequested:
      case QuotationStatus.underRevision:
        return const Color(0xFFECC24A); // Gold
      case QuotationStatus.acceptedByClient:
      case QuotationStatus.bookingConfirmed:
      case QuotationStatus.inProgress:
      case QuotationStatus.completed:
        return const Color(0xFF4EBA7A); // Emerald green (Success)
      case QuotationStatus.cancelled:
      case QuotationStatus.rejectedByClient:
      case QuotationStatus.expired:
        return const Color(0xFFEF4444); // Error / Warning Red
      case QuotationStatus.archived:
        return Colors.white54;
    }
  }
}
