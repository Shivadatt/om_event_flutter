import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/config/app_theme.dart';
import '../../controllers/admin_customer_portal_controller.dart';
import '../../controllers/admin_controller.dart';

class BookingCalendarScreen extends StatefulWidget {
  const BookingCalendarScreen({super.key});

  @override
  State<BookingCalendarScreen> createState() => _BookingCalendarScreenState();
}

class _BookingCalendarScreenState extends State<BookingCalendarScreen> {
  final portalController = Get.find<AdminCustomerPortalController>();
  final adminController = Get.find<AdminController>();
  DateTime focusedMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF091210),
      appBar: AppBar(
        title: Text("BOOKING CALENDAR", style: AppTheme.serifHeader(fontSize: 18)),
        backgroundColor: const Color(0xFF12271F),
        actions: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: Color(0xFFC9A77E)),
            onPressed: () => setState(() {
              focusedMonth = DateTime(focusedMonth.year, focusedMonth.month - 1);
            }),
          ),
          Text(
            "${_getMonthName(focusedMonth.month)} ${focusedMonth.year}",
            style: AppTheme.serifHeader(fontSize: 16),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: Color(0xFFC9A77E)),
            onPressed: () => setState(() {
              focusedMonth = DateTime(focusedMonth.year, focusedMonth.month + 1);
            }),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          _buildWeekDayLabels(),
          Expanded(child: _buildCalendarGrid()),
        ],
      ),
    );
  }

  Widget _buildWeekDayLabels() {
    final weekdays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
    return Container(
      color: const Color(0xFF12271F),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: weekdays.map((day) => Expanded(
          child: Center(
            child: Text(day, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFC9A77E), fontSize: 13)),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final daysInMonth = DateTime(focusedMonth.year, focusedMonth.month + 1, 0).day;
    final firstDayOffset = DateTime(focusedMonth.year, focusedMonth.month, 1).weekday % 7;
    final totalCells = daysInMonth + firstDayOffset;

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 0.8,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: totalCells,
      itemBuilder: (context, index) {
        if (index < firstDayOffset) {
          return Container(color: Colors.transparent);
        }

        final dayNum = index - firstDayOffset + 1;
        final cellDate = DateTime(focusedMonth.year, focusedMonth.month, dayNum);

        // Find bookings on this cellDate
        final dayBookings = portalController.rxAllQuotes.where((q) {
          return q.date.year == cellDate.year && q.date.month == cellDate.month && q.date.day == cellDate.day;
        }).toList();

        return DragTarget<String>(
          onWillAcceptWithDetails: (details) => true,
          onAcceptWithDetails: (details) {
            Get.snackbar("Booking Moved", "Booking rescheduled to ${cellDate.toLocal().toString().split(' ')[0]}");
          },
          builder: (context, candidateData, rejectedData) {
            final isToday = cellDate.day == DateTime.now().day && cellDate.month == DateTime.now().month && cellDate.year == DateTime.now().year;

            return Container(
              decoration: BoxDecoration(
                color: isToday ? const Color(0xFF1A3B30) : const Color(0xFF12271F),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: const Color(0xFFC9A77E).withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(6),
                    child: Text(dayNum.toString(), style: TextStyle(fontWeight: FontWeight.bold, color: isToday ? const Color(0xFFC9A77E) : Colors.white70)),
                  ),
                  Expanded(
                    child: ListView(
                      children: dayBookings.map((b) {
                        return LongPressDraggable<String>(
                          data: b.id,
                          feedback: Material(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              color: const Color(0xFFC9A77E),
                              child: Text(b.quotationNumber, style: const TextStyle(color: Colors.black)),
                            ),
                          ),
                          childWhenDragging: Container(color: Colors.white12),
                          child: InkWell(
                            onTap: () => _showBookingDetails(b.id, b.quotationNumber, b.amount, b.status),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                color: _getStatusColor(b.status).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: Text(
                                b.quotationNumber,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: _getStatusColor(b.status), fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showBookingDetails(String bookingId, String name, double amount, String status) {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF12271F),
        title: Text("Booking Details", style: AppTheme.serifHeader(fontSize: 18)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Booking Ref: $name", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFC9A77E))),
            const SizedBox(height: 8),
            Text("Total Amount: ₹${amount.toStringAsFixed(2)}"),
            Text("Current Status: ${status.toUpperCase()}"),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Close", style: TextStyle(color: Colors.white70))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC9A77E)),
            onPressed: () {
              // Quick update status
              portalController.adminUpdateQuotation(bookingId, {'status': 'confirmed'});
              Get.back();
            },
            child: const Text("Confirm Booking", style: TextStyle(color: Color(0xFF091210))),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
      case 'accepted':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
      case 'rejected':
        return Colors.red;
      default:
        return Colors.white54;
    }
  }

  String _getMonthName(int month) {
    const months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
    return months[month - 1];
  }
}
