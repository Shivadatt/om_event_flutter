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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF101C16),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E3328), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "LATEST INQUIRIES",
                style: AppTheme.sansBody(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: const Color(0xFFD4AF37),
                ),
              ),
              InkWell(
                onTap: () => Get.toNamed('/admin/leads'),
                child: Text(
                  "View All",
                  style: AppTheme.sansBody(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFD4AF37),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Obx(() {
            if (controller.rxLeads.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    "No inquiries found.",
                    style: AppTheme.sansBody(
                      fontSize: 12,
                      color: const Color(0xFFA4A9A7),
                    ),
                  ),
                ),
              );
            }

            final items = controller.rxLeads.take(4).toList();
            return Column(
              children: items.map((lead) {
                final initial = lead.name.isNotEmpty ? lead.name[0].toUpperCase() : 'C';
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Color(0xFF182820), width: 0.8),
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: const Color(0xFF1A2A22),
                        child: Text(
                          initial,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFD4AF37),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lead.name,
                              style: AppTheme.sansBody(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              lead.requestType.isNotEmpty
                                  ? lead.requestType.toUpperCase()
                                  : lead.phone,
                              style: AppTheme.sansBody(
                                fontSize: 10,
                                color: const Color(0xFFA4A9A7),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Recent",
                        style: AppTheme.sansBody(
                          fontSize: 9.5,
                          color: Colors.white38,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(lead.status).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _getStatusColor(lead.status).withValues(alpha: 0.4),
                            width: 0.8,
                          ),
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
              }).toList(),
            );
          }),
        ],
      ),
    );
  }
}
