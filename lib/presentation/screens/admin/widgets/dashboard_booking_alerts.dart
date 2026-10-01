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
      final displayCount = (pending > 0 || cancellations > 0) ? (pending + cancellations) : 3;

      return Container(
        margin: const EdgeInsets.only(top: 14, bottom: 20),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF1B160E),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.35), width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.inventory_2_outlined, size: 16, color: Color(0xFFD4AF37)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                pending > 0
                    ? "$pending Pending Booking${pending > 1 ? 's' : ''} Require Review"
                    : "$displayCount Pending Proposal Reviews",
                style: AppTheme.sansBody(fontSize: 12.5, color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
            InkWell(
              onTap: () {
                if (cancellations > 0) {
                  controller.selectedStatusTab.value = 'Cancellation Requests';
                } else {
                  controller.selectedStatusTab.value = 'Pending';
                }
                Get.toNamed(AppRoutes.adminBookings);
              },
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text(
                  "Take Action",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0E1712),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
