import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/config/app_theme.dart';
import '../../controllers/admin_customer_portal_controller.dart';
import '../../controllers/admin_controller.dart';

class AdminKpiDashboardScreen extends StatefulWidget {
  const AdminKpiDashboardScreen({super.key});

  @override
  State<AdminKpiDashboardScreen> createState() => _AdminKpiDashboardScreenState();
}

class _AdminKpiDashboardScreenState extends State<AdminKpiDashboardScreen> {
  final portalController = Get.find<AdminCustomerPortalController>();
  final adminController = Get.find<AdminController>();
  String selectedBranch = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF091210),
      appBar: AppBar(
        title: Text("ADMIN KPI PERFORMANCE COCKPIT", style: AppTheme.serifHeader(fontSize: 18)),
        backgroundColor: const Color(0xFF12271F),
        actions: [
          DropdownButton<String>(
            value: selectedBranch,
            dropdownColor: const Color(0xFF12271F),
            underline: const SizedBox(),
            icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFC9A77E)),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            items: const [
              DropdownMenuItem(value: 'All', child: Text("All Branches")),
              DropdownMenuItem(value: 'Kadi', child: Text("Kadi Branch")),
              DropdownMenuItem(value: 'Thangadh', child: Text("Thangadh Branch")),
            ],
            onChanged: (val) {
              if (val != null) {
                setState(() => selectedBranch = val);
              }
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row of Today's/Pending KPI Cards
            Row(
              children: [
                Expanded(child: _buildKpiCard("Today's Revenue", "₹1,25,000", Icons.monetization_on, Colors.green)),
                const SizedBox(width: 16),
                Expanded(child: _buildKpiCard("Today's Leads", "12", Icons.assignment_outlined, Colors.orange)),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _buildKpiCard("Pending Quotes", "8", Icons.description_outlined, Colors.blue)),
                const SizedBox(width: 16),
                Expanded(child: _buildKpiCard("Pending Reviews", "6", Icons.rate_review_outlined, Colors.purple)),
              ],
            ),
            const SizedBox(height: 32),

            // Revenue and Performance charts
            Text("Branch Revenue Distribution", style: AppTheme.serifHeader(fontSize: 18)),
            const SizedBox(height: 16),
            _buildCustomBranchChart(),
            const SizedBox(height: 32),

            // Top categories / Top Services / Top branches side by side
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildTopPanel("Top Categories", [
                    _TopItem("Weddings", "65%", const Color(0xFFC9A77E)),
                    _TopItem("Birthdays", "20%", Colors.teal),
                    _TopItem("Receptions", "15%", Colors.amber),
                  ]),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: _buildTopPanel("Top Services", [
                    _TopItem("Stage Flowers Setup", "42 Orders", const Color(0xFFC9A77E)),
                    _TopItem("LED Backdrop Lighting", "28 Orders", Colors.blue),
                    _TopItem("Theme Entrance Decor", "19 Orders", Colors.purple),
                  ]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiCard(String title, String val, IconData icon, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF12271F),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFC9A77E).withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accentColor, size: 28),
          const SizedBox(height: 16),
          Text(val, style: AppTheme.serifHeader(fontSize: 24)),
          const SizedBox(height: 4),
          Text(title, style: AppTheme.sansBody(fontSize: 12, color: Colors.white54)),
        ],
      ),
    );
  }

  Widget _buildCustomBranchChart() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF12271F),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildBar("Kadi Revenue", 120, "₹3.6L"),
          _buildBar("Thangadh Revenue", 180, "₹5.4L"),
          _buildBar("Total Target", 150, "₹4.5L"),
        ],
      ),
    );
  }

  Widget _buildBar(String label, double height, String value) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFC9A77E))),
        const SizedBox(height: 8),
        Container(
          width: 40,
          height: height,
          decoration: BoxDecoration(
            color: const Color(0xFFC9A77E),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.white70)),
      ],
    );
  }

  Widget _buildTopPanel(String title, List<_TopItem> items) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF12271F),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTheme.serifHeader(fontSize: 16)),
          const SizedBox(height: 16),
          Column(
            children: items.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(radius: 4, backgroundColor: item.color),
                        const SizedBox(width: 8),
                        Text(item.name, style: AppTheme.sansBody(fontSize: 13)),
                      ],
                    ),
                    Text(item.metric, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFC9A77E), fontSize: 13)),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _TopItem {
  final String name;
  final String metric;
  final Color color;
  _TopItem(this.name, this.metric, this.color);
}
