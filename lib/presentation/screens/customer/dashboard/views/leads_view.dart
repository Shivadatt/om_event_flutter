import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/config/app_theme.dart';
import '../../../../controllers/customer_dashboard_controller.dart';

/// Leads / Inquiry management tab view for customers.
class LeadsView extends StatelessWidget {
  final CustomerDashboardController controller;
  final VoidCallback onNewInquiryPressed;

  const LeadsView({
    super.key,
    required this.controller,
    required this.onNewInquiryPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "CUSTOMER INQUIRIES",
                    style: AppTheme.sansBody(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFFD4AF37), letterSpacing: 1.5),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "My Design Consultations",
                    style: GoogleFonts.italiana(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              // Enhanced Create Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: const Color(0xFF091210),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                  shadowColor: const Color(0x33D4AF37),
                ),
                onPressed: onNewInquiryPressed,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.add_circle_outline_outlined,
                      size: 18,
                      color: Color(0xFF091210), // Explicit dark color for perfect visibility
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "CREATE NEW INQUIRY",
                      style: AppTheme.sansBody(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF091210),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Inquiry Cards List
          Expanded(
            child: Obx(() {
              if (controller.rxLeads.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.assignment_outlined, color: Colors.white24, size: 48),
                      const SizedBox(height: 16),
                      Text("No active inquiries submitted yet.", style: AppTheme.sansBody(fontSize: 14, color: Colors.white54)),
                    ],
                  ),
                );
              }
              return ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: controller.rxLeads.length,
                itemBuilder: (context, index) {
                  final lead = controller.rxLeads[index];
                  final status = lead.status.toLowerCase();
                  final double progress = status == 'confirmed' || status == 'approved' ? 1.0 : (status == 'pending' ? 0.5 : 0.2);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF171411),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0x1AD4AF37)),
                      boxShadow: const [
                        BoxShadow(color: Colors.black45, blurRadius: 12, offset: Offset(0, 6)),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Left luxury gradient accent bar
                          Container(
                            width: 5,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Color(0xFFD4AF37),
                                  Color(0x33D4AF37),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Top Title & Status Row
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: const Color(0x1AD4AF37),
                                              border: Border.all(color: const Color(0x22D4AF37)),
                                            ),
                                            child: const Icon(Icons.spa_outlined, color: Color(0xFFD4AF37), size: 16),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            lead.service.toUpperCase(),
                                            style: GoogleFonts.italiana(
                                              fontSize: 18,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(lead.status).withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(color: _getStatusColor(lead.status).withValues(alpha: 0.4)),
                                        ),
                                        child: Text(
                                          lead.status.toUpperCase(),
                                          style: AppTheme.sansBody(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: _getStatusColor(lead.status),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),

                                  // Segmented Meta Items Row
                                  LayoutBuilder(
                                    builder: (context, constraints) {
                                      final double itemWidth = (constraints.maxWidth - 32) / 3;
                                      return Wrap(
                                        spacing: 16,
                                        runSpacing: 12,
                                        children: [
                                          _buildSegmentedMetaItem(
                                            width: itemWidth,
                                            icon: Icons.payments_outlined,
                                            label: "Budget Valuation",
                                            val: "₹${lead.budget.toStringAsFixed(0)}",
                                          ),
                                          _buildSegmentedMetaItem(
                                            width: itemWidth,
                                            icon: Icons.calendar_today_outlined,
                                            label: "Target Event Date",
                                            val: lead.eventDate.toLocal().toString().split(' ')[0],
                                          ),
                                          _buildSegmentedMetaItem(
                                            width: itemWidth,
                                            icon: Icons.business_outlined,
                                            label: "Design Studio Branch",
                                            val: lead.branch.isNotEmpty ? lead.branch : "Ahmedabad",
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                  const Divider(color: Color(0x1AD4AF37), height: 40),

                                  // Coordinator & Response Expectation Info
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.support_agent_outlined, color: Color(0xFFD4AF37), size: 14),
                                          const SizedBox(width: 8),
                                          Text(
                                            "Coordinator: Senior Event Curation Designer",
                                            style: AppTheme.sansBody(fontSize: 11, color: Colors.white54),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          const Icon(Icons.timer_outlined, color: Color(0xFFE6C98D), size: 14),
                                          const SizedBox(width: 8),
                                          Text(
                                            "Response expected within 24 hours",
                                            style: AppTheme.sansBody(fontSize: 11, color: const Color(0xFFE6C98D)),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),

                                  // Beautiful Status Milestone indicator bar
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: progress,
                                      minHeight: 5,
                                      backgroundColor: Colors.white10,
                                      valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor(lead.status)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentedMetaItem({
    required double width,
    required IconData icon,
    required String label,
    required String val,
  }) {
    return Container(
      width: width >= 180 ? width : double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x0AD4AF37)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFD4AF37), size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: const TextStyle(fontSize: 8, color: Colors.white30, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  val,
                  style: AppTheme.sansBody(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white70),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
      case 'approved':
      case 'accepted':
        return const Color(0xFF7CA68E); // Muted Sage Green
      case 'pending':
        return const Color(0xFFE6C98D); // Champagne Gold
      case 'cancelled':
      case 'rejected':
        return const Color(0xFFC95C5C); // Muted Copper Red
      default:
        return Colors.white54;
    }
  }
}
