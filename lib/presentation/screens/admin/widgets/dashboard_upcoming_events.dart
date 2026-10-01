import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/config/app_routes.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/utils/formatters.dart';
import '../../../controllers/admin_booking_controller.dart';
import '../bookings/widgets/admin_booking_details_dialog.dart';

class DashboardUpcomingEvents extends StatelessWidget {
  const DashboardUpcomingEvents({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<AdminBookingController>()) return const SizedBox.shrink();
    final controller = Get.find<AdminBookingController>();
    const goldColor = Color(0xFFD4AF37);

    return Obx(() {
      final list = controller.upcomingEvents;

      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF101C16),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF1E3328), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "UPCOMING CELEBRATIONS",
                  style: AppTheme.sansBody(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: goldColor,
                  ),
                ),
                InkWell(
                  onTap: () => Get.toNamed(AppRoutes.adminAvailability),
                  child: Text(
                    "View All",
                    style: AppTheme.sansBody(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: goldColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (list.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    "No upcoming celebrations scheduled.",
                    style: AppTheme.sansBody(fontSize: 12, color: Colors.white38),
                  ),
                ),
              )
            else
              ...list.take(4).map((b) {
                final service = b.items.firstOrNull?.name ?? "Luxury Celebration";
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Color(0xFF182820), width: 0.8)),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.asset(
                          AppAssets.imageLuxuryEveningDecor,
                          width: 38,
                          height: 38,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 38,
                            height: 38,
                            color: const Color(0xFF1B2A22),
                            child: const Icon(Icons.celebration_outlined, size: 18, color: Color(0xFFD4AF37)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              service,
                              style: AppTheme.sansBody(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "${b.customerName} • ${AppFormatters.formatDate(b.eventDate)}",
                              style: AppTheme.sansBody(
                                fontSize: 10,
                                color: const Color(0xFFA4A9A7),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: () => showAdminBookingDetailsDialog(context, b),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: goldColor,
                          side: BorderSide(color: goldColor.withValues(alpha: 0.6), width: 1),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                        child: const Text("Details", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
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
