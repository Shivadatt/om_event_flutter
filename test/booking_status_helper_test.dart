import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:om_event/core/services/past_booking_cancellation_service.dart';
import 'package:om_event/core/utils/booking_status_helper.dart';
import 'package:om_event/core/utils/date_parser.dart';
import 'package:om_event/domain/entities/quotation.dart';

Quotation createTestQuotation({
  required String id,
  required QuotationStatus status,
  required DateTime eventDate,
  String? customerAction,
}) {
  return Quotation(
    id: id,
    publicId: 'OM-$id',
    customerPhone: '+91 9876543210',
    customerName: 'Test Client',
    eventDate: eventDate,
    eventTime: '18:00',
    location: 'Ahmedabad',
    notes: 'Test event notes',
    subtotal: 50000,
    discount: 5000,
    deliveryCharge: 1000,
    travelCharge: 1000,
    gstPercent: 18,
    gstAmount: 8460,
    grandTotal: 55460,
    pdfUrl: '',
    status: status,
    items: const [],
    createdAt: DateTime.utc(2026, 10, 1),
    updatedAt: DateTime.utc(2026, 10, 1),
    customerId: 'cust-123',
    customerAction: customerAction,
  );
}

void main() {
  group('Past Event Auto-Cancellation & Status System Tests', () {
    // Reference date: 8 Oct 2026
    final refToday = DateTime.utc(2026, 10, 8);
    final futureDate = DateTime.utc(2026, 10, 18);
    final pastDate = DateTime.utc(2026, 10, 7); // Exactly matches bug case (07-10-2026)
    final todayDate = DateTime.utc(2026, 10, 8);

    group('Eligibility Status Matrix Tests (Section 19)', () {
      test('A. Past + UNDERREVIEW (underRevision) -> EXPIRED', () {
        final quote = createTestQuotation(
          id: 'A',
          status: QuotationStatus.underRevision,
          eventDate: pastDate,
        );
        expect(
          BookingStatusHelper.getEffectiveQuotationStatus(quote, referenceDate: refToday),
          equals(QuotationStatus.expired),
        );
        expect(
          BookingStatusHelper.getDisplayBookingStatus(quote, referenceDate: refToday),
          equals('Expired'),
        );
      });

      test('B. Past + PUBLISHED -> EXPIRED', () {
        final quote = createTestQuotation(
          id: 'B',
          status: QuotationStatus.published,
          eventDate: pastDate,
        );
        expect(
          BookingStatusHelper.getEffectiveQuotationStatus(quote, referenceDate: refToday),
          equals(QuotationStatus.expired),
        );
        expect(
          BookingStatusHelper.getDisplayBookingStatus(quote, referenceDate: refToday),
          equals('Expired'),
        );
      });

      test('C. Past + bookingConfirmed -> EXPIRED (Section 11 / Case 9)', () {
        final quote = createTestQuotation(
          id: 'C',
          status: QuotationStatus.bookingConfirmed,
          eventDate: pastDate,
        );
        expect(
          PastBookingCancellationService.isEligibleForAutoCancellation(quote, referenceDate: refToday),
          isFalse,
        );
        expect(PastBookingCancellationService.isProtectedStatus(quote.status), isTrue);
        expect(
          BookingStatusHelper.getEffectiveQuotationStatus(quote, referenceDate: refToday),
          equals(QuotationStatus.expired),
        );
      });

      test('D. Past + COMPLETED -> KEEP (NEVER CANCEL)', () {
        final quote = createTestQuotation(
          id: 'D',
          status: QuotationStatus.completed,
          eventDate: pastDate,
        );
        expect(
          PastBookingCancellationService.isEligibleForAutoCancellation(quote, referenceDate: refToday),
          isFalse,
        );
        expect(PastBookingCancellationService.isProtectedStatus(quote.status), isTrue);
        expect(
          BookingStatusHelper.getEffectiveQuotationStatus(quote, referenceDate: refToday),
          equals(QuotationStatus.completed),
        );
      });

      test('E. Today + UNDERREVIEW -> KEEP (NOT PAST YET)', () {
        final quote = createTestQuotation(
          id: 'E',
          status: QuotationStatus.underRevision,
          eventDate: todayDate,
        );
        expect(
          PastBookingCancellationService.isEligibleForAutoCancellation(quote, referenceDate: refToday),
          isFalse,
        );
        expect(
          BookingStatusHelper.getEffectiveQuotationStatus(quote, referenceDate: refToday),
          equals(QuotationStatus.underRevision),
        );
      });

      test('F. Future + UNDERREVIEW -> KEEP', () {
        final quote = createTestQuotation(
          id: 'F',
          status: QuotationStatus.underRevision,
          eventDate: futureDate,
        );
        expect(
          PastBookingCancellationService.isEligibleForAutoCancellation(quote, referenceDate: refToday),
          isFalse,
        );
        expect(
          BookingStatusHelper.getEffectiveQuotationStatus(quote, referenceDate: refToday),
          equals(QuotationStatus.underRevision),
        );
      });

      test('G. Future + bookingConfirmed -> KEEP', () {
        final quote = createTestQuotation(
          id: 'G',
          status: QuotationStatus.bookingConfirmed,
          eventDate: futureDate,
        );
        expect(
          PastBookingCancellationService.isEligibleForAutoCancellation(quote, referenceDate: refToday),
          isFalse,
        );
        expect(
          BookingStatusHelper.getEffectiveQuotationStatus(quote, referenceDate: refToday),
          equals(QuotationStatus.bookingConfirmed),
        );
      });

      test('H. Already CANCELLED -> no additional write / not eligible', () {
        final quote = createTestQuotation(
          id: 'H',
          status: QuotationStatus.cancelled,
          eventDate: pastDate,
        );
        expect(
          PastBookingCancellationService.isEligibleForAutoCancellation(quote, referenceDate: refToday),
          isFalse,
        );
        expect(
          BookingStatusHelper.getEffectiveQuotationStatus(quote, referenceDate: refToday),
          equals(QuotationStatus.cancelled),
        );
      });

      test('I. EXPIRED on past date -> KEEP AS EXPIRED (NEVER AUTO-CANCEL)', () {
        final quote = createTestQuotation(
          id: 'I',
          status: QuotationStatus.expired,
          eventDate: pastDate,
        );
        expect(
          PastBookingCancellationService.isEligibleForAutoCancellation(quote, referenceDate: refToday),
          isFalse,
        );
        expect(
          BookingStatusHelper.getEffectiveQuotationStatus(quote, referenceDate: refToday),
          equals(QuotationStatus.expired),
        );
        expect(
          BookingStatusHelper.getDisplayBookingStatus(quote, referenceDate: refToday),
          equals('Expired'),
        );
      });
    });

    group('Canonical Date Comparison Tests', () {
      test('Today 08-10-2026 vs Event 07-10-2026 -> PAST EVENT', () {
        expect(
          PastBookingCancellationService.isPastEventDate(DateTime.utc(2026, 10, 7), referenceDate: refToday),
          isTrue,
        );
      });

      test('Today 08-10-2026 vs Event 08-10-2026 -> CURRENT DAY (NOT PAST)', () {
        expect(
          PastBookingCancellationService.isPastEventDate(DateTime.utc(2026, 10, 8), referenceDate: refToday),
          isFalse,
        );
      });

      test('Today 08-10-2026 vs Event 09-10-2026 -> FUTURE EVENT', () {
        expect(
          PastBookingCancellationService.isPastEventDate(DateTime.utc(2026, 10, 9), referenceDate: refToday),
          isFalse,
        );
      });
    });

    group('Exact Production Bug Case: OM-20261015-288', () {
      test('OM-20261015-288 on 08-10-2026 with event 07-10-2026 transitions to EXPIRED', () {
        final quote = createTestQuotation(
          id: '1790238329504',
          status: QuotationStatus.underRevision,
          eventDate: DateTime.parse('2026-10-07T00:00:00.000'),
        );

        expect(
          BookingStatusHelper.getEffectiveQuotationStatus(quote, referenceDate: refToday),
          equals(QuotationStatus.expired),
        );
        expect(
          BookingStatusHelper.getDisplayBookingStatus(quote, referenceDate: refToday),
          equals('Expired'),
        );
        expect(
          BookingStatusHelper.getStatusColor(quote, referenceDate: refToday),
          equals(const Color(0xFFEF4444)),
        );
      });

      test('OM-20261015-288 rescheduled to 09-10-2026 or 10-10-2026 is eligible for AUTO-RESTORATION', () {
        // When user changes date to 09-10-2026
        final rescheduledQuote9 = createTestQuotation(
          id: '1790238329504',
          status: QuotationStatus.cancelled,
          eventDate: DateTime.parse('2026-10-09T00:00:00.000'),
        );

        expect(
          PastBookingCancellationService.isPastEventDate(rescheduledQuote9.eventDate, referenceDate: refToday),
          isFalse,
        );
        expect(
          PastBookingCancellationService.isEligibleForAutoRestoration(rescheduledQuote9, referenceDate: refToday),
          isTrue,
        );
        expect(
          PastBookingCancellationService.isEligibleForAutoCancellation(rescheduledQuote9, referenceDate: refToday),
          isFalse,
        );

        // When user changes date to 10-10-2026
        final rescheduledQuote10 = createTestQuotation(
          id: '1790238329504',
          status: QuotationStatus.cancelled,
          eventDate: DateTime.parse('2026-10-10T00:00:00.000'),
        );

        expect(
          PastBookingCancellationService.isPastEventDate(rescheduledQuote10.eventDate, referenceDate: refToday),
          isFalse,
        );
        expect(
          PastBookingCancellationService.isEligibleForAutoRestoration(rescheduledQuote10, referenceDate: refToday),
          isTrue,
        );

        // When restored to underRevision
        final restoredQuote = rescheduledQuote9.copyWith(status: QuotationStatus.underRevision);
        expect(
          BookingStatusHelper.getEffectiveQuotationStatus(restoredQuote, referenceDate: refToday),
          equals(QuotationStatus.underRevision),
        );
        expect(
          BookingStatusHelper.getDisplayBookingStatus(restoredQuote, referenceDate: refToday),
          equals('Under Revision'),
        );
      });

      test('QuotationStatusTransitions allows CANCELLED to underRevision, republished, draft, expired, archived', () {
        expect(QuotationStatusTransitions.isValid(QuotationStatus.cancelled, QuotationStatus.underRevision), isTrue);
        expect(QuotationStatusTransitions.isValid(QuotationStatus.cancelled, QuotationStatus.republished), isTrue);
        expect(QuotationStatusTransitions.isValid(QuotationStatus.cancelled, QuotationStatus.draft), isTrue);
        expect(QuotationStatusTransitions.isValid(QuotationStatus.cancelled, QuotationStatus.expired), isTrue);
        expect(QuotationStatusTransitions.isValid(QuotationStatus.cancelled, QuotationStatus.archived), isTrue);
        expect(QuotationStatusTransitions.isValid(QuotationStatus.cancelled, QuotationStatus.bookingConfirmed), isFalse);
        expect(QuotationStatusTransitions.isValid(QuotationStatus.expired, QuotationStatus.underRevision), isTrue);
      });
    });

    group('Firestore Timestamp Parsing & Preserved Data Integrity', () {
      test('Parses ISO8601 string and Timestamp correctly without timezone shift', () {
        final ts = Timestamp.fromDate(DateTime.utc(2026, 10, 7, 5, 30));
        final parsed = DateParser.parse(ts);
        expect(parsed.year, equals(2026));
        expect(parsed.month, equals(10));
        expect(parsed.day, equals(7));

        final quote = createTestQuotation(
          id: 'ts-1',
          status: QuotationStatus.published,
          eventDate: parsed,
        );
        expect(
          PastBookingCancellationService.isEligibleForAutoCancellation(quote, referenceDate: refToday),
          isTrue,
        );
      });
    });
  });
}
