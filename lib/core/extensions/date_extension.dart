import 'package:intl/intl.dart';

/// Extension methods on [DateTime] to simplify localized date formatting.
extension DateExtension on DateTime {
  /// Formats this date as "dd MMMM yyyy" (e.g. 15 August 2026).
  String get formatMedium => DateFormat('dd MMMM yyyy').format(this);

  /// Formats this date as "dd-MM-yyyy" (e.g. 15-08-2026).
  String get formatShort => DateFormat('dd-MM-yyyy').format(this);

  /// Formats this date using a custom pattern.
  String formatCustom(String pattern) => DateFormat(pattern).format(this);
}
