import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../domain/entities/experience.dart';
import '../../controllers/admin_controller.dart';
import 'widgets/admin_back_button.dart';
import 'widgets/admin_layout.dart';
import 'widgets/experience_list_tile.dart';
import 'widgets/experience_form_dialog.dart';

/// Manage Experiences (Catalog) screen redesigned to match the
/// Option 2 Modern Card Style reference design:
/// - Compact page header with eyebrow, title, subtitle & solid gold "+ Add Experience" action
/// - Single unified toolbar with dynamic status filter pills (All, Active, Featured, Hidden)
/// - Integrated compact search field, sort dropdown (Latest, Price, Rating, etc.) & Grid/List view toggles
/// - High-density responsive 4-column desktop grid with fixed ~330px card height
/// - Seamless optimistic status toggles without full-screen reloads
class ManageExperiencesScreen extends StatefulWidget {
  const ManageExperiencesScreen({super.key});

  @override
  State<ManageExperiencesScreen> createState() => _ManageExperiencesScreenState();
}

class _ManageExperiencesScreenState extends State<ManageExperiencesScreen> {
  final AdminController controller = Get.find<AdminController>();
  final TextEditingController _searchCtrl = TextEditingController();

  String _selectedFilter = 'all'; // 'all', 'active', 'featured', 'hidden'
  String _selectedSort = 'latest'; // 'latest', 'price_asc', 'price_desc', 'rating', 'popular', 'name'
  String _searchQuery = '';
  bool _isGridView = true;

