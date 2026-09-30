import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/config/app_routes.dart';
import '../../../core/config/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_image.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/catalog_controller.dart';
import '../../widgets/item_visual_placeholder.dart';
import '../../../domain/entities/package_option.dart';
import 'widgets/customer_booking_dialog.dart';
import 'helpers/customer_drawer_helper.dart';

/// Customer Service Detail / Package Detail Screen.
/// Restructured to match the compact, luxury "Option 2 Modern Card Style":
/// - Centered premium container card with subtle gold border & warm glow
/// - Balanced 2-column layout (Image Left ~45%, Details Right ~55%)
/// - Horizontal 3-tier package selection with strong champagne gold highlight
/// - Compact package feature list with checkmarks
/// - Side-by-side customization dropdowns (Color Story & Design Mood)
/// - Side-by-side primary booking CTA & secondary Add To Selection CTA
class ExperienceDetailScreen extends StatefulWidget {
  const ExperienceDetailScreen({super.key});

  @override
  State<ExperienceDetailScreen> createState() => _ExperienceDetailScreenState();
}

class _ExperienceDetailScreenState extends State<ExperienceDetailScreen> {
  final _notesController = TextEditingController();
  String _selectedColor = '';
  String _selectedTheme = '';
  PackageOption? _selectedPackage;

