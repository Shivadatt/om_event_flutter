import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../../core/config/app_theme.dart';
import '../../../../../core/services/inquiry_image_resolver.dart';
import '../../../../../core/widgets/app_image.dart';
import '../../../../../domain/entities/customer_lead.dart';
import '../../../../controllers/customer_dashboard_controller.dart';

/// Leads / Inquiry management tab view for customers.
/// Designed to visually match Option 2 Modern Card Style.
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 32,
        vertical: isMobile ? 20 : 28,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header Section ──────────────────────────────────────────
          _buildHeader(context, isMobile: isMobile),
          SizedBox(height: isMobile ? 20 : 28),

          // ── Inquiry Cards List / States ─────────────────────────────
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.rxLeads.isEmpty) {
                return _buildLoadingState(isMobile: isMobile);
              }

              if (controller.rxLeads.isEmpty) {
                return _buildEmptyState(context);
              }

              return ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: controller.rxLeads.length,
                itemBuilder: (context, index) {
                  final lead = controller.rxLeads[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: isMobile
                        ? _buildMobileCard(context, lead, index)
                        : _buildDesktopCard(context, lead, index),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  // ── 1. Page Header ──────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, {required bool isMobile}) {
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "CUSTOMER INQUIRIES",
            style: AppTheme.sansBody(
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFD4AF37),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "My Consultations",
            style: GoogleFonts.italiana(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Create, track and manage your event design consultations with our expert team.",
            style: AppTheme.sansBody(
              fontSize: 11,
              color: Colors.white60,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: _buildCreateButton(isFullWidth: true),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "CUSTOMER INQUIRIES",
                style: AppTheme.sansBody(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFD4AF37),
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "My Design Consultations",
                style: GoogleFonts.italiana(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Create, track and manage your event design consultations with our expert team.",
                style: AppTheme.sansBody(
                  fontSize: 12.5,
                  color: Colors.white60,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 20),
        _buildCreateButton(isFullWidth: false),
      ],
    );
  }

  Widget _buildCreateButton({required bool isFullWidth}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFE5C378),
        foregroundColor: const Color(0xFF091210),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        shadowColor: const Color(0x33D4AF37),
      ),
      onPressed: onNewInquiryPressed,
      child: Row(
        mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.add,
            size: 18,
            color: Color(0xFF091210),
          ),
          const SizedBox(width: 8),
          Text(
            "CREATE NEW INQUIRY",
            style: AppTheme.sansBody(
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF091210),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  // ── 2. Desktop Card Layout (Matching First Reference Image) ─────────────────
  Widget _buildDesktopCard(BuildContext context, CustomerLead lead, int index) {
    final coverUrl = InquiryImageResolver.resolve(lead);
    final status = lead.status.toLowerCase();
    final double progress = (status == 'confirmed' || status == 'approved' || status == 'accepted')
        ? 1.0
        : (status == 'pending' ? 0.35 : 0.65);

    final currencyFmt = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    final budgetStr = currencyFmt.format(lead.budget);
    final eventDateStr = DateFormat('d MMM yyyy').format(lead.eventDate);
    final submittedDateStr = DateFormat('d MMM yyyy').format(lead.date);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111412),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x2BD4AF37), width: 1.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left: Vertical Aspect Image
          Container(
            width: 175,
            height: 235,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: const Color(0xFF17201B),
              border: Border.all(color: const Color(0x22D4AF37), width: 1),
            ),
            clipBehavior: Clip.antiAlias,
            child: coverUrl.isNotEmpty
                ? AppImage(
                    url: coverUrl,
                    width: 175,
                    height: 235,
                    fit: BoxFit.cover,
                    placeholder: _buildFallbackImage(),
                  )
                : _buildFallbackImage(),
          ),

          // Center & Right: Card Information Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 20, 24, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row 1: Brand Icon + Title + Reference ID & Status Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF14201A),
                              border: Border.all(color: const Color(0xFFD4AF37), width: 1.2),
                              boxShadow: const [
                                BoxShadow(color: Color(0x33D4AF37), blurRadius: 6),
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.spa_outlined,
                                color: Color(0xFFD4AF37),
                                size: 18,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                lead.service.toUpperCase(),
                                style: GoogleFonts.italiana(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                lead.leadNumber.isNotEmpty
                                    ? lead.leadNumber
                                    : (lead.id.isNotEmpty
                                        ? "L-${lead.id.substring(0, math.min(10, lead.id.length)).toUpperCase()}"
                                        : "L-${DateTime.now().millisecondsSinceEpoch}"),
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  color: Color(0xFFD4AF37),
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      _buildStatusBadge(lead.status),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Row 2: 4 Compact Segmented Metadata Items
                  Wrap(
                    spacing: 24,
                    runSpacing: 12,
                    children: [
                      _buildCompactMetaItem(
                        icon: Icons.payments_outlined,
                        val: budgetStr,
                        label: "Budget Valuation",
                      ),
                      _buildCompactMetaItem(
                        icon: Icons.calendar_today_outlined,
                        val: eventDateStr,
                        label: "Target Event Date",
                      ),
                      _buildCompactMetaItem(
                        icon: Icons.business_outlined,
                        val: lead.branch.isNotEmpty ? lead.branch : "Kadi",
                        label: "Studio Branch",
                      ),
                      _buildCompactMetaItem(
                        icon: Icons.schedule_outlined,
                        val: submittedDateStr,
                        label: "Submitted Date",
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Row 3: Progress Bar & Response Notice
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 4,
                          backgroundColor: Colors.white.withValues(alpha: 0.08),
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE5C378)),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: Color(0xFFE6C98D),
                              size: 13,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              "Response expected within 24 hours",
                              style: AppTheme.sansBody(
                                fontSize: 10.5,
                                color: const Color(0xFFE6C98D),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Row 4: Coordinator (Left) & Actions (Right)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Coordinator Block
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0x55D4AF37), width: 1),
                              color: const Color(0xFF1A2620),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Image.network(
                              'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?q=80&w=200',
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Center(
                                child: Icon(
                                  Icons.person,
                                  size: 16,
                                  color: Color(0xFFD4AF37),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Coordinator",
                                style: AppTheme.sansBody(
                                  fontSize: 9.5,
                                  color: Colors.white38,
                                ),
                              ),
                              Text(
                                "Senior Event Curation Designer",
                                style: AppTheme.sansBody(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Actions Block: View Details + More
                      Row(
                        children: [
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0x66D4AF37), width: 1.0),
                              backgroundColor: const Color(0x0DD4AF37),
                              foregroundColor: const Color(0xFFE5C378),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                            ),
                            onPressed: () => _showLeadDetailsDialog(context, lead),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "View Details",
                                  style: AppTheme.sansBody(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFFE5C378),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 14,
                                  color: Color(0xFFE5C378),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildMoreMenu(context, lead),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── 3. Mobile Card Layout (Matching Mobile Preview on Image 1) ──────────────
  Widget _buildMobileCard(BuildContext context, CustomerLead lead, int index) {
    final coverUrl = InquiryImageResolver.resolve(lead);
    final currencyFmt = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    final budgetStr = currencyFmt.format(lead.budget);
    final eventDateStr = DateFormat('d MMM yyyy').format(lead.eventDate);
    final submittedDateStr = DateFormat('d MMM yyyy').format(lead.date);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111412),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x2BD4AF37), width: 1.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Thumbnail + Title/ID + Status
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: const Color(0xFF16211B),
                  border: Border.all(color: const Color(0x33D4AF37)),
                ),
                clipBehavior: Clip.antiAlias,
                child: coverUrl.isNotEmpty
                    ? AppImage(
                        url: coverUrl,
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                        placeholder: _buildFallbackImage(),
                      )
                    : _buildFallbackImage(),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lead.service.toUpperCase(),
                      style: GoogleFonts.italiana(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      lead.leadNumber.isNotEmpty
                          ? lead.leadNumber
                          : (lead.id.isNotEmpty
                              ? "L-${lead.id.substring(0, math.min(10, lead.id.length)).toUpperCase()}"
                              : "INQUIRY"),
                      style: const TextStyle(
                        fontSize: 9.5,
                        color: Color(0xFFD4AF37),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _buildStatusBadge(lead.status),
            ],
          ),
          const SizedBox(height: 14),

          // Metadata List (Mobile Stacked)
          _buildMobileMetaRow(Icons.payments_outlined, budgetStr, "Budget Valuation"),
          const SizedBox(height: 6),
          _buildMobileMetaRow(Icons.calendar_today_outlined, eventDateStr, "Target Event Date"),
          const SizedBox(height: 6),
          _buildMobileMetaRow(Icons.business_outlined, lead.branch.isNotEmpty ? lead.branch : "Kadi", "Studio Branch"),
          const SizedBox(height: 6),
          _buildMobileMetaRow(Icons.schedule_outlined, submittedDateStr, "Submitted Date"),
          const SizedBox(height: 12),

          // Response notice
          Row(
            children: [
              const Icon(Icons.info_outline, color: Color(0xFFE6C98D), size: 12),
              const SizedBox(width: 5),
              Text(
                "Response expected within 24 hours",
                style: AppTheme.sansBody(fontSize: 10, color: const Color(0xFFE6C98D)),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Full width View Details Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0x66D4AF37)),
                backgroundColor: const Color(0x0DD4AF37),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => _showLeadDetailsDialog(context, lead),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "View Details",
                    style: AppTheme.sansBody(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFE5C378),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.arrow_forward_rounded, size: 14, color: Color(0xFFE5C378)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileMetaRow(IconData icon, String val, String label) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFD4AF37), size: 15),
        const SizedBox(width: 10),
        Text(
          val,
          style: AppTheme.sansBody(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(width: 6),
        Text(
          "($label)",
          style: const TextStyle(fontSize: 9.5, color: Colors.white38),
        ),
      ],
    );
  }

  // ── 4. Compact Metadata Item (Desktop) ──────────────────────────────────────
  Widget _buildCompactMetaItem({
    required IconData icon,
    required String val,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 2),
          child: Icon(icon, color: const Color(0xFFD4AF37), size: 17),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              val,
              style: AppTheme.sansBody(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.white38,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── 5. Status Badge ─────────────────────────────────────────────────────────
  Widget _buildStatusBadge(String status) {
    final s = status.toLowerCase();
    Color badgeColor = const Color(0xFFE5C378);
    Color bgColor = const Color(0xFF231C14);

    if (s == 'confirmed' || s == 'approved' || s == 'accepted') {
      badgeColor = const Color(0xFF7CA68E);
      bgColor = const Color(0xFF132219);
    } else if (s == 'cancelled' || s == 'rejected') {
      badgeColor = const Color(0xFFC95C5C);
      bgColor = const Color(0xFF281313);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: badgeColor.withValues(alpha: 0.5), width: 1.0),
      ),
      child: Text(
        status.toUpperCase(),
        style: AppTheme.sansBody(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: badgeColor,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  // ── 6. More Actions Overflow Menu ───────────────────────────────────────────
  Widget _buildMoreMenu(BuildContext context, CustomerLead lead) {
    return Theme(
      data: Theme.of(context).copyWith(
        popupMenuTheme: const PopupMenuThemeData(
          color: Color(0xFF171411),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            side: BorderSide(color: Color(0x33D4AF37)),
          ),
        ),
      ),
      child: PopupMenuButton<String>(
        icon: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: const Color(0x0DD4AF37),
            border: Border.all(color: const Color(0x33D4AF37)),
          ),
          child: const Center(
            child: Icon(Icons.more_horiz, color: Colors.white70, size: 18),
          ),
        ),
        tooltip: "More options",
        onSelected: (val) {
          if (val == 'details') {
            _showLeadDetailsDialog(context, lead);
          } else if (val == 'support') {
            // Switch to Concierge tab (tab 9)
            Get.snackbar(
              "Concierge Support",
              "Connecting with your event curator for inquiry ${lead.leadNumber}...",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: const Color(0xFF14201A),
              colorText: const Color(0xFFD4AF37),
            );
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'details',
            child: Row(
              children: [
                Icon(Icons.visibility_outlined, color: Color(0xFFD4AF37), size: 16),
                SizedBox(width: 10),
                Text("View Full Details", style: TextStyle(color: Colors.white, fontSize: 12.5)),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'support',
            child: Row(
              children: [
                Icon(Icons.support_agent_outlined, color: Color(0xFFD4AF37), size: 16),
                SizedBox(width: 10),
                Text("Contact Curator", style: TextStyle(color: Colors.white, fontSize: 12.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 7. Lead Details Modal Dialog ────────────────────────────────────────────
  void _showLeadDetailsDialog(BuildContext context, CustomerLead lead) {
    final currencyFmt = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    final eventDateStr = DateFormat('EEEE, d MMMM yyyy').format(lead.eventDate);
    final submittedDateStr = DateFormat('d MMMM yyyy, h:mm a').format(lead.date);

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 520,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: const Color(0xFF0F1512),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFD4AF37), width: 1.2),
            boxShadow: const [
              BoxShadow(color: Colors.black87, blurRadius: 24, offset: Offset(0, 8)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "CONSULTATION DETAILS",
                        style: AppTheme.sansBody(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFD4AF37),
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        lead.service.toUpperCase(),
                        style: GoogleFonts.italiana(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  _buildStatusBadge(lead.status),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                "Reference: ${lead.leadNumber.isNotEmpty ? lead.leadNumber : lead.id}",
                style: const TextStyle(fontSize: 11, color: Colors.white54),
              ),
              const Divider(color: Color(0x22D4AF37), height: 32),

              // Detailed metadata list
              _buildDetailRow(Icons.payments_outlined, "Budget Valuation", currencyFmt.format(lead.budget)),
              const SizedBox(height: 12),
              _buildDetailRow(Icons.calendar_today_outlined, "Target Event Date", eventDateStr),
              const SizedBox(height: 12),
              _buildDetailRow(Icons.business_outlined, "Design Studio Branch", lead.branch.isNotEmpty ? lead.branch : "Kadi"),
              const SizedBox(height: 12),
              _buildDetailRow(Icons.schedule_outlined, "Submitted On", submittedDateStr),
              const SizedBox(height: 12),
              _buildDetailRow(Icons.person_pin_outlined, "Curation Coordinator", "Senior Event Curation Designer"),
              if (lead.adminNotes.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildDetailRow(Icons.notes_outlined, "Consultant Notes", lead.adminNotes),
              ],
              const Divider(color: Color(0x22D4AF37), height: 32),

              // Action button
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE5C378),
                    foregroundColor: const Color(0xFF091210),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => Get.back(),
                  child: const Text("CLOSE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFFD4AF37), size: 16),
        const SizedBox(width: 12),
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: const TextStyle(fontSize: 11.5, color: Colors.white54),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
          ),
        ),
      ],
    );
  }

  // ── 8. Empty State ──────────────────────────────────────────────────────────
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: const Color(0xFF111412),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0x22D4AF37)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x1AD4AF37),
              ),
              child: const Icon(Icons.assignment_outlined, color: Color(0xFFD4AF37), size: 32),
            ),
            const SizedBox(height: 18),
            Text(
              "CUSTOMER INQUIRIES",
              style: AppTheme.sansBody(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFD4AF37),
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "No design consultations yet.",
              style: GoogleFonts.italiana(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              "Start your first consultation with our team and let our curation coordinators design your dream event.",
              style: AppTheme.sansBody(fontSize: 12, color: Colors.white54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _buildCreateButton(isFullWidth: false),
          ],
        ),
      ),
    );
  }

  // ── 9. Loading State Skeleton ───────────────────────────────────────────────
  Widget _buildLoadingState({required bool isMobile}) {
    return ListView.builder(
      itemCount: 2,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 24),
          height: isMobile ? 180 : 230,
          decoration: BoxDecoration(
            color: const Color(0xFF111412),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0x1AD4AF37)),
          ),
          child: const Center(
            child: SizedBox(
              width: 26,
              height: 26,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFFD4AF37),
              ),
            ),
          ),
        );
      },
    );
  }

  // ── 10. Fallback Brand Placeholder Image ──────────────────────────────────
  Widget _buildFallbackImage() {
    return Container(
      color: const Color(0xFF14201A),
      child: const Center(
        child: Icon(Icons.spa_outlined, color: Color(0xFFD4AF37), size: 36),
      ),
    );
  }
}
