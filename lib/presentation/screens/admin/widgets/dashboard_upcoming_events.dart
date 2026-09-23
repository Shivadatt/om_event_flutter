import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/config/app_routes.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../controllers/admin_booking_controller.dart';
import '../bookings/widgets/admin_booking_details_dialog.dart';

class DashboardUpcomingEvents extends StatelessWidget {
  const DashboardUpcomingEvents({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<AdminBookingController>()) return const SizedBox.shrink();
    final controller = Get.find<AdminBookingController>();
    final goldColor = const Color(0xFFD4AF37);

    return Obx(() {
      final list = controller.upcomingEvents;
      if (list.isEmpty) return const SizedBox.shrink();

      return Container(
        margin: const EdgeInsets.only(bottom: 24),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF122018),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF1E332B)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.event_available_outlined, size: 18, color: Color(0xFFD4AF37)),
                    const SizedBox(width: 8),
                    Text(
                      "UPCOMING CELEBRATIONS",
                      style: AppTheme.serifHeader(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: goldColor,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () => Get.toNamed(AppRoutes.adminAvailability),
                  child: Text("VIEW CALENDAR", style: AppTheme.sansBody(fontSize: 11, color: goldColor, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const Divider(color: Color(0xFF1E332B), height: 16),
            ...list.map((b) {
              final service = b.items.firstOrNull?.name ?? "Event Decor";
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFF182B24), width: 0.8)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: goldColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: goldColor.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        children: [
                          Text(
                            b.eventDate.day.toString(),
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: goldColor),
                          ),
                          Text(
                            AppFormatters.formatDate(b.eventDate).split(' ').firstOrNull ?? '',
                            style: const TextStyle(fontSize: 9, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(service, style: AppTheme.sansBody(fontSize: 13, color: Colors.white, fontWeight: FontWeight.bold)),
                          Text("${b.customerName} • ${b.location}", style: AppTheme.sansBody(fontSize: 11, color: Colors.white60)),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text("Time: ${b.eventTime}", style: AppTheme.sansBody(fontSize: 11, color: Colors.white70)),
                    ),
                    ElevatedButton(
                      onPressed: () => showAdminBookingDetailsDialog(context, b),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF162923),
                        foregroundColor: goldColor,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                          side: BorderSide(color: goldColor.withValues(alpha: 0.4)),
                        ),
                      ),
                      child: const Text("Details", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      );
    });
  }
}
