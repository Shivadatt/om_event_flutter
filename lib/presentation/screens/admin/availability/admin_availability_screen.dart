import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/services/booking_availability_service.dart';
import '../../../../core/utils/formatters.dart';
import '../../../controllers/admin_booking_controller.dart';
import '../bookings/widgets/admin_booking_details_dialog.dart';
import 'widgets/admin_calendar_widget.dart';

class AdminAvailabilityScreen extends GetView<AdminBookingController> {
  const AdminAvailabilityScreen({super.key});

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 6),
        Text(label, style: AppTheme.sansBody(fontSize: 11, color: Colors.white70)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final goldColor = const Color(0xFFD4AF37);
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              "AVAILABILITY CALENDAR",
              style: AppTheme.sansBody(
                fontSize: 11,
                color: goldColor,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Visual schedule of confirmed bookings and available event dates (1 event per day).",
              style: AppTheme.sansBody(fontSize: 13, color: Colors.white60),
            ),
            const SizedBox(height: 16),

            // Legend
            Wrap(
              spacing: 18,
              runSpacing: 8,
              children: [
                _buildLegendItem("Confirmed / Accepted", goldColor),
                _buildLegendItem("Pending Review", const Color(0xFFF59E0B)),
                _buildLegendItem("Available", const Color(0xFF1E332B)),
              ],
            ),
            const SizedBox(height: 24),

            // Main Content: Calendar + Inspector
            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(flex: 7, child: AdminCalendarWidget()),
                  const SizedBox(width: 24),
                  Expanded(flex: 5, child: _buildDayInspector(context)),
                ],
              )
            else
              Column(
                children: [
                  const AdminCalendarWidget(),
                  const SizedBox(height: 20),
                  _buildDayInspector(context),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayInspector(BuildContext context) {
    final goldColor = const Color(0xFFD4AF37);

    return Obx(() {
      final selectedDate = controller.selectedCalendarDate.value;
      if (selectedDate == null) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFF122018),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF1E332B)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.touch_app_outlined, size: 36, color: Colors.white30),
              const SizedBox(height: 12),
              Text(
                "Select a Date",
                style: AppTheme.sansBody(fontSize: 14, color: Colors.white70, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                "Click any day on the calendar to view scheduled bookings and availability details.",
                textAlign: TextAlign.center,
                style: AppTheme.sansBody(fontSize: 11, color: Colors.white38),
              ),
            ],
          ),
        );
      }

      final dateKey = BookingAvailabilityService.normalizeDateString(selectedDate);
      final booking = controller.bookingsByDateMap[dateKey];

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF122018),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF1E332B)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 18, color: Color(0xFFD4AF37)),
                const SizedBox(width: 8),
                Text(
                  AppFormatters.formatDate(selectedDate),
                  style: AppTheme.serifHeader(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: booking != null ? goldColor.withValues(alpha: 0.15) : const Color(0xFF10B981).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: booking != null ? goldColor : const Color(0xFF10B981)),
                  ),
                  child: Text(
                    booking != null ? "1 BOOKING SCHEDULED" : "AVAILABLE",
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: booking != null ? goldColor : const Color(0xFF10B981),
                    ),
                  ),
                ),
              ],
            ),
            const Divider(color: Color(0xFF1E332B), height: 24),

            if (booking != null) ...[
              Text(
                booking.publicId,
                style: AppTheme.sansBody(fontSize: 14, color: goldColor, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                booking.customerName,
                style: AppTheme.sansBody(fontSize: 15, color: Colors.white, fontWeight: FontWeight.bold),
              ),
              Text(
                booking.customerPhone,
                style: AppTheme.sansBody(fontSize: 11, color: Colors.white54),
              ),
              const SizedBox(height: 10),
              Text(
                "${booking.items.firstOrNull?.name ?? 'Event Decor'} (${booking.items.firstOrNull?.theme ?? 'Custom'})",
                style: AppTheme.sansBody(fontSize: 12, color: Colors.white70),
              ),
              const SizedBox(height: 4),
              Text(
                "Time: ${booking.eventTime} • Venue: ${booking.location}",
                style: AppTheme.sansBody(fontSize: 11, color: Colors.white54),
              ),
              const SizedBox(height: 12),
              Text(
                "Total: ${AppFormatters.formatCurrency(booking.grandTotal)}",
                style: AppTheme.sansBody(fontSize: 13, color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => showAdminBookingDetailsDialog(context, booking),
                  icon: const Icon(Icons.open_in_new_rounded, size: 14),
                  label: const Text("VIEW BOOKING DETAILS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: goldColor,
                    foregroundColor: const Color(0xFF0F1B18),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF10B981), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "No events scheduled. This date is completely free for new client reservations.",
                        style: AppTheme.sansBody(fontSize: 12, color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    });
  }
}
