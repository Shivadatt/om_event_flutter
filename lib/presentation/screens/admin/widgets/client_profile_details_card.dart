import 'package:flutter/material.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/customer_model.dart';

class ClientProfileDetailsCard extends StatelessWidget {
  final CustomerModel customer;
  final bool isMobile;

  const ClientProfileDetailsCard({
    super.key,
    required this.customer,
    this.isMobile = false,
  });

  Widget _detailRow(
    BuildContext context,
    String label,
    String value,
    Color textColor,
  ) {
    final labelWidth = isMobile ? 100.0 : 120.0;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isMobile ? 8 : 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: labelWidth,
            child: Text(
              label.toUpperCase(),
              style: AppTheme.sansBody(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryAccent,
                letterSpacing: 1.0,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : "Not Configured",
              style: AppTheme.sansBody(
                fontSize: isMobile ? 12 : 13,
                color: value.isNotEmpty
                    ? textColor
                    : textColor.withValues(alpha: 0.4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color inputFillColor =
        isDark ? const Color(0xFF1A1715) : const Color(0xFFFAF8F5);
    final Color borderColor = isDark ? AppColors.darkLine : AppColors.lightLine;
    final Color textColor = isDark ? AppColors.darkInk : AppColors.lightInk;

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: inputFillColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _detailRow(context, "Name", customer.name, textColor),
          Divider(height: 1, thickness: 1, color: borderColor),
          _detailRow(context, "Client Type", customer.type, textColor),
          Divider(height: 1, thickness: 1, color: borderColor),
          _detailRow(context, "Phone Number", customer.phone, textColor),
          Divider(height: 1, thickness: 1, color: borderColor),
          _detailRow(context, "Email", customer.email, textColor),
          Divider(height: 1, thickness: 1, color: borderColor),
          _detailRow(context, "Address", customer.address, textColor),
          Divider(height: 1, thickness: 1, color: borderColor),
          _detailRow(context, "City", customer.city, textColor),
          if (customer.state.isNotEmpty) ...[
            Divider(height: 1, thickness: 1, color: borderColor),
            _detailRow(context, "State", customer.state, textColor),
          ],
          if (customer.pincode.isNotEmpty) ...[
            Divider(height: 1, thickness: 1, color: borderColor),
            _detailRow(context, "Pincode", customer.pincode, textColor),
          ],
          if (customer.mapLocation.isNotEmpty) ...[
            Divider(height: 1, thickness: 1, color: borderColor),
            _detailRow(context, "Map Location", customer.mapLocation, textColor),
          ],
        ],
      ),
    );
  }
}
