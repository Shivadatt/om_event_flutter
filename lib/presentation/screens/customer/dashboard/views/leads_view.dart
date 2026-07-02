import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/config/app_theme.dart';
import '../../../../controllers/customer_dashboard_controller.dart';

/// Leads / Inquiry management tab view for customers.
class LeadsView extends StatelessWidget {
  final CustomerDashboardController controller;
  final VoidCallback onNewInquiryPressed;

  const LeadsView({
    super.key,
    required this.controller,
    required this.onNewInquiryPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("My Leads / Inquiries", style: AppTheme.serifHeader(fontSize: 24)),
              ElevatedButton.icon(
                icon: const Icon(Icons.add, size: 18),
                label: const Text("New Inquiry"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC9A77E),
                  foregroundColor: const Color(0xFF091210),
                ),
                onPressed: onNewInquiryPressed,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Obx(() {
              if (controller.rxLeads.isEmpty) {
                return Center(
                  child: Text("No inquiries submitted yet.", style: AppTheme.sansBody(fontSize: 14, color: Colors.white54)),
                );
              }
              return ListView.builder(
                itemCount: controller.rxLeads.length,
                itemBuilder: (context, index) {
                  final lead = controller.rxLeads[index];
                  return Card(
                    color: const Color(0xFF12271F),
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ListTile(
                      title: Text(lead.service, style: AppTheme.serifHeader(fontSize: 16)),
                      subtitle: Text(
                        "Budget: ₹${lead.budget.toStringAsFixed(0)} | Event: ${lead.eventDate.toLocal().toString().split(' ')[0]}",
                        style: AppTheme.sansBody(fontSize: 13, color: Colors.white70),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getStatusColor(lead.status).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: _getStatusColor(lead.status)),
                        ),
                        child: Text(
                          lead.status,
                          style: TextStyle(color: _getStatusColor(lead.status), fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
      case 'approved':
      case 'accepted':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
      case 'rejected':
        return Colors.red;
      default:
        return Colors.white54;
    }
  }
}
