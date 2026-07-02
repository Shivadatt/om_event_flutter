import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/services/export_service.dart';
import '../../../../controllers/admin_customer_portal_controller.dart';

/// Admin sub-view for verifying customer payment receipts.
class PaymentsAdminView extends StatelessWidget {
  final AdminCustomerPortalController portalController;

  const PaymentsAdminView({
    super.key,
    required this.portalController,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (portalController.rxAllPayments.isEmpty) {
        return const Center(child: Text("No payment transactions recorded."));
      }
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.download, size: 16),
                  label: const Text("Export Payments CSV"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC9A77E),
                    foregroundColor: const Color(0xFF091210),
                  ),
                  onPressed: () {
                    ExportService.exportToCsv(
                      filename: 'payments',
                      headers: ['ID', 'Customer ID', 'Booking ID', 'Amount', 'Method', 'Status', 'Date'],
                      rows: portalController.rxAllPayments.map((p) => [
                        p.id,
                        p.customerId,
                        p.bookingId,
                        p.amount,
                        p.method,
                        p.status,
                        p.paymentDate.toIso8601String(),
                      ]).toList(),
                    );
                  },
                )
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: portalController.rxAllPayments.length,
              itemBuilder: (context, index) {
                final pay = portalController.rxAllPayments[index];
                return Card(
                  color: const Color(0xFF12271F),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text("Amount: ₹${pay.amount.toStringAsFixed(2)} via ${pay.method}"),
                    subtitle: Text("Status: ${pay.status.toUpperCase()} | Date: ${pay.paymentDate.toLocal().toString().split(' ')[0]}"),
                    trailing: pay.status == 'pending'
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                onPressed: () => portalController.adminVerifyPayment(pay.id, 'approved'),
                                child: const Text("Approve", style: TextStyle(color: Colors.white)),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                                onPressed: () => portalController.adminVerifyPayment(pay.id, 'rejected'),
                                child: const Text("Reject", style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          )
                        : Text("Verified", style: TextStyle(color: pay.status == 'approved' ? Colors.green : Colors.red)),
                  ),
                );
              },
            ),
          ),
        ],
      );
    });
  }
}
