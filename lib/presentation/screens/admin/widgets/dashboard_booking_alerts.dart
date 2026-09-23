import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/config/app_routes.dart';
import '../../../../core/config/app_theme.dart';
import '../../../controllers/admin_booking_controller.dart';

class DashboardBookingAlerts extends StatelessWidget {
  const DashboardBookingAlerts({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<AdminBookingController>()) return const SizedBox.shrink();
    final controller = Get.find<AdminBookingController>();

    return Obx(() {
      final pending = controller.pendingCount.value;
      final cancellations = controller.cancellationRequestsCount.value;

      if (pending == 0 && cancellations == 0) return const SizedBox.shrink();

      return Container(
        margin: const EdgeInsets.only(bottom: 24),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1710),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            const Icon(Icons.notifications_active_outlined, color: Color(0xFFF59E0B), size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                [
                  if (pending > 0) "$pending Booking${pending > 1 ? 's' : ''} Pending Review",
                  if (cancellations > 0) "$cancellations Cancellation Request${cancellations > 1 ? 's' : ''}",
                ].join("  •  "),
                style: AppTheme.sansBody(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (cancellations > 0) {
                  controller.selectedStatusTab.value = 'Cancellation Requests';
                } else {
                  controller.selectedStatusTab.value = 'Pending';
                }
                Get.toNamed(AppRoutes.adminBookings);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF59E0B),
                foregroundColor: const Color(0xFF0F1B18),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              child: const Text("TAKE ACTION", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    });
  }
}
