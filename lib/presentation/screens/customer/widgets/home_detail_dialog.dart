import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:om_event/core/config/app_routes.dart';
import 'package:om_event/core/config/app_theme.dart';
import 'package:om_event/core/constants/app_colors.dart';
import 'package:om_event/domain/entities/experience.dart';
import 'package:om_event/domain/entities/package_option.dart';
import 'package:om_event/presentation/controllers/cart_controller.dart';
import 'package:om_event/presentation/controllers/customer_auth_controller.dart';
import 'package:om_event/presentation/screens/customer/auth/widgets/customer_auth_box.dart';
import 'customer_booking_dialog.dart';
import 'home_detail_parts.dart';

void showExperienceDetailDialog(BuildContext context, Experience item) {
  showDialog(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.70),
    builder: (_) => ExperienceDetailDialog(item: item),
  );
}

class ExperienceDetailDialog extends StatefulWidget {
  final Experience item;
  const ExperienceDetailDialog({super.key, required this.item});

  @override
  State<ExperienceDetailDialog> createState() => _ExperienceDetailDialogState();
}

class _ExperienceDetailDialogState extends State<ExperienceDetailDialog> {
  final _notesController = TextEditingController();
  String _selectedColor = '';
  String _selectedTheme = '';
  late PackageOption _selectedPackage;

