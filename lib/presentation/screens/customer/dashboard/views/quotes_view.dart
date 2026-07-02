import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/config/app_theme.dart';
import '../../../../controllers/customer_dashboard_controller.dart';

/// Quotations management tab view for customers.
class QuotesView extends StatelessWidget {
  final CustomerDashboardController controller;
  final Function(String) onRequestRevision;

  const QuotesView({
    super.key,
    required this.controller,
    required this.onRequestRevision,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("My Quotations", style: AppTheme.serifHeader(fontSize: 24)),
          const SizedBox(height: 24),
          Expanded(
            child: Obx(() {
              if (controller.rxQuotations.isEmpty) {
                return Center(
                  child: Text("No quotations received yet.", style: AppTheme.sansBody(fontSize: 14, color: Colors.white54)),
                );
              }
              return ListView.builder(
                itemCount: controller.rxQuotations.length,
                itemBuilder: (context, index) {
                  final quote = controller.rxQuotations[index];
                  return Card(
                    color: const Color(0xFF12271F),
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ExpansionTile(
                      iconColor: const Color(0xFFC9A77E),
                      collapsedIconColor: Colors.white70,
                      title: Text(quote.quotationNumber, style: AppTheme.serifHeader(fontSize: 16)),
                      subtitle: Text("Amount: ₹${quote.amount.toStringAsFixed(2)} | Expiry: ${quote.expiryDate.toLocal().toString().split(' ')[0]}"),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Status: ${quote.status.toUpperCase()}", style: AppTheme.serifHeader(fontSize: 14, color: _getStatusColor(quote.status))),
                              const SizedBox(height: 12),
                              if (quote.notes.isNotEmpty) ...[
                                Text("Notes: ${quote.notes}", style: AppTheme.sansBody(fontSize: 13)),
                                const SizedBox(height: 12),
                              ],
                              Row(
                                children: [
                                  if (quote.status == 'pending') ...[
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                      onPressed: () => controller.acceptQuotation(quote.id),
                                      child: const Text("Accept", style: TextStyle(color: Colors.white)),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                      onPressed: () => controller.rejectQuotation(quote.id),
                                      child: const Text("Reject", style: TextStyle(color: Colors.white)),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                                      onPressed: () => onRequestRevision(quote.id),
                                      child: const Text("Request Revision", style: TextStyle(color: Colors.white)),
                                    ),
                                  ],
                                  const Spacer(),
                                  if (quote.pdfUrl.isNotEmpty)
                                    TextButton.icon(
                                      icon: const Icon(Icons.download, color: Color(0xFFC9A77E)),
                                      label: const Text("Download PDF", style: TextStyle(color: Color(0xFFC9A77E))),
                                      onPressed: () {
                                        Get.snackbar("Download Started", "Downloading proposal documents...");
                                      },
                                    ),
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
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
