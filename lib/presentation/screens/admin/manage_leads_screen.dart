import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/config/app_theme.dart';
import '../../../core/utils/booking_communication_helper.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/entities/lead.dart';
import '../../controllers/admin_controller.dart';
import '../customer/helpers/customer_dialog_helper.dart';
import 'widgets/admin_back_button.dart';
import 'widgets/admin_layout.dart';

class ManageLeadsScreen extends StatefulWidget {
  const ManageLeadsScreen({super.key});

  @override
  State<ManageLeadsScreen> createState() => _ManageLeadsScreenState();
}

class _ManageLeadsScreenState extends State<ManageLeadsScreen> {
  final AdminController controller = Get.find<AdminController>();
  final TextEditingController _searchCtrl = TextEditingController();

  // Status Filter: 'all' | 'new' | 'contacted' | 'closed'
  String _selectedStatusFilter = 'all';

  // View Mode: true for Grid, false for List
  bool _isGridView = true;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  int _getCrossAxisCount(double width) {
    if (width >= 900) return 3; // Desktop matches reference
    if (width >= 620) return 2;  // Tablet
    return 1;                   // Mobile
  }

  String _getEventCoverUrl(String requestType, int index) {
    final List<String> covers = [
      'https://images.unsplash.com/photo-1519741497674-611481863552?q=80&w=600', // Luxury wedding stage
      'https://images.unsplash.com/photo-1513151233558-d860c5398176?q=80&w=600', // Birthday party celebration
      'https://images.unsplash.com/photo-1541976844346-f18aeac57b06?q=80&w=600', // Pathway
      'https://images.unsplash.com/photo-1527529482837-4698179dc6ce?q=80&w=600', // Party Decor
      'https://images.unsplash.com/photo-1464366400600-7168b8af9bc3?q=80&w=600', // Luxury Ballroom
      'https://images.unsplash.com/photo-1511285560929-80b456fea0bc?q=80&w=600', // Ring stage
      'https://images.unsplash.com/photo-1519671482749-fd09be7ccebf?q=80&w=600', // Inside Canopy
      'https://images.unsplash.com/photo-1530103862676-de8c9debad1d?q=80&w=600', // Gold Balloon Arch
      'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?q=80&w=600', // Evening Lights
      'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?q=80&w=600', // Candle pathway
    ];
    return covers[index % covers.length];
  }

  String _cleanText(String text) {
    String cleaned = text.replaceAll('bWedding/b', 'Wedding')
                         .replaceAll('bBirthday/b', 'Birthday')
                         .replaceAll('bBaby Shower/b', 'Baby Shower')
                         .replaceAll('bCandle Light/b', 'Candle Light')
                         .replaceAll('bCorporate/b', 'Corporate Event')
                         .replaceAll('bEngagement/b', 'Engagement');
    cleaned = cleaned.replaceAll(RegExp(r'<[^>]*>'), '');
    final match = RegExp(r'^b(.+)/b$').firstMatch(cleaned);
    if (match != null) {
      cleaned = match.group(1) ?? cleaned;
    }
    if (cleaned.startsWith('b') && cleaned.endsWith('/b')) {
      cleaned = cleaned.substring(1, cleaned.length - 2);
    }
    return cleaned.trim().isEmpty ? 'Event Decor' : cleaned.trim();
  }

