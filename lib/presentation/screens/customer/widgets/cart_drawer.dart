import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/config/constants.dart';
import '../../../../core/utils/formatters.dart';
import '../../../controllers/cart_controller.dart';
import '../../../controllers/quotation_controller.dart';
import '../helpers/customer_dialog_helper.dart';

/// Shopping Cart / Selection Drawer overlay for the Customer portal.
/// Exactly matches the target design reference with compact vertical flow,
/// rich item cards, integrated price breakup, special offer teaser, 4 benefit badges,
/// and full-width gold quotation CTA.
class CartDrawer extends StatelessWidget {
  final CartController cartController;
  final QuotationController quoteController;

  const CartDrawer({
    super.key,
    required this.cartController,
    required this.quoteController,
  });

  @override
  Widget build(BuildContext context) {
    const Color drawerBg = Color(0xFF091410);
    const Color cardBg = Color(0xFF0F1E19);
    const Color borderColor = Color(0xFF22362E);
    const Color goldColor = Color(0xFFC8A96E);
    const Color goldLight = Color(0xFFE8CC8A);
    const Color inkColor = Color(0xFFF5F0E8);
    const Color mutedColor = Color(0xFF7A9088);
    const Color successColor = Color(0xFF52C48A);

    final screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth >= 1200;
    final bool isLaptop = screenWidth >= 1024 && screenWidth < 1200;
    final bool isTablet = screenWidth >= 600 && screenWidth < 1024;
    final bool isMobile = screenWidth < 600;
    final bool isNarrowMobile = screenWidth < 360;

    // Responsive Drawer Width:
    // Desktop: approx 340–380px, website visible behind
    // Laptop: approx 320–350px
    // Tablet: compact right drawer max 340px, website clearly visible behind
    // Mobile: full-width drawer fitting device viewport cleanly
    final double drawerWidth;
    if (isDesktop) {
      drawerWidth = (screenWidth * 0.22).clamp(340.0, 380.0);
    } else if (isLaptop) {
      drawerWidth = (screenWidth * 0.30).clamp(320.0, 350.0);
    } else if (isTablet) {
      drawerWidth = (screenWidth * 0.45).clamp(310.0, 340.0);
    } else {
      drawerWidth = screenWidth;
    }

    final double contentHPadding = isDesktop
        ? 18.0
        : (isLaptop ? 16.0 : (isTablet ? 16.0 : (isNarrowMobile ? 12.0 : 14.0)));

    return Drawer(
      width: drawerWidth,
      backgroundColor: drawerBg,
      elevation: 28,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isMobile ? 0 : 20),
          bottomLeft: Radius.circular(isMobile ? 0 : 20),
        ),
        side: isMobile
            ? BorderSide.none
            : BorderSide(
                color: goldColor.withValues(alpha: 0.42),
                width: 1.4,
              ),
      ),
      child: Stack(
        children: [
          // Background subtle luminous golden curves at bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 180,
            child: IgnorePointer(
              child: CustomPaint(
                painter: _DrawerGoldRibbonPainter(goldColor: goldColor),
              ),
            ),
          ),
          SafeArea(
            child: Obx(() {
              final items = cartController.rxCartItems;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── 1. Header (Vertical Gold Line, Eyebrow, Title, Close Button) ───
                  _buildHeader(
                    context,
                    items.length,
                    goldColor,
                    goldLight,
                    inkColor,
                    isMobile: isMobile,
                    isNarrowMobile: isNarrowMobile,
                  ),

                  // ─── 2. Drawer Content Flow ───
                  if (items.isEmpty)
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: goldColor.withValues(alpha: 0.08),
                                border: Border.all(
                                  color: goldColor.withValues(alpha: 0.22),
                                  width: 1.5,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  "✦",
                                  style: TextStyle(
                                    fontSize: 28,
                                    color: goldColor.withValues(alpha: 0.7),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              "Your canvas is open.",
                              style: GoogleFonts.italiana(
                                fontSize: 22,
                                color: inkColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 40),
                              child: Text(
                                "Add signature experiences and we'll craft your quotation as you go.",
                                textAlign: TextAlign.center,
                                style: AppTheme.sansBody(
                                  fontSize: 12,
                                  color: mutedColor,
                                  height: 1.6,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(
                          contentHPadding,
                          isMobile ? 12 : 16,
                          contentHPadding,
                          math.max(24.0, MediaQuery.of(context).padding.bottom + 16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Selected Item Cards (No huge empty space below)
                            for (int i = 0; i < items.length; i++) ...[
                              _buildItemCard(
                                context,
                                items[i],
                                i,
                                cardBg,
                                borderColor,
                                goldColor,
                                goldLight,
                                inkColor,
                                mutedColor,
                                isMobile: isMobile,
                                isNarrowMobile: isNarrowMobile,
                              ),
                              if (i < items.length - 1) const SizedBox(height: 12),
                            ],

                            const SizedBox(height: 14),

                            // ─── 3. Price Breakup Card ───
                            _buildPriceBreakupCard(
                              cardBg,
                              borderColor,
                              goldColor,
                              goldLight,
                              inkColor,
                              mutedColor,
                              successColor,
                              isMobile: isMobile,
                              isNarrowMobile: isNarrowMobile,
                            ),

                            const SizedBox(height: 14),

                            // ─── 4. Special Offer Teaser Card ───
                            _buildSpecialOfferCard(
                              cardBg,
                              borderColor,
                              goldColor,
                              goldLight,
                              mutedColor,
                              isMobile: isMobile,
                              isNarrowMobile: isNarrowMobile,
                            ),

                            const SizedBox(height: 14),

                            // ─── 5. Four Benefit Cards Row / 2x2 Grid ───
                            _buildBenefitCards(goldColor),

                            const SizedBox(height: 18),

                            // ─── 6. Create My Quotation CTA Button ───
                            _buildCreateQuotationButton(
                              context,
                              goldColor,
                              isCompact: isNarrowMobile,
                            ),

                            const SizedBox(height: 12),

                            // ─── 7. Security Message ───
                            _buildSecurityMessage(
                              goldColor,
                              mutedColor,
                              isCompact: isNarrowMobile,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // 1. HEADER (EXACT FIRST IMAGE MATCH)
  // ============================================================================
  Widget _buildHeader(
    BuildContext context,
    int count,
    Color goldColor,
    Color goldLight,
    Color inkColor, {
    bool isMobile = false,
    bool isNarrowMobile = false,
  }) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        isNarrowMobile ? 14 : (isMobile ? 16 : 20),
        isNarrowMobile ? 14 : 18,
        isNarrowMobile ? 12 : 18,
        isNarrowMobile ? 14 : 18,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF0C1914),
        border: Border(
          bottom: BorderSide(
            color: goldColor.withValues(alpha: 0.16),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Vertical gold accent bar
          Container(
            width: 3.5,
            height: isNarrowMobile ? 34 : 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [goldLight, goldColor],
              ),
            ),
          ),
          SizedBox(width: isNarrowMobile ? 10 : 14),
          // Eyebrow and Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "YOUR EVENT CANVAS",
                  style: AppTheme.sansBody(
                    fontSize: isNarrowMobile ? 8.5 : 9.5,
                    fontWeight: FontWeight.bold,
                    color: goldColor,
                    letterSpacing: isNarrowMobile ? 1.4 : 2.0,
                  ),
                ),
                const SizedBox(height: 2),
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.italiana(
                      fontSize: isNarrowMobile ? 20 : (isMobile ? 22 : 25),
                      color: inkColor,
                      height: 1.1,
                    ),
                    children: [
                      const TextSpan(text: "Selection "),
                      TextSpan(
                        text: "($count)",
                        style: GoogleFonts.italiana(
                          color: goldColor,
                          fontWeight: FontWeight.bold,
                          fontSize: isNarrowMobile ? 18 : (isMobile ? 20 : 22),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Circular close button
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: isNarrowMobile ? 32 : 36,
              height: isNarrowMobile ? 32 : 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF14241D),
                border: Border.all(
                  color: goldColor.withValues(alpha: 0.35),
                  width: 1.1,
                ),
              ),
              child: Icon(
                Icons.close_rounded,
                size: isNarrowMobile ? 15 : 17,
                color: const Color(0xFFE8E5DD),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // 2. SELECTED ITEM CARD (EXACT FIRST IMAGE MATCH)
  // ============================================================================
  Widget _buildItemCard(
    BuildContext context,
    dynamic item,
    int index,
    Color cardBg,
    Color borderColor,
    Color goldColor,
    Color goldLight,
    Color inkColor,
    Color mutedColor, {
    bool isMobile = false,
    bool isNarrowMobile = false,
  }) {
    final customization = [item.color, item.theme]
        .where((e) => e != null && e.toString().trim().isNotEmpty)
        .join(' · ');

    final subtitle = customization.isNotEmpty
        ? customization
        : (item.experience.categoryName.isNotEmpty ? item.experience.categoryName : "Custom Event Styling");

    final double thumbW = isNarrowMobile ? 74.0 : (isMobile ? 82.0 : 92.0);
    final double thumbH = isNarrowMobile ? 62.0 : (isMobile ? 68.0 : 74.0);

    return Container(
      padding: EdgeInsets.all(isNarrowMobile ? 10 : (isMobile ? 11 : 12)),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Image Thumbnail (Fixed Aspect Ratio, Object-Fit Cover)
          Container(
            width: thumbW,
            height: thumbH,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: goldColor.withValues(alpha: 0.28),
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: item.experience.imageUrl.startsWith('assets/')
                  ? Image.asset(
                      item.experience.imageUrl,
                      fit: BoxFit.cover,
                    )
                  : Image.network(
                      item.experience.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFF162821),
                        child: Icon(
                          Icons.celebration_outlined,
                          size: 24,
                          color: goldColor.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
            ),
          ),
          SizedBox(width: isNarrowMobile ? 8 : 12),
          // Middle Details: Title, Category/Theme, Price
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.experience.name,
                  style: GoogleFonts.italiana(
                    fontSize: isNarrowMobile ? 14.5 : (isMobile ? 15.5 : 16.0),
                    fontWeight: FontWeight.bold,
                    color: inkColor,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: AppTheme.sansBody(
                    fontSize: isNarrowMobile ? 9.5 : 10.5,
                    color: mutedColor,
                    letterSpacing: 0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: isNarrowMobile ? 6 : 10),
                Text(
                  AppFormatters.formatCurrency(
                    item.experience.effectivePrice * item.quantity,
                  ),
                  style: GoogleFonts.montserrat(
                    fontSize: isNarrowMobile ? 14.0 : 15.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: isNarrowMobile ? 6 : 8),
          // Right Controls: Delete (Top) & Quantity (Bottom)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Delete Button (Top Right)
              GestureDetector(
                onTap: () => cartController.removeFromCart(index),
                child: Container(
                  padding: EdgeInsets.all(isNarrowMobile ? 5 : 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF261414),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.redAccent.withValues(alpha: 0.28),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.delete_outline_rounded,
                    size: isNarrowMobile ? 14 : 15,
                    color: const Color(0xFFE57373),
                  ),
                ),
              ),
              SizedBox(height: isNarrowMobile ? 10 : 14),
              // Quantity Control Pill (Bottom Right: [- 1 +])
              Container(
                height: isNarrowMobile ? 26 : 29,
                decoration: BoxDecoration(
                  color: const Color(0xFF162720),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: goldColor.withValues(alpha: 0.35),
                    width: 1.1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () => cartController.changeQuantity(index, -1),
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: isNarrowMobile ? 6 : 8),
                        child: Icon(
                          Icons.remove_rounded,
                          size: isNarrowMobile ? 12 : 13,
                          color: inkColor.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                    Text(
                      '${item.quantity}',
                      style: AppTheme.sansBody(
                        fontSize: isNarrowMobile ? 11 : 12,
                        fontWeight: FontWeight.bold,
                        color: goldLight,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => cartController.changeQuantity(index, 1),
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: isNarrowMobile ? 6 : 8),
                        child: Icon(
                          Icons.add_rounded,
                          size: isNarrowMobile ? 12 : 13,
                          color: inkColor.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // 3. PRICE BREAKUP CARD (EXACT FIRST IMAGE MATCH)
  // ============================================================================
  Widget _buildPriceBreakupCard(
    Color cardBg,
    Color borderColor,
    Color goldColor,
    Color goldLight,
    Color inkColor,
    Color mutedColor,
    Color successColor, {
    bool isMobile = false,
    bool isNarrowMobile = false,
  }) {
    return Container(
      padding: EdgeInsets.all(isNarrowMobile ? 12 : (isMobile ? 14 : 16)),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Title with Icon
          Row(
            children: [
              Icon(
                Icons.groups_outlined,
                size: isNarrowMobile ? 15 : 16,
                color: goldLight,
              ),
              const SizedBox(width: 8),
              Text(
                "PRICE BREAKUP",
                style: AppTheme.sansBody(
                  fontSize: isNarrowMobile ? 9.5 : 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.8,
                  color: goldColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Breakdown Rows with Individual Category Icons
          _breakupRow(
            icon: Icons.layers_outlined,
            label: "Subtotal",
            value: AppFormatters.formatCurrency(cartController.subtotal),
            valueColor: Colors.white,
            mutedColor: mutedColor,
            goldColor: goldColor,
            isCompact: isNarrowMobile,
          ),
          _breakupRow(
            icon: Icons.card_giftcard_outlined,
            label: "Celebration discount",
            value: cartController.volumeDiscount > 0
                ? "- ${AppFormatters.formatCurrency(cartController.volumeDiscount)}"
                : "Unlock at ₹50k",
            valueColor: cartController.volumeDiscount > 0 ? successColor : mutedColor,
            mutedColor: mutedColor,
            goldColor: goldColor,
            isCompact: isNarrowMobile,
          ),
          if (cartController.deliveryCharge > 0)
            _breakupRow(
              icon: Icons.local_shipping_outlined,
              label: "Delivery Charge",
              value: AppFormatters.formatCurrency(cartController.deliveryCharge),
              valueColor: Colors.white,
              mutedColor: mutedColor,
              goldColor: goldColor,
              isCompact: isNarrowMobile,
            ),
          _breakupRow(
            icon: Icons.percent_rounded,
            label: "GST (${AppConstants.gstPercent.toStringAsFixed(0)}%)",
            value: AppFormatters.formatCurrency(cartController.gstAmount),
            valueColor: Colors.white,
            mutedColor: mutedColor,
            goldColor: goldColor,
            isCompact: isNarrowMobile,
          ),
          if (AppConstants.enableClientFeeWaiver)
            _breakupRow(
              icon: Icons.local_offer_outlined,
              label: "Extra Discount!!",
              value: "- ${AppFormatters.formatCurrency(cartController.clientWaiverDiscount)}",
              valueColor: successColor,
              mutedColor: mutedColor,
              goldColor: goldColor,
              isCompact: isNarrowMobile,
            ),

          SizedBox(height: isNarrowMobile ? 10 : 14),

          // Highlighted Inner Container: ESTIMATED TOTAL
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isNarrowMobile ? 12 : 16,
              vertical: isNarrowMobile ? 10 : 13,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF14241C),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: goldColor.withValues(alpha: 0.38),
                width: 1.2,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "ESTIMATED TOTAL",
                        style: AppTheme.sansBody(
                          fontSize: isNarrowMobile ? 8.5 : 9.5,
                          letterSpacing: isNarrowMobile ? 1.2 : 1.8,
                          fontWeight: FontWeight.bold,
                          color: goldColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Incl. taxes & charges",
                        style: AppTheme.sansBody(
                          fontSize: isNarrowMobile ? 9.0 : 10.0,
                          color: mutedColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  AppFormatters.formatCurrency(cartController.grandTotal),
                  style: GoogleFonts.montserrat(
                    fontSize: isNarrowMobile ? 17.5 : (isMobile ? 19.0 : 21.0),
                    fontWeight: FontWeight.bold,
                    color: goldLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _breakupRow({
    required IconData icon,
    required String label,
    required String value,
    required Color valueColor,
    required Color mutedColor,
    required Color goldColor,
    bool isCompact = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isCompact ? 3.5 : 4.5),
      child: Row(
        children: [
          Icon(icon, size: isCompact ? 13 : 14, color: goldColor.withValues(alpha: 0.7)),
          SizedBox(width: isCompact ? 6 : 8),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.sansBody(
                fontSize: isCompact ? 10.5 : 11.5,
                color: mutedColor,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: AppTheme.sansBody(
              fontSize: isCompact ? 11.0 : 12.0,
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // 4. SPECIAL OFFER TEASER CARD (EXACT FIRST IMAGE MATCH)
  // ============================================================================
  Widget _buildSpecialOfferCard(
    Color cardBg,
    Color borderColor,
    Color goldColor,
    Color goldLight,
    Color mutedColor, {
    bool isMobile = false,
    bool isNarrowMobile = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isNarrowMobile ? 10 : 14,
        vertical: isNarrowMobile ? 10 : 13,
      ),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1.0),
      ),
      child: Row(
        children: [
          Container(
            width: isNarrowMobile ? 30 : 34,
            height: isNarrowMobile ? 30 : 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: goldColor.withValues(alpha: 0.12),
              border: Border.all(
                color: goldColor.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.local_offer_outlined,
              size: isNarrowMobile ? 14 : 16,
              color: goldLight,
            ),
          ),
          SizedBox(width: isNarrowMobile ? 8 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Add more items to unlock special offers!",
                  style: AppTheme.sansBody(
                    fontSize: isNarrowMobile ? 10.5 : 11.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Reach ₹50,000 to get an exclusive celebration discount.",
                  style: AppTheme.sansBody(
                    fontSize: isNarrowMobile ? 9.0 : 10.0,
                    color: mutedColor,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            size: isNarrowMobile ? 18 : 20,
            color: Colors.white54,
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // 5. FOUR BENEFIT CARDS (EXACT FIRST IMAGE MATCH)
  // ============================================================================
  Widget _buildBenefitCards(Color goldColor) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        // On Desktop / Laptop with width >= 335, 4 cards fit cleanly in a row
        if (availableWidth >= 335) {
          return Row(
            children: [
              _benefitCard(
                icon: Icons.shield_outlined,
                title: "Secure & Safe\nQuotation",
                goldColor: goldColor,
                isCompact: true,
              ),
              const SizedBox(width: 6),
              _benefitCard(
                icon: Icons.lock_clock_outlined,
                title: "Instant\nPrice Updates",
                goldColor: goldColor,
                isCompact: true,
              ),
              const SizedBox(width: 6),
              _benefitCard(
                icon: Icons.bookmark_border_rounded,
                title: "Save for\nLater",
                goldColor: goldColor,
                isCompact: true,
              ),
              const SizedBox(width: 6),
              _benefitCard(
                icon: Icons.people_outline_rounded,
                title: "Share with\nFamily / Team",
                goldColor: goldColor,
                isCompact: true,
              ),
            ],
          );
        }

        // On Tablet and Mobile (< 335), render a 2x2 grid
        if (availableWidth >= 230) {
          return Column(
            children: [
              Row(
                children: [
                  _benefitCard(
                    icon: Icons.shield_outlined,
                    title: "Secure & Safe\nQuotation",
                    goldColor: goldColor,
                  ),
                  const SizedBox(width: 8),
                  _benefitCard(
                    icon: Icons.lock_clock_outlined,
                    title: "Instant\nPrice Updates",
                    goldColor: goldColor,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _benefitCard(
                    icon: Icons.bookmark_border_rounded,
                    title: "Save for\nLater",
                    goldColor: goldColor,
                  ),
                  const SizedBox(width: 8),
                  _benefitCard(
                    icon: Icons.people_outline_rounded,
                    title: "Share with\nFamily / Team",
                    goldColor: goldColor,
                  ),
                ],
              ),
            ],
          );
        }

        // Fallback for extremely narrow viewports (< 230)
        return Column(
          children: [
            Row(children: [_benefitCard(icon: Icons.shield_outlined, title: "Secure & Safe Quotation", goldColor: goldColor)]),
            const SizedBox(height: 6),
            Row(children: [_benefitCard(icon: Icons.lock_clock_outlined, title: "Instant Price Updates", goldColor: goldColor)]),
            const SizedBox(height: 6),
            Row(children: [_benefitCard(icon: Icons.bookmark_border_rounded, title: "Save for Later", goldColor: goldColor)]),
            const SizedBox(height: 6),
            Row(children: [_benefitCard(icon: Icons.people_outline_rounded, title: "Share with Family / Team", goldColor: goldColor)]),
          ],
        );
      },
    );
  }

  Widget _benefitCard({
    required IconData icon,
    required String title,
    required Color goldColor,
    bool isCompact = false,
  }) {
    return Expanded(
      child: Container(
        height: isCompact ? 72 : 76,
        padding: EdgeInsets.symmetric(horizontal: isCompact ? 2 : 4, vertical: isCompact ? 6 : 8),
        decoration: BoxDecoration(
          color: const Color(0xFF0F1E19),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF22362E), width: 1.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: isCompact ? 22 : 25,
              height: isCompact ? 22 : 25,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF182A22),
                border: Border.all(
                  color: goldColor.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Icon(icon, size: isCompact ? 11 : 13, color: goldColor),
            ),
            SizedBox(height: isCompact ? 4 : 6),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTheme.sansBody(
                fontSize: isCompact ? 8.5 : 9.5,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
                height: 1.15,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // 6. CREATE MY QUOTATION BUTTON (EXACT FIRST IMAGE MATCH)
  // ============================================================================
  Widget _buildCreateQuotationButton(
    BuildContext context,
    Color goldColor, {
    bool isCompact = false,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
        CustomerDialogHelper.openQuoteDialog(
          context,
          quoteController,
        );
      },
      child: Container(
        height: isCompact ? 44 : 48,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFE8CC8A), Color(0xFFC8A96E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: goldColor.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: isCompact ? 12 : 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description_outlined,
              size: isCompact ? 16 : 18,
              color: const Color(0xFF0D1915),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                "CREATE MY QUOTATION",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.sansBody(
                  fontSize: isCompact ? 11 : 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: isCompact ? 0.8 : 1.5,
                  color: const Color(0xFF0D1915),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_rounded,
              size: isCompact ? 14 : 16,
              color: const Color(0xFF0D1915),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // 7. SECURITY MESSAGE (EXACT FIRST IMAGE MATCH)
  // ============================================================================
  Widget _buildSecurityMessage(
    Color goldColor,
    Color mutedColor, {
    bool isCompact = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.shield_outlined,
          size: isCompact ? 12 : 13,
          color: goldColor.withValues(alpha: 0.8),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            "Your information is secure with us.",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.sansBody(
              fontSize: isCompact ? 9.5 : 10.5,
              color: mutedColor,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Decorative Golden Ribbon Curves Painter ──────────────────────────────────
class _DrawerGoldRibbonPainter extends CustomPainter {
  final Color goldColor;

  const _DrawerGoldRibbonPainter({required this.goldColor});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Broad soft golden glow wave
    final glowPaint = Paint()
      ..color = goldColor.withValues(alpha: 0.12)
      ..strokeWidth = 14.0
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);

    final glowPath = Path()
      ..moveTo(0, h * 0.92)
      ..cubicTo(w * 0.32, h * 0.22, w * 0.68, h * 0.82, w, h * 0.12);
    canvas.drawPath(glowPath, glowPaint);

    // 2. Primary crisp gold ribbon
    final p1 = Paint()
      ..color = goldColor.withValues(alpha: 0.38)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;

    final path1 = Path()
      ..moveTo(0, h * 0.92)
      ..cubicTo(w * 0.32, h * 0.22, w * 0.68, h * 0.82, w, h * 0.12);
    canvas.drawPath(path1, p1);

    // 3. Secondary flowing ribbon
    final p2 = Paint()
      ..color = goldColor.withValues(alpha: 0.22)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final path2 = Path()
      ..moveTo(w * 0.08, h * 0.98)
      ..cubicTo(w * 0.38, h * 0.32, w * 0.74, h * 0.86, w, h * 0.24);
    canvas.drawPath(path2, p2);

    // 4. Tertiary delicate ribbon
    final p3 = Paint()
      ..color = goldColor.withValues(alpha: 0.14)
      ..strokeWidth = 0.9
      ..style = PaintingStyle.stroke;

    final path3 = Path()
      ..moveTo(w * 0.18, h * 1.0)
      ..cubicTo(w * 0.46, h * 0.44, w * 0.80, h * 0.90, w, h * 0.36);
    canvas.drawPath(path3, p3);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
