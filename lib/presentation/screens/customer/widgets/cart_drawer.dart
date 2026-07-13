import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/config/constants.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../controllers/cart_controller.dart';
import '../../../controllers/quotation_controller.dart';
import '../helpers/customer_dialog_helper.dart';

/// Shopping Cart / Selection Drawer overlay for the Customer portal.
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
    const Color drawerBg = Color(0xFF0D1915);
    const Color cardBg = Color(0xFF132219);
    const Color borderColor = Color(0xFF2A3D34);
    const Color goldColor = Color(0xFFC8A96E);
    const Color goldLight = Color(0xFFE8CC8A);
    const Color inkColor = Color(0xFFF5F0E8);
    const Color mutedColor = Color(0xFF7A9088);
    const Color successColor = Color(0xFF52C48A);

    return Drawer(
      width: math.min(440, MediaQuery.of(context).size.width * 0.88),
      backgroundColor: drawerBg,
      child: SafeArea(
        child: Obx(() {
          final items = cartController.rxCartItems;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Premium Header ───────────────────────────────────────
              Container(
                padding: const EdgeInsets.fromLTRB(24, 20, 20, 20),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F1E19),
                  border: Border(
                    bottom: BorderSide(
                      color: goldColor.withValues(alpha: 0.18),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    // Gold accent bar
                    Container(
                      width: 3,
                      height: 44,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [goldLight, goldColor],
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "YOUR EVENT CANVAS",
                            style: AppTheme.sansBody(
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              color: goldColor,
                              letterSpacing: 2.0,
                            ),
                          ),
                          const SizedBox(height: 3),
                          RichText(
                            text: TextSpan(
                              style: GoogleFonts.italiana(
                                fontSize: 26,
                                color: inkColor,
                                height: 1.1,
                              ),
                              children: [
                                const TextSpan(text: "Selection "),
                                TextSpan(
                                  text: "(${items.length})",
                                  style: GoogleFonts.italiana(
                                    color: goldColor,
                                    fontSize: 22,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Close button
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF1A2D26),
                          border: Border.all(
                            color: borderColor,
                            width: 1.2,
                          ),
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 16,
                          color: inkColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ─── Cart Items ───────────────────────────────────────────
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
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final customization = [item.color, item.theme]
                          .where((e) => e.isNotEmpty)
                          .join(' · ');

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: borderColor,
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.18),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Thumbnail with gold gradient border
                            Container(
                              width: 70,
                              height: 70,
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                gradient: const LinearGradient(
                                  colors: [goldColor, Color(0xFF8A6A30)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: item.experience.imageUrl.startsWith('assets/')
                                    ? Image.asset(
                                        item.experience.imageUrl,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.network(
                                        item.experience.imageUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          color: const Color(0xFF1A2D26),
                                          child: const Icon(
                                            Icons.celebration_outlined,
                                            size: 22,
                                            color: mutedColor,
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            // Item details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.experience.name,
                                    style: GoogleFonts.italiana(
                                      fontSize: 17,
                                      color: inkColor,
                                      height: 1.2,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (customization.isNotEmpty) ...[
                                    const SizedBox(height: 3),
                                    Text(
                                      customization,
                                      style: AppTheme.sansBody(
                                        fontSize: 10.5,
                                        color: mutedColor,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 8),
                                  Text(
                                    AppFormatters.formatCurrency(
                                      item.experience.effectivePrice * item.quantity,
                                    ),
                                    style: AppTheme.sansBody(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: goldLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Controls column
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                // Delete button
                                GestureDetector(
                                  onTap: () => cartController.removeFromCart(index),
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.redAccent.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.redAccent.withValues(alpha: 0.25),
                                        width: 1,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.delete_outline_rounded,
                                      size: 15,
                                      color: Colors.redAccent,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // Quantity pill
                                Container(
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1A2D26),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: goldColor.withValues(alpha: 0.35),
                                      width: 1.2,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      GestureDetector(
                                        onTap: () => cartController.changeQuantity(index, -1),
                                        behavior: HitTestBehavior.opaque,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 9),
                                          child: Icon(
                                            Icons.remove_rounded,
                                            size: 13,
                                            color: inkColor.withValues(alpha: 0.8),
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '${item.quantity}',
                                        style: AppTheme.sansBody(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: goldLight,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () => cartController.changeQuantity(index, 1),
                                        behavior: HitTestBehavior.opaque,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 9),
                                          child: Icon(
                                            Icons.add_rounded,
                                            size: 13,
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
                    },
                  ),
                ),

              // ─── Summary & CTA ────────────────────────────────────────
              if (items.isNotEmpty)
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF0A1510),
                    border: Border(
                      top: BorderSide(color: Color(0xFF2A3D34), width: 1),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                  child: Column(
                    children: [
                      // Summary rows
                      _summaryRow(
                        "Subtotal",
                        AppFormatters.formatCurrency(cartController.subtotal),
                        inkColor: inkColor,
                        mutedColor: mutedColor,
                      ),
                      _summaryRow(
                        "Celebration discount",
                        cartController.volumeDiscount > 0
                            ? "- ${AppFormatters.formatCurrency(cartController.volumeDiscount)}"
                            : "Unlock at ₹50k",
                        inkColor: cartController.volumeDiscount > 0
                            ? successColor
                            : mutedColor,
                        mutedColor: mutedColor,
                      ),
                      _summaryRow(
                        "Delivery Charge",
                        AppFormatters.formatCurrency(cartController.deliveryCharge),
                        inkColor: inkColor,
                        mutedColor: mutedColor,
                      ),
                      _summaryRow(
                        "GST (${AppConstants.gstPercent.toStringAsFixed(0)}%)",
                        AppFormatters.formatCurrency(cartController.gstAmount),
                        inkColor: inkColor,
                        mutedColor: mutedColor,
                      ),
                      if (AppConstants.enableClientFeeWaiver)
                        _summaryRow(
                          "Extra Discount!!",
                          "- ${AppFormatters.formatCurrency(cartController.clientWaiverDiscount)}",
                          inkColor: successColor,
                          mutedColor: mutedColor,
                        ),

                      const SizedBox(height: 14),

                      // Estimated Total highlight card
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              goldColor.withValues(alpha: 0.14),
                              goldColor.withValues(alpha: 0.06),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: goldColor.withValues(alpha: 0.35),
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "ESTIMATED TOTAL",
                                  style: AppTheme.sansBody(
                                    fontSize: 9,
                                    letterSpacing: 1.8,
                                    fontWeight: FontWeight.bold,
                                    color: goldColor,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "Incl. taxes & charges",
                                  style: AppTheme.sansBody(
                                    fontSize: 10,
                                    color: mutedColor,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              AppFormatters.formatCurrency(cartController.grandTotal),
                              style: GoogleFonts.italiana(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: goldLight,
                                height: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // CTA Button
                      SizedBox(
                        width: double.infinity,
                        child: CustomButton(
                          text: "Create my quotation",
                          onPressed: () {
                            Navigator.of(context).pop();
                            CustomerDialogHelper.openQuoteDialog(
                              context,
                              quoteController,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _summaryRow(
    String label,
    String value, {
    required Color inkColor,
    required Color mutedColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTheme.sansBody(
              fontSize: 12,
              color: mutedColor,
            ),
          ),
          Text(
            value,
            style: AppTheme.sansBody(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: inkColor,
            ),
          ),
        ],
      ),
    );
  }
}