  List<Lead> _getFilteredLeads(List<Lead> allLeads) {
    final query = _searchCtrl.text.trim().toLowerCase();

    return allLeads.where((lead) {
      // 1. Status Filter
      final status = lead.status.toLowerCase();
      if (_selectedStatusFilter == 'new' && status != 'new') {
        return false;
      }
      if (_selectedStatusFilter == 'contacted' && status != 'contacted') {
        return false;
      }
      if (_selectedStatusFilter == 'closed' && status != 'closed' && status != 'won') {
        return false;
      }

      // 2. Search Query
      if (query.isNotEmpty) {
        final nameMatch = lead.name.toLowerCase().contains(query);
        final phoneMatch = lead.phone.toLowerCase().contains(query);
        final emailMatch = lead.email.toLowerCase().contains(query);
        final typeMatch = lead.requestType.toLowerCase().contains(query);
        final reqMatch = lead.requirements.toLowerCase().contains(query);
        if (!nameMatch && !phoneMatch && !emailMatch && !typeMatch && !reqMatch) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  void _openAddInquiryDialog(BuildContext context) {
    CustomerDialogHelper.openLeadDialog(context);
  }

  void _showInquiryDetailsDialog(BuildContext context, Lead lead, String coverUrl) {
    final cleanType = _cleanText(lead.requestType);
    const goldColor = Color(0xFFECC24A);

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.78),
      builder: (ctx) {
        return Dialog(
          backgroundColor: const Color(0xFF0C1914),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: BorderSide(color: goldColor.withValues(alpha: 0.28), width: 1),
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row with Category & Close Button
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          cleanType.toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFF091410),
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (lead.budget != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white24, width: 0.5),
                          ),
                          child: Text(
                            AppFormatters.formatCurrency(lead.budget!),
                            style: const TextStyle(
                              color: goldColor,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 20),
                        onPressed: () => Navigator.of(ctx).pop(),
                        splashRadius: 18,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Customer Name
                  Text(
                    lead.name,
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Contact Info Box
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF081410),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.phone_rounded, color: goldColor, size: 14),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                lead.phone,
                                style: const TextStyle(color: Colors.white, fontSize: 13),
                              ),
                            ),
                            InkWell(
                              onTap: () => BookingCommunicationHelper.openCall(lead.phone),
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.call_outlined, color: Colors.white70, size: 13),
                                    SizedBox(width: 4),
                                    Text("Call", style: TextStyle(color: Colors.white70, fontSize: 11)),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            InkWell(
                              onTap: () => BookingCommunicationHelper.openWhatsApp(
                                message: "Hello ${lead.name}, regarding your $cleanType inquiry with OM Events:",
                              ),
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4EBA7A).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF4EBA7A), size: 13),
                                    SizedBox(width: 4),
                                    Text("WhatsApp", style: TextStyle(color: Color(0xFF4EBA7A), fontSize: 11, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (lead.email.isNotEmpty) ...[
                          const Divider(color: Colors.white10, height: 16),
                          Row(
                            children: [
                              const Icon(Icons.mail_outline_rounded, color: goldColor, size: 14),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  lead.email,
                                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Event Details Row
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF081410),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("EVENT TYPE", style: TextStyle(color: Colors.white38, fontSize: 9.5, letterSpacing: 1.1, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(cleanType, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF081410),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("TARGET DATE", style: TextStyle(color: Colors.white38, fontSize: 9.5, letterSpacing: 1.1, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(
                                lead.eventDate != null ? AppFormatters.formatShortDate(lead.eventDate!) : "TBD",
                                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Requirements / Notes (if any)
                  if (lead.requirements.trim().isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF081410),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("REQUIREMENTS & NOTES", style: TextStyle(color: Colors.white38, fontSize: 9.5, letterSpacing: 1.1, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Text(
                            lead.requirements,
                            style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.45),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 18),

                  // Status Progression Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("UPDATE STATUS:", style: TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                        decoration: BoxDecoration(
                          color: const Color(0xFF142B20),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF2E6B4A)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: lead.status,
                            dropdownColor: const Color(0xFF0C1914),
                            icon: const Icon(Icons.arrow_drop_down_rounded, color: Colors.white, size: 22),
                            items: const [
                              DropdownMenuItem(value: 'new', child: Text("New", style: TextStyle(color: Color(0xFF6EDC98), fontSize: 12, fontWeight: FontWeight.bold))),
                              DropdownMenuItem(value: 'contacted', child: Text("Contacted", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
                              DropdownMenuItem(value: 'qualified', child: Text("Qualified", style: TextStyle(color: goldColor, fontSize: 12, fontWeight: FontWeight.bold))),
                              DropdownMenuItem(value: 'won', child: Text("Won", style: TextStyle(color: Color(0xFF4EBA7A), fontSize: 12, fontWeight: FontWeight.bold))),
                              DropdownMenuItem(value: 'closed', child: Text("Closed", style: TextStyle(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.bold))),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                controller.updateLead(lead.id, val);
                                Navigator.of(ctx).pop();
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isInsideDrawer = AdminLayoutScope.of(context);
    const goldColor = Color(0xFFECC24A);

    return Scaffold(
      appBar: AppBar(
        leading: isInsideDrawer ? null : const AdminBackButton(),
        automaticallyImplyLeading: !isInsideDrawer,
        title: Text(
          "INQUIRY SHOWCASE",
          style: AppTheme.sansBody(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: Colors.white70,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: isInsideDrawer ? 0 : kToolbarHeight,
      ),
      backgroundColor: Colors.transparent,
      body: Obx(() {
        final allLeads = controller.rxLeads;
        final filteredLeads = _getFilteredLeads(allLeads);

        // Calculate dynamic counts
        final int allCount = allLeads.length;
        final int newCount = allLeads.where((l) => l.status.toLowerCase() == 'new').length;
        final int contactedCount = allLeads.where((l) => l.status.toLowerCase() == 'contacted').length;
        final int closedCount = allLeads.where((l) => l.status.toLowerCase() == 'closed' || l.status.toLowerCase() == 'won').length;

        return LayoutBuilder(
          builder: (context, constraints) {
            final double maxWidth = constraints.maxWidth;
            final bool isMobile = maxWidth < 650;
            final int crossAxisCount = _getCrossAxisCount(maxWidth);

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : 24,
                vertical: isMobile ? 14 : 20,
              ),
              child: Align(
                alignment: Alignment.topLeft,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1080),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ==========================================
                      // 1. PAGE HEADER (MATCHES REFERENCE EXACTLY)
                      // ==========================================
                      _buildHeader(context, goldColor, isMobile),
                      const SizedBox(height: 14),

                      // ==========================================
                      // 2. FILTER TOOLBAR (PILLS + SEARCH + VIEW TOGGLE)
                      // ==========================================
                      _buildToolbar(
                        goldColor: goldColor,
                        isMobile: isMobile,
                        allCount: allCount,
                        newCount: newCount,
                        contactedCount: contactedCount,
                        closedCount: closedCount,
                      ),
                      const SizedBox(height: 16),

                      // ==========================================
                      // 3. LEADS SHOWCASE CONTENT (GRID / LIST / EMPTY)
                      // ==========================================
                      if (filteredLeads.isEmpty) ...[
                        _buildEmptyState(goldColor),
                      ] else if (_isGridView) ...[
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: isMobile ? 10 : 14,
                            mainAxisSpacing: isMobile ? 10 : 14,
                            mainAxisExtent: isMobile ? 112 : 315,
                          ),
                          itemCount: filteredLeads.length,
                          itemBuilder: (context, index) {
                            final lead = filteredLeads[index];
                            final coverUrl = _getEventCoverUrl(lead.requestType, index);
                            return isMobile
                                ? _buildMobileHorizontalCard(lead, coverUrl, goldColor, index)
                                : _buildDesktopCard(lead, coverUrl, goldColor, index);
                          },
                        ),
                      ] else ...[
                        // Compact List View
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredLeads.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final lead = filteredLeads[index];
                            final coverUrl = _getEventCoverUrl(lead.requestType, index);
                            return _buildListItemCard(lead, coverUrl, goldColor, index);
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  // ==========================================
  // HEADER WIDGET
  // ==========================================
  Widget _buildHeader(BuildContext context, Color goldColor, bool isMobile) {
    final titleWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Inquiry Showcase",
          style: GoogleFonts.montserrat(
            fontSize: isMobile ? 20 : 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          "Real inquiries, real opportunities. Convert moments into celebrations.",
          style: TextStyle(
            fontSize: isMobile ? 11.0 : 12.0,
            color: Colors.white60,
          ),
        ),
      ],
    );

    final addButton = Container(
      height: 36,
      decoration: BoxDecoration(
        color: goldColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: goldColor.withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _openAddInquiryDialog(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.add_rounded, size: 15, color: Color(0xFF091410)),
                const SizedBox(width: 4),
                Text(
                  "Add Inquiry",
                  style: GoogleFonts.montserrat(
                    fontSize: 12.0,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF091410),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleWidget,
          const SizedBox(height: 10),
          addButton,
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        titleWidget,
        addButton,
      ],
    );
  }

  // ==========================================
  // FILTER TOOLBAR WIDGET
  // ==========================================
  Widget _buildToolbar({
    required Color goldColor,
    required bool isMobile,
    required int allCount,
    required int newCount,
    required int contactedCount,
    required int closedCount,
  }) {
    final filterChips = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildFilterChip("All ($allCount)", 'all', goldColor),
        const SizedBox(width: 8),
        _buildFilterChip("New ($newCount)", 'new', goldColor),
        const SizedBox(width: 8),
        _buildFilterChip("Contacted ($contactedCount)", 'contacted', goldColor),
        const SizedBox(width: 8),
        _buildFilterChip("Closed ($closedCount)", 'closed', goldColor),
      ],
    );

    final searchAndViews = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Search Input Field
        Container(
          width: isMobile ? null : 190,
          height: 34,
          decoration: BoxDecoration(
            color: const Color(0xFF0A1612),
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: Colors.white12, width: 0.9),
          ),
          child: TextField(
            controller: _searchCtrl,
            onChanged: (_) => setState(() {}),
            style: const TextStyle(color: Colors.white, fontSize: 11.5),
            cursorColor: goldColor,
            decoration: InputDecoration(
              hintText: "Search inquiries...",
              hintStyle: const TextStyle(color: Colors.white38, fontSize: 11.0),
              prefixIcon: Icon(Icons.search_rounded, color: goldColor.withValues(alpha: 0.75), size: 15),
              prefixIconConstraints: const BoxConstraints(minWidth: 32, minHeight: 34),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
              isDense: true,
              suffixIcon: _searchCtrl.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 13, color: Colors.white54),
                      splashRadius: 13,
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() {});
                      },
                    )
                  : null,
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Grid View Toggle
        _buildViewToggleButton(
          icon: Icons.grid_view_rounded,
          isSelected: _isGridView,
          goldColor: goldColor,
          onTap: () => setState(() => _isGridView = true),
        ),
        const SizedBox(width: 5),

        // List View Toggle
        _buildViewToggleButton(
          icon: Icons.view_list_rounded,
          isSelected: !_isGridView,
          goldColor: goldColor,
          onTap: () => setState(() => _isGridView = false),
        ),
      ],
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: filterChips,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A1612),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white12, width: 0.9),
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (_) => setState(() {}),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    cursorColor: goldColor,
                    decoration: InputDecoration(
                      hintText: "Search inquiries...",
                      hintStyle: const TextStyle(color: Colors.white38, fontSize: 11.5),
                      prefixIcon: Icon(Icons.search_rounded, color: goldColor.withValues(alpha: 0.75), size: 16),
                      prefixIconConstraints: const BoxConstraints(minWidth: 34, minHeight: 36),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      isDense: true,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _buildViewToggleButton(
                icon: Icons.grid_view_rounded,
                isSelected: _isGridView,
                goldColor: goldColor,
                onTap: () => setState(() => _isGridView = true),
              ),
              const SizedBox(width: 6),
              _buildViewToggleButton(
                icon: Icons.view_list_rounded,
                isSelected: !_isGridView,
                goldColor: goldColor,
                onTap: () => setState(() => _isGridView = false),
              ),
            ],
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        filterChips,
        searchAndViews,
      ],
    );
  }

  Widget _buildFilterChip(String label, String value, Color goldColor) {
    final bool isSelected = _selectedStatusFilter == value;

    return InkWell(
      onTap: () => setState(() => _selectedStatusFilter = value),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? goldColor : const Color(0xFF0D1B16),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? goldColor : Colors.white.withValues(alpha: 0.12),
            width: 0.9,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? const Color(0xFF091410) : Colors.white70,
          ),
        ),
      ),
    );
  }

  Widget _buildViewToggleButton({
    required IconData icon,
    required bool isSelected,
    required Color goldColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF142B20) : const Color(0xFF0A1612),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? goldColor : Colors.white12,
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          size: 16,
          color: isSelected ? goldColor : Colors.white54,
        ),
      ),
    );
  }

  // ==========================================
  // DESKTOP CARD WIDGET (MATCHES REFERENCE EXACTLY)
  // ==========================================
  Widget _buildDesktopCard(Lead lead, String coverUrl, Color goldColor, int index) {
    final cleanType = _cleanText(lead.requestType);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0C1914),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: goldColor.withValues(alpha: 0.18), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.40),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Medium Image Thumbnail with AspectRatio ~ 1.92 : 1
          AspectRatio(
            aspectRatio: 1.92,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.network(
                    coverUrl,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    filterQuality: FilterQuality.medium,
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFF081410),
                      child: Center(
                        child: Icon(Icons.celebration_rounded, color: goldColor.withValues(alpha: 0.3), size: 28),
                      ),
                    ),
                  ),
                ),

                // Ambient Shadow Gradient for Badges
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withValues(alpha: 0.55),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.35),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),

                // Top-Left: Category Badge (White Pill, Bold Dark Caps)
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      cleanType.toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFF091410),
                        fontSize: 9.0,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ),

                // Top-Right: Budget Badge (Dark Pill, Gold Text)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.82),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white24, width: 0.5),
                    ),
                    child: Text(
                      lead.budget != null ? AppFormatters.formatCurrency(lead.budget!) : "₹0",
                      style: const TextStyle(
                        color: Color(0xFFECC24A),
                        fontSize: 10.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. Card Information Body
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 9, 14, 9),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Customer Name
                      Text(
                        lead.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.montserrat(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 5),

                      // Phone Row
                      Row(
                        children: [
                          const Icon(Icons.phone_rounded, color: Color(0xFFE5C378), size: 11),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              lead.phone,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white70, fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),

                      // Email Row
                      Row(
                        children: [
                          const Icon(Icons.mail_outline_rounded, color: Color(0xFFE5C378), size: 11),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              lead.email.isNotEmpty ? lead.email : "No email registered",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white60, fontSize: 10.5),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),

                      // Event Type Row
                      Row(
                        children: [
                          const Icon(Icons.diamond_outlined, color: Color(0xFFE5C378), size: 11),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              cleanType,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Bottom Row: Event Date + Status Dropdown + Circular Golden Arrow Button
                  Row(
                    children: [
                      // Calendar Date
                      Icon(Icons.calendar_today_rounded, color: goldColor.withValues(alpha: 0.9), size: 11),
                      const SizedBox(width: 4),
                      Text(
                        lead.eventDate != null ? AppFormatters.formatShortDate(lead.eventDate!) : "TBD",
                        style: const TextStyle(color: Colors.white70, fontSize: 10.5, fontWeight: FontWeight.w500),
                      ),
                      const Spacer(),

                      // Compact Status Dropdown Pill
                      _buildStatusPill(lead, goldColor),
                      const SizedBox(width: 6),

                      // Circular Golden Arrow Action Button
                      InkWell(
                        onTap: () => _showInquiryDetailsDialog(context, lead, coverUrl),
                        borderRadius: BorderRadius.circular(13),
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFFF5C84C), Color(0xFFD4AF37)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: goldColor.withValues(alpha: 0.35),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.arrow_forward_rounded,
                            size: 13,
                            color: Color(0xFF0A1512),
                          ),
                        ),
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

  // ==========================================
  // MOBILE HORIZONTAL CARD WIDGET (MATCHES REFERENCE MOBILE PREVIEW)
  // ==========================================
  Widget _buildMobileHorizontalCard(Lead lead, String coverUrl, Color goldColor, int index) {
    final cleanType = _cleanText(lead.requestType);

    return InkWell(
      onTap: () => _showInquiryDetailsDialog(context, lead, coverUrl),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 112,
        decoration: BoxDecoration(
          color: const Color(0xFF0C1914),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: goldColor.withValues(alpha: 0.18), width: 1.0),
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            // Left: Square Thumbnail with Budget Badge overlaid
            AspectRatio(
              aspectRatio: 1.0,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.network(
                      coverUrl,
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                      filterQuality: FilterQuality.medium,
                      errorBuilder: (_, __, ___) => Container(color: const Color(0xFF081410)),
                    ),
                  ),
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: goldColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        lead.budget != null ? AppFormatters.formatCurrency(lead.budget!) : "₹0",
                        style: const TextStyle(
                          color: Color(0xFF091410),
                          fontSize: 9.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Right: Content Section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lead.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.montserrat(
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          cleanType,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white60, fontSize: 11.0),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.calendar_today_rounded, color: goldColor.withValues(alpha: 0.85), size: 10),
                            const SizedBox(width: 4),
                            Text(
                              lead.eventDate != null ? AppFormatters.formatShortDate(lead.eventDate!) : "TBD",
                              style: const TextStyle(color: Colors.white70, fontSize: 10.5),
                            ),
                          ],
                        ),
                        _buildStatusPill(lead, goldColor),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // COMPACT LIST ITEM CARD (FOR LIST VIEW MODE)
  // ==========================================
  Widget _buildListItemCard(Lead lead, String coverUrl, Color goldColor, int index) {
    final cleanType = _cleanText(lead.requestType);

    return InkWell(
      onTap: () => _showInquiryDetailsDialog(context, lead, coverUrl),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF0C1914),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: goldColor.withValues(alpha: 0.16), width: 0.8),
        ),
        child: Row(
          children: [
            // Circular Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                coverUrl,
                width: 42,
                height: 42,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(width: 42, height: 42, color: const Color(0xFF081410)),
              ),
            ),
            const SizedBox(width: 12),

            // Name & Phone
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lead.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.montserrat(fontSize: 13.5, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    lead.phone,
                    style: const TextStyle(fontSize: 11, color: Colors.white60),
                  ),
                ],
              ),
            ),

            // Event Type
            Expanded(
              flex: 2,
              child: Text(
                cleanType,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ),

            // Date
            Expanded(
              flex: 2,
              child: Text(
                lead.eventDate != null ? AppFormatters.formatShortDate(lead.eventDate!) : "TBD",
                style: const TextStyle(fontSize: 11.5, color: Colors.white70),
              ),
            ),

            // Budget
            Text(
              lead.budget != null ? AppFormatters.formatCurrency(lead.budget!) : "₹0",
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFF5C84C)),
            ),
            const SizedBox(width: 14),

            // Status Dropdown
            _buildStatusPill(lead, goldColor),
            const SizedBox(width: 10),

            // Circular Arrow Button
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFF5C84C), Color(0xFFD4AF37)],
                ),
              ),
              child: const Icon(Icons.arrow_forward_rounded, size: 13, color: Color(0xFF0A1512)),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // COMPACT STATUS DROPDOWN PILL
  // ==========================================
  Widget _buildStatusPill(Lead lead, Color goldColor) {
    final s = lead.status.toLowerCase();
    Color bg;
    Color border;
    Color textCol;

    switch (s) {
      case 'new':
        bg = const Color(0xFF142B20);
        border = const Color(0xFF2E6B4A);
        textCol = const Color(0xFF6EDC98);
        break;
      case 'contacted':
        bg = const Color(0xFF192520);
        border = Colors.white24;
        textCol = Colors.white;
        break;
      case 'qualified':
        bg = const Color(0xFF232014);
        border = goldColor.withValues(alpha: 0.4);
        textCol = goldColor;
        break;
      case 'won':
        bg = const Color(0xFF142B20);
        border = const Color(0xFF4EBA7A);
        textCol = const Color(0xFF4EBA7A);
        break;
      case 'closed':
      default:
        bg = const Color(0xFF161616);
        border = Colors.white12;
        textCol = Colors.white54;
        break;
    }

    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 7),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border, width: 0.8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: lead.status,
          dropdownColor: const Color(0xFF0C1914),
          icon: Icon(Icons.arrow_drop_down_rounded, color: textCol, size: 16),
          style: TextStyle(
            fontSize: 10.0,
            fontWeight: FontWeight.bold,
            color: textCol,
          ),
          items: const [
            DropdownMenuItem(value: 'new', child: Text("New")),
            DropdownMenuItem(value: 'contacted', child: Text("Contacted")),
            DropdownMenuItem(value: 'qualified', child: Text("Qualified")),
            DropdownMenuItem(value: 'won', child: Text("Won")),
            DropdownMenuItem(value: 'closed', child: Text("Closed")),
          ],
          onChanged: (val) {
            if (val != null) {
              controller.updateLead(lead.id, val);
            }
          },
        ),
      ),
    );
  }

  // ==========================================
  // EMPTY STATE WIDGET
  // ==========================================
  Widget _buildEmptyState(Color goldColor) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
          constraints: const BoxConstraints(maxWidth: 420),
          decoration: BoxDecoration(
            color: const Color(0xFF0C1914),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: goldColor.withValues(alpha: 0.20), width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: goldColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(color: goldColor.withValues(alpha: 0.35)),
                ),
                child: Icon(Icons.search_off_rounded, color: goldColor, size: 26),
              ),
              const SizedBox(height: 16),
              Text(
                "No Inquiries Found",
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "No inquiries match your current status filter or search keyword.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.white60, height: 1.4),
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: () {
                  _searchCtrl.clear();
                  setState(() => _selectedStatusFilter = 'all');
                },
                icon: const Icon(Icons.refresh_rounded, size: 14, color: Color(0xFFECC24A)),
                label: const Text("Reset Filters", style: TextStyle(color: Color(0xFFECC24A), fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: goldColor.withValues(alpha: 0.4)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
