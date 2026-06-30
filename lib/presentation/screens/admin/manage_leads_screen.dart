import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/config/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../controllers/admin_controller.dart';

class ManageLeadsScreen extends GetView<AdminController> {
  const ManageLeadsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "MANAGE LEADS",
          style: AppTheme.sansBody(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2, color: Colors.white),
        ),
      ),
      body: Obx(() {
        final leads = controller.rxLeads;
        if (leads.isEmpty) {
          return const Center(child: Text("No inquiries registered yet."));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(18),
          itemCount: leads.length,
          itemBuilder: (context, index) {
            final lead = leads[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 14),
              color: isDark ? AppTheme.darkPaper : AppTheme.lightPaper,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          lead.requestType.toUpperCase(),
                          style: AppTheme.sansBody(fontSize: 9, color: isDark ? AppTheme.darkGold : AppTheme.lightGold, fontWeight: FontWeight.bold, letterSpacing: 1),
                        ),
                        DropdownButton<String>(
                          value: lead.status,
                          items: const [
                            DropdownMenuItem(value: 'new', child: Text("New")),
                            DropdownMenuItem(value: 'contacted', child: Text("Contacted")),
                            DropdownMenuItem(value: 'qualified', child: Text("Qualified")),
                            DropdownMenuItem(value: 'won', child: Text("Won")),
                            DropdownMenuItem(value: 'closed', child: Text("Closed")),
                          ],
                          onChanged: (val) {
                            if (val != null) controller.updateLead(lead.id, val);
                          },
                          style: const TextStyle(fontSize: 12),
                          underline: const SizedBox(),
                        )
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(lead.name, style: AppTheme.serifHeader(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text("Phone: ${lead.phone}", style: AppTheme.sansBody(fontSize: 13)),
                    if (lead.email.isNotEmpty)
                      Text("Email: ${lead.email}", style: AppTheme.sansBody(fontSize: 13)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (lead.eventDate != null) ...[
                          const Icon(Icons.calendar_today_outlined, size: 12, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(AppFormatters.formatShortDate(lead.eventDate!), style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          const SizedBox(width: 14),
                        ],
                        if (lead.budget != null) ...[
                          const Icon(Icons.wallet_outlined, size: 12, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(AppFormatters.formatCurrency(lead.budget!), style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        ],
                      ],
                    ),
                    if (lead.requirements.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(10),
                        width: double.infinity,
                        color: isDark ? Colors.black26 : Colors.grey.shade100,
                        child: Text(
                          lead.requirements,
                          style: AppTheme.sansBody(fontSize: 12, height: 1.4),
                        ),
                      )
                    ]
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
