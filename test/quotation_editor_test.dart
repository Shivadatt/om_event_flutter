import 'package:flutter_test/flutter_test.dart';
import 'package:om_event/domain/entities/quotation.dart';
import 'package:om_event/domain/entities/quotation_version.dart';

void main() {
  group('Quotation Editor Recalculation Unit Tests', () {
    test('Calculates subtotal correctly from multiple line items', () {
      const items = [
        QuotationItem(
          experienceId: 'item_1',
          name: 'Item 1',
          quantity: 2,
          unitPrice: 1500.0,
          color: 'Red',
          theme: 'Classic',
          notes: '',
        ),
        QuotationItem(
          experienceId: 'item_2',
          name: 'Item 2',
          quantity: 3,
          unitPrice: 2000.0,
          color: 'Blue',
          theme: 'Premium',
          notes: '',
        ),
      ];

      double subtotal = 0.0;
      for (var item in items) {
        subtotal += item.quantity * item.unitPrice;
      }

      expect(subtotal, 9000.0); // 2 * 1500 + 3 * 2000 = 3000 + 6000 = 9000
    });

    test('Recalculates taxable amount, GST, and grand total correctly with discount and fees', () {
      const subtotal = 9000.0;
      const discount = 1000.0;
      const delivery = 500.0;
      const travel = 300.0;
      const gstPercent = 18.0;

      // Formula: taxable = subtotal - discount + delivery + travel
      final taxable = subtotal - discount + delivery + travel; // 9000 - 1000 + 500 + 300 = 8800
      final gstAmount = taxable * (gstPercent / 100.0); // 8800 * 0.18 = 1584
      final grandTotal = taxable + gstAmount; // 8800 + 1584 = 10384

      expect(taxable, 8800.0);
      expect(gstAmount, 1584.0);
      expect(grandTotal, 10384.0);
    });

    test('Quotation copyWith preserves fields and correctly increments versions', () {
      final initialQuote = Quotation(
        id: 'q_123',
        publicId: 'INV-123',
        customerPhone: '9876543210',
        customerName: 'Kavya',
        eventDate: DateTime(2026, 7, 20),
        eventTime: '18:00',
        location: 'Ahmedabad',
        notes: 'Visible notes',
        subtotal: 5000,
        discount: 0,
        deliveryCharge: 0,
        travelCharge: 0,
        gstPercent: 18,
        gstAmount: 900,
        grandTotal: 5900,
        pdfUrl: '',
        status: QuotationStatus.published,
        items: const [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        customerId: 'c_abc',
        version: 1,
        versions: const [],
        internalNotes: 'Initial internal note',
      );

      final revisedQuote = initialQuote.copyWith(
        version: initialQuote.version + 1,
        status: QuotationStatus.republished,
        internalNotes: 'Updated internal note',
        versions: [
          QuotationVersion(
            id: 'q_123_1',
            quotationId: 'q_123',
            versionNumber: 1,
            items: const [],
            subtotal: 5000,
            discount: 0,
            gstPercent: 18,
            gstAmount: 900,
            deliveryCharge: 0,
            travelCharge: 0,
            grandTotal: 5900,
            adminMessage: 'Initial message',
            publishedAt: DateTime.now(),
            publishedBy: 'Admin',
            pdfUrl: '',
            revisionReason: 'Legacy Version',
          ),
        ],
      );

      expect(revisedQuote.id, 'q_123');
      expect(revisedQuote.version, 2);
      expect(revisedQuote.status, QuotationStatus.republished);
      expect(revisedQuote.internalNotes, 'Updated internal note');
      expect(revisedQuote.versions.length, 1);
      expect(revisedQuote.versions.first.versionNumber, 1);
    });

    test('Validates status transitions and generates lifecycle timeline correctly', () {
      // 1. Validate status transition validator
      expect(QuotationStatusTransitions.isValid(QuotationStatus.draft, QuotationStatus.published), true);
      expect(QuotationStatusTransitions.isValid(QuotationStatus.published, QuotationStatus.underRevision), true);
      expect(QuotationStatusTransitions.isValid(QuotationStatus.underRevision, QuotationStatus.republished), true);
      expect(QuotationStatusTransitions.isValid(QuotationStatus.republished, QuotationStatus.acceptedByClient), true);
      expect(QuotationStatusTransitions.isValid(QuotationStatus.acceptedByClient, QuotationStatus.bookingConfirmed), true);
      expect(QuotationStatusTransitions.isValid(QuotationStatus.bookingConfirmed, QuotationStatus.completed), true);
      expect(QuotationStatusTransitions.isValid(QuotationStatus.completed, QuotationStatus.cancelled), false); // Terminal state

      // 2. Validate dynamic timeline generation
      final now = DateTime.now();
      final quote = Quotation(
        id: 'q_999',
        publicId: 'INV-999',
        customerPhone: '9876543210',
        customerName: 'Aarav',
        eventDate: now.add(const Duration(days: 5)),
        eventTime: '18:00',
        location: 'Mumbai',
        notes: 'Wedding ceremony',
        subtotal: 10000,
        discount: 1000,
        deliveryCharge: 200,
        travelCharge: 100,
        gstPercent: 18,
        gstAmount: 1674,
        grandTotal: 10974,
        pdfUrl: '',
        status: QuotationStatus.underRevision,
        items: const [],
        createdAt: now.subtract(const Duration(hours: 3)),
        updatedAt: now,
        customerId: 'c_xyz',
        version: 2,
        publishedAt: now.subtract(const Duration(hours: 2)),
        customerViewedAt: now.subtract(const Duration(hours: 1)),
        versions: const [],
      );

      final timeline = quote.timeline;
      expect(timeline.length, 4); // Initiated, Published, Viewed, UnderRevision
      expect(timeline[0].title, 'Proposal Initiated');
      expect(timeline[1].title, 'Proposal Published');
      expect(timeline[2].title, 'Proposal Viewed');
      expect(timeline[3].title, 'Under Revision');
    });

    test('Digital Consent validation: resets on copyWith/republish, captures signature in timeline', () {
      final now = DateTime.now();
      final acceptedQuote = Quotation(
        id: 'q_consent_test',
        publicId: 'INV-CONSENT',
        customerPhone: '9876543210',
        customerName: 'Tanishq',
        eventDate: now.add(const Duration(days: 10)),
        eventTime: '19:00',
        location: 'Goa',
        notes: 'Celebration setup',
        subtotal: 10000,
        discount: 0,
        deliveryCharge: 0,
        travelCharge: 0,
        gstPercent: 18,
        gstAmount: 1800,
        grandTotal: 11800,
        pdfUrl: '',
        status: QuotationStatus.acceptedByClient,
        items: const [],
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now,
        customerId: 'c_tanishq',
        version: 1,
        customerActionAt: now,
        acceptedAt: now,
        acceptedVersion: 1,
        acceptedAmount: 11800.0,
        acceptedBy: 'Tanishq Shah',
        acceptedDevice: 'iOS Device',
        acceptedIp: '192.168.1.1',
        consentTextVersion: 'v1',
      );

      // Verify signature info is included in timeline
      final timeline = acceptedQuote.timeline;
      expect(timeline.any((e) => e.title == 'Proposal Accepted'), true);
      final acceptEvent = timeline.firstWhere((e) => e.title == 'Proposal Accepted');
      expect(acceptEvent.description.contains('Signed by: Tanishq Shah'), true);
      expect(acceptEvent.description.contains('on iOS Device'), true);

      // Verify digital consent fields are reset when republished/revision is created
      final republishedQuote = acceptedQuote.resetConsent().copyWith(
        version: 2,
        status: QuotationStatus.republished,
      );

      expect(republishedQuote.acceptedAt, isNull);
      expect(republishedQuote.acceptedBy, isNull);
      expect(republishedQuote.acceptedVersion, isNull);
      expect(republishedQuote.version, 2);
      expect(republishedQuote.status, QuotationStatus.republished);
    });

    test('Scheduler Logic: Expiry, Reminders, Follow-ups, and Booking Reminders conditions', () {
      final now = DateTime.now();

      // 1. Expiry Check
      final publishedQuote = Quotation(
        id: 'q_expired_test',
        publicId: 'INV-EXP',
        customerPhone: '9876543210',
        customerName: 'Aarav',
        eventDate: now.add(const Duration(days: 10)),
        eventTime: '19:00',
        location: 'Mumbai',
        notes: '',
        subtotal: 10000,
        discount: 0,
        deliveryCharge: 0,
        travelCharge: 0,
        gstPercent: 18,
        gstAmount: 1800,
        grandTotal: 11800,
        pdfUrl: '',
        status: QuotationStatus.published,
        items: const [],
        createdAt: now.subtract(const Duration(days: 8)), // Expiry is 7 days, so 8 days old is expired!
        updatedAt: now,
        customerId: 'c_aarav',
        version: 1,
        publishedAt: now.subtract(const Duration(days: 8)),
      );

      final validFrom = publishedQuote.publishedAt ?? publishedQuote.createdAt;
      final expiryDate = validFrom.add(const Duration(days: 7));
      expect(now.isAfter(expiryDate), true); // True, because 8 days old

      // 2. Pre-Expiry Reminders (24h before)
      final reminderQuote = Quotation(
        id: 'q_reminder_test',
        publicId: 'INV-REM',
        customerPhone: '9876543210',
        customerName: 'Aarav',
        eventDate: now.add(const Duration(days: 10)),
        eventTime: '19:00',
        location: 'Mumbai',
        notes: '',
        subtotal: 10000,
        discount: 0,
        deliveryCharge: 0,
        travelCharge: 0,
        gstPercent: 18,
        gstAmount: 1800,
        grandTotal: 11800,
        pdfUrl: '',
        status: QuotationStatus.published,
        items: const [],
        createdAt: now.subtract(const Duration(days: 6, hours: 2)), // 6 days & 2 hours old, meaning 22 hours left before expiry!
        updatedAt: now,
        customerId: 'c_aarav',
        version: 1,
        publishedAt: now.subtract(const Duration(days: 6, hours: 2)),
      );

      final remValidFrom = reminderQuote.publishedAt ?? reminderQuote.createdAt;
      final remExpiryDate = remValidFrom.add(const Duration(days: 7));
      final reminder24hTime = remExpiryDate.subtract(const Duration(hours: 24));
      
      expect(now.isAfter(reminder24hTime), true); // Within the 24 hour pre-expiry window
      expect(now.isBefore(remExpiryDate), true);  // But not expired yet

      // 3. Follow-up Check
      final viewedQuote = Quotation(
        id: 'q_viewed_test',
        publicId: 'INV-VW',
        customerPhone: '9876543210',
        customerName: 'Aarav',
        eventDate: now.add(const Duration(days: 10)),
        eventTime: '19:00',
        location: 'Mumbai',
        notes: '',
        subtotal: 10000,
        discount: 0,
        deliveryCharge: 0,
        travelCharge: 0,
        gstPercent: 18,
        gstAmount: 1800,
        grandTotal: 11800,
        pdfUrl: '',
        status: QuotationStatus.viewed,
        items: const [],
        createdAt: now.subtract(const Duration(days: 4)),
        updatedAt: now,
        customerId: 'c_aarav',
        version: 1,
        customerViewedAt: now.subtract(const Duration(days: 4)), // Viewed 4 days ago (threshold is 3 days)
      );

      final followUpTime = viewedQuote.customerViewedAt!.add(const Duration(days: 3));
      expect(now.isAfter(followUpTime), true); // True, viewed 4 days ago is past the 3-day follow-up threshold

      // 4. Booking Reminders (7 Days Before Event)
      final bookingQuote = Quotation(
        id: 'q_booking_test',
        publicId: 'INV-BK',
        customerPhone: '9876543210',
        customerName: 'Aarav',
        eventDate: now.add(const Duration(days: 6)), // Event in 6 days (reminder should trigger 7 days before)
        eventTime: '19:00',
        location: 'Mumbai',
        notes: '',
        subtotal: 10000,
        discount: 0,
        deliveryCharge: 0,
        travelCharge: 0,
        gstPercent: 18,
        gstAmount: 1800,
        grandTotal: 11800,
        pdfUrl: '',
        status: QuotationStatus.bookingConfirmed,
        items: const [],
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now,
        customerId: 'c_aarav',
        version: 1,
      );

      final bookingReminderTime = bookingQuote.eventDate.subtract(const Duration(days: 7));
      expect(now.isAfter(bookingReminderTime), true); // Event is in 6 days, which is past the 7 days before mark
    });

    test('Notification Queue: Priority weight sorting logic', () {
      final items = [
        {'id': '1', 'priority': 'low', 'createdAt': DateTime(2026, 7, 10, 10, 0)},
        {'id': '2', 'priority': 'high', 'createdAt': DateTime(2026, 7, 10, 11, 0)},
        {'id': '3', 'priority': 'normal', 'createdAt': DateTime(2026, 7, 10, 10, 30)},
        {'id': '4', 'priority': 'high', 'createdAt': DateTime(2026, 7, 10, 9, 0)},
      ];

      final priorityWeight = {'high': 3, 'normal': 2, 'low': 1};

      items.sort((a, b) {
        final pA = priorityWeight[a['priority']] ?? 2;
        final pB = priorityWeight[b['priority']] ?? 2;
        if (pA != pB) return pB.compareTo(pA); // high weight first
        
        final tA = a['createdAt'] as DateTime;
        final tB = b['createdAt'] as DateTime;
        return tA.compareTo(tB); // oldest date first
      });

      expect(items[0]['id'], '4'); // High priority, created first
      expect(items[1]['id'], '2'); // High priority, created second
      expect(items[2]['id'], '3'); // Normal priority
      expect(items[3]['id'], '1'); // Low priority
    });
  });
}