  static const Color _goldColor = Color(0xFFD4AF37);
  static const Color _darkSurface = Color(0xFF101915);
  static const Color _borderColor = Color(0xFF1E2D24);

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
    if (width >= 1200) return 4; // 4 columns on desktop (Option 2 exact match)
    if (width >= 880) return 3;  // 3 columns on laptop / large tablet
    if (width >= 580) return 2;  // 2 columns on tablet
    return 1;                    // 1 column on mobile
  }

  @override
  Widget build(BuildContext context) {
    final bool isInsideDrawer = AdminLayoutScope.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: isInsideDrawer
          ? null
          : AppBar(
              leading: const AdminBackButton(),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
      body: Obx(() {
        final allItems = controller.rxExperiences;

        if (controller.isLoadingExperiences.value && allItems.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(_goldColor),
            ),
          );
        }

        // Calculate dynamic counts
        final totalCount = allItems.length;
        final activeCount = allItems.where((e) => e.isActive).length;
        final featuredCount = allItems.where((e) => e.isFeatured).length;
        final hiddenCount = totalCount - activeCount;

        // Apply search and status filters
        final filtered = allItems.where((item) {
          if (_selectedFilter == 'active' && !item.isActive) return false;
          if (_selectedFilter == 'featured' && !item.isFeatured) return false;
          if (_selectedFilter == 'hidden' && item.isActive) return false;

          if (_searchQuery.isNotEmpty) {
            final matchName = item.name.toLowerCase().contains(_searchQuery);
            final matchCategory = item.categoryName.toLowerCase().contains(_searchQuery);
            final matchDesc = item.description.toLowerCase().contains(_searchQuery);
            final matchSlug = item.slug.toLowerCase().contains(_searchQuery);
            return matchName || matchCategory || matchDesc || matchSlug;
          }
          return true;
        }).toList();

        // Apply sorting
        switch (_selectedSort) {
          case 'price_asc':
            filtered.sort((a, b) => a.effectivePrice.compareTo(b.effectivePrice));
            break;
          case 'price_desc':
            filtered.sort((a, b) => b.effectivePrice.compareTo(a.effectivePrice));
            break;
          case 'rating':
            filtered.sort((a, b) => b.rating.compareTo(a.rating));
            break;
          case 'popular':
            filtered.sort((a, b) => b.popularity.compareTo(a.popularity));
            break;
          case 'name':
            filtered.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
            break;
          case 'latest':
          default:
            // Keeps natural Firestore order or reverse order if keyed
            break;
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 1. Page Header (Experiences Title & + Add Button) ──
              _buildPageHeader(context),
              const SizedBox(height: 14),

              // ── 2. Unified Filter, Search & View Controls Toolbar ──
              _buildToolbar(
                totalCount: totalCount,
                activeCount: activeCount,
                featuredCount: featuredCount,
                hiddenCount: hiddenCount,
              ),
              const SizedBox(height: 18),

              // ── 3. High-Density Catalog Grid / List ───────────────
              Expanded(
                child: filtered.isEmpty
                    ? _buildEmptyState()
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          if (!_isGridView) {
                            return ListView.builder(
                              padding: const EdgeInsets.only(bottom: 24),
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final item = filtered[index];
                                return ExperienceListTile(
                                  item: item,
                                  isDark: true,
                                  controller: controller,
                                  isListView: true,
                                  onEdit: () => _showExperienceDialog(context, experience: item),
                                  onDelete: () => _confirmDelete(item.slug),
                                );
                              },
                            );
                          }

                          final crossAxisCount = _getCrossAxisCount(constraints.maxWidth);

                          return GridView.builder(
                            padding: const EdgeInsets.only(bottom: 24),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              crossAxisSpacing: 18,
                              mainAxisSpacing: 18,
                              mainAxisExtent: 332, // Exact compact card height matching reference
                            ),
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final item = filtered[index];
                              return ExperienceListTile(
                                item: item,
                                isDark: true,
                                controller: controller,
                                isListView: false,
                                onEdit: () => _showExperienceDialog(context, experience: item),
                                onDelete: () => _confirmDelete(item.slug),
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

  // ── Page Header Component ──────────────────────────────────────────
  Widget _buildPageHeader(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Title & Subtitle
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "EXPERIENCES",
                style: GoogleFonts.dmSans(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  color: _goldColor,
                  letterSpacing: 1.8,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                "Experiences",
                style: GoogleFonts.dmSans(
                  fontSize: isMobile ? 20 : 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                "Inspire your clients with our beautiful event setups.",
                style: GoogleFonts.dmSans(
                  fontSize: 12.5,
                  color: const Color(0xFFA4A9A7),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),

        // Primary "+ Add Experience" Gold Button
        InkWell(
          onTap: () => _showExperienceDialog(context),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 12 : 18,
              vertical: 9.5,
            ),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFE2B755),
                  Color(0xFFD4AF37),
                  Color(0xFFBF962E),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: _goldColor.withValues(alpha: 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.add_rounded,
                  size: 16,
                  color: Color(0xFF0C1410),
                ),
                const SizedBox(width: 5),
                Text(
                  isMobile ? "Add" : "Add Experience",
                  style: GoogleFonts.dmSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0C1410),
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Unified Filter, Search & View Controls Toolbar ──────────────────
  Widget _buildToolbar({
    required int totalCount,
    required int activeCount,
    required int featuredCount,
    required int hiddenCount,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isNarrow = screenWidth < 900;

    final filterPills = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildFilterPill(
            id: 'all',
            label: "All",
            count: totalCount,
          ),
          const SizedBox(width: 8),
          _buildFilterPill(
            id: 'active',
            label: "Active",
            count: activeCount,
          ),
          const SizedBox(width: 8),
          _buildFilterPill(
            id: 'featured',
            label: "Featured",
            count: featuredCount,
          ),
          const SizedBox(width: 8),
          _buildFilterPill(
            id: 'hidden',
            label: "Hidden",
            count: hiddenCount,
          ),
        ],
      ),
    );

    final rightControls = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Compact Search Field
        SizedBox(
          width: isNarrow ? 180 : 220,
          height: 36,
          child: TextField(
            controller: _searchCtrl,
            style: GoogleFonts.dmSans(fontSize: 12.5, color: Colors.white),
            cursorColor: _goldColor,
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: _darkSurface,
              hintText: "Search experiences...",
              hintStyle: GoogleFonts.dmSans(fontSize: 12.5, color: Colors.white38),
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              prefixIcon: const Icon(
                Icons.search_rounded,
                size: 17,
                color: Colors.white38,
              ),
              suffixIcon: _searchQuery.isNotEmpty
                  ? InkWell(
                      onTap: () => _searchCtrl.clear(),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 15,
                        color: Colors.white38,
                      ),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _goldColor, width: 1.2),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Sort Dropdown Button
        _buildSortDropdown(),
        const SizedBox(width: 8),

        // Grid / List View Toggle Buttons
        Container(
          height: 36,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: _darkSurface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _borderColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildViewToggleButton(
                icon: Icons.grid_view_rounded,
                isActive: _isGridView,
                tooltip: "Grid View",
                onTap: () => setState(() => _isGridView = true),
              ),
              _buildViewToggleButton(
                icon: Icons.format_list_bulleted_rounded,
                isActive: !_isGridView,
                tooltip: "List View",
                onTap: () => setState(() => _isGridView = false),
              ),
            ],
          ),
        ),
      ],
    );

    if (isNarrow) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          filterPills,
          const SizedBox(height: 10),
          rightControls,
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        filterPills,
        rightControls,
      ],
    );
  }

  // ── Filter Status Pill ─────────────────────────────────────────────
  Widget _buildFilterPill({
    required String id,
    required String label,
    required int count,
  }) {
    final isSelected = _selectedFilter == id;

    return InkWell(
      onTap: () => setState(() => _selectedFilter = id),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7.5),
        decoration: BoxDecoration(
          color: isSelected ? _goldColor : _darkSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? _goldColor : _borderColor,
            width: 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _goldColor.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? const Color(0xFF0C1410) : Colors.white70,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF0C1410).withValues(alpha: 0.15)
                    : Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: GoogleFonts.dmSans(
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? const Color(0xFF0C1410) : _goldColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Sort Dropdown Menu ─────────────────────────────────────────────
  Widget _buildSortDropdown() {
    final Map<String, String> sortLabels = {
      'latest': "Latest Added",
      'price_asc': "Price: Low to High",
      'price_desc': "Price: High to Low",
      'rating': "Highest Rated",
      'popular': "Most Popular",
      'name': "Name (A-Z)",
    };

    return PopupMenuButton<String>(
      onSelected: (val) => setState(() => _selectedSort = val),
      color: const Color(0xFF131D17),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: _borderColor),
      ),
      itemBuilder: (context) => sortLabels.entries.map((entry) {
        final isSelected = _selectedSort == entry.key;
        return PopupMenuItem<String>(
          value: entry.key,
          height: 38,
          child: Row(
            children: [
              if (isSelected)
                const Icon(Icons.check_rounded, size: 14, color: _goldColor)
              else
                const SizedBox(width: 14),
              const SizedBox(width: 8),
              Text(
                entry.value,
                style: GoogleFonts.dmSans(
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? _goldColor : Colors.white70,
                ),
              ),
            ],
          ),
        );
      }).toList(),
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: _darkSurface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              sortLabels[_selectedSort] ?? "Sort",
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
              ),
            ),
            const SizedBox(width: 5),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: Colors.white38,
            ),
          ],
        ),
      ),
    );
  }

  // ── Grid/List View Toggle Button ───────────────────────────────────
  Widget _buildViewToggleButton({
    required IconData icon,
    required bool isActive,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(7),
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: isActive ? _goldColor.withValues(alpha: 0.18) : Colors.transparent,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Icon(
            icon,
            size: 16,
            color: isActive ? _goldColor : Colors.white38,
          ),
        ),
      ),
    );
  }

  // ── Empty State ───────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.celebration_outlined,
            size: 48,
            color: Colors.white24,
          ),
          const SizedBox(height: 14),
          Text(
            _searchQuery.isNotEmpty
                ? "No experiences matching '$_searchQuery'"
                : "No experiences found.",
            style: GoogleFonts.dmSans(fontSize: 14, color: Colors.white60),
          ),
          if (_searchQuery.isNotEmpty || _selectedFilter != 'all') ...[
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                setState(() {
                  _searchCtrl.clear();
                  _selectedFilter = 'all';
                });
              },
              child: Text(
                "Reset Filters",
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _goldColor,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Delete Confirmation Dialog ─────────────────────────────────────
  void _confirmDelete(String slug) {
    const Color cardColor = Color(0xFF131D17);
    const Color borderColor = Color(0xFF22352A);

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 420,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: borderColor, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.warning_amber_rounded,
                      color: Color(0xFFEF4444),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    "DELETE EXPERIENCE",
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                "Are you sure you want to delete experience '$slug'? This action cannot be undone and will permanently remove this item from the catalog.",
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  color: Colors.white70,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      "CANCEL",
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white60,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 13,
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      Get.back();
                      controller.deleteExperience(slug);
                    },
                    child: Text(
                      "CONFIRM DELETE",
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
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
  }

  // ── Show Add/Edit Dialog ───────────────────────────────────────────
  void _showExperienceDialog(BuildContext context, {Experience? experience}) {
    Get.dialog(
      ExperienceFormDialog(
        experience: experience,
        controller: controller,
      ),
    );
  }
}
