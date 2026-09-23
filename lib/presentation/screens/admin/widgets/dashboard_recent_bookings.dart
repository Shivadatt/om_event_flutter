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
    final goldColor = const Color(0xFFD4AF37);

    return Obx(() {
      final list = controller.recentBookings;
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
                Text(
                  "RECENT BOOKINGS",
                  style: AppTheme.serifHeader(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: goldColor,
                    letterSpacing: 1.2,
                  ),
                ),
                TextButton(
                  onPressed: () => Get.toNamed(AppRoutes.adminBookings),
                  child: Text("VIEW ALL", style: AppTheme.sansBody(fontSize: 11, color: goldColor, fontWeight: FontWeight.bold)),
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
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(b.publicId, style: AppTheme.sansBody(fontSize: 12, color: goldColor, fontWeight: FontWeight.bold)),
                          Text(b.customerName, style: AppTheme.sansBody(fontSize: 11, color: Colors.white70)),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(service, style: AppTheme.sansBody(fontSize: 12, color: Colors.white60)),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        AppFormatters.formatDate(b.eventDate),
                        style: AppTheme.sansBody(fontSize: 12, color: Colors.white),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getStatusColor(b.status).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: _getStatusColor(b.status)),
                      ),
                      child: Text(
                        b.status.name.toUpperCase(),
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: _getStatusColor(b.status)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.white70),
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
