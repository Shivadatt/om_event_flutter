import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/admin_controller.dart';
import '../../controllers/auth_controller.dart';
import 'widgets/category_list_tile.dart';
import 'parts/manage_categories_dialogs.dart';

/// Manage Categories screen refined for true full-screen desktop presentation
/// matching the Option 2 Modern Card Style reference design:
/// - Top header with real-time category search and admin profile pill
/// - Page header with title, subtitle, and "+ Add Category" gold action button
/// - Filter status chips (Active, Hidden, Total) with view toggles
/// - 3-column desktop grid with compact landscape cards (~245px height)
/// - Fits ~6 categories comfortably within standard desktop viewports
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
    if (width >= 1200) return 3; // 3 columns on desktop matching reference
    if (width >= 750) return 2;  // 2 columns on tablet
    return 1;                    // 1 column on mobile
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    const goldColor = Color(0xFFD4AF37);

    return Scaffold(
      backgroundColor: Colors.transparent, // Inherits luxury ambient background from AdminLayout
      body: Obx(() {
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

        // Apply search and filter chips
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

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 1. Top Bar with Search & Profile ────────────────
              _buildTopBar(context, authController),
              const SizedBox(height: 16),

              // ── 2. Page Header: Title, Subtitle & + Add Category ─
              _buildPageHeader(context, goldColor),
              const SizedBox(height: 14),

              // ── 3. Filter Status Chips & View Toggles ────────────
              _buildFilterChipsRow(activeCount, hiddenCount, totalCount, goldColor),
              const SizedBox(height: 16),

              // ── 4. 3-Column Responsive Grid ──────────────────────
              Expanded(
                child: filteredList.isEmpty
                    ? Center(
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
                      )
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          final crossAxisCount = _getCrossAxisCount(constraints.maxWidth);

                          return GridView.builder(
                            padding: const EdgeInsets.only(bottom: 24),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              crossAxisSpacing: 18,
                              mainAxisSpacing: 18,
                              mainAxisExtent: 245, // Exact compact height matching reference
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
                        },
                      ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // ── Top Header / Search & Profile Bar ───────────────────────────────
  Widget _buildTopBar(BuildContext context, AuthController authController) {
    const goldColor = Color(0xFFD4AF37);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          // Search box
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: 320,
                height: 36,
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
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: Icon(
                        Icons.search_rounded,
                        size: 18,
                        color: Colors.white38,
                      ),
                    ),
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 26,
                      minHeight: 26,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? InkWell(
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
                          )
                        : null,
                    suffixIconConstraints: const BoxConstraints(
                      minWidth: 24,
                      minHeight: 24,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    filled: false,
                    fillColor: Colors.transparent,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ),
          ),

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
                    size: 19,
                    color: goldColor,
                  ),
                  Positioned(
                    top: -1,
                    right: -1,
                    child: Container(
                      width: 6.5,
                      height: 6.5,
                      decoration: const BoxDecoration(
                        color: goldColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),

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
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF101915),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
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
                              color: goldColor,
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
                                color: goldColor,
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

  // ── Page Header: Title, Subtitle & + Add Category Button ───────────
  Widget _buildPageHeader(BuildContext context, Color goldColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Manage Categories",
              style: GoogleFonts.dmSans(
                fontSize: 22,
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
            ),
          ],
        ),

        // + Add Category Button (Gold pill matching reference)
        ElevatedButton.icon(
          onPressed: () => widget.showCategoryDialog(context),
          icon: const Icon(Icons.add_rounded, size: 16, color: Color(0xFF0C1410)),
          label: Text(
            "Add Category",
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ],
    );
  }

  // ── Filter Status Chips & View Toggles ─────────────────────────────
  Widget _buildFilterChipsRow(
    int active,
    int hidden,
    int total,
    Color goldColor,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Filter Chips: Active, Hidden, Total
        Row(
          children: [
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
            const SizedBox(width: 10),
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
            const SizedBox(width: 10),
            _chip(
              label: "$total Total Categories",
              color: Colors.white70,
              bg: const Color(0xFF14201A),
              isSelected: _selectedFilter == 'all',
              onTap: () {
                setState(() {
                  _selectedFilter = 'all';
                });
              },
            ),
          ],
        ),

        // Right View Mode Toggles
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF14201A),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.white12),
              ),
              child: const Icon(Icons.calendar_today_outlined, size: 14, color: Colors.white54),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF1B2A22),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: goldColor.withValues(alpha: 0.5)),
              ),
              child: Icon(Icons.grid_view_rounded, size: 14, color: goldColor),
            ),
          ],
        ),
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
}
