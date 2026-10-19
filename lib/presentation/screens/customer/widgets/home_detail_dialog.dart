import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:om_event/core/config/app_routes.dart';
import 'package:om_event/core/config/app_theme.dart';
import 'package:om_event/core/constants/app_colors.dart';
import 'package:om_event/domain/entities/experience.dart';
import 'package:om_event/domain/entities/package_option.dart';
import 'package:om_event/presentation/controllers/cart_controller.dart';
import '../helpers/customer_drawer_helper.dart';
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
    final mediaQuery = MediaQuery.of(context);
    final width = mediaQuery.size.width;
    final height = mediaQuery.size.height;
    final padding = mediaQuery.padding;
    final double keyboardHeight = mediaQuery.viewInsets.bottom;
    final double availableHeight = (height - keyboardHeight - padding.top - padding.bottom).clamp(200.0, double.infinity);

    // Responsive Breakpoint Classification
    final bool isDesktop = width >= 1200;
    final bool isLaptop = width >= 1024 && width < 1200;
    final bool isTwoColumn = width >= 1024 && availableHeight >= 520;
    final bool isTablet = width >= 600 && width < 1024;
    final bool isMobile = width < 600;
    final bool isNarrowMobile = width < 360;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final paperColor = isDark ? AppColors.darkPaper : AppColors.lightPaper;
    final inkColor = isDark ? AppColors.darkInk : AppColors.lightInk;
    final mutedColor = isDark ? AppColors.darkMuted : AppColors.lightMuted;
    final lineColor = isDark ? AppColors.darkLine : AppColors.lightLine;
    final goldColor = isDark ? AppColors.darkGold : AppColors.lightGold;

    // Responsive Dialog Sizing & Insets
    final double dialogWidth;
    final double dialogMaxHeight;
    final EdgeInsets dialogInsetPadding;

    if (isDesktop) {
      dialogWidth = (width * 0.76).clamp(1000.0, 1140.0);
      dialogMaxHeight = (availableHeight * 0.88).clamp(540.0, 780.0);
      dialogInsetPadding = const EdgeInsets.symmetric(horizontal: 32, vertical: 24);
    } else if (isLaptop) {
      dialogWidth = (width * 0.88).clamp(880.0, 990.0);
      dialogMaxHeight = (availableHeight * 0.90).clamp(500.0, 740.0);
      dialogInsetPadding = const EdgeInsets.symmetric(horizontal: 24, vertical: 20);
    } else if (isTablet) {
      dialogWidth = (width * 0.86).clamp(520.0, 680.0);
      dialogMaxHeight = availableHeight * 0.92;
      dialogInsetPadding = const EdgeInsets.symmetric(horizontal: 20, vertical: 20);
    } else {
      // Mobile (320px to 599px)
      dialogWidth = (width - (isNarrowMobile ? 24.0 : 32.0)).clamp(280.0, 520.0);
      dialogMaxHeight = availableHeight * 0.94;
      dialogInsetPadding = EdgeInsets.symmetric(
        horizontal: isNarrowMobile ? 12.0 : 16.0,
        vertical: 16.0,
      );
    }

    final double contentHPadding = isDesktop
        ? 36.0
        : (isLaptop ? 26.0 : (isTablet ? 26.0 : (isNarrowMobile ? 12.0 : 16.0)));
    final double contentVPadding = isDesktop
        ? 32.0
        : (isLaptop ? 24.0 : (isTablet ? 22.0 : 16.0));

    final double titleFontSize = isDesktop
        ? 38.0
        : (isLaptop ? 31.0 : (isTablet ? 28.0 : (isNarrowMobile ? 21.0 : 23.0)));

    List<Widget> buildContentList() {
      return [
        Text(
          " · CUSTOMIZABLE",
          style: AppTheme.sansBody(
            fontSize: isMobile ? 9.5 : 10,
            color: goldColor,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
        SizedBox(height: isMobile ? 6 : 8),
        Text(
          item.name,
          style: GoogleFonts.italiana(
            fontSize: titleFontSize,
            color: inkColor,
            height: 1.15,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: isMobile ? 8 : 10),
        Text(
          item.description,
          style: AppTheme.sansBody(
            fontSize: isMobile ? 12.0 : 13.0,
            color: inkColor.withValues(alpha: 0.7),
            height: 1.55,
          ),
        ),
        SizedBox(height: isMobile ? 14 : 18),
        ExperiencePriceCard(
          item: item,
          hasDiscount: _selectedPackage.discountPrice != null && _selectedPackage.price > _selectedPackage.effectivePrice,
          discountPct: _selectedPackage.discountPrice != null && _selectedPackage.price > _selectedPackage.effectivePrice
              ? ((1 - _selectedPackage.effectivePrice / _selectedPackage.price) * 100).round()
              : 0,
          savedAmount: _selectedPackage.price - _selectedPackage.effectivePrice,
          isCompact: isMobile,
        ),
        SizedBox(height: isMobile ? 14 : 18),

        // Dynamic Package Selector (Basic, Premium, Luxury)
        Text(
          "CHOOSE PACKAGE TIER",
          style: AppTheme.sansBody(
            fontSize: isMobile ? 8.5 : 9.0,
            color: inkColor,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.3,
          ),
        ),
        SizedBox(height: isMobile ? 6 : 8),
        Row(
          children: item.dynamicPackages.map((pkg) {
            final isSelected = _selectedPackage.id == pkg.id;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: isMobile ? (isNarrowMobile ? 2.0 : 3.0) : 4.0),
                child: InkWell(
                  onTap: () => setState(() => _selectedPackage = pkg),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: isMobile ? 8.0 : 10.0,
                      horizontal: isMobile ? 4.0 : 8.0,
                    ),
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
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.sansBody(
                            fontSize: isMobile ? (isNarrowMobile ? 8.5 : 9.0) : 10.0,
                            fontWeight: FontWeight.w800,
                            color: isSelected ? goldColor : inkColor.withValues(alpha: 0.7),
                            letterSpacing: isNarrowMobile ? 0.5 : 1.0,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "₹${pkg.effectivePrice.toStringAsFixed(0)}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.sansBody(
                            fontSize: isMobile ? (isNarrowMobile ? 10.5 : 11.0) : 12.0,
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
        SizedBox(height: isMobile ? 10 : 14),

        // Selected package inclusions bullet list
        Container(
          padding: EdgeInsets.all(isMobile ? 10 : 12),
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
                  Icon(Icons.stars_rounded, size: isMobile ? 13 : 14, color: goldColor),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      "${_selectedPackage.name} includes:",
                      style: AppTheme.sansBody(
                        fontSize: isMobile ? 10.5 : 11,
                        color: goldColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
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
                      Text("• ", style: TextStyle(color: goldColor, fontSize: isMobile ? 11 : 12)),
                      Expanded(
                        child: Text(
                          f,
                          style: AppTheme.sansBody(
                            fontSize: isMobile ? 10.5 : 11,
                            color: inkColor.withValues(alpha: 0.8),
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
        SizedBox(height: isMobile ? 14 : 18),

        if (item.colors.isNotEmpty) ...[
          Text(
            "COLOR STORY",
            style: AppTheme.sansBody(
              fontSize: isMobile ? 8.5 : 9,
              color: inkColor,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.3,
            ),
          ),
          const SizedBox(height: 6),
          ModalDropdown(
            value: _selectedColor,
            items: item.colors,
            onChanged: (v) => setState(() => _selectedColor = v),
          ),
          SizedBox(height: isMobile ? 12 : 16),
        ],
        if (item.themes.isNotEmpty) ...[
          Text(
            "DESIGN MOOD",
            style: AppTheme.sansBody(
              fontSize: isMobile ? 8.5 : 9,
              color: inkColor,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.3,
            ),
          ),
          const SizedBox(height: 6),
          ModalDropdown(
            value: _selectedTheme,
            items: item.themes,
            onChanged: (v) => setState(() => _selectedTheme = v),
          ),
          SizedBox(height: isMobile ? 12 : 16),
        ],
        Text(
          "YOUR NOTE",
          style: AppTheme.sansBody(
            fontSize: isMobile ? 8.5 : 9,
            color: inkColor,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.3,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _notesController,
          maxLines: isMobile ? 2 : 3,
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
        SizedBox(height: isMobile ? 18 : 22),
        _buildActionButtons(cartController, item, paperColor, inkColor, goldColor, isMobile: isMobile),
        const SizedBox(height: 8),
      ];
    }

    Widget bodyContent;
    if (isTwoColumn) {
      bodyContent = Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: isDesktop ? (dialogWidth * 0.48) : (dialogWidth * 0.44),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: ExperienceDetailImage(
                url: item.imageUrl,
                title: item.name,
                categorySlug: item.categorySlug,
                categoryName: item.categoryName,
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: contentHPadding,
                vertical: contentVPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: buildContentList(),
              ),
            ),
          ),
        ],
      );
    } else {
      // Single-column layout for Tablet and Mobile
      bodyContent = SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Experience image spanning 100% width of modal with controlled aspect ratio
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: AspectRatio(
                aspectRatio: isTablet ? (16 / 9) : (16 / 9.5),
                child: ExperienceDetailImage(
                  url: item.imageUrl,
                  title: item.name,
                  categorySlug: item.categorySlug,
                  categoryName: item.categoryName,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: contentHPadding,
                vertical: contentVPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: buildContentList(),
              ),
            ),
          ],
        ),
      );
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: dialogInsetPadding,
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
              bodyContent,
              // Close button at top right
              Positioned(
                top: isMobile ? 12 : 14,
                right: isMobile ? 12 : 14,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: isMobile ? 32 : 36,
                      height: isMobile ? 32 : 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D1915).withValues(alpha: 0.75),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        border: Border.all(
                          color: AppColors.secondaryAccent.withValues(alpha: 0.35),
                          width: 1.2,
                        ),
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: isMobile ? 16 : 18,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(
    CartController cartController,
    Experience item,
    Color paperColor,
    Color inkColor,
    Color goldColor, {
    bool isMobile = false,
  }) {
    return Column(
      children: [
        // Primary CTA: Book This Package
        SizedBox(
          width: double.infinity,
          height: isMobile ? 44 : 48,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              showCustomerBookingDialog(
                context,
                experience: item,
                selectedPackage: _selectedPackage,
              );
            },
            icon: Icon(Icons.calendar_today_outlined, size: isMobile ? 14 : 16, color: const Color(0xFF0D1915)),
            label: Text(
              "BOOK THIS PACKAGE (${_selectedPackage.tier.toUpperCase()})",
              style: AppTheme.sansBody(
                fontSize: isMobile ? 11 : 12,
                color: const Color(0xFF0D1915),
                fontWeight: FontWeight.w800,
                letterSpacing: isMobile ? 0.8 : 1.2,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: goldColor,
              foregroundColor: const Color(0xFF0D1915),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
        SizedBox(height: isMobile ? 8 : 10),
        // Secondary CTA: Add to Selection
        SizedBox(
          width: double.infinity,
          height: isMobile ? 40 : 44,
          child: OutlinedButton.icon(
            onPressed: () {
              final experienceToCart = item.copyWith(
                price: _selectedPackage.price,
                offerPrice: _selectedPackage.effectivePrice,
              );
              cartController.addToCart(
                experienceToCart,
                color: _selectedColor,
                theme: _selectedTheme,
                notes: _notesController.text,
              );
              Navigator.of(context).pop();
              CustomerDrawerHelper.openEventCanvas(context);
              Get.snackbar(
                "Added to Canvas",
                "${item.name} added to your selection.",
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: paperColor,
                colorText: inkColor,
                margin: const EdgeInsets.all(16),
              );
            },
            icon: Icon(Icons.add, size: isMobile ? 14 : 15, color: goldColor),
            label: Text(
              "ADD TO MY SELECTION",
              style: AppTheme.sansBody(
                fontSize: isMobile ? 10.5 : 11,
                color: goldColor,
                fontWeight: FontWeight.w700,
                letterSpacing: isMobile ? 0.8 : 1.1,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: goldColor.withValues(alpha: 0.6), width: 1.2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
        const SizedBox(height: 6),
        TextButton.icon(
          onPressed: () {
            Navigator.of(context).pop();
            Get.toNamed('${AppRoutes.detail}/${item.slug}');
          },
          icon: Icon(Icons.open_in_new_rounded, size: 13, color: goldColor.withValues(alpha: 0.8)),
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
