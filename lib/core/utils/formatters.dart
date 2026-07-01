import 'package:intl/intl.dart';

class AppFormatters {
  static final NumberFormat _inrCurrencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static final NumberFormat _inrCurrencyDoubleFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  static String formatCurrency(double amount) {
    return _inrCurrencyFormat.format(amount);
  }

  static String formatCurrencyDecimal(double amount) {
    return _inrCurrencyDoubleFormat.format(amount);
  }

  static String formatDate(DateTime date) {
    return DateFormat('dd MMMM yyyy').format(date);
  }

  static String formatTime(String hourMinute24) {
    try {
      final parts = hourMinute24.split(':');
      final time = DateTime(
        2026,
        1,
        1,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );
      return DateFormat('hh:mm a').format(time);
    } catch (_) {
      return hourMinute24;
    }
  }

  static String formatShortDate(DateTime date) {
    return DateFormat('dd-MM-yyyy').format(date);
  }
}
