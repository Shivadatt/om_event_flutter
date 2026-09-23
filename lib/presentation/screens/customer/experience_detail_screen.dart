import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/config/app_routes.dart';
import '../../../core/config/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_input.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/catalog_controller.dart';
import '../../widgets/item_visual_placeholder.dart';
import '../../controllers/customer_auth_controller.dart';
import '../../../domain/entities/package_option.dart';
import 'auth/widgets/customer_auth_box.dart';
import 'widgets/customer_booking_dialog.dart';

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
        errorBuilder:
            (_, __, ___) => ItemVisualPlaceholder(
              title: title,
              categorySlug: categorySlug,
              categoryName: categoryName,
            ),
      );
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder:
          (_, __, ___) => ItemVisualPlaceholder(
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 800;

    return Obx(() {
      // Gracefully handle initial loading on direct browser deep links & reloads
      if (catalogController.isLoadingExperiences.value && catalogController.rxExperiences.isEmpty) {
        return Scaffold(
          backgroundColor: const Color(0xFF0F1B18),
          appBar: AppBar(
            backgroundColor: const Color(0xFF0F1B18),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.white70),
              onPressed: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                } else {
                  Get.offAllNamed(AppRoutes.home);
                }
              },
            ),
          ),
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: Color(0xFFD4AF37)),
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

      final item = catalogController.rxExperiences.firstWhereOrNull(
        (element) => element.slug == slug,
      );

      if (item == null) {
        return Scaffold(
          backgroundColor: const Color(0xFF0F1B18),
          appBar: AppBar(
            backgroundColor: const Color(0xFF0F1B18),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.white70),
              onPressed: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                } else {
                  Get.offAllNamed(AppRoutes.home);
                }
              },
            ),
            title: Text("Experience", style: GoogleFonts.italiana(color: Colors.white)),
          ),
          body: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 480),
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.search_off_rounded, size: 52, color: Color(0xFFD4AF37)),
                  const SizedBox(height: 18),
                  Text(
                    "Experience Not Found",
                    style: GoogleFonts.italiana(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "The setup or service you are looking for may have been updated or renamed.",
                    style: AppTheme.sansBody(fontSize: 13, color: Colors.white60),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Get.offAllNamed(AppRoutes.home),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      foregroundColor: const Color(0xFF0F1B18),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
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

    // Initialize customizer dropdowns
    if (_selectedColor.isEmpty && item.colors.isNotEmpty) {
      _selectedColor = item.colors.first;
    }
    if (_selectedTheme.isEmpty && item.themes.isNotEmpty) {
      _selectedTheme = item.themes.first;
    }
    if (_selectedPackage == null && item.dynamicPackages.isNotEmpty) {
      _selectedPackage = item.dynamicPackages.first;
    }

    final detailContent = [
      Text(
        "${item.categoryName.toUpperCase()} · CUSTOMIZABLE",
        style: AppTheme.sansBody(
          fontSize: 10,
          color: isDark ? AppTheme.darkGold : AppTheme.lightGold,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
      const SizedBox(height: 12),
      Text(
        item.name,
        style: AppTheme.serifHeader(
          fontSize: 34,
          color: isDark ? AppTheme.darkInk : AppTheme.lightInk,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          const Icon(Icons.star, size: 14, color: Colors.amber),
          const SizedBox(width: 4),
          Text(
            "${item.rating} (${item.reviewCount} Verified Reviews)",
            style: AppTheme.sansBody(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      const SizedBox(height: 20),
      Text(
        item.description,
        style: AppTheme.sansBody(
          fontSize: 14,
          color: isDark ? AppTheme.darkMuted : AppTheme.lightMuted,
          height: 1.6,
        ),
      ),
      const SizedBox(height: 24),
      Row(
        children: [
          Text(
            AppFormatters.formatCurrency(item.effectivePrice),
            style: AppTheme.sansBody(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Text(
            "starting price",
            style: AppTheme.sansBody(
              fontSize: 11,
              color: isDark ? AppTheme.darkMuted : AppTheme.lightMuted,
            ),
          ),
        ],
      ),
      const Divider(height: 40),

      // Package Selection
      Text(
        "CHOOSE PACKAGE TIER",
        style: AppTheme.sansBody(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
          color: isDark ? AppTheme.darkGold : AppTheme.lightGold,
        ),
      ),
      const SizedBox(height: 12),
      Row(
        children: item.dynamicPackages.map((pkg) {
          final isSelected = _selectedPackage?.id == pkg.id;
          final goldColor = isDark ? AppTheme.darkGold : AppTheme.lightGold;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: InkWell(
                onTap: () => setState(() => _selectedPackage = pkg),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? goldColor.withValues(alpha: 0.15)
                        : (isDark ? AppTheme.darkPaper : AppTheme.lightPaper),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? goldColor
                          : (isDark ? AppTheme.darkLine : AppTheme.lightLine),
                      width: isSelected ? 1.8 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        pkg.tier.toUpperCase(),
                        style: AppTheme.sansBody(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: isSelected ? goldColor : (isDark ? AppTheme.darkMuted : AppTheme.lightMuted),
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppFormatters.formatCurrency(pkg.effectivePrice),
                        style: AppTheme.sansBody(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppTheme.darkInk : AppTheme.lightInk,
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
      const SizedBox(height: 14),
      if (_selectedPackage != null)
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkPaper : AppTheme.lightPaper,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDark ? AppTheme.darkLine : AppTheme.lightLine,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${_selectedPackage!.name} Included Features:",
                style: AppTheme.sansBody(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppTheme.darkGold : AppTheme.lightGold,
                ),
              ),
              const SizedBox(height: 6),
              ..._selectedPackage!.features.map(
                (f) => Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("• ", style: TextStyle(color: isDark ? AppTheme.darkGold : AppTheme.lightGold, fontSize: 12)),
                      Expanded(
                        child: Text(
                          f,
                          style: AppTheme.sansBody(
                            fontSize: 11,
                            color: isDark ? AppTheme.darkInk.withValues(alpha: 0.8) : AppTheme.lightInk.withValues(alpha: 0.8),
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
      const SizedBox(height: 24),

      // Customizer Settings Dropdowns
      Text(
        "CUSTOMISE YOUR SETUP",
        style: AppTheme.sansBody(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
      const SizedBox(height: 18),
      if (item.colors.isNotEmpty) ...[
        Text(
          "COLOR STORY",
          style: AppTheme.sansBody(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(
              color: isDark ? AppTheme.darkLine : AppTheme.lightLine,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: _selectedColor,
              items:
                  item.colors
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedColor = val);
              },
            ),
          ),
        ),
        const SizedBox(height: 18),
      ],
      if (item.themes.isNotEmpty) ...[
        Text(
          "DESIGN MOOD / THEME",
          style: AppTheme.sansBody(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(
              color: isDark ? AppTheme.darkLine : AppTheme.lightLine,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: _selectedTheme,
              items:
                  item.themes
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedTheme = val);
              },
            ),
          ),
        ),
        const SizedBox(height: 18),
      ],
      CustomInput(
        label: "YOUR NOTE",
        placeholder: "Tell us about any specific details or ideas...",
        controller: _notesController,
        maxLines: 3,
      ),
      const SizedBox(height: 24),
      Wrap(
        spacing: 12,
        runSpacing: 6,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check, color: Colors.green, size: 12),
              const SizedBox(width: 4),
              Text(
                "Styling & Installation",
                style: AppTheme.sansBody(
                  fontSize: 10,
                  color: isDark ? AppTheme.darkMuted : AppTheme.lightMuted,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check, color: Colors.green, size: 12),
              const SizedBox(width: 4),
              Text(
                "Teardown",
                style: AppTheme.sansBody(
                  fontSize: 10,
                  color: isDark ? AppTheme.darkMuted : AppTheme.lightMuted,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check, color: Colors.green, size: 12),
              const SizedBox(width: 4),
              Text(
                "Dedicated Coordinator",
                style: AppTheme.sansBody(
                  fontSize: 10,
                  color: isDark ? AppTheme.darkMuted : AppTheme.lightMuted,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
      const SizedBox(height: 24),
      CustomButton(
        text: "Book this package (${(_selectedPackage?.tier ?? 'basic').toUpperCase()})",
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
      ),
      const SizedBox(height: 12),
      CustomButton(
        text: "Add to my selection",
        isPrimary: false,
        onPressed: () {
          final authController = Get.find<CustomerAuthController>();
          if (!authController.isLoggedIn) {
            Get.snackbar(
              "Login Required",
              "Please login first to add items to your selection.",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: const Color(0xFF1B2D27).withValues(alpha: 0.85),
              colorText: Colors.white,
              margin: const EdgeInsets.all(16),
            );
            Get.dialog(
              Dialog(
                backgroundColor: Colors.transparent,
                child: CustomerAuthBox(
                  onSuccess: () {
                    cartController.addToCart(
                      item,
                      color: _selectedColor,
                      theme: _selectedTheme,
                      notes: _notesController.text,
                    );
                  },
                ),
              ),
            );
          } else {
            cartController.addToCart(
              item,
              color: _selectedColor,
              theme: _selectedTheme,
              notes: _notesController.text,
            );
            Get.back();
            Get.snackbar(
              "Added to Canvas",
              "${item.name} added to your selection.",
            );
          }
        },
      ),
      const SizedBox(height: 40),
    ];

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF141A18) : const Color(0xFFFBF9F4),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1200),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child:
                isDesktop
                    ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Column: Image/Placeholder
                        Expanded(
                          flex: 10,
                          child: Container(
                            height: 520,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color:
                                    isDark
                                        ? AppTheme.darkLine
                                        : AppTheme.lightLine,
                              ),
                            ),
                            child: _buildImage(
                              item.imageUrl,
                              item.name,
                              item.categorySlug,
                              item.categoryName,
                            ),
                          ),
                        ),
                        const SizedBox(width: 48),
                        // Right Column: Customizer fields
                        Expanded(
                          flex: 10,
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: detailContent,
                            ),
                          ),
                        ),
                      ],
                    )
                    : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 320,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color:
                                    isDark
                                        ? AppTheme.darkLine
                                        : AppTheme.lightLine,
                              ),
                            ),
                            child: _buildImage(
                              item.imageUrl,
                              item.name,
                              item.categorySlug,
                              item.categoryName,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ...detailContent,
                        ],
                      ),
                    ),
          ),
        ),
      ),
    );
    });
  }
}
