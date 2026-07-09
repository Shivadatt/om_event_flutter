import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/services/export_service.dart';
import '../../../../controllers/admin_customer_portal_controller.dart';

/// Admin sub-view for universal global search queries and action activity logs tracking.
class SearchLogsAdminView extends StatefulWidget {
  final AdminCustomerPortalController portalController;

  const SearchLogsAdminView({
    super.key,
    required this.portalController,
  });

  @override
  State<SearchLogsAdminView> createState() => _SearchLogsAdminViewState();
}

class _SearchLogsAdminViewState extends State<SearchLogsAdminView> {
  String globalSearchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search, color: Color(0xFFC9A77E)),
              labelText: "Universal search across bookings, leads, quotes...",
              labelStyle: TextStyle(color: Color(0xFFC9A77E)),
              filled: true,
              fillColor: Colors.black12,
            ),
            onChanged: (val) {
              setState(() => globalSearchQuery = val.toLowerCase());
            },
          ),
          const SizedBox(height: 24),

          Expanded(
            child: Obx(() {
              final matchingQuotes = widget.portalController.rxAllQuotes
                  .where((q) => q.quotationNumber.toLowerCase().contains(globalSearchQuery))
                  .toList();
              return ListView(
                children: [
                  if (matchingQuotes.isNotEmpty) ...[
                    const Text("Matching Quotations", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFC9A77E))),
                    const SizedBox(height: 8),
                    ...matchingQuotes.map((q) => ListTile(
                      leading: const Icon(Icons.description, color: Colors.white70),
                      title: Text(q.quotationNumber),
                      subtitle: Text("Amount: ₹${q.amount} | Status: ${q.status}"),
                    )),
                    const SizedBox(height: 24),
                  ],

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Admin & Customer Action Logs", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFC9A77E), fontSize: 16)),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.download, size: 16),
                        label: const Text("Export Logs CSV"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC9A77E),
                          foregroundColor: const Color(0xFF091210),
                        ),
                        onPressed: () {
                          ExportService.exportToCsv(
                            filename: 'activity_logs',
                            headers: ['ID', 'Customer ID', 'Action Status', 'Details', 'Timestamp'],
                            rows: widget.portalController.rxAllActivities.map((a) => [
                              a.id,
                              a.customerId,
                              a.status,
                              a.details,
                              a.updatedAt.toIso8601String(),
                            ]).toList(),
                          );
                        },
                      )
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...widget.portalController.rxAllActivities.map((a) => ListTile(
                    leading: const Icon(Icons.history, color: Colors.white30),
                    title: Text(a.status),
                    subtitle: Text(a.details),
                    trailing: Text(a.updatedAt.toString().split(' ').first, style: const TextStyle(fontSize: 11, color: Colors.white30)),
                  )),
                ],
              );
            }),
          )
        ],
      ),
    );
  }
}
