import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/config/constants.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../controllers/cart_controller.dart';
import '../../../controllers/quotation_controller.dart';
import '../helpers/customer_dialog_helper.dart';

/// Shopping Cart / Selection Drawer overlay for the Customer portal.
class CartDrawer extends StatelessWidget {
  final CartController cartController;
  final QuotationController quoteController;

  /// Creates a [CartDrawer] connected to [cartController] and [quoteController].
  const CartDrawer({
    super.key,
    required this.cartController,
    required this.quoteController,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Resolve dynamic colors based on current theme brightness
    final creamColor = isDark ? AppColors.darkCream : AppColors.lightCream;
    final paperColor = isDark ? AppColors.darkPaper : AppColors.lightPaper;
    final inkColor = isDark ? AppColors.darkInk : AppColors.lightInk;
    final mutedColor = isDark ? AppColors.darkMuted : AppColors.lightMuted;
    final lineColor = isDark ? AppColors.darkLine : AppColors.lightLine;
    final goldColor = isDark ? AppColors.darkGold : AppColors.lightGold;

    return Drawer(
      width: math.min(480, MediaQuery.of(context).size.width * 0.85),
      backgroundColor: creamColor,
      child: SafeArea(
        child: Obx(() {
          final items = cartController.rxCartItems;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drawer Head
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "YOUR EVENT CANVAS",
                          style: AppTheme.sansBody(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: goldColor,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Selection (${items.length})",
                          style: AppTheme.serifHeader(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: inkColor,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: paperColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: lineColor,
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          size: 16,
                          color: inkColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Cart Items List
              if (items.isEmpty)
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "✦",
                            style: AppTheme.serifHeader(
                              fontSize: 34,
                              color: goldColor,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Your canvas is open.",
                            style: AppTheme.serifHeader(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: inkColor,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Add signature experiences and we'll calculate charges as you go.",
                            textAlign: TextAlign.center,
                            style: AppTheme.sansBody(
                              fontSize: 12,
                              color: mutedColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final customization = [
                        item.color,
                        item.theme,
                      ].where((e) => e.isNotEmpty).join(' · ');

                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: lineColor,
                            ),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Thumbnail with rounded corners & shadow/border
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: paperColor,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: lineColor,
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(7),
                                child: item.experience.imageUrl.startsWith('assets/')
                                    ? Image.asset(
                                        item.experience.imageUrl,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.network(
                                        item.experience.imageUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (_, __, ___) => Icon(
                                              Icons.image,
                                              size: 20,
                                              color: mutedColor,
                                            ),
                                      ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.experience.name,
                                    style: AppTheme.serifHeader(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: inkColor,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    customization.isEmpty
                                        ? "Customizable"
                                        : customization,
                                    style: AppTheme.sansBody(
                                      fontSize: 11,
                                      color: mutedColor,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    AppFormatters.formatCurrency(
                                      item.experience.effectivePrice *
                                          item.quantity,
                                    ),
                                    style: AppTheme.sansBody(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: inkColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                // Styled circular Delete Button
                                GestureDetector(
                                  onTap: () => cartController.removeFromCart(index),
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.redAccent.withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.delete_outline_rounded,
                                      size: 16,
                                      color: Colors.redAccent,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                // Styled cohesive Pill-shaped Quantity selector
                                Container(
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: paperColor,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: lineColor,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      GestureDetector(
                                        onTap: () => cartController.changeQuantity(index, -1),
                                        behavior: HitTestBehavior.opaque,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          child: Icon(
                                            Icons.remove_rounded,
                                            size: 12,
                                            color: inkColor,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '${item.quantity}',
                                        style: AppTheme.sansBody(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: inkColor,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () => cartController.changeQuantity(index, 1),
                                        behavior: HitTestBehavior.opaque,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          child: Icon(
                                            Icons.add_rounded,
                                            size: 12,
                                            color: inkColor,
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

              // Totals Summary & Submit
              if (items.isNotEmpty) ...[
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      _summaryRow(
                        "Subtotal",
                        AppFormatters.formatCurrency(cartController.subtotal),
                        labelColor: mutedColor,
                        color: inkColor,
                      ),
                      _summaryRow(
                        "Celebration discount",
                        cartController.volumeDiscount > 0
                            ? "- ${AppFormatters.formatCurrency(cartController.volumeDiscount)}"
                            : "Unlock at ₹50k",
                        labelColor: mutedColor,
                        color:
                            cartController.volumeDiscount > 0
                                ? AppColors.success
                                : mutedColor,
                      ),
                      _summaryRow(
                        "Delivery Charge",
                        AppFormatters.formatCurrency(
                          cartController.deliveryCharge,
                        ),
                        labelColor: mutedColor,
                        color: inkColor,
                      ),
                      _summaryRow(
                        "GST (${AppConstants.gstPercent.toStringAsFixed(0)}%)",
                        AppFormatters.formatCurrency(cartController.gstAmount),
                        labelColor: mutedColor,
                        color: inkColor,
                      ),
                      if (AppConstants.enableClientFeeWaiver)
                        _summaryRow(
                          "Extra Discount!!",
                          "- ${AppFormatters.formatCurrency(cartController.clientWaiverDiscount)}",
                          labelColor: mutedColor,
                          color: AppColors.success,
                        ),
                      const SizedBox(height: 14),
                      // Estimated Total Row highlights inside a container
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: paperColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: lineColor,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Estimated Total",
                              style: AppTheme.sansBody(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: inkColor,
                              ),
                            ),
                            Text(
                              AppFormatters.formatCurrency(cartController.grandTotal),
                              style: GoogleFonts.italiana(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: inkColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: CustomButton(
                          text: "Create my quotation",
                          onPressed: () {
                            // Close drawer and open Quotation dialog
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
            ],
          );
        }),
      ),
    );
  }

  Widget _summaryRow(
    String label,
    String value, {
    bool isBold = false,
    double fontSize = 12,
    Color? color,
    Color? labelColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTheme.sansBody(
              fontSize: fontSize,
              color: labelColor,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: AppTheme.sansBody(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
