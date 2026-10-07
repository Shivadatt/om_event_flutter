import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/booking_communication_helper.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/validators.dart';
import '../../../../data/models/quotation_model.dart';
import '../../../../domain/entities/quotation.dart';
import 'cancellation_request_dialog.dart';
import 'customer_review_dialog.dart';

void showBookingTrackerDialog(BuildContext context, {String? initialReferenceId}) {
  showDialog(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.78),
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
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;

      // 1. If customer is authenticated, attempt reading their owned quotation
      if (currentUserId != null) {
        try {
          final querySnap = await FirebaseFirestore.instance
              .collection('quotations')
              .where('publicId', isEqualTo: refId)
              .limit(1)
              .get();

          if (querySnap.docs.isNotEmpty) {
            final doc = querySnap.docs.first;
            final model = QuotationModel.fromJson(doc.data(), doc.id);
            if (model.customerId == currentUserId) {
              bool phoneMatched = true;
              if (cleanPhone.isNotEmpty) {
                final docPhone = AppValidators.cleanPhone(model.customerPhone);
                phoneMatched = docPhone.endsWith(cleanPhone) || cleanPhone.endsWith(docPhone);
              }
              setState(() {
                _foundQuotation = model;
                _isPhoneVerified = phoneMatched;
              });
              return;
            }
          }
        } catch (_) {
          // If query fails (e.g. not owner), fallback to public safe timeline projection
        }
      }

      // 2. Public Tracker Projection (P1 FIX: Zero PII, no quotation enumeration)
      final timelineDoc = await FirebaseFirestore.instance
          .collection('booking_timelines')
          .doc(refId)
          .get();

      if (!timelineDoc.exists) {
        setState(() {
          _errorMessage =
              "No booking request found for Reference ID '$refId'. Please verify your ID format (e.g. OM-20260928-104).";
        });
        return;
      }

      final data = timelineDoc.data() ?? {};
      final phoneLast4 = (data['phoneLast4'] ?? '').toString();
      bool phoneMatched = false;

      if (cleanPhone.isNotEmpty) {
        if (phoneLast4.isNotEmpty && cleanPhone.endsWith(phoneLast4)) {
          phoneMatched = true;
        } else {
          setState(() {
            _errorMessage =
                "The phone number provided does not match the record for this booking ID.";
          });
          return;
        }
      }

      final eventDate = DateTime.tryParse(data['eventDate'] ?? '') ?? DateTime.now();
      final rawStatusStr = data['status'] ?? 'published';
      final status = QuotationStatus.fromString(rawStatusStr);
      final serviceName = data['serviceName'] ?? 'Event Decor';
      final double grandTotal = (data['grandTotal'] as num?)?.toDouble() ?? 0.0;

      // Construct safe model containing strictly tracker-safe fields (zero PII)
      final safeProjection = Quotation(
        id: refId,
        publicId: refId,
        customerPhone: phoneLast4.isNotEmpty ? '******$phoneLast4' : 'Protected',
        customerName: data['maskedName'] ?? 'Valued Client',
        eventDate: eventDate,
        eventTime: data['eventTime'] ?? '',
        location: data['maskedVenue'] ?? 'Protected Location',
        notes: '',
        subtotal: grandTotal,
        discount: 0,
        deliveryCharge: 0,
        travelCharge: 0,
        gstPercent: 0,
        gstAmount: 0,
        grandTotal: grandTotal,
        pdfUrl: '',
        status: status,
        items: [
          QuotationItem(
            experienceId: '',
            name: serviceName,
            quantity: 1,
            unitPrice: grandTotal,
            color: '',
            theme: '',
            notes: '',
          ),
        ],
        createdAt: eventDate,
        updatedAt: DateTime.now(),
        customerId: '',
      );

      setState(() {
        _foundQuotation = safeProjection;
        _isPhoneVerified = phoneMatched;
      });
    } catch (e) {
      setState(() {
        _errorMessage =
            "Unable to locate booking details for this reference ID. Please check the code and try again.";
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 600;
    final outerWidth = isDesktop ? 530.0 : math.min(530.0, screenWidth - 28);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 24),
      child: Center(
        child: SizedBox(
          width: outerWidth,
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.90,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF07120E),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: goldColor.withValues(alpha: 0.38),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.82),
                  blurRadius: 38,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: [
                  // 1. Ambient Gold Waves Background (Radiant Wings on Left & Right)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _GoldWavesPainter(goldColor: goldColor),
                    ),
                  ),

                  // 2. Content-Driven Scrollable Area
                  SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 28 : 16,
                      vertical: 26,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Inner Centered Form Card
                        _buildInnerCard(context, goldColor, isDesktop),

                        // Error Banner (if any)
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 14),
                          _buildErrorBox(),
                        ],

                        // Quotation Details & Tracking Steps (if found)
                        if (_foundQuotation != null) ...[
                          const SizedBox(height: 16),
                          _buildQuotationDetails(context, goldColor),
                        ],
                      ],
                    ),
                  ),

                  // 3. Top-Right Close Button in Outer Frame
                  Positioned(
                    top: 16,
                    right: 16,
                    child: _buildCloseButton(context, goldColor),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // INNER CARD (EXACT PROPORTIONS TO REFERENCE IMAGE 2)
  // ==========================================
  Widget _buildInnerCard(BuildContext context, Color goldColor, bool isDesktop) {
    const innerCardWidth = 345.0;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: innerCardWidth),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Inner Dark Emerald Card Container
            Container(
              margin: const EdgeInsets.only(top: 26),
              padding: const EdgeInsets.fromLTRB(20, 32, 20, 20),
              decoration: BoxDecoration(
                color: const Color(0xFF0C1914),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: goldColor.withValues(alpha: 0.28),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.55),
                    blurRadius: 22,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Gold Eyebrow
                    Text(
                      "LIVE BOOKING STATUS",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                        color: goldColor,
                        letterSpacing: 1.8,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Display Title
                    Text(
                      "Track Your Event",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.italiana(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Subtitle / Prompt
                    Text(
                      "Enter your booking reference details to get\nreal-time updates on your event.",
                      textAlign: TextAlign.center,
                      style: AppTheme.sansBody(
                        fontSize: 11,
                        color: Colors.white70,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 1. Booking Reference Field
                    _buildInputField(
                      controller: _refController,
                      hintText: "e.g. OM-20260928-104",
                      icon: Icons.article_outlined,
                      goldColor: goldColor,
                      textCapitalization: TextCapitalization.characters,
                      validator: (val) =>
                          val != null && val.trim().isNotEmpty ? null : "Booking reference ID required.",
                    ),
                    const SizedBox(height: 9),

                    // 2. Mobile Number Field
                    _buildInputField(
                      controller: _phoneController,
                      hintText: "e.g. 9876543210 (optional)",
                      icon: Icons.phone_outlined,
                      goldColor: goldColor,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 13),

                    // 3. Full-Width Premium Gold Lookup Button
                    _buildLookupButton(goldColor),
                    const SizedBox(height: 18),

                    // 4. Bottom 3-Column Feature Row
                    _buildFeatureRow(goldColor),
                  ],
                ),
              ),
            ),

            // Overlapping Circular Calendar Icon Holder at Top Center
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFF091612),
                    shape: BoxShape.circle,
                    border: Border.all(color: goldColor, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: goldColor.withValues(alpha: 0.45),
                        blurRadius: 18,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.calendar_month_rounded,
                      color: goldColor,
                      size: 23,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // TEXT INPUT FIELD (COMPACT WITH LEADING ICON)
  // ==========================================
  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required Color goldColor,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? Function(String?)? validator,
  }) {
    return SizedBox(
      height: 42,
      child: TextFormField(
        controller: controller,
        style: const TextStyle(color: Colors.white, fontSize: 12.5),
        cursorColor: goldColor,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        validator: validator,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
          prefixIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Icon(icon, color: goldColor, size: 17),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 38, minHeight: 40),
          filled: true,
          fillColor: const Color(0xFF071410),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          isDense: true,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: goldColor.withValues(alpha: 0.28)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: goldColor, width: 1.2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE57373)),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE57373), width: 1.2),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // FULL-WIDTH GOLD LOOKUP BUTTON (Lookup Status →)
  // ==========================================
  Widget _buildLookupButton(Color goldColor) {
    return Container(
      height: 42,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE5C378), Color(0xFFD4AF37), Color(0xFFC59D2E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(21),
        boxShadow: [
          BoxShadow(
            color: goldColor.withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(21),
          onTap: _isLoading ? null : _trackBooking,
          child: Center(
            child: _isLoading
                ? const SizedBox(
                    width: 17,
                    height: 17,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF091210)),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Lookup Status",
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF091210),
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 14,
                        color: Color(0xFF091210),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // BOTTOM 3-COLUMN FEATURE ROW
  // ==========================================
  Widget _buildFeatureRow(Color goldColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: _buildFeatureItem(
            icon: Icons.visibility_outlined,
            line1: "Real-time",
            line2: "Tracking",
            goldColor: goldColor,
          ),
        ),
        Container(
          width: 1,
          height: 26,
          color: Colors.white.withValues(alpha: 0.08),
        ),
        Expanded(
          child: _buildFeatureItem(
            icon: Icons.notifications_none_rounded,
            line1: "Instant",
            line2: "Updates",
            goldColor: goldColor,
          ),
        ),
        Container(
          width: 1,
          height: 26,
          color: Colors.white.withValues(alpha: 0.08),
        ),
        Expanded(
          child: _buildFeatureItem(
            icon: Icons.shield_outlined,
            line1: "Secure",
            line2: "& Private",
            goldColor: goldColor,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String line1,
    required String line2,
    required Color goldColor,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: goldColor.withValues(alpha: 0.10),
            shape: BoxShape.circle,
            border: Border.all(color: goldColor.withValues(alpha: 0.35), width: 1.0),
          ),
          child: Icon(icon, size: 14, color: goldColor),
        ),
        const SizedBox(height: 5),
        Text(
          line1,
          textAlign: TextAlign.center,
          style: AppTheme.sansBody(
            fontSize: 9.5,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            height: 1.15,
          ),
        ),
        Text(
          line2,
          textAlign: TextAlign.center,
          style: AppTheme.sansBody(
            fontSize: 8.5,
            color: Colors.white60,
            height: 1.15,
          ),
        ),
      ],
    );
  }

  // ==========================================
  // TOP-RIGHT CLOSE BUTTON
  // ==========================================
  Widget _buildCloseButton(BuildContext context, Color goldColor) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFF0E1C17).withValues(alpha: 0.85),
            shape: BoxShape.circle,
            border: Border.all(color: goldColor.withValues(alpha: 0.35), width: 1),
          ),
          child: const Icon(
            Icons.close_rounded,
            size: 16,
            color: Colors.white70,
          ),
        ),
      ),
    );
  }

  // ==========================================
  // ERROR BANNER
  // ==========================================
  Widget _buildErrorBox() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 345),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF261919),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE57373).withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              const Icon(Icons.error_outline_rounded, color: Color(0xFFE57373), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _errorMessage!,
                  style: AppTheme.sansBody(fontSize: 11.5, color: const Color(0xFFFFB4A8)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // FOUND QUOTATION DETAILS & TIMELINE
  // ==========================================
  Widget _buildQuotationDetails(BuildContext context, Color goldColor) {
    const cardBg = Color(0xFF0E1C17);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 345),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
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
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: goldColor,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _getStatusColor(_foundQuotation!.status).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _getStatusColor(_foundQuotation!.status)),
                    ),
                    child: Text(
                      _foundQuotation!.status.name.toUpperCase(),
                      style: AppTheme.sansBody(
                        fontSize: 9,
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
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 14),

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

              const SizedBox(height: 16),
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
                  icon: const Icon(Icons.chat_bubble_outline_rounded, size: 14, color: Color(0xFF4EBA7A)),
                  label: Text(
                    "Chat With Coordinator on WhatsApp",
                    style: AppTheme.sansBody(fontSize: 11, color: const Color(0xFF4EBA7A), fontWeight: FontWeight.w700),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF4EBA7A), width: 1.2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 9),
                  ),
                ),
              ),
              const SizedBox(height: 10),

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
                    icon: const Icon(Icons.star_rounded, size: 15, color: Color(0xFF0F1B18)),
                    label: Text(
                      "Leave a Verified Review",
                      style: AppTheme.sansBody(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                        color: const Color(0xFF0F1B18),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: goldColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
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
                      const Icon(Icons.cancel_outlined, size: 15, color: Color(0xFFE57373)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "This reservation has been cancelled per client request.",
                          style: AppTheme.sansBody(fontSize: 10.5, color: const Color(0xFFE57373)),
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
                    icon: const Icon(Icons.event_busy_outlined, size: 13, color: Colors.white54),
                    label: Text(
                      "Request Booking Cancellation",
                      style: AppTheme.sansBody(fontSize: 10.5, color: Colors.white54),
                    ),
                  ),
                ),
            ],
          ),
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
            width: 80,
            child: Text(
              label,
              style: AppTheme.sansBody(fontSize: 10.5, color: Colors.white54, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTheme.sansBody(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600),
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
              width: 19,
              height: 19,
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
                    ? const Icon(Icons.check, size: 11, color: Color(0xFF0D1915))
                    : Text(
                        "$stepNum",
                        style: const TextStyle(fontSize: 9, color: Colors.white70, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 19,
                color: isCompleted ? activeColor.withValues(alpha: 0.6) : const Color(0xFF1E3A32),
              ),
          ],
        ),
        const SizedBox(width: 9),
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Text(
            title,
            style: AppTheme.sansBody(
              fontSize: 11,
              color: isCompleted ? Colors.white : Colors.white38,
              fontWeight: isCompleted ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// GOLD WAVES PAINTER (PROMINENT RADIANT METALLIC CURVES MATCHING REFERENCE)
// ============================================================================
class _GoldWavesPainter extends CustomPainter {
  final Color goldColor;

  _GoldWavesPainter({required this.goldColor});

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width < 10 || size.height < 10) return;
    final w = size.width;
    final h = size.height;

    // 1. Warm Golden Radial Halo behind Calendar Icon (Top Center)
    final haloCenter = Offset(w * 0.5, h * 0.12);
    final haloPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          goldColor.withValues(alpha: 0.42),
          goldColor.withValues(alpha: 0.18),
          goldColor.withValues(alpha: 0.04),
          Colors.transparent,
        ],
        stops: const [0.0, 0.35, 0.70, 1.0],
      ).createShader(Rect.fromCircle(center: haloCenter, radius: 85));
    canvas.drawCircle(haloCenter, 85, haloPaint);

    // 2. LEFT SIDE FLOWING GOLDEN WAVES
    // Swooping curves from outer left edge and bottom-left toward the inner card
    const leftCount = 22;
    for (int i = 0; i < leftCount; i++) {
      final t = i / (leftCount - 1);
      final path = Path();
      
      // Start along outer left border
      path.moveTo(0, h * (0.24 + t * 0.60));
      
      // Control points creating the graceful inward curve seen in Reference Image 2
      path.cubicTo(
        w * (0.04 + t * 0.08),
        h * (0.32 + t * 0.52),
        w * (0.10 + t * 0.14),
        h * (0.72 + t * 0.22),
        w * (0.24 + t * 0.14),
        h * (0.92 - (1 - t) * 0.14),
      );

      final curveAlpha = (math.sin(t * math.pi) * 0.40 + 0.10).clamp(0.08, 0.48);
      final strokeW = 0.8 + t * 0.9;
      
      final paint = Paint()
        ..color = Color.lerp(const Color(0xFFD4AF37), const Color(0xFFF7E2A4), t)!
            .withValues(alpha: curveAlpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW;
      
      canvas.drawPath(path, paint);
    }

    // Additional cross-swoop wave lines on left
    for (int i = 0; i < 10; i++) {
      final t = i / 9.0;
      final path = Path();
      path.moveTo(w * (0.02 + t * 0.10), h);
      path.cubicTo(
        w * (0.07 + t * 0.11),
        h * (0.80 - t * 0.26),
        w * (0.05 + t * 0.08),
        h * (0.50 - t * 0.18),
        0,
        h * (0.35 + t * 0.32),
      );
      final alpha = (math.sin(t * math.pi) * 0.32 + 0.08).clamp(0.06, 0.38);
      final paint = Paint()
        ..color = const Color(0xFFE5C378).withValues(alpha: alpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.9;
      canvas.drawPath(path, paint);
    }

    // 3. RIGHT SIDE FLOWING GOLDEN WAVES
    // Symmetrical radiant curves from outer right edge toward the inner card
    const rightCount = 22;
    for (int i = 0; i < rightCount; i++) {
      final t = i / (rightCount - 1);
      final path = Path();
      
      path.moveTo(w, h * (0.24 + t * 0.60));
      
      path.cubicTo(
        w * (0.96 - t * 0.08),
        h * (0.32 + t * 0.52),
        w * (0.90 - t * 0.14),
        h * (0.72 + t * 0.22),
        w * (0.76 - t * 0.14),
        h * (0.92 - (1 - t) * 0.14),
      );

      final curveAlpha = (math.sin(t * math.pi) * 0.40 + 0.10).clamp(0.08, 0.48);
      final strokeW = 0.8 + t * 0.9;
      
      final paint = Paint()
        ..color = Color.lerp(const Color(0xFFD4AF37), const Color(0xFFF7E2A4), t)!
            .withValues(alpha: curveAlpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW;
      
      canvas.drawPath(path, paint);
    }

    // Additional cross-swoop wave lines on right
    for (int i = 0; i < 10; i++) {
      final t = i / 9.0;
      final path = Path();
      path.moveTo(w * (0.98 - t * 0.10), h);
      path.cubicTo(
        w * (0.93 - t * 0.11),
        h * (0.80 - t * 0.26),
        w * (0.95 - t * 0.08),
        h * (0.50 - t * 0.18),
        w,
        h * (0.35 + t * 0.32),
      );
      final alpha = (math.sin(t * math.pi) * 0.32 + 0.08).clamp(0.06, 0.38);
      final paint = Paint()
        ..color = const Color(0xFFE5C378).withValues(alpha: alpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.9;
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
