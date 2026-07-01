import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

  /// Creates a [CartDrawer] connected to [cartController] and [quoteController].
  const CartDrawer({
    super.key,
    required this.cartController,
    required this.quoteController,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      width: math.min(480, MediaQuery.of(context).size.width * 0.85),
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
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        Text(
                          "Selection (${items.length})",
                          style: AppTheme.serifHeader(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
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
                              color:
                                  isDark
                                      ? AppTheme.darkGold
                                      : AppTheme.lightGold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Your canvas is open.",
                            style: AppTheme.serifHeader(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Add signature experiences and we'll calculate charges as you go.",
                            textAlign: TextAlign.center,
                            style: AppTheme.sansBody(
                              fontSize: 12,
                              color:
                                  isDark
                                      ? AppTheme.darkMuted
                                      : AppTheme.lightMuted,
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
                              color:
                                  isDark
                                      ? AppTheme.darkLine
                                      : AppTheme.lightLine,
                            ),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Thumbnail
                            Container(
                              width: 60,
                              height: 60,
                              color: Colors.grey.shade800,
                              child:
                                  item.experience.imageUrl.startsWith('assets/')
                                      ? Image.asset(
                                        item.experience.imageUrl,
                                        fit: BoxFit.cover,
                                      )
                                      : Image.network(
                                        item.experience.imageUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (_, __, ___) => const Icon(
                                              Icons.image,
                                              size: 20,
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
                                    ),
                                  ),
                                  Text(
                                    customization.isEmpty
                                        ? "Customizable"
                                        : customization,
                                    style: AppTheme.sansBody(
                                      fontSize: 10,
                                      color:
                                          isDark
                                              ? AppTheme.darkMuted
                                              : AppTheme.lightMuted,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    AppFormatters.formatCurrency(
                                      item.experience.effectivePrice *
                                          item.quantity,
                                    ),
                                    style: AppTheme.sansBody(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    size: 18,
                                    color: Colors.redAccent,
                                  ),
                                  onPressed:
                                      () =>
                                          cartController.removeFromCart(index),
                                ),
                                // Quantity selector
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap:
                                          () => cartController.changeQuantity(
                                            index,
                                            -1,
                                          ),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color:
                                                isDark
                                                    ? AppTheme.darkLine
                                                    : AppTheme.lightLine,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.remove,
                                          size: 12,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      child: Text(
                                        '${item.quantity}',
                                        style: const TextStyle(fontSize: 11),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap:
                                          () => cartController.changeQuantity(
                                            index,
                                            1,
                                          ),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color:
                                                isDark
                                                    ? AppTheme.darkLine
                                                    : AppTheme.lightLine,
                                          ),
                                        ),
                                        child: const Icon(Icons.add, size: 12),
                                      ),
                                    ),
                                  ],
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
                      ),
                      _summaryRow(
                        "Celebration discount",
                        cartController.volumeDiscount > 0
                            ? "- ${AppFormatters.formatCurrency(cartController.volumeDiscount)}"
                            : "Unlock at ₹50k",
                        color:
                            cartController.volumeDiscount > 0
                                ? Colors.green
                                : Colors.grey,
                      ),
                      _summaryRow(
                        "Delivery Charge",
                        AppFormatters.formatCurrency(
                          cartController.deliveryCharge,
                        ),
                      ),
                      _summaryRow(
                        "GST (${AppConstants.gstPercent.toStringAsFixed(0)}%)",
                        AppFormatters.formatCurrency(cartController.gstAmount),
                      ),
                      if (AppConstants.enableClientFeeWaiver)
                        _summaryRow(
                          "Extra Discount!!",
                          "- ${AppFormatters.formatCurrency(cartController.clientWaiverDiscount)}",
                          color: Colors.green,
                        ),
                      const Divider(height: 16),
                      _summaryRow(
                        "Estimated Total",
                        AppFormatters.formatCurrency(cartController.grandTotal),
                        isBold: true,
                        fontSize: 18,
                      ),
                      const SizedBox(height: 18),
                      CustomButton(
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
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTheme.sansBody(
              fontSize: fontSize,
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
