import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/config/app_theme.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/quotation.dart';
import '../../../domain/entities/quotation_version.dart';
import '../../utils/version_comparison_helper.dart';

class VersionComparisonSheet extends StatefulWidget {
  final Quotation quotation;

  const VersionComparisonSheet({super.key, required this.quotation});

  static void show(BuildContext context, Quotation quotation) {
    Get.bottomSheet(
      VersionComparisonSheet(quotation: quotation),
      isScrollControlled: true,
      ignoreSafeArea: false,
    );
  }

  @override
  State<VersionComparisonSheet> createState() => _VersionComparisonSheetState();
}

class _VersionComparisonSheetState extends State<VersionComparisonSheet> {
  QuotationVersion? selectedVersion;

  @override
  void initState() {
    super.initState();
    if (widget.quotation.versions.isNotEmpty) {
      selectedVersion = widget.quotation.versions.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? AppColors.darkInk : AppColors.lightInk;
    final Color subtitleColor = isDark ? AppColors.darkMuted : AppColors.lightMuted;
    final Color paperColor = isDark ? AppColors.darkPaper : AppColors.lightPaper;
    final Color lineColor = isDark ? AppColors.darkLine : AppColors.lightLine;

    final versions = widget.quotation.versions;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: paperColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: lineColor, width: 1.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sheet Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "VERSION COMPARISON",
                    style: AppTheme.sansBody(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryAccent,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Proposal Changes",
                    style: AppTheme.serifHeader(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Get.back(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (versions.isEmpty) ...[
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history_rounded, size: 48, color: subtitleColor.withValues(alpha: 0.5)),
                    const SizedBox(height: 16),
                    Text(
                      "No Revisions Yet",
                      style: AppTheme.sansBody(fontSize: 14, fontWeight: FontWeight.bold, color: textColor),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "This quotation only has the initial version (v1).",
                      style: AppTheme.sansBody(fontSize: 12, color: subtitleColor),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            // Version Selector
            Wrap(
              spacing: 12,
              runSpacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  "Compare past version: ",
                  style: AppTheme.sansBody(fontSize: 13, color: textColor, fontWeight: FontWeight.w500),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: lineColor),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<QuotationVersion>(
                      value: selectedVersion,
                      dropdownColor: paperColor,
                      style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.bold),
                      items: versions.map((ver) {
                        return DropdownMenuItem(
                          value: ver,
                          child: Text("Version ${ver.versionNumber} (₹${ver.grandTotal.toStringAsFixed(0)})"),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedVersion = value;
                        });
                      },
                    ),
                  ),
                ),
                Text(
                  "➔  Current Version (v${widget.quotation.version})",
                  style: AppTheme.sansBody(fontSize: 13, color: AppColors.primaryAccent, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 700;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Pricing Summary Diffs
                        _buildPricingSummarySection(isDark, textColor, lineColor, isWide),
                        const SizedBox(height: 28),

                        // Revision Logs Section
                        _buildRevisionLogsSection(isDark, textColor, subtitleColor, lineColor),
                        const SizedBox(height: 28),

                        // Item Changes Section
                        _buildItemChangesSection(isDark, textColor, subtitleColor, lineColor),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPricingSummarySection(bool isDark, Color textColor, Color lineColor, bool isWide) {
    if (selectedVersion == null) return const SizedBox.shrink();
    final ver = selectedVersion!;
    final curr = widget.quotation;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "PRICING BREAKDOWN COMPARISON",
          style: AppTheme.sansBody(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryAccent, letterSpacing: 1.0),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: lineColor),
          ),
          clipBehavior: Clip.antiAlias,
          child: Table(
            border: TableBorder.symmetric(inside: BorderSide(color: lineColor, width: 0.5)),
            columnWidths: const {
              0: FlexColumnWidth(2),
              1: FlexColumnWidth(1.5),
              2: FlexColumnWidth(0.5),
              3: FlexColumnWidth(1.5),
            },
            children: [
              _buildPricingRow("Subtotal", ver.subtotal, curr.subtotal, textColor),
              _buildPricingRow("GST Amount (${curr.gstPercent.toStringAsFixed(0)}%)", ver.gstAmount, curr.gstAmount, textColor),
              _buildPricingRow("Discount Offered", ver.discount, curr.discount, textColor, isNegativeDiff: true),
              _buildPricingRow("Delivery Charges", ver.deliveryCharge, curr.deliveryCharge, textColor),
              _buildPricingRow("Travel Charges", ver.travelCharge, curr.travelCharge, textColor),
              _buildPricingRow("Grand Total", ver.grandTotal, curr.grandTotal, textColor, isBold: true),
            ],
          ),
        ),
      ],
    );
  }

