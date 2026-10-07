import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../controllers/admin_booking_controller.dart';
import 'widgets/admin_booking_card.dart';
import 'widgets/admin_booking_table.dart';

class AdminBookingsScreen extends GetView<AdminBookingController> {
  const AdminBookingsScreen({super.key});

  Widget _buildKpiCard({
    required String label,
    required int count,
    required IconData icon,
    required Color accentColor,
  }) {
    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F1D18), Color(0xFF0C1914)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.22),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF081410),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: accentColor.withValues(alpha: 0.35),
                width: 1.0,
              ),
            ),
            child: Icon(icon, color: accentColor, size: 18),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                count.toString(),
                style: GoogleFonts.montserrat(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10.5,
                  color: Colors.white60,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKpiRow(bool isDesktop, bool isTablet) {
    final total = controller.totalCount.value;
    final pending = controller.pendingCount.value;
    final accepted = controller.acceptedCount.value;
    final confirmed = controller.confirmedCount.value;
    const goldColor = Color(0xFFECC24A);
    const greenColor = Color(0xFF4EBA7A);

    final card1 = _buildKpiCard(
      label: "Total Bookings",
      count: total,
      icon: Icons.calendar_month_outlined,
      accentColor: goldColor,
    );
    final card2 = _buildKpiCard(
      label: "Pending",
      count: pending,
      icon: Icons.hourglass_empty_rounded,
      accentColor: goldColor,
    );
    final card3 = _buildKpiCard(
      label: "Accepted",
      count: accepted,
      icon: Icons.assignment_turned_in_outlined,
      accentColor: goldColor,
    );
    final card4 = _buildKpiCard(
      label: "Confirmed",
      count: confirmed,
      icon: Icons.check_circle_rounded,
      accentColor: greenColor,
    );

    if (isDesktop) {
      return Row(
        children: [
          Expanded(child: card1),
          const SizedBox(width: 12),
          Expanded(child: card2),
          const SizedBox(width: 12),
          Expanded(child: card3),
          const SizedBox(width: 12),
          Expanded(child: card4),
        ],
      );
    } else if (isTablet) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: card1),
              const SizedBox(width: 10),
              Expanded(child: card2),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: card3),
              const SizedBox(width: 10),
              Expanded(child: card4),
            ],
          ),
        ],
      );
    } else {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            SizedBox(width: 155, child: card1),
            const SizedBox(width: 10),
            SizedBox(width: 135, child: card2),
            const SizedBox(width: 10),
            SizedBox(width: 135, child: card3),
            const SizedBox(width: 10),
            SizedBox(width: 145, child: card4),
          ],
        ),
      );
    }
  }

  Widget _buildSearchAndFilterBar(bool isMobile) {
    const goldColor = Color(0xFFECC24A);
    final hasSearchText = controller.searchQuery.value.isNotEmpty;
    final isListView = controller.viewMode.value == BookingViewMode.list;

    final searchField = Container(
      height: 36,
      decoration: BoxDecoration(
        color: const Color(0xFF0A1612),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: goldColor.withValues(alpha: 0.22), width: 0.9),
      ),
      child: TextField(
        controller: controller.searchController,
        onChanged: (val) => controller.updateSearch(val),
        style: const TextStyle(color: Colors.white, fontSize: 12),
        cursorColor: goldColor,
        decoration: InputDecoration(
          hintText: "Search by booking ID (OM-...), client name, phone, or venue...",
          hintStyle: const TextStyle(color: Colors.white38, fontSize: 11.5),
          prefixIcon: const Icon(Icons.search_rounded, size: 16, color: goldColor),
          prefixIconConstraints: const BoxConstraints(minWidth: 34, minHeight: 36),
          suffixIcon: hasSearchText
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, size: 16, color: Colors.white60),
                  splashRadius: 16,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  tooltip: "Clear search",
                  onPressed: controller.clearSearch,
                )
              : null,
          suffixIconConstraints: const BoxConstraints(minWidth: 32, minHeight: 36),
          filled: false,
          fillColor: Colors.transparent,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          isDense: true,
        ),
      ),
    );

    final dateDropdown = Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1612),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: goldColor.withValues(alpha: 0.22), width: 0.9),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: controller.selectedDateFilter.value,
          dropdownColor: const Color(0xFF0C1914),
          style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w500),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: goldColor),
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
      ),
    );

    final sortDropdown = Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1612),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: goldColor.withValues(alpha: 0.22), width: 0.9),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: controller.selectedSort.value,
          dropdownColor: const Color(0xFF0C1914),
          style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w500),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: goldColor),
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
      ),
    );

    final viewToggle = Container(
      height: 36,
      decoration: BoxDecoration(
        color: const Color(0xFF0A1612),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: goldColor.withValues(alpha: 0.22), width: 0.9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Tooltip(
            message: "List View",
            child: InkWell(
              onTap: () => controller.viewMode.value = BookingViewMode.list,
              borderRadius: BorderRadius.circular(9),
              child: Container(
                width: 32,
                height: 36,
                decoration: BoxDecoration(
                  color: isListView ? goldColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(
                  Icons.table_rows_rounded,
                  size: 15,
                  color: isListView ? const Color(0xFF091410) : Colors.white54,
                ),
              ),
            ),
          ),
          Tooltip(
            message: "Grid View",
            child: InkWell(
              onTap: () => controller.viewMode.value = BookingViewMode.grid,
              borderRadius: BorderRadius.circular(9),
              child: Container(
                width: 32,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: !isListView ? goldColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(
                  Icons.grid_view_rounded,
                  size: 15,
                  color: !isListView ? const Color(0xFF091410) : Colors.white54,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    if (isMobile) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: searchField),
              const SizedBox(width: 8),
              viewToggle,
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: dateDropdown),
              const SizedBox(width: 8),
              Expanded(child: sortDropdown),
            ],
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: searchField),
        const SizedBox(width: 10),
        dateDropdown,
        const SizedBox(width: 8),
        sortDropdown,
        const SizedBox(width: 8),
        viewToggle,
      ],
    );
  }

  Widget _buildStatusChip(String label, int count, bool isSelected, VoidCallback onTap) {
    const goldColor = Color(0xFFECC24A);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 30,
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? goldColor : const Color(0xFF0C1914),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? goldColor : Colors.white.withValues(alpha: 0.12),
            width: 0.9,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? const Color(0xFF091410) : Colors.white70,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF091410)
                      : Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? goldColor : Colors.white70,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 950;
    final isTablet = width >= 650 && width < 950;
    final isMobile = width < 650;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Obx(() {
        if (controller.isLoading.value && controller.rxAllBookings.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFECC24A)),
          );
        }

        final bookings = controller.filteredBookings;
        final selectedTab = controller.selectedStatusTab.value;

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 16 : 24,
            vertical: isMobile ? 14 : 20,
          ),
          child: Container(
            width: double.infinity,
            padding: isDesktop ? const EdgeInsets.all(20) : EdgeInsets.zero,
            decoration: isDesktop
                ? BoxDecoration(
                    color: const Color(0xFF091410).withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: const Color(0xFFECC24A).withValues(alpha: 0.22),
                      width: 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  )
                : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header with Golden Wave Ornament
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "BOOKING MANAGEMENT",
                          style: GoogleFonts.montserrat(
                            fontSize: isMobile ? 18 : 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          "Complete booking details with easy tracking and quick actions.",
                          style: TextStyle(fontSize: 11.5, color: Colors.white60),
                        ),
                      ],
                    ),
                    if (isDesktop)
                      Opacity(
                        opacity: 0.55,
                        child: CustomPaint(
                          size: const Size(120, 38),
                          painter: _GoldHeaderWavePainter(),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 14),

                // 2. 4 KPI Cards
                _buildKpiRow(isDesktop, isTablet),
                const SizedBox(height: 14),

                // 3. Search + Date + Sort Toolbar
                _buildSearchAndFilterBar(isMobile),
                const SizedBox(height: 12),

                // 4. Status Filter Tabs
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
                      _buildStatusChip("Cancelled", controller.cancelledCount.value, selectedTab == 'Cancelled', () => controller.selectedStatusTab.value = 'Cancelled'),
                      _buildStatusChip("Rejected", controller.rejectedCount.value, selectedTab == 'Rejected', () => controller.selectedStatusTab.value = 'Rejected'),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // 5. Booking List / Table / Grid
                if (bookings.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0C1914),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFECC24A).withValues(alpha: 0.18)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: const Color(0xFFECC24A).withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFECC24A).withValues(alpha: 0.35)),
                          ),
                          child: const Icon(Icons.inbox_outlined, size: 26, color: Color(0xFFECC24A)),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          "No Bookings Found",
                          style: GoogleFonts.montserrat(
                            fontSize: 15,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          controller.searchQuery.value.trim().isNotEmpty
                              ? "No bookings match '${controller.searchQuery.value.trim()}'${selectedTab != 'All' ? " with status '$selectedTab'" : ""}."
                              : "No bookings found for '$selectedTab'.",
                          style: const TextStyle(fontSize: 12, color: Colors.white54),
                        ),
                      ],
                    ),
                  )
                else if (controller.viewMode.value == BookingViewMode.grid)
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final gridWidth = constraints.maxWidth;
                      final int crossAxisCount = gridWidth >= 1150
                          ? 3
                          : (gridWidth >= 680 ? 2 : 1);

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: bookings.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          mainAxisExtent: 220,
                        ),
                        itemBuilder: (context, index) => AdminBookingCard(
                          booking: bookings[index],
                          isGridCard: true,
                        ),
                      );
                    },
                  )
                else if (isDesktop)
                  Container(
                    width: double.infinity,
                    height: (MediaQuery.of(context).size.height - 290).clamp(380.0, 580.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0C1914),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFECC24A).withValues(alpha: 0.18)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: AdminBookingTable(bookings: bookings),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: bookings.length,
                    itemBuilder: (context, index) => AdminBookingCard(
                      booking: bookings[index],
                      isGridCard: false,
                    ),
                  ),
                  ],
                ),
              ),
            );
      }),
    );
  }
}

class _GoldHeaderWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFECC24A).withValues(alpha: 0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final path1 = Path();
    path1.moveTo(0, size.height * 0.7);
    path1.cubicTo(
      size.width * 0.3, size.height * 0.1,
      size.width * 0.7, size.height * 0.9,
      size.width, size.height * 0.3,
    );
    canvas.drawPath(path1, paint);

    final path2 = Path();
    path2.moveTo(0, size.height * 0.5);
    path2.cubicTo(
      size.width * 0.35, size.height * 0.8,
      size.width * 0.65, size.height * 0.2,
      size.width, size.height * 0.6,
    );
    canvas.drawPath(path2, paint);

    final path3 = Path();
    path3.moveTo(size.width * 0.15, size.height);
    path3.cubicTo(
      size.width * 0.45, size.height * 0.3,
      size.width * 0.8, size.height * 0.7,
      size.width, size.height * 0.1,
    );
    canvas.drawPath(path3, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

