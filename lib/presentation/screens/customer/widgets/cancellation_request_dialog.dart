import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/constants/app_collections.dart';
import '../../../../core/services/fcm/notification_local_service.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../domain/entities/quotation.dart';

void showCancellationRequestDialog(
  BuildContext context, {
  required Quotation quotation,
  required VoidCallback onCancelled,
}) {
  showDialog(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.8),
    builder: (_) => CancellationRequestDialog(
      quotation: quotation,
      onCancelled: onCancelled,
    ),
  );
}

class CancellationRequestDialog extends StatefulWidget {
  final Quotation quotation;
  final VoidCallback onCancelled;

  const CancellationRequestDialog({
    super.key,
    required this.quotation,
    required this.onCancelled,
  });

  @override
  State<CancellationRequestDialog> createState() => _CancellationRequestDialogState();
}

class _CancellationRequestDialogState extends State<CancellationRequestDialog> {
  final _reasonOptions = [
    'Event Date Postponed / Rescheduled',
    'Venue Changed / Relocated',
    'Personal / Family Emergency',
    'Budget / Scale Adjustments',
    'Change in Event Plans',
    'Other Reason',
  ];

  late String _selectedReason;
  final _notesCtrl = TextEditingController();
  bool _acknowledgedPolicy = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedReason = _reasonOptions.first;
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  int get _daysRemaining {
    final now = DateTime.now();
    return widget.quotation.eventDate.difference(now).inDays;
  }

  String get _refundTierNotice {
    final days = _daysRemaining;
    if (days >= 15) {
      return "Notice Period: 15+ Days Remaining. Eligible for 100% rescheduling credit or cancellation subject to standard administrative processing.";
    } else if (days >= 7) {
      return "Notice Period: 7-14 Days Remaining. Cancellations in this window are subject to 50% advance retention to cover committed artisan preparations.";
    } else {
      return "Notice Period: Under 7 Days. Due to custom fabrication and slot locking, cancellations are non-refundable per policy.";
    }
  }

  Color get _tierNoticeColor {
    final days = _daysRemaining;
    if (days >= 15) return const Color(0xFF4EBA7A);
    if (days >= 7) return const Color(0xFFD4AF37);
    return const Color(0xFFE57373);
  }