  @override
  void initState() {
    super.initState();
    final pkgs = widget.item.dynamicPackages;
    _selectedPackage = pkgs.isNotEmpty
        ? pkgs.first
        : PackageOption.generateDefaults(
            serviceId: widget.item.id,
            serviceName: widget.item.name,
            basePrice: widget.item.effectivePrice,
            baseDuration: widget.item.durationHours,
          ).first;

    if (widget.item.colors.isNotEmpty) {
      _selectedColor = widget.item.colors.first;
    }
    if (widget.item.themes.isNotEmpty) {
      _selectedTheme = widget.item.themes.first;
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartController = Get.find<CartController>();
    final item = widget.item;
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final isDesktop = width >= 800;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final paperColor = isDark ? AppColors.darkPaper : AppColors.lightPaper;
    final inkColor = isDark ? AppColors.darkInk : AppColors.lightInk;
    final mutedColor = isDark ? AppColors.darkMuted : AppColors.lightMuted;
    final lineColor = isDark ? AppColors.darkLine : AppColors.lightLine;
    final goldColor = isDark ? AppColors.darkGold : AppColors.lightGold;

    final dialogWidth = (width * 0.9).clamp(320.0, 940.0);
    final dialogMaxHeight = (height - keyboardHeight) * 0.92;

    Widget rightPanel = SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 36 : 20, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isDesktop) ...[
            AspectRatio(
              aspectRatio: 1.4,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: ExperienceDetailImage(url: item.imageUrl, title: item.name, categorySlug: item.categorySlug, categoryName: item.categoryName),
              ),
            ),
            const SizedBox(height: 20),
          ],
          Text(
            " · CUSTOMIZABLE",
            style: AppTheme.sansBody(fontSize: 10, color: goldColor, fontWeight: FontWeight.w700, letterSpacing: 1.5),
          ),
          const SizedBox(height: 10),
          Text(
            item.name,
            style: GoogleFonts.italiana(fontSize: isDesktop ? 40 : 28, color: inkColor, height: 1.1, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Text(
            item.description,
            style: AppTheme.sansBody(fontSize: 13, color: inkColor.withValues(alpha: 0.7), height: 1.6),
          ),
          const SizedBox(height: 20),
          const SizedBox(height: 20),
          ExperiencePriceCard(
            item: item,
            hasDiscount: _selectedPackage.discountPrice != null && _selectedPackage.price > _selectedPackage.effectivePrice,
            discountPct: _selectedPackage.discountPrice != null && _selectedPackage.price > _selectedPackage.effectivePrice
                ? ((1 - _selectedPackage.effectivePrice / _selectedPackage.price) * 100).round()
                : 0,
            savedAmount: _selectedPackage.price - _selectedPackage.effectivePrice,
          ),
          const SizedBox(height: 20),

          // Dynamic Package Selector (Basic, Premium, Luxury)
          Text("CHOOSE PACKAGE TIER", style: AppTheme.sansBody(fontSize: 9, color: inkColor, fontWeight: FontWeight.w700, letterSpacing: 1.3)),
          const SizedBox(height: 10),
          Row(
            children: item.dynamicPackages.map((pkg) {
              final isSelected = _selectedPackage.id == pkg.id;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: InkWell(
                    onTap: () => setState(() => _selectedPackage = pkg),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? goldColor.withValues(alpha: 0.15) : paperColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? goldColor : lineColor,
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
                              color: isSelected ? goldColor : inkColor.withValues(alpha: 0.7),
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "₹${pkg.effectivePrice.toStringAsFixed(0)}",
                            style: AppTheme.sansBody(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isSelected ? Colors.white : inkColor,
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

          // Selected package inclusions bullet list
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: paperColor.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: lineColor.withValues(alpha: 0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.stars_rounded, size: 14, color: goldColor),
                    const SizedBox(width: 6),
                    Text(
                      "${_selectedPackage.name} includes:",
                      style: AppTheme.sansBody(fontSize: 11, color: goldColor, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ..._selectedPackage.features.map(
                  (f) => Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("• ", style: TextStyle(color: goldColor, fontSize: 12)),
                        Expanded(
                          child: Text(
                            f,
                            style: AppTheme.sansBody(fontSize: 11, color: inkColor.withValues(alpha: 0.8)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          if (item.colors.isNotEmpty) ...[
            Text("COLOR STORY", style: AppTheme.sansBody(fontSize: 9, color: inkColor, fontWeight: FontWeight.w700, letterSpacing: 1.3)),
            const SizedBox(height: 6),
            ModalDropdown(value: _selectedColor, items: item.colors, onChanged: (v) => setState(() => _selectedColor = v)),
            const SizedBox(height: 16),
          ],
          if (item.themes.isNotEmpty) ...[
            Text("DESIGN MOOD", style: AppTheme.sansBody(fontSize: 9, color: inkColor, fontWeight: FontWeight.w700, letterSpacing: 1.3)),
            const SizedBox(height: 6),
            ModalDropdown(value: _selectedTheme, items: item.themes, onChanged: (v) => setState(() => _selectedTheme = v)),
            const SizedBox(height: 16),
          ],
          Text("YOUR NOTE", style: AppTheme.sansBody(fontSize: 9, color: inkColor, fontWeight: FontWeight.w700, letterSpacing: 1.3)),
          const SizedBox(height: 6),
          TextField(
            controller: _notesController,
            maxLines: 3,
            style: AppTheme.sansBody(fontSize: 13, color: inkColor),
            decoration: InputDecoration(
              filled: true,
              fillColor: paperColor,
              hintText: "Names, venue details or a specific idea…",
              hintStyle: AppTheme.sansBody(fontSize: 12, color: mutedColor),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: lineColor, width: 1.5)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: lineColor, width: 1.5)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: goldColor, width: 1.5)),
            ),
          ),
          const SizedBox(height: 24),
          _buildActionButtons(cartController, item, paperColor, inkColor, goldColor),
          const SizedBox(height: 12),
        ],
      ),
    );

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: ((width - dialogWidth) / 2).clamp(8.0, double.infinity),
        vertical: ((height - keyboardHeight) - dialogMaxHeight) / 2,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: dialogWidth, maxHeight: dialogMaxHeight),
        child: Material(
          color: const Color(0xFF0D1915),
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: AppColors.secondaryAccent.withValues(alpha: 0.18), width: 1),
          ),
          child: Stack(
            children: [
              isDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          width: dialogWidth * 0.47,
                          child: ExperienceDetailImage(url: item.imageUrl, title: item.name, categorySlug: item.categorySlug, categoryName: item.categoryName),
                        ),
                        Expanded(child: rightPanel),
                      ],
                    )
                  : rightPanel,
              Positioned(
                top: 16,
                right: 16,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: paperColor,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, 2))],
                      border: Border.all(color: lineColor, width: 1),
                    ),
                    child: Icon(Icons.close_rounded, size: 18, color: inkColor),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(CartController cartController, Experience item, Color paperColor, Color inkColor, Color goldColor) {
    return Column(
      children: [
        // Primary CTA: Book This Package
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              showCustomerBookingDialog(
                context,
                experience: item,
                selectedPackage: _selectedPackage,
              );
            },
            icon: const Icon(Icons.calendar_today_outlined, size: 16, color: Color(0xFF0D1915)),
            label: Text(
              "BOOK THIS PACKAGE (${_selectedPackage.tier.toUpperCase()})",
              style: AppTheme.sansBody(fontSize: 12, color: const Color(0xFF0D1915), fontWeight: FontWeight.w800, letterSpacing: 1.2),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: goldColor,
              foregroundColor: const Color(0xFF0D1915),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Secondary CTA: Add to Selection
        SizedBox(
          width: double.infinity,
          height: 44,
          child: OutlinedButton.icon(
            onPressed: () {
              final authController = Get.find<CustomerAuthController>();
              if (!authController.isLoggedIn) {
                Get.dialog(
                  Dialog(
                    backgroundColor: Colors.transparent,
                    child: CustomerAuthBox(
                      onSuccess: () {
                        cartController.addToCart(item, color: _selectedColor, theme: _selectedTheme, notes: _notesController.text);
                      },
                    ),
                  ),
                );
              } else {
                cartController.addToCart(item, color: _selectedColor, theme: _selectedTheme, notes: _notesController.text);
                Navigator.of(context).pop();
                Get.snackbar(
                  "Added to Canvas",
                  "${item.name} added to your selection.",
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: paperColor,
                  colorText: inkColor,
                  margin: const EdgeInsets.all(16),
                );
              }
            },
            icon: Icon(Icons.add, size: 15, color: goldColor),
            label: Text(
              "ADD TO MY SELECTION",
              style: AppTheme.sansBody(fontSize: 11, color: goldColor, fontWeight: FontWeight.w700, letterSpacing: 1.1),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: goldColor.withValues(alpha: 0.6), width: 1.2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: () {
            Navigator.of(context).pop();
            Get.toNamed('${AppRoutes.detail}/${item.slug}');
          },
          icon: Icon(Icons.open_in_new_rounded, size: 14, color: goldColor.withValues(alpha: 0.8)),
          label: Text(
            "VIEW FULL DETAILS PAGE",
            style: AppTheme.sansBody(
              fontSize: 10,
              color: goldColor.withValues(alpha: 0.8),
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ],
    );
  }
}