  TableRow _buildPricingRow(String label, double oldVal, double newVal, Color textColor, {bool isBold = false, bool isNegativeDiff = false}) {
    final diff = newVal - oldVal;
    Color diffColor = Colors.white24;
    String diffText = '';

    if (diff != 0) {
      // If it's a discount, a larger discount is positive for client (decreases grand total)
      final decreasedIsGood = isNegativeDiff ? false : true;
      final isDecreased = diff < 0;

      if (isDecreased) {
        diffColor = decreasedIsGood ? AppColors.success : AppColors.error;
        diffText = " ( -₹${diff.abs().toStringAsFixed(0)} )";
      } else {
        diffColor = decreasedIsGood ? AppColors.error : AppColors.success;
        diffText = " ( +₹${diff.toStringAsFixed(0)} )";
      }
    }

    final style = TextStyle(
      color: textColor,
      fontSize: 12.5,
      fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
    );

    return TableRow(
      children: [
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Text(label, style: style),
          ),
        ),
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Text("₹${oldVal.toStringAsFixed(0)}", style: style.copyWith(color: Colors.grey)),
          ),
        ),
        const TableCell(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Icon(Icons.arrow_right_alt_rounded, size: 16, color: Colors.grey),
          ),
        ),
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Text("₹${newVal.toStringAsFixed(0)}", style: style),
                if (diffText.isNotEmpty)
                  Text(
                    diffText,
                    style: style.copyWith(fontSize: 11, color: diffColor, fontWeight: FontWeight.bold),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRevisionLogsSection(bool isDark, Color textColor, Color subtitleColor, Color lineColor) {
    if (selectedVersion == null) return const SizedBox.shrink();
    final ver = selectedVersion!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "REVISION NOTES",
          style: AppTheme.sansBody(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryAccent, letterSpacing: 1.0),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.black12 : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: lineColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.edit_note_rounded, size: 16, color: AppColors.primaryAccent),
                        const SizedBox(width: 8),
                        const Text("Admin Revision Message", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      ver.adminMessage?.isNotEmpty == true 
                          ? ver.adminMessage! 
                          : "No comments left by Coordinator.",
                      style: TextStyle(fontSize: 11.5, color: subtitleColor),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.black12 : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: lineColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.feedback_outlined, size: 16, color: AppColors.primaryAccent),
                        const SizedBox(width: 8),
                        const Text("Client Modification Request", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      ver.revisionReason?.isNotEmpty == true 
                          ? ver.revisionReason! 
                          : "No revision feedback comments provided.",
                      style: TextStyle(fontSize: 11.5, color: subtitleColor),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildItemChangesSection(bool isDark, Color textColor, Color subtitleColor, Color lineColor) {
    if (selectedVersion == null) return const SizedBox.shrink();
    final diff = VersionComparisonHelper.compareItems(selectedVersion!.items, widget.quotation.items);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "SCENOGRAPHY & DECORATION ITEM CHANGES",
          style: AppTheme.sansBody(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryAccent, letterSpacing: 1.0),
        ),
        const SizedBox(height: 12),
        if (!diff.hasChanges)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline_rounded, color: AppColors.success, size: 18),
                const SizedBox(width: 10),
                Text(
                  "No items added, deleted, or priced differently.",
                  style: TextStyle(color: subtitleColor, fontSize: 12.5),
                ),
              ],
            ),
          )
        else ...[
          // Added Items
          if (diff.added.isNotEmpty) ...[
            _buildSectionHeader("Items Added", AppColors.success),
            ...diff.added.map((item) => _buildAddedRemovedTile(item, true, AppColors.success)),
            const SizedBox(height: 12),
          ],

          // Removed Items
          if (diff.removed.isNotEmpty) ...[
            _buildSectionHeader("Items Removed", AppColors.error),
            ...diff.removed.map((item) => _buildAddedRemovedTile(item, false, AppColors.error)),
            const SizedBox(height: 12),
          ],

          // Modified Items
          if (diff.modified.isNotEmpty) ...[
            _buildSectionHeader("Items Modified", AppColors.warning),
            ...diff.modified.map((mod) => _buildModifiedTile(mod, isDark, textColor, subtitleColor, lineColor)),
          ],
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color, letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildAddedRemovedTile(QuotationItem item, bool isAdded, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12.5,
                  decoration: isAdded ? TextDecoration.none : TextDecoration.lineThrough,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Qty: ${item.quantity}  |  Price: ₹${item.unitPrice.toStringAsFixed(0)}",
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
          Text(
            "${isAdded ? '+' : '-'} ₹${item.totalPrice.toStringAsFixed(0)}",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildModifiedTile(ModifiedItemDiff mod, bool isDark, Color textColor, Color subtitleColor, Color lineColor) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            mod.newItem.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              // Quantity Comparison
              if (mod.quantityChanged)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Quantity", style: TextStyle(fontSize: 10, color: Colors.grey)),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text("${mod.oldItem.quantity}", style: const TextStyle(fontSize: 11, decoration: TextDecoration.lineThrough, color: Colors.grey)),
                          const Icon(Icons.arrow_right_alt_rounded, size: 14, color: Colors.grey),
                          Text("${mod.newItem.quantity}", style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.warning)),
                        ],
                      ),
                    ],
                  ),
                ),

              // Price Comparison
              if (mod.priceChanged)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Unit Price", style: TextStyle(fontSize: 10, color: Colors.grey)),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text("₹${mod.oldItem.unitPrice.toStringAsFixed(0)}", style: const TextStyle(fontSize: 11, decoration: TextDecoration.lineThrough, color: Colors.grey)),
                          const Icon(Icons.arrow_right_alt_rounded, size: 14, color: Colors.grey),
                          Text("₹${mod.newItem.unitPrice.toStringAsFixed(0)}", style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.warning)),
                        ],
                      ),
                    ],
                  ),
                ),

              // Total Price Comparison
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Total Price", style: TextStyle(fontSize: 10, color: Colors.grey)),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text("₹${mod.oldItem.totalPrice.toStringAsFixed(0)}", style: const TextStyle(fontSize: 11, decoration: TextDecoration.lineThrough, color: Colors.grey)),
                        const Icon(Icons.arrow_right_alt_rounded, size: 14, color: Colors.grey),
                        Text("₹${mod.newItem.totalPrice.toStringAsFixed(0)}", style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.warning)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (mod.notesChanged) ...[
            const SizedBox(height: 8),
            Text(
              "Notes: \"${mod.oldItem.notes}\" ➔ \"${mod.newItem.notes}\"",
              style: TextStyle(fontSize: 10.5, fontStyle: FontStyle.italic, color: subtitleColor),
            ),
          ],
        ],
      ),
    );
  }
}
