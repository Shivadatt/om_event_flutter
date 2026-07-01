import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/config/app_theme.dart';
import '../../../controllers/admin_controller.dart';

/// CRM panel component listing the latest incoming inquiries inside AdminDashboardScreen.
class RecentInquiriesWidget extends StatelessWidget {
  /// The active admin dashboard controller.
  final AdminController controller;

  /// Creates a [RecentInquiriesWidget] widget instance.
  const RecentInquiriesWidget({super.key, required this.controller});

  Color _getStatusColor(String status) {
    switch (status) {
      case 'new':
        return Colors.blue;
      case 'contacted':
        return Colors.orange;
      case 'qualified':
        return Colors.indigo;
      case 'won':
        return const Color(0xFF3BA776);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF162822),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF254235), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "LATEST INQUIRIES",
            style: AppTheme.sansBody(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: const Color(0xFFC8A26A),
            ),
          ),
          const SizedBox(height: 16),
          Obx(() {
            if (controller.rxLeads.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  "No inquiries found.",
                  style: AppTheme.sansBody(
                    fontSize: 13,
                    color: const Color(0xFFA4A9A7),
                  ),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount:
                  controller.rxLeads.length > 4 ? 4 : controller.rxLeads.length,
              itemBuilder: (context, index) {
                final lead = controller.rxLeads[index];
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Color(0xFF254235)),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lead.name,
                            style: AppTheme.serifHeader(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFF4F4F4),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            lead.phone,
                            style: AppTheme.sansBody(
                              fontSize: 11,
                              color: const Color(0xFFA4A9A7),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(
                            lead.status,
                          ).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Text(
                          lead.status.toUpperCase(),
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: _getStatusColor(lead.status),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }
}
