import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/admin_controller.dart';
import '../../controllers/auth_controller.dart';
import 'widgets/category_list_tile.dart';
import 'widgets/luxury_gold_waves_painter.dart';
import 'parts/manage_categories_dialogs.dart';

/// Manage Categories screen redesigned to Option 4 Premium Detailed Style:
/// - Atmospheric luxury background with champagne gold wave lines and radial glows
/// - Desktop top bar with pill search field and admin profile indicator
/// - Compact page header with title, subtitle, and "+ Add Category" gold action button
/// - Filter status chips (Active, Hidden, Total) with real-time active/grid/list toggle
/// - Responsive 3-column desktop grid with compact cards (~270px height)
/// - Responsive 1-column mobile layout with fluid spacing and no overflow
class ManageCategoriesScreen extends StatefulWidget {
  const ManageCategoriesScreen({super.key});

  AdminController get controller => Get.find<AdminController>();

  @override
  State<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _selectedFilter = 'all'; // 'all', 'active', 'hidden'
  String _searchQuery = '';
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      setState(() {
        _searchQuery = _searchCtrl.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  int _getCrossAxisCount(double width) {
    if (width >= 1150) return 3; // 3 columns on standard/wide desktop
    if (width >= 720) return 2;  // 2 columns on tablet
    return 1;                    // 1 column on mobile
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    const goldColor = Color(0xFFD4AF37);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // ── Option 4 Background Luxury Gold Wave Ribbons ──────────────
          const Positioned.fill(
            child: RepaintBoundary(
              child: CustomPaint(
                painter: LuxuryGoldWavesPainter(),
              ),
            ),
          ),

          // ── Main Screen Content ───────────────────────────────────────
          Positioned.fill(
            child: Obx(() {
              final allCategories = widget.controller.rxCategories;
              if (widget.controller.isLoadingCategories.value && allCategories.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(goldColor),
                  ),
                );
              }

              final activeCount = widget.controller.activeCategoriesCount.value;
              final totalCount = allCategories.length;
              final hiddenCount = totalCount - activeCount;

              // Filter categories by status & query
              final filteredList = allCategories.where((c) {
                if (_selectedFilter == 'active' && !c.isActive) return false;
                if (_selectedFilter == 'hidden' && c.isActive) return false;
                if (_searchQuery.isNotEmpty) {
                  final matchName = c.name.toLowerCase().contains(_searchQuery);
                  final matchSlug = c.slug.toLowerCase().contains(_searchQuery);
                  final matchDesc = c.description.toLowerCase().contains(_searchQuery);
                  return matchName || matchSlug || matchDesc;
                }
                return true;
              }).toList();

              // Sort ascending by sortOrder matching Option 4 display
              filteredList.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

              return LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 768;
                  final horizontalPadding = isMobile ? 16.0 : 24.0;

                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: isMobile ? 12.0 : 14.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── 1. Top Bar / Search ───────────────────────────
                        if (!isMobile) ...[
                          _buildDesktopTopBar(context, authController, goldColor),
                          const SizedBox(height: 16),
                        ],

                        // ── 2. Page Header: Title & "+ Add Category" ──────
                        _buildPageHeader(context, isMobile, goldColor),
                        const SizedBox(height: 14),

                        // ── 3. Mobile Search Field (if mobile) ───────────
                        if (isMobile) ...[
                          _buildSearchField(goldColor, isFullWidth: true),
                          const SizedBox(height: 12),
                        ],

                        // ── 4. Filter Status Chips & View Toggles ─────────
                        _buildFilterRow(
                          isMobile: isMobile,
                          active: activeCount,
                          hidden: hiddenCount,
                          total: totalCount,
                          goldColor: goldColor,
                        ),
                        const SizedBox(height: 16),

                        // ── 5. Responsive Category Grid / List View ───────
                        Expanded(
                          child: filteredList.isEmpty
                              ? _buildEmptyState()
                              : _isGridView
                                  ? _buildGridView(filteredList, constraints.maxWidth, isMobile)
                                  : _buildListView(filteredList),
                        ),
                      ],
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

  // ── Desktop Top Bar with Search & Profile Pill ───────────────────────
  Widget _buildDesktopTopBar(
    BuildContext context,
    AuthController authController,
    Color goldColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          // Search Pill
          _buildSearchField(goldColor, isFullWidth: false),

          const Spacer(),

          // Right Controls: Notification Bell + Admin Profile Pill
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Notification Bell with Badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(
                    Icons.notifications_none_rounded,
                    size: 20,
                    color: Color(0xFFD4AF37),
                  ),
                  Positioned(
                    top: -1,
                    right: -1,
                    child: Container(
                      width: 6.5,
                      height: 6.5,
                      decoration: const BoxDecoration(
                        color: Color(0xFFD4AF37),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),

              // Admin Profile Pill
              Obx(() {
                final currentAdmin = authController.rxAdminRole.value;
                if (currentAdmin == null) return const SizedBox();
                final name = currentAdmin.name.isEmpty
                    ? currentAdmin.email.split('@').first
                    : currentAdmin.name;
                final initial = name.isNotEmpty ? name[0].toUpperCase() : 'A';

                return InkWell(
                  onTap: () => Get.toNamed('/admin/profile'),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF101915),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: const Color(0xFF1E3027),
                          child: Text(
                            initial,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFD4AF37),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              name,
                              style: GoogleFonts.dmSans(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              currentAdmin.roleType.replaceAll('_', ' ').toUpperCase(),
                              style: GoogleFonts.dmSans(
                                fontSize: 7.5,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFD4AF37),
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 14,
                          color: Colors.white38,
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  // ── Unified Search Field Pill matching Option 4 ─────────────────────
  Widget _buildSearchField(Color goldColor, {required bool isFullWidth}) {
    return Container(
      width: isFullWidth ? double.infinity : 340,
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF101915),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12), width: 1.0),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.search_rounded,
            size: 18,
            color: Colors.white38,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchCtrl,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: Colors.white,
                fontWeight: FontWeight.w400,
              ),
              cursorColor: goldColor,
              decoration: InputDecoration(
                hintText: "Search categories...",
                hintStyle: GoogleFonts.dmSans(
                  fontSize: 13,
                  color: Colors.white38,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            InkWell(
              onTap: () => _searchCtrl.clear(),
              borderRadius: BorderRadius.circular(12),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: Colors.white38,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Page Header: Title, Subtitle & + Add Category Button ───────────
  Widget _buildPageHeader(BuildContext context, bool isMobile, Color goldColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isMobile ? "Categories" : "Manage Categories",
                style: GoogleFonts.dmSans(
                  fontSize: isMobile ? 20 : 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                "Create, edit, and organize your event categories.",
                style: GoogleFonts.dmSans(
                  fontSize: 11.5,
                  color: const Color(0xFFA4A9A7),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),

        const SizedBox(width: 12),

        // + Add Category Button (Gold pill matching Option 4 reference)
        ElevatedButton.icon(
          onPressed: () => widget.showCategoryDialog(context),
          icon: const Icon(Icons.add_rounded, size: 16, color: Color(0xFF0C1410)),
          label: Text(
            isMobile ? "Add" : "Add Category",
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0C1410),
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: goldColor,
            foregroundColor: const Color(0xFF0C1410),
            elevation: 0,
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 12 : 16,
              vertical: 10,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ],
    );
  }

  // ── Filter Status Chips & View Toggles Row ─────────────────────────
  Widget _buildFilterRow({
    required bool isMobile,
    required int active,
    required int hidden,
    required int total,
    required Color goldColor,
  }) {
    final chips = [
      _chip(
        label: "$active Active",
        color: const Color(0xFF22C55E),
        bg: const Color(0xFF0C2417),
        isSelected: _selectedFilter == 'active',
        onTap: () {
          setState(() {
            _selectedFilter = _selectedFilter == 'active' ? 'all' : 'active';
          });
        },
      ),
      const SizedBox(width: 8),
      _chip(
        label: "$hidden Hidden",
        color: const Color(0xFFEF4444),
        bg: const Color(0xFF271214),
        isSelected: _selectedFilter == 'hidden',
        onTap: () {
          setState(() {
            _selectedFilter = _selectedFilter == 'hidden' ? 'all' : 'hidden';
          });
        },
      ),
      const SizedBox(width: 8),
      _chip(
        label: isMobile ? "$total Total" : "$total Total Categories",
        color: Colors.white70,
        bg: const Color(0xFF14201A),
        isSelected: _selectedFilter == 'all',
        onTap: () {
          setState(() {
            _selectedFilter = 'all';
          });
        },
      ),
    ];

    final viewToggles = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // List/Table View Mode
        InkWell(
          onTap: () => setState(() => _isGridView = false),
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: !_isGridView ? const Color(0xFF1B2A22) : const Color(0xFF14201A),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: !_isGridView ? goldColor.withValues(alpha: 0.6) : Colors.white12,
              ),
            ),
            child: Icon(
              Icons.format_list_bulleted_rounded,
              size: 15,
              color: !_isGridView ? goldColor : Colors.white54,
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Grid View Mode
        InkWell(
          onTap: () => setState(() => _isGridView = true),
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: _isGridView ? const Color(0xFF1B2A22) : const Color(0xFF14201A),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: _isGridView ? goldColor.withValues(alpha: 0.6) : Colors.white12,
              ),
            ),
            child: Icon(
              Icons.grid_view_rounded,
              size: 15,
              color: _isGridView ? goldColor : Colors.white54,
            ),
          ),
        ),
      ],
    );

    if (isMobile) {
      return Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(children: chips),
            ),
          ),
          const SizedBox(width: 8),
          viewToggles,
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(children: chips),
        viewToggles,
      ],
    );
  }

  Widget _chip({
    required String label,
    required Color color,
    required Color bg,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? bg : const Color(0xFF101915),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color.withValues(alpha: 0.6) : Colors.white10,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isSelected ? color : Colors.white60,
          ),
        ),
      ),
    );
  }

  // ── Grid View Matching Option 4 Reference ─────────────────────────
  Widget _buildGridView(List filteredList, double width, bool isMobile) {
    final crossAxisCount = _getCrossAxisCount(width);
    final cardExtent = isMobile ? 260.0 : 270.0;

    return GridView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      physics: const BouncingScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 18,
        mainAxisSpacing: 18,
        mainAxisExtent: cardExtent,
      ),
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        final cat = filteredList[index];
        return CategoryListTile(
          cat: cat,
          isDark: true,
          controller: widget.controller,
          onEdit: () => widget.showCategoryDialog(context, category: cat),
          onDelete: () => widget.confirmDelete(cat.slug),
        );
      },
    );
  }

  // ── List / Table View Mode ────────────────────────────────────────
  Widget _buildListView(List filteredList) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      physics: const BouncingScrollPhysics(),
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        final cat = filteredList[index];
        return CategoryRowTile(
          cat: cat,
          controller: widget.controller,
          onEdit: () => widget.showCategoryDialog(context, category: cat),
          onDelete: () => widget.confirmDelete(cat.slug),
        );
      },
    );
  }

  // ── Empty State ───────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.category_outlined, size: 48, color: Colors.white24),
          const SizedBox(height: 12),
          Text(
            _searchQuery.isNotEmpty
                ? "No categories matching '$_searchQuery'"
                : "No categories found.",
            style: GoogleFonts.dmSans(fontSize: 14, color: Colors.white60),
          ),
        ],
      ),
    );
  }
}
