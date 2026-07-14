import 'package:flutter/material.dart';
import '../../../../../core/config/app_theme.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/utils/formatters.dart';
import '../../../../../core/widgets/custom_input.dart';
import '../../../../../domain/entities/quotation.dart';

/// Renders event details, client visible/internal notes, and operational settings inputs.
class EditorEventDetailsSection extends StatelessWidget {
  final Quotation quotation;
  final TextEditingController dateController;
  final TextEditingController timeController;
  final TextEditingController locController;
  final TextEditingController notesController;
  final TextEditingController internalNotesController;
  final TextEditingController adminMessageController;
  final TextEditingController operationalNotesController;
  final TextEditingController bookingDetailsController;
  final TextEditingController staffAssignmentController;
  final TextEditingController logisticsController;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;
  final bool isPermLocked;

  const EditorEventDetailsSection({
    super.key,
    required this.quotation,
    required this.dateController,
    required this.timeController,
    required this.locController,
    required this.notesController,
    required this.internalNotesController,
    required this.adminMessageController,
    required this.operationalNotesController,
    required this.bookingDetailsController,
    required this.staffAssignmentController,
    required this.logisticsController,
    required this.selectedDate,
    required this.onDateChanged,
    required this.isPermLocked,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final creamColor = isDark ? AppColors.darkCream : AppColors.lightCream;
    final paperColor = isDark ? AppColors.darkPaper : AppColors.lightPaper;
    final inkColor = isDark ? AppColors.darkInk : AppColors.lightInk;
    final goldColor = isDark ? AppColors.darkGold : AppColors.lightGold;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (quotation.acceptedAt != null) ...[
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 24),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0x0A4CAF50),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0x334CAF50)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.verified_user_rounded, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      "DIGITAL CONSENT SIGNED",
                      style: AppTheme.sansBody(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  "Accepted By: ${quotation.acceptedBy ?? 'Customer'}",
                  style: AppTheme.sansBody(fontSize: 13, fontWeight: FontWeight.bold, color: inkColor),
                ),
                const SizedBox(height: 4),
                Text(
                  "Accepted Version: v${quotation.acceptedVersion ?? quotation.version}",
                  style: AppTheme.sansBody(fontSize: 12, color: inkColor.withValues(alpha: 0.7)),
                ),
                Text(
                  "Accepted Amount: ${AppFormatters.formatCurrency(quotation.acceptedAmount ?? quotation.grandTotal)}",
                  style: AppTheme.sansBody(fontSize: 12, color: inkColor.withValues(alpha: 0.7)),
                ),
                Text(
                  "Consent Time: ${AppFormatters.formatShortDate(quotation.acceptedAt!)} ${quotation.acceptedAt!.toLocal().toString().split(' ')[1].substring(0, 5)}",
                  style: AppTheme.sansBody(fontSize: 12, color: inkColor.withValues(alpha: 0.7)),
                ),
                Text(
                  "Device: ${quotation.acceptedDevice ?? 'Unknown'}",
                  style: AppTheme.sansBody(fontSize: 12, color: inkColor.withValues(alpha: 0.7)),
                ),
                if (quotation.acceptedIp != null)
                  Text(
                    "IP Address: ${quotation.acceptedIp}",
                    style: AppTheme.sansBody(fontSize: 12, color: inkColor.withValues(alpha: 0.7)),
                  ),
                const SizedBox(height: 8),
                Text(
                  "Consent Text: \"I confirm that I have reviewed this quotation and agree with the pricing, services and terms.\"",
                  style: AppTheme.sansBody(fontSize: 11, color: inkColor.withValues(alpha: 0.5)).copyWith(fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
        ],
        Text(
          "EVENT DETAILS & NOTES",
          style: AppTheme.sansBody(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: goldColor,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CustomInput(
                label: "Event Date",
                placeholder: "YYYY-MM-DD",
                controller: dateController,
                readOnly: true,
                onTap: isPermLocked ? null : () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now().subtract(const Duration(days: 30)),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    builder: (context, child) => Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.dark(
                          primary: goldColor,
                          onPrimary: creamColor,
                          surface: paperColor,
                          onSurface: inkColor,
                        ),
                      ),
                      child: child!,
                    ),
                    initialEntryMode: DatePickerEntryMode.calendar,
                  );
                  if (picked != null) {
                    onDateChanged(picked);
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomInput(
                label: "Event Time",
                placeholder: "HH:MM",
                controller: timeController,
                readOnly: isPermLocked,
              ),
            ),
          ],
        ),
        CustomInput(
          label: "Venue / Location",
          placeholder: "Venue name, area and city",
          controller: locController,
          readOnly: isPermLocked,
        ),
        const SizedBox(height: 8),
        CustomInput(
          label: "Customer Visible Notes",
          placeholder: "Special requirements / client instructions...",
          controller: notesController,
          maxLines: 2,
          readOnly: isPermLocked,
        ),
        CustomInput(
          label: "Internal Admin Notes (Private)",
          placeholder: "Private notes for decoration staff, pricing calculations...",
          controller: internalNotesController,
          maxLines: 2,
          readOnly: isPermLocked,
        ),
        CustomInput(
          label: "Message to Client",
          placeholder: "Write a short status overview or greeting for the client portal...",
          controller: adminMessageController,
          maxLines: 2,
          readOnly: isPermLocked,
        ),
        const SizedBox(height: 24),
        Text(
          "OPERATIONAL & LOGISTICS DETAILS",
          style: AppTheme.sansBody(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: goldColor,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        CustomInput(
          label: "Operational Notes",
          placeholder: "Preparation details, timing instructions for setup staff...",
          controller: operationalNotesController,
          maxLines: 2,
          readOnly: isPermLocked,
        ),
        CustomInput(
          label: "Booking Details",
          placeholder: "Booking confirmation numbers, package selection descriptions...",
          controller: bookingDetailsController,
          maxLines: 2,
          readOnly: isPermLocked,
        ),
        CustomInput(
          label: "Staff Assignment",
          placeholder: "Assigned event managers, florist details, designers...",
          controller: staffAssignmentController,
          maxLines: 2,
          readOnly: isPermLocked,
        ),
        CustomInput(
          label: "Logistics Details",
          placeholder: "Vehicles numbers, delivery status, transport arrangements...",
          controller: logisticsController,
          maxLines: 2,
          readOnly: isPermLocked,
        ),
      ],
    );
  }
}
