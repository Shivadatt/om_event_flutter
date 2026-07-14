import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:om_event/core/config/app_theme.dart';
import 'package:om_event/core/constants/app_colors.dart';
import 'package:om_event/domain/entities/experience.dart';
import 'package:om_event/presentation/controllers/cart_controller.dart';
import 'package:om_event/presentation/controllers/customer_auth_controller.dart';
import 'package:om_event/presentation/screens/customer/auth/widgets/customer_auth_box.dart';
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

  @override
  void initState() {
    super.initState();
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

    final hasDiscount = item.offerPrice != null && item.price > item.effectivePrice;
    final discountPct = hasDiscount ? ((1 - item.effectivePrice / item.price) * 100).round() : 0;
    final savedAmount = item.price - item.effectivePrice;

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
          ExperiencePriceCard(item: item, hasDiscount: hasDiscount, discountPct: discountPct, savedAmount: savedAmount),
          const SizedBox(height: 24),
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
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: const [
              InclusionChip(label: "Styling & installation"),
              InclusionChip(label: "Teardown"),
              InclusionChip(label: "Dedicated coordinator"),
            ],
          ),
          const SizedBox(height: 20),
          _buildActionButton(cartController, item, paperColor, inkColor, goldColor),
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

  Widget _buildActionButton(CartController cartController, Experience item, Color paperColor, Color inkColor, Color goldColor) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: () {
          final authController = Get.find<CustomerAuthController>();
          if (!authController.isLoggedIn) {
            Get.snackbar(
              "Login Required",
              "Please login first to add items to your selection.",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: const Color(0xFF1B2D27).withValues(alpha: 0.85),
              colorText: Colors.white,
              borderColor: AppColors.secondaryAccent.withValues(alpha: 0.3),
              borderWidth: 1.2,
              margin: const EdgeInsets.all(16),
            );
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
              " added to your selection.",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: paperColor,
              colorText: inkColor,
              margin: const EdgeInsets.all(16),
              boxShadows: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, 2))],
            );
          }
        },
        icon: const Icon(Icons.add, size: 16, color: Colors.white),
        label: Text("ADD TO MY SELECTION", style: AppTheme.sansBody(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
        style: ElevatedButton.styleFrom(backgroundColor: goldColor, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
      ),
    );
  }
}
