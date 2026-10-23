import 'package:flutter/material.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../data/models/customer_model.dart';
import '../../../controllers/admin_controller.dart';

class ClientProfileInquiriesTab extends StatelessWidget {
  final CustomerModel customer;
  final AdminController controller;
  final bool isMobile;

  const ClientProfileInquiriesTab({
    super.key,
    required this.customer,
    required this.controller,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    final leads = controller.rxLeads
        .where((l) => l.phone == customer.phone)
        .toList();

    if (leads.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            "No inquiries received from this client.",
            style: AppTheme.sansBody(fontSize: 12, color: AppColors.darkMuted),
          ),
        ),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color inputFillColor =
        isDark ? const Color(0xFF1A1715) : const Color(0xFFFAF8F5);
    final Color borderColor = isDark ? AppColors.darkLine : AppColors.lightLine;

    return ListView.builder(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      itemCount: leads.length,
      itemBuilder: (context, index) {
        final l = leads[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: inputFillColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.requestType.toUpperCase(),
                      style: AppTheme.sansBody(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryAccent,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Requested: ${l.eventDate != null ? AppFormatters.formatShortDate(l.eventDate!) : 'TBD'}",
                      style: AppTheme.sansBody(
                        fontSize: 11,
                        color: AppColors.darkMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  l.status.toUpperCase(),
                  style: AppTheme.sansBody(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryAccent,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
