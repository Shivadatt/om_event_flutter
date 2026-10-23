import 'package:flutter/material.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../data/models/customer_model.dart';
import 'customer_stats_calculator.dart';

/// Reusable avatar widget for customer list and cards.
/// Displays network photo with rounded radius or fallback gold-gradient initials medallion.
class CustomerAvatarBadge extends StatelessWidget {
  final CustomerModel customer;
  final Color primaryAccent;
  final double size;

  const CustomerAvatarBadge({
    super.key,
    required this.customer,
    required this.primaryAccent,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    final initials = CustomerStatsCalculator.getInitials(customer.name);

    if (customer.profileImageUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(size / 2),
        child: Image.network(
          customer.profileImageUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildInitialsAvatar(initials),
        ),
      );
    }
    return _buildInitialsAvatar(initials);
  }

  Widget _buildInitialsAvatar(String initials) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryAccent.withValues(alpha: 0.25),
            primaryAccent.withValues(alpha: 0.08),
          ],
        ),
        border: Border.all(
          color: primaryAccent.withValues(alpha: 0.4),
          width: 1.2,
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: AppTheme.serifHeader(
            fontSize: size * 0.38,
            fontWeight: FontWeight.bold,
            color: primaryAccent,
          ),
        ),
      ),
    );
  }
}
