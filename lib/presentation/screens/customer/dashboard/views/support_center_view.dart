import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../../core/config/app_theme.dart';
import '../../../../../core/services/business_details_service.dart';
import '../../../../../core/utils/booking_communication_helper.dart';
import '../../../../../domain/entities/business_details_entity.dart';
import '../../../../../domain/entities/support_ticket.dart';
import '../../../../controllers/customer_dashboard_controller.dart';

/// Support Ticket and Hotline communications view for customers.
/// Implements Option 4: "Premium Detailed Style" with canonical dynamic contact
/// SSOT binding from BusinessDetailsService & AppConfigService.
class SupportCenterView extends StatefulWidget {
  final CustomerDashboardController controller;

  const SupportCenterView({
    super.key,
    required this.controller,
  });

  @override
  State<SupportCenterView> createState() => _SupportCenterViewState();
}

class _SupportCenterViewState extends State<SupportCenterView> {
  final rxSelectedFilter = 'All Tickets'.obs;
  final rxSearchQuery = ''.obs;
  final searchCtrl = TextEditingController();
  final _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    searchCtrl.dispose();
    super.dispose();
  }

  String _formatRelativeTime(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inSeconds < 60) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return DateFormat('dd MMM yyyy').format(dateTime);
    }
  }

  String _resolveWorkingHours(BusinessDetailsEntity details) {
    if (details.workingHours.monday.isNotEmpty) {
      return 'Mon - Sun, ${details.workingHours.monday}';
    }
    if (details.branches.isNotEmpty && details.branches.first.workingHours.isNotEmpty) {
      return details.branches.first.workingHours;
    }
    return 'Mon - Sun, 9:00 AM - 9:00 PM';
  }

  List<SupportTicket> _getFilteredTickets(List<SupportTicket> tickets) {
    var result = List<SupportTicket>.from(tickets);
    result.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final filter = rxSelectedFilter.value;
    if (filter == 'Active Review') {
      result = result.where((t) {
        final s = t.status.toLowerCase();
        return s == 'active review' || s == 'open' || s == 'in progress';
      }).toList();
    } else if (filter == 'Resolved') {
      result = result.where((t) => t.status.toLowerCase() == 'resolved').toList();
    } else if (filter == 'Closed') {
      result = result.where((t) => t.status.toLowerCase() == 'closed').toList();
    } else if (filter == 'Pending') {
      result = result.where((t) => t.status.toLowerCase() == 'pending').toList();
    }

    final query = rxSearchQuery.value.trim().toLowerCase();
    if (query.isNotEmpty) {
      result = result.where((t) =>
        t.subject.toLowerCase().contains(query) ||
        t.id.toLowerCase().contains(query) ||
        t.status.toLowerCase().contains(query)
      ).toList();
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 700;
    final bool isTablet = screenWidth >= 700 && screenWidth < 1050;

    return Obx(() {
      final details = BusinessDetailsService.to.rxDetails.value;
      final tickets = widget.controller.rxTickets;
      final filteredTickets = _getFilteredTickets(tickets);

      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 16 : 32,
          vertical: isMobile ? 18 : 28,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── 1. Header (Eyebrow + Title + Subtitle + 24/7 Support Card) ───
            _buildHeader(details: details, isMobile: isMobile),

            const SizedBox(height: 24),

            // ─── 2. Contact Action Cards (WhatsApp + Call + Email) ───
            _buildContactCards(
              details: details,
              isMobile: isMobile,
              isTablet: isTablet,
            ),

            const SizedBox(height: 20),

            // ─── 3. Full-width Prominent CTA: + Raise Support Ticket → ───
            _buildRaiseTicketBanner(isMobile: isMobile),

            const SizedBox(height: 32),

            // ─── 4. Ticket History Header & Table/Cards ───
            _buildTicketHistorySection(
              filteredTickets: filteredTickets,
              isMobile: isMobile,
              totalTicketsCount: tickets.length,
            ),

            const SizedBox(height: 40),
          ],
        ),
      );
    });
  }

  String _resolveSupportAvailability(BusinessDetailsEntity details) {
    if (details.workingHours.emergencyHours.trim().isNotEmpty) {
      final hours = details.workingHours.emergencyHours.trim();
      return hours.toLowerCase().contains('support') ? hours.toUpperCase() : '$hours SUPPORT';
    }
    if (details.workingHours.monday.trim().isNotEmpty) {
      return '${details.workingHours.monday.trim().toUpperCase()} SUPPORT';
    }
    if (details.branches.isNotEmpty && details.branches.first.workingHours.trim().isNotEmpty) {
      return '${details.branches.first.workingHours.trim().toUpperCase()} SUPPORT';
    }
    return '24/7 SUPPORT';
  }

  // ─── Header Section ────────────────────────────────────────────────────────
  Widget _buildHeader({required BusinessDetailsEntity details, required bool isMobile}) {
    final titleBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "CONCIERGE HELP & CHAT",
          style: AppTheme.sansBody(
            fontSize: 10.5,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFD4AF37),
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Premium Concierge Center",
          style: GoogleFonts.italiana(
            fontSize: isMobile ? 22 : 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Dedicated support to make every moment of your event flawless.",
          style: AppTheme.sansBody(
            fontSize: isMobile ? 11.5 : 12.5,
            color: Colors.white60,
          ),
        ),
      ],
    );

    // Support info card (top right)
    final supportCard = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1713),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFD4AF37).withValues(alpha: 0.25),
          width: 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFD4AF37).withValues(alpha: 0.12),
              border: Border.all(
                color: const Color(0xFFD4AF37).withValues(alpha: 0.35),
                width: 1.0,
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.headset_mic_outlined,
                color: Color(0xFFD4AF37),
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _resolveSupportAvailability(details),
                style: GoogleFonts.italiana(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFE8CC8A),
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                "We're always here for you",
                style: AppTheme.sansBody(
                  fontSize: 10,
                  color: Colors.white54,
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleBlock,
          const SizedBox(height: 14),
          supportCard,
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: titleBlock),
        const SizedBox(width: 20),
        supportCard,
      ],
    );
  }

  // ─── Contact Action Cards ──────────────────────────────────────────────────
  Widget _buildContactCards({
    required BusinessDetailsEntity details,
    required bool isMobile,
    required bool isTablet,
  }) {
    // Resolve dynamic WhatsApp options (both canonical numbers from SSOT)
    final waOptions = BookingCommunicationHelper.getBusinessWhatsAppOptions();
    final wa1 = waOptions.isNotEmpty ? waOptions.first : null;
    final wa2 = waOptions.length > 1 ? waOptions[1] : null;

    // Resolve dynamic Phone options (both canonical numbers from SSOT) & Hours
    final phoneOptions = BookingCommunicationHelper.getBusinessPhoneOptions();
    final phone1 = phoneOptions.isNotEmpty ? phoneOptions.first : null;
    final phone2 = phoneOptions.length > 1 ? phoneOptions[1] : null;
    final workingHours = _resolveWorkingHours(details);

    // Resolve dynamic Email
    final email = BookingCommunicationHelper.getBusinessEmail();

    if (isMobile) {
      final waSubtitle = waOptions.map((o) => o.displayPhone).join("  •  ");
      final phoneSubtitle = phoneOptions.map((o) => o.displayPhone).join("  •  ");

      return Column(
        children: [
          _buildMobileContactCard(
            badgeColor: const Color(0x1F25D366),
            iconColor: const Color(0xFF25D366),
            icon: Icons.chat_bubble_rounded,
            title: "WhatsApp Chat",
            value: waSubtitle,
            onTap: () => _handleWhatsAppCta(waOptions),
          ),
          const SizedBox(height: 10),
          _buildMobileContactCard(
            badgeColor: const Color(0x1FD4AF37),
            iconColor: const Color(0xFFD4AF37),
            icon: Icons.phone_in_talk_rounded,
            title: "Call Hotline",
            value: phoneSubtitle,
            onTap: () => _handleCallCta(phoneOptions),
          ),
          const SizedBox(height: 10),
          _buildMobileContactCard(
            badgeColor: const Color(0x1FD4AF37),
            iconColor: const Color(0xFFD4AF37),
            icon: Icons.mail_outline_rounded,
            title: "Email Desk",
            value: email,
            onTap: () => BookingCommunicationHelper.openEmail(
              email: email,
              subject: "Concierge Support Request",
              body: "Hello Om Events Concierge Team,\n\nI need assistance regarding: ",
            ),
          ),
        ],
      );
    }

    final waCard = _buildWhatsAppCard(
      wa1: wa1,
      wa2: wa2,
      onCta: () => _handleWhatsAppCta(waOptions),
    );

    final phoneCard = _buildCallCard(
      phone1: phone1,
      phone2: phone2,
      workingHours: workingHours,
      onCta: () => _handleCallCta(phoneOptions),
    );

    final emailCard = _buildEmailCard(
      email: email,
      onCta: () => BookingCommunicationHelper.openEmail(
        email: email,
        subject: "Concierge Support Request",
        body: "Hello Om Events Concierge Team,\n\nI need assistance regarding: ",
      ),
    );

    if (isTablet) {
      return Column(
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: waCard),
                const SizedBox(width: 14),
                Expanded(child: phoneCard),
              ],
            ),
          ),
          const SizedBox(height: 14),
          emailCard,
        ],
      );
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: waCard),
          const SizedBox(width: 14),
          Expanded(child: phoneCard),
          const SizedBox(width: 14),
          Expanded(child: emailCard),
        ],
      ),
    );
  }

  void _openWhatsAppForOption(BusinessContactOption option) {
    final customerName = widget.controller.rxProfile.value?.fullName;
    BookingCommunicationHelper.openWhatsApp(
      phone: option.rawPhone,
      message: BookingCommunicationHelper.generateGeneralInquiryMessage(
        customerName: customerName,
      ),
    );
  }

  void _openCallForOption(BusinessContactOption option) {
    BookingCommunicationHelper.openCall(option.rawPhone);
  }

  void _handleWhatsAppCta(List<BusinessContactOption> options) {
    if (options.length <= 1) {
      if (options.isNotEmpty) _openWhatsAppForOption(options.first);
      return;
    }
    _showContactChooserDialog(
      title: "WHATSAPP CHAT",
      subtitle: "Select your preferred WhatsApp support desk:",
      icon: Icons.chat_bubble_rounded,
      iconColor: const Color(0xFF25D366),
      options: options,
      onSelect: _openWhatsAppForOption,
    );
  }

  void _handleCallCta(List<BusinessContactOption> options) {
    if (options.length <= 1) {
      if (options.isNotEmpty) _openCallForOption(options.first);
      return;
    }
    _showContactChooserDialog(
      title: "CALL HOTLINE",
      subtitle: "Select the team you would like to connect with:",
      icon: Icons.phone_in_talk_rounded,
      iconColor: const Color(0xFFD4AF37),
      options: options,
      onSelect: _openCallForOption,
    );
  }

  void _showContactChooserDialog({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required List<BusinessContactOption> options,
    required void Function(BusinessContactOption option) onSelect,
  }) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 380,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xFF0F1713),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFD4AF37).withValues(alpha: 0.35),
              width: 1.2,
            ),
            boxShadow: const [
              BoxShadow(color: Colors.black87, blurRadius: 24, offset: Offset(0, 8)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: iconColor.withValues(alpha: 0.15),
                      border: Border.all(color: iconColor.withValues(alpha: 0.4)),
                    ),
                    child: Center(child: Icon(icon, color: iconColor, size: 18)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.italiana(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: AppTheme.sansBody(fontSize: 10.5, color: Colors.white60),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18, color: Colors.white54),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, color: Color(0x1AD4AF37)),
              const SizedBox(height: 12),
              ...options.map((opt) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
                    ),
                  ),
                  child: Material(
                    color: const Color(0xFF14201A),
                    borderRadius: BorderRadius.circular(10),
                    clipBehavior: Clip.antiAlias,
                    child: ListTile(
                      dense: true,
                      hoverColor: const Color(0x1AD4AF37),
                      leading: Icon(icon, color: iconColor, size: 18),
                      title: Text(
                        opt.displayPhone,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        opt.label,
                        style: TextStyle(
                          color: opt.isPrimary ? const Color(0xFFE8CC8A) : Colors.white60,
                          fontSize: 11,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 13,
                        color: Color(0xFFD4AF37),
                      ),
                      onTap: () {
                        Get.back();
                        onSelect(opt);
                      },
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWhatsAppCard({
    required BusinessContactOption? wa1,
    required BusinessContactOption? wa2,
    required VoidCallback onCta,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1713),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFD4AF37).withValues(alpha: 0.22),
          width: 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0x1F25D366),
                  border: Border.all(
                    color: const Color(0xFF25D366).withValues(alpha: 0.4),
                    width: 1.0,
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.chat_bubble_rounded, color: Color(0xFF25D366), size: 20),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "WhatsApp Chat",
                      style: GoogleFonts.italiana(
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Instant response from our support team",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.sansBody(
                        fontSize: 10.5,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (wa1 != null)
            _buildInteractiveContactRow(
              icon: Icons.chat_bubble_outline_rounded,
              iconColor: const Color(0xFF25D366),
              label: wa1.label,
              displayPhone: wa1.displayPhone,
              onTap: () => _openWhatsAppForOption(wa1),
            ),
          if (wa2 != null) ...[
            const SizedBox(height: 4),
            _buildInteractiveContactRow(
              icon: Icons.chat_bubble_outline_rounded,
              iconColor: const Color(0xFF25D366),
              label: wa2.label,
              displayPhone: wa2.displayPhone,
              onTap: () => _openWhatsAppForOption(wa2),
            ),
          ],
          const Spacer(),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 36,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE5C365),
                foregroundColor: const Color(0xFF091210),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                textStyle: AppTheme.sansBody(
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: onCta,
              child: const Text("Chat Now →"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallCard({
    required BusinessContactOption? phone1,
    required BusinessContactOption? phone2,
    required String workingHours,
    required VoidCallback onCta,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1713),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFD4AF37).withValues(alpha: 0.22),
          width: 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0x1FD4AF37),
                  border: Border.all(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
                    width: 1.0,
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.phone_in_talk_rounded, color: Color(0xFFD4AF37), size: 20),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Call Hotline",
                      style: GoogleFonts.italiana(
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      workingHours,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.sansBody(
                        fontSize: 10.5,
                        color: const Color(0xFFD4AF37).withValues(alpha: 0.85),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (phone1 != null)
            _buildInteractiveContactRow(
              icon: Icons.phone_outlined,
              iconColor: const Color(0xFFD4AF37),
              label: phone1.label,
              displayPhone: phone1.displayPhone,
              onTap: () => _openCallForOption(phone1),
            ),
          if (phone2 != null) ...[
            const SizedBox(height: 4),
            _buildInteractiveContactRow(
              icon: Icons.phone_outlined,
              iconColor: const Color(0xFFD4AF37),
              label: phone2.label,
              displayPhone: phone2.displayPhone,
              onTap: () => _openCallForOption(phone2),
            ),
          ],
          const Spacer(),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 36,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE5C365),
                foregroundColor: const Color(0xFF091210),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                textStyle: AppTheme.sansBody(
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: onCta,
              child: const Text("Call Now →"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailCard({
    required String email,
    required VoidCallback onCta,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1713),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFD4AF37).withValues(alpha: 0.22),
          width: 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0x1FD4AF37),
                  border: Border.all(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
                    width: 1.0,
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.mail_outline_rounded, color: Color(0xFFD4AF37), size: 20),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Email Desk",
                      style: GoogleFonts.italiana(
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Inquiries & custom proposals",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.sansBody(
                        fontSize: 10.5,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: onCta,
            borderRadius: BorderRadius.circular(6),
            hoverColor: const Color(0x14D4AF37),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.5, horizontal: 2),
              child: Row(
                children: [
                  const Icon(Icons.email_outlined, size: 12, color: Color(0xFFD4AF37)),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.sansBody(
                        fontSize: 11,
                        color: const Color(0xFFE8CC8A),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 19),
            child: Text(
              "Response within 24 hrs",
              style: AppTheme.sansBody(
                fontSize: 10.5,
                color: Colors.white54,
              ),
            ),
          ),
          const Spacer(),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 36,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE5C365),
                foregroundColor: const Color(0xFF091210),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                textStyle: AppTheme.sansBody(
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: onCta,
              child: const Text("Send Email →"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveContactRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String displayPhone,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      hoverColor: const Color(0x14D4AF37),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.5, horizontal: 2),
        child: Row(
          children: [
            Icon(icon, size: 12, color: iconColor.withValues(alpha: 0.9)),
            const SizedBox(width: 7),
            Text(
              "$label: ",
              style: AppTheme.sansBody(
                fontSize: 10.5,
                color: Colors.white60,
                fontWeight: FontWeight.w500,
              ),
            ),
            Expanded(
              child: Text(
                displayPhone,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.sansBody(
                  fontSize: 11,
                  color: const Color(0xFFE8CC8A),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileContactCard({
    required Color badgeColor,
    required Color iconColor,
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF0F1713),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFD4AF37).withValues(alpha: 0.22),
            width: 1.0,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black45,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: badgeColor,
                border: Border.all(
                  color: iconColor.withValues(alpha: 0.4),
                  width: 1.0,
                ),
              ),
              child: Center(
                child: Icon(icon, color: iconColor, size: 20),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.sansBody(
                      fontSize: 12,
                      color: const Color(0xFFE8CC8A).withValues(alpha: 0.85),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFFD4AF37),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  // ─── Prominent Raise Ticket Banner ─────────────────────────────────────────
  Widget _buildRaiseTicketBanner({required bool isMobile}) {
    return Container(
      width: double.infinity,
      height: 46,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE5C365),
          foregroundColor: const Color(0xFF091210),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: _showRaiseTicketDialog,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add, size: 18, color: Color(0xFF091210)),
            const SizedBox(width: 8),
            Text(
              isMobile ? "Raise Ticket" : "Raise Support Ticket →",
              style: AppTheme.sansBody(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF091210),
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Ticket History Section ────────────────────────────────────────────────
  Widget _buildTicketHistorySection({
    required List<SupportTicket> filteredTickets,
    required bool isMobile,
    required int totalTicketsCount,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Filter bar & Search
        if (isMobile) ...[
          Text(
            "Ticket History",
            style: GoogleFonts.italiana(
              fontSize: 19,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildSearchField()),
              const SizedBox(width: 10),
              _buildFilterDropdown(),
            ],
          ),
        ] else ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Ticket History",
                style: GoogleFonts.italiana(
                  fontSize: 19,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              Row(
                children: [
                  _buildFilterDropdown(),
                  const SizedBox(width: 12),
                  SizedBox(width: 220, child: _buildSearchField()),
                ],
              ),
            ],
          ),
        ],

        const SizedBox(height: 16),

        // Ticket Items
        if (filteredTickets.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
            decoration: BoxDecoration(
              color: const Color(0xFF0F1713),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                width: 1.0,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.confirmation_number_outlined,
                  size: 34,
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.5),
                ),
                const SizedBox(height: 12),
                Text(
                  totalTicketsCount == 0
                      ? "No support tickets raised yet."
                      : "No tickets match your filter criteria.",
                  style: GoogleFonts.italiana(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  totalTicketsCount == 0
                      ? "Click '+ Raise Support Ticket' above to get dedicated concierge assistance."
                      : "Try resetting your search query or status filter.",
                  style: AppTheme.sansBody(fontSize: 11, color: Colors.white38),
                ),
              ],
            ),
          )
        else if (isMobile)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredTickets.length,
            itemBuilder: (context, index) {
              final ticket = filteredTickets[index];
              return _buildMobileTicketCard(ticket);
            },
          )
        else
          _buildDesktopTicketTable(filteredTickets),
      ],
    );
  }

  Widget _buildSearchField() {
    final isFocused = _searchFocusNode.hasFocus;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      height: 35,
      decoration: BoxDecoration(
        color: const Color(0xFF101914),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isFocused
              ? const Color(0xFFD4AF37).withValues(alpha: 0.6)
              : const Color(0xFFD4AF37).withValues(alpha: 0.25),
          width: 1.0,
        ),
        boxShadow: isFocused
            ? [
                BoxShadow(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.12),
                  blurRadius: 6,
                  offset: const Offset(0, 1),
                ),
              ]
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: 10),
          Icon(
            Icons.search_rounded,
            size: 15,
            color: isFocused
                ? const Color(0xFFD4AF37)
                : const Color(0xFFD4AF37).withValues(alpha: 0.6),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: searchCtrl,
              focusNode: _searchFocusNode,
              onChanged: (val) => rxSearchQuery.value = val,
              style: AppTheme.sansBody(fontSize: 11, color: Colors.white),
              cursorColor: const Color(0xFFD4AF37),
              textAlignVertical: TextAlignVertical.center,
              decoration: InputDecoration(
                hintText: "Search tickets...",
                hintStyle: AppTheme.sansBody(
                  fontSize: 10.5,
                  color: const Color(0xFF6B7E76),
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                filled: false,
                fillColor: Colors.transparent,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 9),
              ),
            ),
          ),
          if (searchCtrl.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close, size: 14, color: Colors.white38),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
              onPressed: () {
                searchCtrl.clear();
                rxSearchQuery.value = '';
              },
            )
          else
            const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown() {
    final filters = ['All Tickets', 'Active Review', 'Pending', 'Resolved', 'Closed'];

    return Container(
      height: 35,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1713),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFD4AF37).withValues(alpha: 0.25),
          width: 1.0,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: rxSelectedFilter.value,
          dropdownColor: const Color(0xFF0F1713),
          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFD4AF37), size: 18),
          style: AppTheme.sansBody(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
          items: filters.map((f) {
            return DropdownMenuItem<String>(
              value: f,
              child: Text(f),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) rxSelectedFilter.value = val;
          },
        ),
      ),
    );
  }

  Widget _buildDesktopTicketTable(List<SupportTicket> tickets) {
    final headerStyle = AppTheme.sansBody(
      fontSize: 9.5,
      fontWeight: FontWeight.bold,
      color: const Color(0xFFD4AF37),
      letterSpacing: 1.0,
    );

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F1713),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFD4AF37).withValues(alpha: 0.22),
          width: 1.0,
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 14, offset: Offset(0, 5)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Column(
          children: [
            // Table Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              color: const Color(0xFF0B1410),
              child: Row(
                children: [
                  SizedBox(width: 80, child: Text("TICKET ID", style: headerStyle)),
                  Expanded(flex: 3, child: Text("SUBJECT", style: headerStyle)),
                  Expanded(flex: 2, child: Text("STATUS", style: headerStyle)),
                  Expanded(flex: 2, child: Text("CREATED ON", style: headerStyle)),
                  Expanded(flex: 2, child: Text("LAST UPDATED", style: headerStyle)),
                  SizedBox(
                    width: 60,
                    child: Text("ACTIONS", style: headerStyle, textAlign: TextAlign.center),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0x1AD4AF37)),

            // Rows
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tickets.length,
              separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0x14D4AF37)),
              itemBuilder: (context, index) {
                final ticket = tickets[index];
                final ticketCode = ticket.id.startsWith('T-')
                    ? ticket.id
                    : 'T-${ticket.id.length > 5 ? ticket.id.substring(ticket.id.length - 4).toUpperCase() : (ticket.id.isEmpty ? "${index + 101}" : ticket.id)}';

                return InkWell(
                  onTap: () => _showTicketThreadDialog(ticket),
                  hoverColor: const Color(0x0DD4AF37),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 80,
                          child: Text(
                            ticketCode,
                            style: GoogleFonts.italiana(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            ticket.subject,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: _buildStatusBadge(ticket.status),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            DateFormat('dd MMM yyyy').format(ticket.createdAt),
                            style: AppTheme.sansBody(fontSize: 11.5, color: Colors.white70),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            _formatRelativeTime(ticket.createdAt),
                            style: AppTheme.sansBody(fontSize: 11.5, color: Colors.white38),
                          ),
                        ),
                        SizedBox(
                          width: 60,
                          child: Center(
                            child: IconButton(
                              icon: const Icon(
                                Icons.more_horiz,
                                color: Color(0xFFD4AF37),
                                size: 20,
                              ),
                              onPressed: () => _showTicketThreadDialog(ticket),
                              tooltip: "View conversation",
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileTicketCard(SupportTicket ticket) {
    final ticketCode = ticket.id.startsWith('T-')
        ? ticket.id
        : 'T-${ticket.id.length > 5 ? ticket.id.substring(ticket.id.length - 4).toUpperCase() : ticket.id}';

    return InkWell(
      onTap: () => _showTicketThreadDialog(ticket),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF0F1713),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFD4AF37).withValues(alpha: 0.22),
            width: 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  ticketCode,
                  style: GoogleFonts.italiana(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFE8CC8A),
                    letterSpacing: 0.5,
                  ),
                ),
                _buildStatusBadge(ticket.status),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              ticket.subject,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('dd MMM yyyy').format(ticket.createdAt),
                  style: AppTheme.sansBody(fontSize: 10.5, color: Colors.white54),
                ),
                Text(
                  _formatRelativeTime(ticket.createdAt),
                  style: AppTheme.sansBody(fontSize: 10.5, color: Colors.white38),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final s = status.toLowerCase();
    Color bg;
    Color textColor;
    Color border;
    String displayStatus = status.toUpperCase();

    if (s == 'open' || s == 'active review' || s == 'in progress') {
      displayStatus = 'ACTIVE REVIEW';
      bg = const Color(0x26D4AF37);
      textColor = const Color(0xFFE8CC8A);
      border = const Color(0x66D4AF37);
    } else if (s == 'resolved') {
      displayStatus = 'RESOLVED';
      bg = const Color(0x2625D366);
      textColor = const Color(0xFF4ADE80);
      border = const Color(0x6625D366);
    } else if (s == 'closed') {
      displayStatus = 'CLOSED';
      bg = Colors.white10;
      textColor = Colors.white54;
      border = Colors.white24;
    } else {
      displayStatus = 'PENDING';
      bg = const Color(0x2638BDF8);
      textColor = const Color(0xFF7DD3FC);
      border = const Color(0x6638BDF8);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border, width: 0.9),
      ),
      child: Text(
        displayStatus,
        style: TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.6,
          color: textColor,
        ),
      ),
    );
  }

  // ─── Dialogs: Raise Ticket & Conversation Thread ───────────────────────────
  void _showRaiseTicketDialog() {
    final subCtrl = TextEditingController();
    final msgCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 480,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF0F1713),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
              width: 1.2,
            ),
            boxShadow: const [
              BoxShadow(color: Colors.black87, blurRadius: 24, offset: Offset(0, 8)),
            ],
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "RAISE SUPPORT TICKET",
                      style: GoogleFonts.italiana(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFE8CC8A),
                        letterSpacing: 1.0,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white54, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  "Describe your event or logistic inquiry. Our concierge team responds promptly.",
                  style: AppTheme.sansBody(fontSize: 11.5, color: Colors.white60),
                ),
                const SizedBox(height: 18),

                // Subject
                Text(
                  "Subject",
                  style: AppTheme.sansBody(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFE8CC8A),
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: subCtrl,
                  style: AppTheme.sansBody(fontSize: 12.5, color: Colors.white),
                  cursorColor: const Color(0xFFD4AF37),
                  validator: (v) => (v == null || v.trim().isEmpty) ? "Please enter a subject" : null,
                  decoration: InputDecoration(
                    hintText: "e.g. Flower setup delay, invoice question...",
                    hintStyle: AppTheme.sansBody(fontSize: 11, color: Colors.white30),
                    filled: true,
                    fillColor: const Color(0xFF14201A),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: const Color(0xFFD4AF37).withValues(alpha: 0.3)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: const Color(0xFFD4AF37).withValues(alpha: 0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFD4AF37)),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Message
                Text(
                  "Detailed Message",
                  style: AppTheme.sansBody(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFE8CC8A),
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: msgCtrl,
                  maxLines: 4,
                  style: AppTheme.sansBody(fontSize: 12.5, color: Colors.white),
                  cursorColor: const Color(0xFFD4AF37),
                  validator: (v) => (v == null || v.trim().isEmpty) ? "Please write your message" : null,
                  decoration: InputDecoration(
                    hintText: "Describe the matter in detail so we can route it to the right team...",
                    hintStyle: AppTheme.sansBody(fontSize: 11, color: Colors.white30),
                    filled: true,
                    fillColor: const Color(0xFF14201A),
                    contentPadding: const EdgeInsets.all(14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: const Color(0xFFD4AF37).withValues(alpha: 0.3)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: const Color(0xFFD4AF37).withValues(alpha: 0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFD4AF37)),
                    ),
                  ),
                ),
                const SizedBox(height: 22),

                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text(
                        "CANCEL",
                        style: AppTheme.sansBody(fontSize: 11, color: Colors.white60),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE8CC8A),
                        foregroundColor: const Color(0xFF091210),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      ),
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) return;
                        Get.back();
                        await widget.controller.raiseSupportTicket(
                          subject: subCtrl.text.trim(),
                          message: msgCtrl.text.trim(),
                        );
                      },
                      child: Text(
                        "SUBMIT TICKET",
                        style: AppTheme.sansBody(fontSize: 11.5, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showTicketThreadDialog(SupportTicket ticket) {
    final replyCtrl = TextEditingController();

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 520,
          constraints: const BoxConstraints(maxHeight: 600),
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xFF0F1713),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
              width: 1.2,
            ),
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
                  Expanded(
                    child: Text(
                      ticket.subject,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.italiana(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildStatusBadge(ticket.status),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white54, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                "Created on ${DateFormat('dd MMM yyyy, hh:mm a').format(ticket.createdAt)}",
                style: AppTheme.sansBody(fontSize: 10.5, color: Colors.white38),
              ),
              const SizedBox(height: 14),
              const Divider(height: 1, color: Color(0x1AD4AF37)),
              const SizedBox(height: 14),

              // Messages list
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: ticket.messages.length,
                  itemBuilder: (context, i) {
                    final msg = ticket.messages[i];
                    final isCustomer = msg.startsWith("Customer:");
                    final content = msg.replaceFirst(RegExp(r'^(Customer|Support):\s*'), '');

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isCustomer
                            ? const Color(0xFF14201A)
                            : const Color(0xFF19251E),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isCustomer
                              ? const Color(0x26D4AF37)
                              : const Color(0x40D4AF37),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                isCustomer ? "You" : "Concierge Desk",
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  color: isCustomer ? const Color(0xFFE8CC8A) : const Color(0xFF7DD3FC),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            content,
                            style: AppTheme.sansBody(fontSize: 12, color: Colors.white),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),
              const Divider(height: 1, color: Color(0x1AD4AF37)),
              const SizedBox(height: 12),

              // Reply field if ticket is open
              if (ticket.status.toLowerCase() != 'closed') ...[
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: replyCtrl,
                        style: AppTheme.sansBody(fontSize: 12, color: Colors.white),
                        cursorColor: const Color(0xFFD4AF37),
                        decoration: InputDecoration(
                          hintText: "Type your reply to concierge...",
                          hintStyle: AppTheme.sansBody(fontSize: 11, color: Colors.white30),
                          filled: true,
                          fillColor: const Color(0xFF14201A),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: const Color(0xFFD4AF37).withValues(alpha: 0.3)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: const Color(0xFFD4AF37).withValues(alpha: 0.3)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFFD4AF37)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE8CC8A),
                        foregroundColor: const Color(0xFF091210),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      onPressed: () async {
                        if (replyCtrl.text.trim().isEmpty) return;
                        final text = replyCtrl.text.trim();
                        Get.back();
                        await widget.controller.replySupportTicket(
                          ticketId: ticket.id,
                          message: text,
                        );
                      },
                      child: const Icon(Icons.send_rounded, size: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () async {
                      Get.back();
                      await widget.controller.closeSupportTicket(ticketId: ticket.id);
                    },
                    child: Text(
                      "CLOSE TICKET",
                      style: AppTheme.sansBody(fontSize: 10, color: Colors.white38),
                    ),
                  ),
                ),
              ] else
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Text(
                      "This concierge ticket has been closed.",
                      style: AppTheme.sansBody(fontSize: 11, color: Colors.white38),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
