import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/admin_customer_portal_controller.dart';

/// Admin sub-view for approving or rejecting customer rebooking requests.
class RebooksAdminView extends StatelessWidget {
  final AdminCustomerPortalController portalController;

  const RebooksAdminView({
    super.key,
    required this.portalController,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (portalController.rxAllRebookRequests.isEmpty) {
        return const Center(child: Text("No rebooking requests found."));
      }
      return ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: portalController.rxAllRebookRequests.length,
        itemBuilder: (context, index) {
          final req = portalController.rxAllRebookRequests[index];
          return Card(
            color: const Color(0xFF12271F),
            child: ListTile(
              title: Text("Rebook Booking ID: ${req.previousBookingId}"),
              subtitle: Text("Requested Date: ${req.newDate.toLocal().toString().split(' ')[0]} | Status: ${req.status}"),
              trailing: req.status == 'Pending'
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: () => portalController.adminApproveRebook(req.id, 'Approved'),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () => portalController.adminApproveRebook(req.id, 'Rejected'),
                        ),
                      ],
                    )
                  : null,
            ),
          );
        },
      );
    });
  }
}
