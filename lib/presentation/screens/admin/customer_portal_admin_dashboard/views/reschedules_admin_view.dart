import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/config/app_theme.dart';
import '../../../../controllers/admin_customer_portal_controller.dart';

/// Admin sub-view for approving rescheduling & cancellation requests.
class ReschedulesAdminView extends StatefulWidget {
  final AdminCustomerPortalController portalController;

  const ReschedulesAdminView({
    super.key,
    required this.portalController,
  });

  @override
  State<ReschedulesAdminView> createState() => _ReschedulesAdminViewState();
}

class _ReschedulesAdminViewState extends State<ReschedulesAdminView> {
  final rxRequests = <_MockRescheduleRequest>[
    _MockRescheduleRequest('R-101', 'Booking #B-552', '2026-08-15', 'Preferred date due to monsoon', 'Pending'),
  ].obs;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Rescheduling & Cancellation Requests", style: AppTheme.serifHeader(fontSize: 22)),
          const SizedBox(height: 24),
          Expanded(
            child: Obx(() {
              if (rxRequests.isEmpty) {
                return const Center(child: Text("No active reschedule or cancellation requests logged."));
              }
              return ListView.builder(
                itemCount: rxRequests.length,
                itemBuilder: (context, index) {
                  final req = rxRequests[index];
                  return Card(
                    color: const Color(0xFF12271F),
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(req.title, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFC9A77E))),
                      subtitle: Text("Requested Date: ${req.requestedDate}\nReason: ${req.reason}"),
                      isThreeLine: true,
                      trailing: req.status == 'Pending'
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                  onPressed: () {
                                    setState(() {
                                      req.status = 'Approved';
                                    });
                                    Get.snackbar("Approved", "Reschedule request approved. System updated.");
                                  },
                                  child: const Text("Approve", style: TextStyle(color: Colors.white)),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                                  onPressed: () {
                                    setState(() {
                                      req.status = 'Rejected';
                                    });
                                    Get.snackbar("Rejected", "Reschedule request rejected.");
                                  },
                                  child: const Text("Reject", style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            )
                          : Text(req.status, style: TextStyle(color: req.status == 'Approved' ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
                    ),
                  );
                },
              );
            }),
          )
        ],
      ),
    );
  }
}

class _MockRescheduleRequest {
  final String id;
  final String title;
  final String requestedDate;
  final String reason;
  String status;
  _MockRescheduleRequest(this.id, this.title, this.requestedDate, this.reason, this.status);
}