  Future<void> _submitCancellation() async {
    if (!_acknowledgedPolicy) {
      Get.snackbar(
        "Agreement Required",
        "Please acknowledge the cancellation and refund terms.",
        backgroundColor: const Color(0xFF1F1210),
        colorText: const Color(0xFFE57373),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final docRef = FirebaseFirestore.instance
          .collection(AppCollections.quotations)
          .doc(widget.quotation.id);

      final fullReason = "$_selectedReason${_notesCtrl.text.trim().isNotEmpty ? ' — ${_notesCtrl.text.trim()}' : ''}";

      await docRef.update({
        'status': QuotationStatus.cancelled.name,
        'cancellation_reason': fullReason,
        'cancellation_requested_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      // Write customer notification to Firestore
      try {
        await FirebaseFirestore.instance.collection(AppCollections.customerNotifications).add({
          'customerId': widget.quotation.customerId,
          'customer_id': widget.quotation.customerId,
          'title': 'Booking Cancellation Confirmed',
          'body': 'Your booking ${widget.quotation.publicId} has been successfully cancelled.',
          'type': 'cancellation',
          'reference_id': widget.quotation.publicId,
          'publicBookingId': widget.quotation.publicId,
          'bookingId': widget.quotation.id,
          'createdAt': FieldValue.serverTimestamp(),
          'created_at': FieldValue.serverTimestamp(),
          'isRead': false,
          'is_read': false,
        });
      } catch (e) {
        AppLogger.warning("Unable to write customer notification: $e");
      }

      // Show local in-app alert
      if (Get.isRegistered<NotificationLocalService>()) {
        NotificationLocalService.to.show(
          title: "Booking Cancelled",
          body: "Booking ${widget.quotation.publicId} has been cancelled per your request.",
        );
      }

      if (mounted) {
        Navigator.of(context).pop();
        widget.onCancelled();
        Get.snackbar(
          "Cancellation Processed",
          "Booking ${widget.quotation.publicId} status has been updated to Cancelled.",
          backgroundColor: const Color(0xFF152621),
          colorText: const Color(0xFFD4AF37),
          duration: const Duration(seconds: 4),
        );
      }
    } catch (e) {
      AppLogger.error("Cancellation submission failed", e);
      if (mounted) {
        Get.snackbar(
          "Submission Failed",
          "Could not process cancellation: ${e.toString()}",
          backgroundColor: const Color(0xFF1F1210),
          colorText: const Color(0xFFE57373),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final goldColor = const Color(0xFFD4AF37);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        width: 580,
        decoration: BoxDecoration(
          color: const Color(0xFF0F1B18),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: goldColor.withValues(alpha: 0.35)),
          boxShadow: const [BoxShadow(color: Colors.black87, blurRadius: 25)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              decoration: BoxDecoration(
                color: const Color(0xFF152621),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                border: Border(bottom: BorderSide(color: goldColor.withValues(alpha: 0.15))),
              ),
              child: Row(
                children: [
                  Icon(Icons.event_busy_rounded, color: goldColor, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "REQUEST BOOKING CANCELLATION",
                      style: GoogleFonts.italiana(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white60, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Body
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Booking Summary Pill
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF152621),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("REFERENCE ID", style: AppTheme.sansBody(fontSize: 9.5, color: Colors.white54, fontWeight: FontWeight.bold)),
                              Text(widget.quotation.publicId, style: AppTheme.sansBody(fontSize: 13, color: goldColor, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text("EVENT DATE", style: AppTheme.sansBody(fontSize: 9.5, color: Colors.white54, fontWeight: FontWeight.bold)),
                              Text(AppFormatters.formatDate(widget.quotation.eventDate), style: AppTheme.sansBody(fontSize: 12, color: Colors.white)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Refund Tier Banner
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: _tierNoticeColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _tierNoticeColor.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline, size: 16, color: _tierNoticeColor),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _refundTierNotice,
                              style: AppTheme.sansBody(fontSize: 12, color: Colors.white, height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Reason Dropdown
                    Text("Select Cancellation Reason *", style: AppTheme.sansBody(fontSize: 11.5, color: Colors.white70, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF152621),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: goldColor.withValues(alpha: 0.3)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedReason,
                          isExpanded: true,
                          dropdownColor: const Color(0xFF152621),
                          style: AppTheme.sansBody(fontSize: 13, color: Colors.white),
                          items: _reasonOptions.map((opt) {
                            return DropdownMenuItem(value: opt, child: Text(opt));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedReason = val);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Additional Remarks
                    Text("Additional Remarks (Optional)", style: AppTheme.sansBody(fontSize: 11.5, color: Colors.white70, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _notesCtrl,
                      maxLines: 2,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      cursorColor: goldColor,
                      decoration: InputDecoration(
                        hintText: "Add any specific context for our planning coordinator...",
                        hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                        filled: true,
                        fillColor: const Color(0xFF152621),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: goldColor.withValues(alpha: 0.2))),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: goldColor)),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Acknowledgement Checkbox
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _acknowledgedPolicy,
                      activeColor: goldColor,
                      checkColor: const Color(0xFF091210),
                      title: Text(
                        "I acknowledge the OM Events & Decorators Cancellation Policy. I understand slot reservation and refund calculations follow these terms.",
                        style: AppTheme.sansBody(fontSize: 11.5, color: Colors.white70),
                      ),
                      onChanged: (val) => setState(() => _acknowledgedPolicy = val ?? false),
                    ),
                  ],
                ),
              ),
            ),

            // Footer Actions
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Colors.white12)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      "KEEP MY BOOKING",
                      style: AppTheme.sansBody(fontSize: 11.5, color: Colors.white70, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitCancellation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE57373),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      textStyle: AppTheme.sansBody(fontSize: 11.5, fontWeight: FontWeight.bold),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text("CONFIRM CANCELLATION"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
