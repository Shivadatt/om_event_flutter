import '../utils/formatters.dart';

/// Extension methods on [double] to format numbers and currency.
extension DoubleExtension on double {
  /// Formats this double as an INR currency string (e.g. ₹15,000).
  String get toCurrency => AppFormatters.formatCurrency(this);

  /// Formats this double as an INR currency string with decimal places (e.g. ₹15,000.00).
  String get toCurrencyDecimal => AppFormatters.formatCurrencyDecimal(this);
}
