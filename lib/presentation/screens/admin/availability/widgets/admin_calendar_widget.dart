import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/config/app_theme.dart';
import '../../../../../core/services/booking_availability_service.dart';
import '../../../../../domain/entities/quotation.dart';
import '../../../../controllers/admin_booking_controller.dart';

class AdminCalendarWidget extends StatelessWidget {
  const AdminCalendarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminBookingController>();
    final goldColor = const Color(0xFFD4AF37);

    return Obx(() {
      final currentMonth = controller.selectedCalendarMonth.value;
      final selectedDate = controller.selectedCalendarDate.value;
      final bookingsMap = controller.bookingsByDateMap;

      final daysInMonth = DateTime(currentMonth.year, currentMonth.month + 1, 0).day;
      final firstDayWeekday = DateTime(currentMonth.year, currentMonth.month, 1).weekday; // 1 = Mon, 7 = Sun
      final paddingDays = firstDayWeekday - 1;

      final monthNames = [
        "January", "February", "March", "April", "May", "June",
        "July", "August", "September", "October", "November", "December"
      ];

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF122018),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF1E332B)),
        ),
        child: Column(
          children: [
            // Month Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left_rounded, color: Colors.white70),
                  onPressed: () {
                    controller.selectedCalendarMonth.value =
                        DateTime(currentMonth.year, currentMonth.month - 1, 1);
                  },
                ),
                Text(
                  "${monthNames[currentMonth.month - 1]} ${currentMonth.year}".toUpperCase(),
                  style: AppTheme.serifHeader(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: goldColor,
                    letterSpacing: 1.2,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right_rounded, color: Colors.white70),
                  onPressed: () {
                    controller.selectedCalendarMonth.value =
                        DateTime(currentMonth.year, currentMonth.month + 1, 1);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Weekday labels
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"].map((day) {
                return SizedBox(
                  width: 36,
                  child: Center(
                    child: Text(
                      day,
                      style: AppTheme.sansBody(fontSize: 10, color: Colors.white38, fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              }).toList(),
            ),
            const Divider(color: Color(0xFF1E332B), height: 18),

            // Days Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: paddingDays + daysInMonth,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1.1,
              ),
              itemBuilder: (context, index) {
                if (index < paddingDays) {
                  return const SizedBox.shrink();
                }

                final dayNum = index - paddingDays + 1;
                final cellDate = DateTime(currentMonth.year, currentMonth.month, dayNum);
                final dateKey = BookingAvailabilityService.normalizeDateString(cellDate);
                final booking = bookingsMap[dateKey];

                final isSelected = selectedDate != null &&
                    selectedDate.year == cellDate.year &&
                    selectedDate.month == cellDate.month &&
                    selectedDate.day == cellDate.day;

                Color cellBorder = const Color(0xFF1E332B);
                Color cellBg = Colors.transparent;
                Color textColor = Colors.white70;

                if (booking != null) {
                  if (booking.status == QuotationStatus.bookingConfirmed ||
                      booking.status == QuotationStatus.acceptedByClient) {
                    cellBg = goldColor.withValues(alpha: 0.25);
                    cellBorder = goldColor;
                    textColor = goldColor;
                  } else if (booking.status == QuotationStatus.published ||
                      booking.status == QuotationStatus.draft) {
                    cellBg = const Color(0xFFF59E0B).withValues(alpha: 0.2);
                    cellBorder = const Color(0xFFF59E0B);
                    textColor = const Color(0xFFF59E0B);
                  }
                }

                if (isSelected) {
                  cellBorder = Colors.white;
                }

                return InkWell(
                  onTap: () => controller.selectedCalendarDate.value = cellDate,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: cellBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: cellBorder, width: isSelected ? 2 : 1),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          dayNum.toString(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                        if (booking != null) ...[
                          const SizedBox(height: 2),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: textColor,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      );
    });
  }
}
