import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/config/app_theme.dart';
import '../../../controllers/admin_booking_controller.dart';
import 'widgets/admin_booking_card.dart';
import 'widgets/admin_booking_table.dart';

class AdminBookingsScreen extends GetView<AdminBookingController> {
  const AdminBookingsScreen({super.key});

  Widget _buildStatusChip(String label, int count, bool isSelected, VoidCallback onTap) {
    final goldColor = const Color(0xFFD4AF37);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        showCheckmark: false,
        backgroundColor: const Color(0xFF122018),
        selectedColor: goldColor.withValues(alpha: 0.2),
        side: BorderSide(
          color: isSelected ? goldColor : const Color(0xFF1E332B),
          width: 1,
        ),
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTheme.sansBody(
                fontSize: 11,
                color: isSelected ? goldColor : Colors.white70,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected ? goldColor : Colors.white24,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? const Color(0xFF0F1B18) : Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
        onSelected: (_) => onTap(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final goldColor = const Color(0xFFD4AF37);
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 950;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Obx(() {
        if (controller.isLoading.value && controller.rxAllBookings.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
          );
        }

        final bookings = controller.filteredBookings;
        final selectedTab = controller.selectedStatusTab.value;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                "BOOKING MANAGEMENT",
                style: AppTheme.sansBody(
                  fontSize: 11,
                  color: goldColor,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Manage customer bookings, availability and event status.",
                style: AppTheme.sansBody(fontSize: 13, color: Colors.white60),
              ),
              const SizedBox(height: 20),

              // Search & Date Filter Bar
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF122018),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF1E332B)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            onChanged: (val) => controller.searchQuery.value = val,
                            style: const TextStyle(color: Colors.white, fontSize: 13),
                            decoration: InputDecoration(
                              hintText: "Search by booking ID (OM-...), client name, phone, or venue...",
                              hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                              prefixIcon: const Icon(Icons.search, size: 18, color: Color(0xFFD4AF37)),
                              isDense: true,
                              filled: true,
                              fillColor: const Color(0xFF0C1714),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Color(0xFF1E332B)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        DropdownButton<String>(
                          value: controller.selectedDateFilter.value,
                          dropdownColor: const Color(0xFF122018),
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                          underline: const SizedBox(),
                          items: const [
                            DropdownMenuItem(value: 'All', child: Text("All Dates")),
                            DropdownMenuItem(value: 'Today', child: Text("Today")),
                            DropdownMenuItem(value: 'Tomorrow', child: Text("Tomorrow")),
                            DropdownMenuItem(value: 'This Week', child: Text("This Week")),
                            DropdownMenuItem(value: 'This Month', child: Text("This Month")),
                          ],
                          onChanged: (val) {
                            if (val != null) controller.selectedDateFilter.value = val;
                          },
                        ),
                        const SizedBox(width: 12),
                        DropdownButton<String>(
                          value: controller.selectedSort.value,
                          dropdownColor: const Color(0xFF122018),
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                          underline: const SizedBox(),
                          items: const [
                            DropdownMenuItem(value: 'Newest', child: Text("Sort: Newest")),
                            DropdownMenuItem(value: 'Oldest', child: Text("Sort: Oldest")),
                            DropdownMenuItem(value: 'Event Date Asc', child: Text("Event Date ↑")),
                            DropdownMenuItem(value: 'Event Date Desc', child: Text("Event Date ↓")),
                          ],
                          onChanged: (val) {
                            if (val != null) controller.selectedSort.value = val;
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Status Filter Tabs
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildStatusChip("All Bookings", controller.totalCount.value, selectedTab == 'All', () => controller.selectedStatusTab.value = 'All'),
                    _buildStatusChip("Pending", controller.pendingCount.value, selectedTab == 'Pending', () => controller.selectedStatusTab.value = 'Pending'),
                    _buildStatusChip("Accepted", controller.acceptedCount.value, selectedTab == 'Accepted', () => controller.selectedStatusTab.value = 'Accepted'),
                    _buildStatusChip("Confirmed", controller.confirmedCount.value, selectedTab == 'Confirmed', () => controller.selectedStatusTab.value = 'Confirmed'),
                    _buildStatusChip("Cancellation Requests", controller.cancellationRequestsCount.value, selectedTab == 'Cancellation Requests', () => controller.selectedStatusTab.value = 'Cancellation Requests'),
                    _buildStatusChip("Completed", controller.completedCount.value, selectedTab == 'Completed', () => controller.selectedStatusTab.value = 'Completed'),
                    _buildStatusChip("Cancelled", 0, selectedTab == 'Cancelled', () => controller.selectedStatusTab.value = 'Cancelled'),
                    _buildStatusChip("Rejected", 0, selectedTab == 'Rejected', () => controller.selectedStatusTab.value = 'Rejected'),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Booking List / Table
              if (bookings.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(48),
                  decoration: BoxDecoration(
                    color: const Color(0xFF122018),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF1E332B)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.inbox_outlined, size: 48, color: Colors.white24),
                      const SizedBox(height: 12),
                      Text(
                        "No Bookings Found",
                        style: AppTheme.sansBody(fontSize: 14, color: Colors.white70, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "No bookings match '$selectedTab' or search query.",
                        style: AppTheme.sansBody(fontSize: 12, color: Colors.white38),
                      ),
                    ],
                  ),
                )
              else if (isDesktop)
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF122018),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF1E332B)),
                  ),
                  child: AdminBookingTable(bookings: bookings),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: bookings.length,
                  itemBuilder: (context, index) => AdminBookingCard(booking: bookings[index]),
                ),
            ],
          ),
        );
      }),
    );
  }
}
