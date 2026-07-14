import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/config/app_theme.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/utils/formatters.dart';
import '../../../../controllers/admin_controller.dart';

/// Renders quotation items table or cards with interactive quantity and pricing updates.
class EditorItemsListSection extends StatelessWidget {
  final AdminController controller;
  final bool isFinLocked;
  final VoidCallback onAddButtonPressed;

  const EditorItemsListSection({
    super.key,
    required this.controller,
    required this.isFinLocked,
    required this.onAddButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final paperColor = isDark ? AppColors.darkPaper : AppColors.lightPaper;
    final inkColor = isDark ? AppColors.darkInk : AppColors.lightInk;
    final lineColor = isDark ? AppColors.darkLine : AppColors.lightLine;
    final goldColor = isDark ? AppColors.darkGold : AppColors.lightGold;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "LINE ITEMS",
              style: AppTheme.sansBody(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: goldColor,
                letterSpacing: 1.5,
              ),
            ),
            TextButton.icon(
              icon: const Icon(Icons.add, size: 18),
              label: const Text("Add Decoration Item"),
              style: TextButton.styleFrom(foregroundColor: goldColor),
              onPressed: isFinLocked ? null : onAddButtonPressed,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Obx(() {
          final items = controller.rxEditorItems;
          if (items.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border.all(color: lineColor),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(child: Text("No items added. Add items from the catalog.")),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 500;
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final qtyCtrl = TextEditingController(text: item.quantity.toString());
                  final priceCtrl = TextEditingController(text: item.unitPrice.toStringAsFixed(0));

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: paperColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: lineColor),
                    ),
                    child: isDesktop
                        ? Row(
                            children: [
                              Expanded(
                                flex: 4,
                                child: Text(
                                  item.name,
                                  style: AppTheme.sansBody(fontSize: 14, color: inkColor, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  controller: qtyCtrl,
                                  enabled: !isFinLocked,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: "QTY",
                                    labelStyle: AppTheme.sansBody(fontSize: 10, color: goldColor),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  ),
                                  onChanged: (val) {
                                    final qty = int.tryParse(val) ?? 1;
                                    controller.updateItemQuantity(item.experienceId, qty);
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  controller: priceCtrl,
                                  enabled: !isFinLocked,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  decoration: InputDecoration(
                                    labelText: "PRICE (₹)",
                                    labelStyle: AppTheme.sansBody(fontSize: 10, color: goldColor),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  ),
                                  onChanged: (val) {
                                    final price = double.tryParse(val) ?? 0.0;
                                    controller.updateItemUnitPrice(item.experienceId, price);
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                AppFormatters.formatCurrency(item.quantity * item.unitPrice),
                                style: AppTheme.sansBody(fontSize: 13, fontWeight: FontWeight.bold, color: inkColor),
                              ),
                              const SizedBox(width: 12),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                onPressed: isFinLocked ? null : () => controller.removeEditorItem(item.experienceId),
                              ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: AppTheme.sansBody(fontSize: 14, color: inkColor, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: qtyCtrl,
                                      enabled: !isFinLocked,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        labelText: "QTY",
                                        labelStyle: AppTheme.sansBody(fontSize: 10, color: goldColor),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                      ),
                                      onChanged: (val) {
                                        final qty = int.tryParse(val) ?? 1;
                                        controller.updateItemQuantity(item.experienceId, qty);
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: TextFormField(
                                      controller: priceCtrl,
                                      enabled: !isFinLocked,
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      decoration: InputDecoration(
                                        labelText: "PRICE (₹)",
                                        labelStyle: AppTheme.sansBody(fontSize: 10, color: goldColor),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                      ),
                                      onChanged: (val) {
                                        final price = double.tryParse(val) ?? 0.0;
                                        controller.updateItemUnitPrice(item.experienceId, price);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Total: ${AppFormatters.formatCurrency(item.quantity * item.unitPrice)}",
                                    style: AppTheme.sansBody(fontSize: 13, fontWeight: FontWeight.bold, color: inkColor),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                    onPressed: isFinLocked ? null : () => controller.removeEditorItem(item.experienceId),
                                  ),
                                ],
                              ),
                            ],
                          ),
                  );
                },
              );
            },
          );
        }),
      ],
    );
  }
}
