import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/config/app_routes.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../domain/entities/quotation.dart';
import '../../../controllers/admin_booking_controller.dart';
import '../bookings/widgets/admin_booking_details_dialog.dart';

class DashboardRecentBookings extends StatelessWidget {
  const DashboardRecentBookings({super.key});

  Color _getStatusColor(QuotationStatus status) {
    switch (status) {
      case QuotationStatus.published:
      case QuotationStatus.draft:
      case QuotationStatus.viewed:
      case QuotationStatus.republished:
        return const Color(0xFFF59E0B);
      case QuotationStatus.acceptedByClient:
        return const Color(0xFF3B82F6);
      case QuotationStatus.bookingConfirmed:
      case QuotationStatus.inProgress:
        return const Color(0xFF10B981);
      case QuotationStatus.completed:
        return const Color(0xFFD4AF37);
      case QuotationStatus.cancelled:
      case QuotationStatus.rejectedByClient:
        return const Color(0xFFEF4444);
      default:
        return Colors.white54;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<AdminBookingController>()) return const SizedBox.shrink();
    final controller = Get.find<AdminBookingController>();
    const goldColor = Color(0xFFD4AF37);

    return Obx(() {
      final list = controller.recentBookings;

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
                  "RECENT BOOKINGS",
                  style: AppTheme.sansBody(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: goldColor,
                  ),
                ),
                InkWell(
                  onTap: () => Get.toNamed(AppRoutes.adminBookings),
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
                    "No recent bookings recorded.",
                    style: AppTheme.sansBody(fontSize: 12, color: Colors.white38),
                  ),
                ),
              )
            else
              ...list.take(4).map((b) {
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Color(0xFF182820), width: 0.8)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              b.publicId,
                              style: AppTheme.sansBody(
                                fontSize: 11.5,
                                color: goldColor,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              b.customerName,
                              style: AppTheme.sansBody(
                                fontSize: 10,
                                color: Colors.white70,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          AppFormatters.formatDate(b.eventDate),
                          style: AppTheme.sansBody(fontSize: 10.5, color: Colors.white60),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: _getStatusColor(b.status).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _getStatusColor(b.status).withValues(alpha: 0.4),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          b.status.name.toUpperCase(),
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: _getStatusColor(b.status),
                          ),
                        ),
                      ),
                      IconButton(
                        padding: const EdgeInsets.only(left: 6),
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.white38),
                        onPressed: () => showAdminBookingDetailsDialog(context, b),
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
