import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/config/app_theme.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/utils/formatters.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../../../../../core/widgets/custom_input.dart';
import '../../../../controllers/admin_controller.dart';

/// Renders adjustments fields, live calculation breakdown table, and buttons for draft saving or publishing.
class EditorRightPanel extends StatelessWidget {
  final AdminController controller;
  final TextEditingController discountController;
  final TextEditingController travelController;
  final TextEditingController gstPercentController;
  final bool isFinLocked;
  final bool isPermLocked;
  final VoidCallback onSaveDraftPressed;
  final VoidCallback onPublishPressed;

  const EditorRightPanel({
    super.key,
    required this.controller,
    required this.discountController,
    required this.travelController,
    required this.gstPercentController,
    required this.isFinLocked,
    required this.isPermLocked,
    required this.onSaveDraftPressed,
    required this.onPublishPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inkColor = isDark ? AppColors.darkInk : AppColors.lightInk;
    final goldColor = isDark ? AppColors.darkGold : AppColors.lightGold;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "PRICING ADJUSTMENTS",
          style: AppTheme.sansBody(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: goldColor,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        CustomInput(
          label: "Discount (₹)",
          placeholder: "0",
          controller: discountController,
          keyboardType: TextInputType.number,
          readOnly: isFinLocked,
        ),
        CustomInput(
          label: "Travel (₹)",
          placeholder: "0",
          controller: travelController,
          keyboardType: TextInputType.number,
          readOnly: isFinLocked,
        ),
        CustomInput(
          label: "GST (%)",
          placeholder: "18",
          controller: gstPercentController,
          keyboardType: TextInputType.number,
          readOnly: isFinLocked,
        ),
        const Divider(height: 32),
        Text(
          "LIVE CALCULATION SUMMARY",
          style: AppTheme.sansBody(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: goldColor,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        _buildSummaryRow("Subtotal", controller.editorSubtotal, inkColor),
        _buildSummaryRow("Discount", controller.editorDiscount, Colors.green, isNeg: true),
        _buildSummaryRow("Travel Fee", controller.editorTravel, inkColor),
        Obx(() => _buildStaticRow(
              "GST (${controller.editorGstPercent.value.toStringAsFixed(0)}%)",
              AppFormatters.formatCurrency(controller.editorGstAmount.value),
              inkColor,
            )),
        const Divider(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "GRAND TOTAL",
              style: AppTheme.sansBody(fontSize: 14, fontWeight: FontWeight.bold, color: inkColor),
            ),
            Obx(() => Text(
                  AppFormatters.formatCurrency(controller.editorGrandTotal.value),
                  style: AppTheme.serifHeader(fontSize: 24, fontWeight: FontWeight.bold, color: goldColor),
                )),
          ],
        ),
        const SizedBox(height: 24),
        Obx(() {
          final saving = controller.isSavingDraft.value;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomButton(
                text: "Save Draft Changes",
                isLoading: saving,
                onPressed: saving || isPermLocked ? null : onSaveDraftPressed,
              ),
              const SizedBox(height: 12),
              CustomButton(
                text: "Publish Revised Proposal",
                isLoading: false,
                onPressed: saving || isPermLocked ? null : onPublishPressed,
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildSummaryRow(String title, RxDouble valueRx, Color color, {bool isNeg = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTheme.sansBody(fontSize: 13, color: Colors.grey)),
          Obx(() => Text(
                "${isNeg ? '-' : ''}${AppFormatters.formatCurrency(valueRx.value)}",
                style: AppTheme.sansBody(fontSize: 13, color: color, fontWeight: FontWeight.bold),
              )),
        ],
      ),
    );
  }

  Widget _buildStaticRow(String title, String valStr, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTheme.sansBody(fontSize: 13, color: Colors.grey)),
          Text(
            valStr,
            style: AppTheme.sansBody(fontSize: 13, color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
