import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/services/export_service.dart';
import '../../../../../domain/entities/quotation.dart';
import '../../../../controllers/admin_customer_portal_controller.dart';

/// Admin sub-view for managing customer quotations.
class QuotesAdminView extends StatelessWidget {
  final AdminCustomerPortalController portalController;

  const QuotesAdminView({
    super.key,
    required this.portalController,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final rawQuotes = portalController.rxAllQuotes;
      if (rawQuotes.isEmpty) {
        return const Center(child: Text("No customer quotations logged."));
      }

      // Sort quotations by createdAt descending (latest created on top)
      final quotations = List<Quotation>.from(rawQuotes)
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.download, size: 16),
                  label: const Text("Export Quotes CSV"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC9A77E),
                    foregroundColor: const Color(0xFF091210),
                  ),
                  onPressed: () {
                    ExportService.exportToCsv(
                      filename: 'quotations',
                      headers: ['ID', 'Quotation Number', 'Amount', 'Status', 'Event Date'],
                      rows: quotations.map((q) => [
                        q.id,
                        q.publicId,
                        q.grandTotal,
                        q.status,
                        q.eventDate.toIso8601String(),
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
              itemCount: quotations.length,
              itemBuilder: (context, index) {
                final quote = quotations[index];
                return Card(
                  color: const Color(0xFF12271F),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(
                      "Quote: ${quote.publicId} (₹${quote.grandTotal.toStringAsFixed(2)})",
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFC9A77E)),
                    ),
                    subtitle: Text("Status: ${quote.status.nameStr.toUpperCase()} | Event Date: ${quote.eventDate.toLocal().toString().split(' ')[0]}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check_circle_outline, color: Colors.green),
                          onPressed: () => portalController.adminUpdateQuotation(quote.id, {'status': 'bookingConfirmed'}),
                        ),
                        IconButton(
                          icon: const Icon(Icons.cancel_outlined, color: Colors.redAccent),
                          onPressed: () => portalController.adminUpdateQuotation(quote.id, {'status': 'cancelled'}),
                        ),
                      ],
                    ),
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
