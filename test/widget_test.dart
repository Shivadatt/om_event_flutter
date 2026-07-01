import 'package:flutter_test/flutter_test.dart';
import 'package:om_event/core/utils/formatters.dart';
import 'package:om_event/core/utils/validators.dart';

void main() {
  group('Validators Unit Tests', () {
    test('Phone cleaning strips non-digits and returns last 10 characters', () {
      expect(AppValidators.cleanPhone('+91 95121-49944'), '9512149944');
      expect(AppValidators.cleanPhone('093135 13156'), '9313513156');
      expect(AppValidators.cleanPhone('9876543210'), '9876543210');
      expect(AppValidators.cleanPhone('12345'), '12345');
    });

    test('Phone validation verifies clean 10 digit Indian mobiles', () {
      expect(AppValidators.isValidPhone('+91 95121 49944'), true);
      expect(AppValidators.isValidPhone('9512149944'), true);
      expect(AppValidators.isValidPhone('12345'), false);
      expect(AppValidators.isValidPhone(''), false);
    });

    test('Email validation checks format constraints', () {
      expect(AppValidators.isValidEmail('hello@omevents.in'), true);
      expect(
        AppValidators.isValidEmail('omeventsanddecorators@gmail.com'),
        true,
      );
      expect(AppValidators.isValidEmail('invalid-email'), false);
      expect(
        AppValidators.isValidEmail(''),
        true,
      ); // Optional field allowed empty
    });

    test('Future date validator identifies past vs future events', () {
      final future = DateTime.now().add(const Duration(days: 30));
      final past = DateTime.now().subtract(const Duration(days: 1));
      expect(AppValidators.isFutureDate(future), true);
      expect(AppValidators.isFutureDate(past), false);
    });
  });

  group('Formatters Unit Tests', () {
    test('Currency formatter outputs properly formatted INR values', () {
      expect(AppFormatters.formatCurrency(18500), '₹18,500');
      expect(AppFormatters.formatCurrency(14900), '₹14,900');
      expect(AppFormatters.formatCurrency(0), '₹0');
    });

    test('Short date formatter formats DateTime into short strings', () {
      final date = DateTime(2026, 6, 29);
      expect(AppFormatters.formatShortDate(date), '29-06-2026');
    });
  });
}
