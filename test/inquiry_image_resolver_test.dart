import 'package:flutter_test/flutter_test.dart';
import 'package:om_event/core/services/inquiry_image_resolver.dart';
import 'package:om_event/domain/entities/customer_lead.dart';

void main() {
  setUp(() {
    InquiryImageResolver.clearCache();
  });

  group('InquiryImageResolver Tests', () {
    test('1. Resolves BABY SHOWER to canonical Baby Shower catalog image', () {
      final lead = CustomerLead(
        id: 'L-1',
        customerId: 'C-1',
        leadNumber: 'L-1790759112608',
        date: DateTime.now(),
        service: 'BABY SHOWER',
        branch: 'Kadi',
        budget: 10000,
        eventDate: DateTime.now().add(const Duration(days: 20)),
        status: 'Pending',
      );

      final resolvedUrl = InquiryImageResolver.resolve(lead);
      expect(resolvedUrl, equals('assets/images/babyshower.jpg'));
    });

    test('2. Resolves BIRTHDAY SERVICE to canonical Birthday catalog image', () {
      final lead = CustomerLead(
        id: 'L-2',
        customerId: 'C-1',
        leadNumber: 'L-1790750912402',
        date: DateTime.now(),
        service: 'BIRTHDAY SERVICE',
        branch: 'Kadi',
        budget: 8000,
        eventDate: DateTime.now().add(const Duration(days: 20)),
        status: 'Pending',
      );

      final resolvedUrl = InquiryImageResolver.resolve(lead);
      expect(resolvedUrl, equals('assets/images/birthday.jpg'));
    });

    test('3. Resolves FLOWER DECORATION to canonical Flower Decoration catalog image', () {
      final lead = CustomerLead(
        id: 'L-3',
        customerId: 'C-1',
        leadNumber: 'L-1790750912403',
        date: DateTime.now(),
        service: 'FLOWER DECORATION',
        branch: 'Kadi',
        budget: 15000,
        eventDate: DateTime.now().add(const Duration(days: 15)),
        status: 'Pending',
      );

      final resolvedUrl = InquiryImageResolver.resolve(lead);
      expect(resolvedUrl, equals('assets/images/wedding-stage.jpg'));
    });

    test('4. Resolves CHHATHI POOJAN to canonical Chhathi Pujan catalog image', () {
      final lead = CustomerLead(
        id: 'L-4',
        customerId: 'C-1',
        leadNumber: 'L-1790750912404',
        date: DateTime.now(),
        service: 'CHHATHI POOJAN',
        branch: 'Kadi',
        budget: 25000,
        eventDate: DateTime.now().add(const Duration(days: 10)),
        status: 'Pending',
      );

      final resolvedUrl = InquiryImageResolver.resolve(lead);
      expect(resolvedUrl, equals('assets/images/Chhathhi.jpg'));
    });

    test('5. Resolves ROOM DECORATION to canonical Room Decoration catalog image', () {
      final lead = CustomerLead(
        id: 'L-5',
        customerId: 'C-1',
        leadNumber: 'L-1790750912405',
        date: DateTime.now(),
        service: 'ROOM DECORATION',
        branch: 'Kadi',
        budget: 5000,
        eventDate: DateTime.now().add(const Duration(days: 5)),
        status: 'Pending',
      );

      final resolvedUrl = InquiryImageResolver.resolve(lead);
      expect(resolvedUrl, equals('assets/images/birthday-balloons.jpg'));
    });

    test('6. Historical inquiry with existing imageUrl preserves exact image', () {
      const historicalUrl = 'https://custom-storage.example.com/historical_inquiry_img.jpg';
      final lead = CustomerLead(
        id: 'L-6',
        customerId: 'C-1',
        leadNumber: 'L-HISTORICAL',
        date: DateTime.now(),
        service: 'BABY SHOWER',
        branch: 'Kadi',
        budget: 10000,
        eventDate: DateTime.now(),
        status: 'Completed',
        imageUrl: historicalUrl,
      );

      final resolvedUrl = InquiryImageResolver.resolve(lead);
      expect(resolvedUrl, equals(historicalUrl));
    });

    test('7. Inquiry with canonical serviceId resolves directly to that item', () {
      final lead = CustomerLead(
        id: 'L-7',
        customerId: 'C-1',
        leadNumber: 'L-BY-ID',
        date: DateTime.now(),
        service: 'Custom text that does not match directly',
        serviceId: 'signature-brand-launch',
        branch: 'Kadi',
        budget: 50000,
        eventDate: DateTime.now(),
        status: 'Pending',
      );

      final resolvedUrl = InquiryImageResolver.resolve(lead);
      expect(resolvedUrl, equals('assets/images/Pyro.jpg'));
    });

    test('8. Inquiry with canonical categoryId resolves to category image', () {
      final lead = CustomerLead(
        id: 'L-8',
        customerId: 'C-1',
        leadNumber: 'L-BY-CAT',
        date: DateTime.now(),
        service: 'Custom Event',
        categoryId: 'entries',
        branch: 'Kadi',
        budget: 20000,
        eventDate: DateTime.now(),
        status: 'Pending',
      );

      final resolvedUrl = InquiryImageResolver.resolve(lead);
      expect(resolvedUrl, equals('assets/images/SmokeEntry.jpg'));
    });

    test('9. Caching prevents redundant operations and returns cached url', () {
      final lead = CustomerLead(
        id: 'L-CACHE',
        customerId: 'C-1',
        leadNumber: 'L-CACHE-TEST',
        date: DateTime.now(),
        service: 'Baby Shower',
        branch: 'Kadi',
        budget: 10000,
        eventDate: DateTime.now(),
        status: 'Pending',
      );

      final url1 = InquiryImageResolver.resolve(lead);
      final url2 = InquiryImageResolver.resolve(lead);
      expect(url1, equals(url2));
    });
  });
}
