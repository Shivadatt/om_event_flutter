import '../../../../core/utils/formatters.dart';
import '../../../../data/models/customer_model.dart';
import '../../../../domain/entities/quotation.dart';

/// Client statistics calculated from canonical customer records and linked quotations.
class CustomerStats {
  final double totalSpent;
  final int totalBookings;
  final String effectiveType;

  const CustomerStats({
    required this.totalSpent,
    required this.totalBookings,
    required this.effectiveType,
  });
}

/// Helper calculations for customer metrics and formatting.
class CustomerStatsCalculator {
  static CustomerStats calculate(CustomerModel customer, List<Quotation> quotes) {
    final cleanCustPhone = customer.phone.replaceAll(RegExp(r'\D'), '');
    final clientQuotes = quotes.where((q) {
      final cleanQuotePhone = q.customerPhone.replaceAll(RegExp(r'\D'), '');
      final phoneMatch = cleanCustPhone.isNotEmpty &&
          cleanQuotePhone.isNotEmpty &&
          (cleanQuotePhone.contains(cleanCustPhone) || cleanCustPhone.contains(cleanQuotePhone));
      final idMatch = customer.id.isNotEmpty && (q.customerId == customer.id || q.customerPhone == customer.id);
      final nameMatch = customer.name.isNotEmpty &&
          q.customerName.trim().toLowerCase() == customer.name.trim().toLowerCase();
      return phoneMatch || idMatch || nameMatch;
    }).toList();

    final int totalBookings = clientQuotes.length;
    final double totalSpent = clientQuotes.fold(0.0, (sum, q) => sum + q.grandTotal);

    String effectiveType = customer.type.trim();
    if (effectiveType.isEmpty || effectiveType.toLowerCase() == 'individual') {
      final hasCorporateQuote = clientQuotes.any((q) =>
          q.items.any((item) =>
              item.name.toLowerCase().contains('corporate') ||
              item.theme.toLowerCase().contains('corporate')) ||
          q.notes.toLowerCase().contains('corporate') ||
          q.notes.toLowerCase().contains('company'));
      if (hasCorporateQuote) {
        effectiveType = 'Corporate';
      } else if (totalSpent >= 50000) {
        effectiveType = 'VIP';
      } else {
        effectiveType = 'Individual';
      }
    }

    return CustomerStats(
      totalSpent: totalSpent,
      totalBookings: totalBookings,
      effectiveType: effectiveType,
    );
  }

  static String formatRevenueCompact(double amount) {
    if (amount >= 10000000) {
      return '₹${(amount / 10000000).toStringAsFixed(1)}Cr';
    } else if (amount >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '₹${(amount / 1000).toStringAsFixed(1)}K';
    }
    return AppFormatters.formatCurrency(amount);
  }

  static String getInitials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'C';
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return trimmed.substring(0, trimmed.length >= 2 ? 2 : 1).toUpperCase();
  }
}