  static const Color _goldColor = Color(0xFFD4AF37);
  static const Color _cardBgColor = Color(0xFF09120E);
  static const Color _inputBgColor = Color(0xFF0D1713);

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Widget _buildImage(
    String url,
    String title,
    String categorySlug,
    String categoryName,
  ) {
    if (url.isEmpty) {
      return ItemVisualPlaceholder(
        title: title,
        categorySlug: categorySlug,
        categoryName: categoryName,
      );
    }
    if (url.startsWith('assets/')) {
      return Image.asset(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => ItemVisualPlaceholder(
          title: title,
          categorySlug: categorySlug,
          categoryName: categoryName,
        ),
      );
    }
    return AppImage(
      url: url,
      fit: BoxFit.cover,
      placeholder: ItemVisualPlaceholder(
        title: title,
        categorySlug: categorySlug,
        categoryName: categoryName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final slug = Get.parameters['slug'];
    final catalogController = Get.find<CatalogController>();
    final cartController = Get.find<CartController>();
    final width = MediaQuery.of(context).size.width;
    final bool isDesktop = width >= 900;
    final bool isMobile = width < 600;

    return Obx(() {
      // ── 1. Loading State ───────────────────────────────────────────────────
      if (catalogController.isLoadingExperiences.value && catalogController.rxExperiences.isEmpty) {
        return Scaffold(
          backgroundColor: const Color(0xFF070C0A),
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: _goldColor),
                const SizedBox(height: 16),
                Text(
                  "Loading Experience Details...",
                  style: AppTheme.sansBody(fontSize: 13, color: Colors.white70),
                ),
              ],
            ),
          ),
        );
      }

      // ── 2. Experience Lookup ───────────────────────────────────────────────
      final item = catalogController.rxExperiences.firstWhereOrNull(
        (element) => element.slug == slug,
      );

      if (item == null) {
        return Scaffold(
          backgroundColor: const Color(0xFF070C0A),
          body: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 480),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: _cardBgColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _goldColor.withValues(alpha: 0.3)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.search_off_rounded, size: 48, color: _goldColor),
                  const SizedBox(height: 16),
                  Text(
                    "Experience Not Found",
                    style: GoogleFonts.italiana(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "The setup or service you are looking for may have been updated or renamed.",
                    style: AppTheme.sansBody(fontSize: 12.5, color: Colors.white60),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Get.offAllNamed(AppRoutes.home),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _goldColor,
                      foregroundColor: const Color(0xFF09120E),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text(
                      "EXPLORE ALL EXPERIENCES",
                      style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }

      // Initialize customizer dropdowns and default package
      if (_selectedColor.isEmpty && item.colors.isNotEmpty) {
        _selectedColor = item.colors.first;
      }
      if (_selectedTheme.isEmpty && item.themes.isNotEmpty) {
        _selectedTheme = item.themes.first;
      }
      if (_selectedPackage == null && item.dynamicPackages.isNotEmpty) {
        _selectedPackage = item.dynamicPackages.first;
      }

      final currentPkg = _selectedPackage ?? (item.dynamicPackages.isNotEmpty ? item.dynamicPackages.first : null);
      final isLargeDesktop = width >= 1440;
      final double hPadding = isLargeDesktop ? 56 : (isDesktop ? 40 : (isMobile ? 16 : 24));
      final double imageDesktopHeight = (MediaQuery.of(context).size.height * 0.72).clamp(520.0, 600.0);

      return Scaffold(
        backgroundColor: const Color(0xFF070C0A),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: hPadding,
              vertical: isDesktop ? 24 : 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── 3. Back Navigation Button ──────────────────────────────
                _buildBackNavigation(context),
                const SizedBox(height: 22),

                // ── 4. Main Service Detail (Full-Width Responsive 2-Column) ──
                if (isDesktop)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Column: Hero Service Image (~44%)
                      Expanded(
                        flex: 44,
                        child: _buildServiceImage(item, height: imageDesktopHeight),
                      ),
                      const SizedBox(width: 36),

                      // Right Column: Service Info & Controls (~56%)
                      Expanded(
                        flex: 56,
                        child: _buildServiceDetails(
                          context,
                          item,
                          currentPkg,
                          cartController,
                          isDesktop: true,
                        ),
                      ),
                    ],
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Mobile/Tablet: Stacked Hero Image
                      _buildServiceImage(item, height: isMobile ? 320 : 420),
                      const SizedBox(height: 22),
                      _buildServiceDetails(
                        context,
                        item,
                        currentPkg,
                        cartController,
                        isDesktop: false,
                      ),
                    ],
                  ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      );
    });
  }

  // ── Back Button (Positioned Cleanly in Page Container) ─────────────────────
  Widget _buildBackNavigation(BuildContext context) {
    return InkWell(
      onTap: () {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        } else {
          Get.offAllNamed(AppRoutes.home);
        }
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF0F1814),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _goldColor.withValues(alpha: 0.3), width: 1.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.arrow_back_ios_new_rounded, size: 12, color: _goldColor),
            const SizedBox(width: 8),
            Text(
              "Back to Experiences",
              style: AppTheme.sansBody(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: _goldColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Left Column: Service Hero Image ───────────────────────────────────────
  Widget _buildServiceImage(dynamic item, {required double height}) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0D1713),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _goldColor.withValues(alpha: 0.35),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: _goldColor.withValues(alpha: 0.08),
            blurRadius: 20,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: _buildImage(
        item.imageUrl,
        item.name,
        item.categorySlug,
        item.categoryName,
      ),
    );
  }

  // ── Right Column: Service Information & Controls ───────────────────────────
  Widget _buildServiceDetails(
    BuildContext context,
    dynamic item,
    PackageOption? currentPkg,
    CartController cartController, {
    required bool isDesktop,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── 1. Category / Service Type Subtitle ──
        Text(
          "${item.categoryName.toUpperCase()} • CUSTOMIZABLE",
          style: AppTheme.sansBody(
            fontSize: 9.5,
            fontWeight: FontWeight.bold,
            color: _goldColor,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 4),

        // ── 2. Service Title ──
        Text(
          item.name,
          style: GoogleFonts.italiana(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 6),

        // ── 3. Rating & Reviews ──
        Row(
          children: [
            const Icon(Icons.star_rounded, size: 16, color: _goldColor),
            const SizedBox(width: 4),
            Text(
              "${item.rating} (${item.reviewCount} Verified Reviews)",
              style: AppTheme.sansBody(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // ── 4. Description ──
        Text(
          item.description,
          style: AppTheme.sansBody(
            fontSize: 12.5,
            color: Colors.white60,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 12),

        // ── 5. Starting Price ──
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              AppFormatters.formatCurrency(item.effectivePrice),
              style: AppTheme.sansBody(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              "starting price",
              style: AppTheme.sansBody(
                fontSize: 11,
                color: Colors.white54,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // ── 6. Choose Package Tier (Horizontal 3-Cards) ──
        Text(
          "CHOOSE PACKAGE TIER",
          style: AppTheme.sansBody(
            fontSize: 9.5,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.4,
            color: _goldColor,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: item.dynamicPackages.map<Widget>((pkg) {
            final isSelected = currentPkg?.id == pkg.id;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: InkWell(
                  onTap: () => setState(() => _selectedPackage = pkg),
                  borderRadius: BorderRadius.circular(10),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? _goldColor : const Color(0xFF0F1814),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? _goldColor : _goldColor.withValues(alpha: 0.25),
                        width: isSelected ? 1.5 : 1.0,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: _goldColor.withValues(alpha: 0.25),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          pkg.tier.toUpperCase(),
                          style: AppTheme.sansBody(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? const Color(0xFF09120E) : Colors.white60,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          AppFormatters.formatCurrency(pkg.effectivePrice),
                          style: AppTheme.sansBody(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? const Color(0xFF09120E) : Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),

        // ── 7. Package Features Box ──
        if (currentPkg != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF0B1410),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _goldColor.withValues(alpha: 0.2), width: 1.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${currentPkg.name} Included Features:",
                  style: AppTheme.sansBody(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: _goldColor,
                  ),
                ),
                const SizedBox(height: 6),
                ...currentPkg.features.map(
                  (f) => Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_rounded, color: _goldColor, size: 13),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            f,
                            style: AppTheme.sansBody(
                              fontSize: 11,
                              color: Colors.white70,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 14),

        // ── 8. Customization Dropdowns (Side-by-Side on Desktop) ──
        if (item.colors.isNotEmpty || item.themes.isNotEmpty) ...[
          if (isDesktop && item.colors.isNotEmpty && item.themes.isNotEmpty)
            Row(
              children: [
                Expanded(
                  child: _buildCustomDropdown(
                    label: "Color Story",
                    value: _selectedColor,
                    options: item.colors,
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedColor = val);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildCustomDropdown(
                    label: "Design Mood / Theme",
                    value: _selectedTheme,
                    options: item.themes,
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedTheme = val);
                    },
                  ),
                ),
              ],
            )
          else ...[
            if (item.colors.isNotEmpty)
              _buildCustomDropdown(
                label: "Color Story",
                value: _selectedColor,
                options: item.colors,
                onChanged: (val) {
                  if (val != null) setState(() => _selectedColor = val);
                },
              ),
            if (item.themes.isNotEmpty) ...[
              const SizedBox(height: 10),
              _buildCustomDropdown(
                label: "Design Mood / Theme",
                value: _selectedTheme,
                options: item.themes,
                onChanged: (val) {
                  if (val != null) setState(() => _selectedTheme = val);
                },
              ),
            ],
          ],
          const SizedBox(height: 12),
        ],

        // ── 9. Note Input Field ──
        Text(
          "Your Note",
          style: AppTheme.sansBody(
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: _inputBgColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _goldColor.withValues(alpha: 0.25), width: 1.0),
          ),
          child: TextField(
            controller: _notesController,
            maxLines: 2,
            cursorColor: _goldColor,
            style: AppTheme.sansBody(fontSize: 11.5, color: Colors.white),
            decoration: InputDecoration.collapsed(
              hintText: "Tell us about any specific details or ideas...",
              hintStyle: AppTheme.sansBody(fontSize: 11, color: Colors.white38),
            ),
          ),
        ),
        const SizedBox(height: 14),

        // ── 10. Service Benefits (Styling, Teardown, Coordinator) ──
        Wrap(
          spacing: 14,
          runSpacing: 6,
          children: [
            _buildBenefitItem("Styling & Installation"),
            _buildBenefitItem("Teardown"),
            _buildBenefitItem("Dedicated Coordinator"),
          ],
        ),
        const SizedBox(height: 18),

        // ── 11. Action Buttons (Side-by-Side on Desktop) ──
        if (isDesktop)
          Row(
            children: [
              Expanded(
                flex: 3,
                child: _buildPrimaryBookingButton(context, item, currentPkg),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: _buildSecondaryAddButton(context, item, currentPkg, cartController),
              ),
            ],
          )
        else
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: _buildPrimaryBookingButton(context, item, currentPkg),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: _buildSecondaryAddButton(context, item, currentPkg, cartController),
              ),
            ],
          ),
      ],
    );
  }

  // ── Helper: Custom Dropdown Control ────────────────────────────────────────
  Widget _buildCustomDropdown({
    required String label,
    required String value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.sansBody(
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
          decoration: BoxDecoration(
            color: _inputBgColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _goldColor.withValues(alpha: 0.25), width: 1.0),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: options.contains(value) ? value : options.firstOrNull,
              dropdownColor: const Color(0xFF121D18),
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: _goldColor, size: 18),
              style: AppTheme.sansBody(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500),
              items: options.map((opt) {
                return DropdownMenuItem(
                  value: opt,
                  child: Text(opt),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  // ── Helper: Benefit Item with Gold Checkmark ───────────────────────────────
  Widget _buildBenefitItem(String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.check_rounded, color: _goldColor, size: 13),
        const SizedBox(width: 4),
        Text(
          text,
          style: AppTheme.sansBody(
            fontSize: 10.5,
            color: Colors.white60,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ── Helper: Primary Booking CTA ───────────────────────────────────────────
  Widget _buildPrimaryBookingButton(
    BuildContext context,
    dynamic item,
    PackageOption? currentPkg,
  ) {
    final tierName = (currentPkg?.tier ?? 'basic').toUpperCase();

    return ElevatedButton(
      onPressed: () {
        final pkg = _selectedPackage ?? (item.dynamicPackages.isNotEmpty ? item.dynamicPackages.first : null);
        if (pkg != null) {
          showCustomerBookingDialog(
            context,
            experience: item,
            selectedPackage: pkg,
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: _goldColor,
        foregroundColor: const Color(0xFF09120E),
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
      ),
      child: Text(
        "BOOK THIS PACKAGE ($tierName)",
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTheme.sansBody(
          fontSize: 11.5,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF09120E),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // ── Helper: Secondary Add To Selection CTA ─────────────────────────────────
  Widget _buildSecondaryAddButton(
    BuildContext context,
    dynamic item,
    PackageOption? currentPkg,
    CartController cartController,
  ) {
    return OutlinedButton(
      onPressed: () {
        final experienceToCart = currentPkg != null
            ? item.copyWith(
                price: currentPkg.price,
                offerPrice: currentPkg.effectivePrice,
              )
            : item;
        cartController.addToCart(
          experienceToCart,
          color: _selectedColor,
          theme: _selectedTheme,
          notes: _notesController.text,
        );
        CustomerDrawerHelper.openEventCanvas(context);
        Get.snackbar(
          "Added to Selection",
          "${item.name} added to your selection.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF171411),
          colorText: _goldColor,
          margin: const EdgeInsets.all(16),
        );
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: _goldColor,
        side: const BorderSide(color: _goldColor, width: 1.2),
        backgroundColor: const Color(0xFF0E1713),
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(
        "ADD TO MY SELECTION",
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTheme.sansBody(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: _goldColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
