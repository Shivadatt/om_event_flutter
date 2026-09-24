import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_input.dart';
import '../../../../data/models/quotation_model.dart';
import '../../../../domain/entities/quotation.dart';
import 'cancellation_request_dialog.dart';
import 'customer_review_dialog.dart';
import '../../../../core/utils/booking_communication_helper.dart';

void showBookingTrackerDialog(BuildContext context, {String? initialReferenceId}) {
  showDialog(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.75),
    builder: (_) => BookingTrackerDialog(initialReferenceId: initialReferenceId),
  );
}

class BookingTrackerDialog extends StatefulWidget {
  final String? initialReferenceId;

  const BookingTrackerDialog({super.key, this.initialReferenceId});

  @override
  State<BookingTrackerDialog> createState() => _BookingTrackerDialogState();
}

class _BookingTrackerDialogState extends State<BookingTrackerDialog> {
  final _refController = TextEditingController();
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  Quotation? _foundQuotation;
  String? _errorMessage;
  bool _isPhoneVerified = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialReferenceId != null) {
      _refController.text = widget.initialReferenceId!;
    }
  }

  @override
  void dispose() {
    _refController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _trackBooking() async {
    if (_formKey.currentState?.validate() != true) return;

    final refId = _refController.text.trim().toUpperCase();
    final cleanPhone = AppValidators.cleanPhone(_phoneController.text.trim());

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _foundQuotation = null;
    });

    try {
      final querySnap = await FirebaseFirestore.instance
          .collection('quotations')
          .where('publicId', isEqualTo: refId)
          .limit(1)
          .get();

      if (querySnap.docs.isEmpty) {
        setState(() {
          _errorMessage =
              "No booking request found for Reference ID '$refId'. Please verify your ID format (e.g. OM-20260928-104).";
        });
        return;
      }

      final doc = querySnap.docs.first;
      final model = QuotationModel.fromJson(doc.data(), doc.id);

      // Verify phone number matches if provided
      bool phoneMatched = false;
      if (cleanPhone.isNotEmpty) {
        final docPhone = AppValidators.cleanPhone(model.customerPhone);
        if (!docPhone.endsWith(cleanPhone) && !cleanPhone.endsWith(docPhone)) {
          setState(() {
            _errorMessage =
                "The phone number provided does not match the record for this booking ID.";
          });
          return;
        }
        phoneMatched = true;
      }

      // Check if logged in customer matches
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      final isOwner = currentUserId != null && currentUserId == model.customerId;

      setState(() {
        _foundQuotation = model;
        _isPhoneVerified = phoneMatched || isOwner;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Unable to locate booking details for this reference ID. Please check the code and try again.";
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _maskName(String name) {
    if (_isPhoneVerified) return name;
    if (name.isEmpty) return "Valued Client";
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      final p = parts[0];
      if (p.length <= 2) return "${p[0]}*";
      return "${p.substring(0, 2)}${'*' * (p.length - 2)}";
    }
    return parts.map((p) {
      if (p.length <= 1) return p;
      if (p.length <= 2) return "${p[0]}*";
      return "${p.substring(0, 2)}${'*' * (p.length - 2)}";
    }).join(' ');
  }

  String _maskVenue(String venue) {
    if (_isPhoneVerified) return venue;
    if (venue.isEmpty) return "Protected Location";
    final parts = venue.split(',');
    if (parts.isNotEmpty && parts[0].trim().isNotEmpty) {
      return "${parts[0].trim()} (Protected Location)";
    }
    return "Protected Location";
  }

  int _getStatusStep(QuotationStatus status) {
    switch (status) {
      case QuotationStatus.draft:
      case QuotationStatus.published:
        return 1;
      case QuotationStatus.viewed:
      case QuotationStatus.revisionRequested:
      case QuotationStatus.underRevision:
      case QuotationStatus.republished:
        return 2;
      case QuotationStatus.acceptedByClient:
        return 3;
      case QuotationStatus.bookingConfirmed:
        return 4;
      case QuotationStatus.inProgress:
      case QuotationStatus.completed:
        return 5;
      case QuotationStatus.cancelled:
      case QuotationStatus.expired:
      case QuotationStatus.rejectedByClient:
      case QuotationStatus.archived:
        return 0;
    }
  }

  String _getStatusTitle(QuotationStatus status) {
    switch (status) {
      case QuotationStatus.draft:
      case QuotationStatus.published:
        return "Request Received — Under Review";
      case QuotationStatus.viewed:
      case QuotationStatus.revisionRequested:
      case QuotationStatus.underRevision:
      case QuotationStatus.republished:
        return "Quotation & Decor Moodboard Ready";
      case QuotationStatus.acceptedByClient:
        return "Client Accepted — Finalizing Confirmation";
      case QuotationStatus.bookingConfirmed:
        return "Booking Confirmed — Slot Reserved";
      case QuotationStatus.inProgress:
        return "Setup In Progress";
      case QuotationStatus.completed:
        return "Event Successfully Completed";
      case QuotationStatus.cancelled:
        return "Booking Cancelled";
      case QuotationStatus.rejectedByClient:
        return "Booking Declined";
      case QuotationStatus.expired:
        return "Booking Expired";
      case QuotationStatus.archived:
        return "Booking Archived";
    }
  }

  Color _getStatusColor(QuotationStatus status) {
    switch (status) {
      case QuotationStatus.bookingConfirmed:
      case QuotationStatus.completed:
        return const Color(0xFF4EBA7A);
      case QuotationStatus.inProgress:
      case QuotationStatus.acceptedByClient:
      case QuotationStatus.draft:
      case QuotationStatus.published:
      case QuotationStatus.viewed:
      case QuotationStatus.revisionRequested:
      case QuotationStatus.underRevision:
      case QuotationStatus.republished:
        return AppColors.secondaryAccent;
      case QuotationStatus.cancelled:
      case QuotationStatus.rejectedByClient:
      case QuotationStatus.expired:
      case QuotationStatus.archived:
        return const Color(0xFFE57373);
    }
  }

  @override
  Widget build(BuildContext context) {
    final goldColor = AppColors.secondaryAccent;
    const darkBg = Color(0xFF0D1915);
    const cardBg = Color(0xFF152621);
    const borderColor = Color(0xFF1E3A32);

    return Dialog(
      backgroundColor: darkBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: borderColor, width: 1.2),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 600,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: borderColor, width: 1)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "LIVE BOOKING STATUS",
                          style: AppTheme.sansBody(
                            fontSize: 10,
                            color: goldColor,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Track Your Event",
                          style: GoogleFonts.italiana(
                            fontSize: 22,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, color: Colors.white70),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "ENTER BOOKING REFERENCE",
                        style: AppTheme.sansBody(
                          fontSize: 11,
                          color: goldColor,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      CustomInput(
                        label: "Booking Reference ID *",
                        placeholder: "e.g. OM-20260928-104",
                        controller: _refController,
                        validator: (val) =>
                            val != null && val.trim().isNotEmpty ? null : "Reference ID required.",
                      ),
                      CustomInput(
                        label: "10-Digit Mobile Number (Optional for quick verify)",
                        placeholder: "e.g. 9876543210",
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: CustomButton(
                          text: "LOOKUP STATUS",
                          isLoading: _isLoading,
                          onPressed: _trackBooking,
                        ),
                      ),

                      if (_errorMessage != null) ...[
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF261919),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFE57373).withValues(alpha: 0.4)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline_rounded, color: Color(0xFFE57373), size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: AppTheme.sansBody(fontSize: 12, color: const Color(0xFFFFB4A8)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      if (_foundQuotation != null) ...[
                        const SizedBox(height: 24),
                        const Divider(color: borderColor),
                        const SizedBox(height: 16),

                        // Booking Card
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: goldColor.withValues(alpha: 0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _foundQuotation!.publicId,
                                      style: AppTheme.serifHeader(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                        color: goldColor,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(_foundQuotation!.status).withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: _getStatusColor(_foundQuotation!.status)),
                                    ),
                                    child: Text(
                                      _foundQuotation!.status.name.toUpperCase(),
                                      style: AppTheme.sansBody(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color: _getStatusColor(_foundQuotation!.status),
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _getStatusTitle(_foundQuotation!.status),
                                style: AppTheme.sansBody(
                                  fontSize: 13,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 16),

                              _buildInfoRow("Customer", _maskName(_foundQuotation!.customerName)),
                              _buildInfoRow("Service", _foundQuotation!.items.firstOrNull?.name ?? "Event Decor"),
                              _buildInfoRow("Event Date", AppFormatters.formatDate(_foundQuotation!.eventDate)),
                              _buildInfoRow("Time", _foundQuotation!.eventTime),
                              _buildInfoRow("Venue", _maskVenue(_foundQuotation!.location)),
                              _buildInfoRow("Grand Total", AppFormatters.formatCurrency(_foundQuotation!.grandTotal)),
                              if (!_isPhoneVerified) ...[
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.04),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: Colors.white12),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.shield_outlined, size: 13, color: Colors.white54),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          "Personal info masked for privacy. Enter your registered phone number above to reveal full details.",
                                          style: AppTheme.sansBody(fontSize: 10, color: Colors.white60),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              const SizedBox(height: 16),

                              // Progress Steps Timeline
                              Text(
                                "PROGRESS TRACKER",
                                style: AppTheme.sansBody(
                                  fontSize: 10,
                                  color: goldColor,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _buildStep(1, "Request Received", _getStatusStep(_foundQuotation!.status) >= 1, goldColor),
                              _buildStep(2, "Proposal & Styling Review", _getStatusStep(_foundQuotation!.status) >= 2, goldColor),
                              _buildStep(3, "Quotation Accepted", _getStatusStep(_foundQuotation!.status) >= 3, goldColor),
                              _buildStep(4, "Date Locked & Confirmed", _getStatusStep(_foundQuotation!.status) >= 4, goldColor),
                              _buildStep(5, "Event Executed", _getStatusStep(_foundQuotation!.status) >= 5, goldColor, isLast: true),

                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: () async {
                                    final service = _foundQuotation!.items.isNotEmpty
                                        ? _foundQuotation!.items.first.name
                                        : "Event Decor";
                                    final package = _foundQuotation!.items.isNotEmpty && _foundQuotation!.items.first.theme.isNotEmpty
                                        ? _foundQuotation!.items.first.theme
                                        : (_foundQuotation!.bookingDetails ?? "Custom");
                                    final message = BookingCommunicationHelper.generateBookingWhatsAppMessage(
                                      bookingId: _foundQuotation!.publicId,
                                      serviceName: service,
                                      packageName: package,
                                      eventDate: _foundQuotation!.eventDate,
                                      status: _foundQuotation!.status,
                                    );
                                    await BookingCommunicationHelper.openWhatsApp(message: message);
                                  },
                                  icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16, color: Color(0xFF4EBA7A)),
                                  label: Text(
                                    "Chat With Coordinator on WhatsApp",
                                    style: AppTheme.sansBody(fontSize: 12, color: const Color(0xFF4EBA7A), fontWeight: FontWeight.w700),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Color(0xFF4EBA7A), width: 1.2),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Review Submission Action for Completed Bookings
                              if (_getStatusStep(_foundQuotation!.status) >= 5 ||
                                  _foundQuotation!.status == QuotationStatus.completed) ...[
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      showCustomerReviewDialog(
                                        context,
                                        quotation: _foundQuotation!,
                                        onSubmitted: _trackBooking,
                                      );
                                    },
                                    icon: const Icon(Icons.star_rounded, size: 18, color: Color(0xFF0F1B18)),
                                    label: Text(
                                      "Leave a Verified Review",
                                      style: AppTheme.sansBody(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.8,
                                        color: const Color(0xFF0F1B18),
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: goldColor,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ],

                              // Cancellation Action or Cancelled Banner
                              if (_foundQuotation!.status == QuotationStatus.cancelled)
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE57373).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: const Color(0xFFE57373).withValues(alpha: 0.3)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.cancel_outlined, size: 16, color: Color(0xFFE57373)),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          "This reservation has been cancelled per client request.",
                                          style: AppTheme.sansBody(fontSize: 11, color: const Color(0xFFE57373)),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else if (_foundQuotation!.status != QuotationStatus.completed &&
                                  _getStatusStep(_foundQuotation!.status) < 5)
                                Center(
                                  child: TextButton.icon(
                                    onPressed: () {
                                      showCancellationRequestDialog(
                                        context,
                                        quotation: _foundQuotation!,
                                        onCancelled: _trackBooking,
                                      );
                                    },
                                    icon: const Icon(Icons.event_busy_outlined, size: 14, color: Colors.white54),
                                    label: Text(
                                      "Request Booking Cancellation",
                                      style: AppTheme.sansBody(fontSize: 11, color: Colors.white54),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: AppTheme.sansBody(fontSize: 11, color: Colors.white54, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTheme.sansBody(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(int stepNum, String title, bool isCompleted, Color activeColor, {bool isLast = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted ? activeColor : const Color(0xFF1E3A32),
                border: Border.all(
                  color: isCompleted ? activeColor : Colors.white24,
                  width: 1.5,
                ),
              ),
              child: Center(
                child: isCompleted
                    ? const Icon(Icons.check, size: 13, color: Color(0xFF0D1915))
                    : Text(
                        "$stepNum",
                        style: const TextStyle(fontSize: 10, color: Colors.white70, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 22,
                color: isCompleted ? activeColor.withValues(alpha: 0.6) : const Color(0xFF1E3A32),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            title,
            style: AppTheme.sansBody(
              fontSize: 12,
              color: isCompleted ? Colors.white : Colors.white38,
              fontWeight: isCompleted ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}
