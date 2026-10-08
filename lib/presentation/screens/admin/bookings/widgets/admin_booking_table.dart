import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/utils/booking_status_helper.dart';
import '../../../../../core/utils/formatters.dart';
import '../../../../../domain/entities/quotation.dart';
import 'admin_booking_details_dialog.dart';
import 'admin_cancellation_review_dialog.dart';

class AdminBookingTable extends StatefulWidget {
  final List<Quotation> bookings;

  const AdminBookingTable({super.key, required this.bookings});

  @override
  State<AdminBookingTable> createState() => _AdminBookingTableState();
}

class _AdminBookingTableState extends State<AdminBookingTable> {
  final ScrollController _verticalScrollController = ScrollController();
  final ScrollController _horizontalScrollController = ScrollController();

  static const goldColor = Color(0xFFECC24A);

  @override
  void dispose() {
    _verticalScrollController.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }

  Color _getStatusColor(Quotation booking, {bool isCancellationRequested = false}) {
    return BookingStatusHelper.getStatusColor(
      booking,
      isCancellationRequested: isCancellationRequested,
    );
  }

  String _getStatusLabel(Quotation booking, bool isCancRequested) {
    if (isCancRequested) return "CANCELLATION REQ";
    return BookingStatusHelper.getDisplayBookingStatus(booking).toUpperCase();
  }

  Widget _buildTableHeader() {
    const headerStyle = TextStyle(
      fontSize: 9.5,
      color: goldColor,
      fontWeight: FontWeight.bold,
      letterSpacing: 0.8,
    );

    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: const BoxDecoration(
        color: Color(0xFF081410),
      ),
      child: const Row(
        children: [
          SizedBox(
            width: 30,
            child: Icon(
              Icons.check_box_outline_blank_rounded,
              size: 15,
              color: Color(0x8DECC24A),
            ),
          ),
          Expanded(flex: 14, child: Text("BOOKING ID", style: headerStyle)),
          Expanded(flex: 18, child: Text("CUSTOMER", style: headerStyle)),
          Expanded(flex: 20, child: Text("SERVICE", style: headerStyle)),
          Expanded(flex: 13, child: Text("EVENT DATE", style: headerStyle)),
          Expanded(flex: 11, child: Text("VENUE", style: headerStyle)),
          Expanded(flex: 10, child: Text("AMOUNT", style: headerStyle)),
          Expanded(flex: 11, child: Text("STATUS", style: headerStyle)),
          Expanded(flex: 11, child: Text("ACTION", style: headerStyle)),
        ],
      ),
    );
  }

  Widget _buildTableRow(BuildContext context, Quotation b) {
    final serviceName = b.items.firstOrNull?.name ?? "Event Decor";
    final isCancRequested = b.customerAction == 'cancellation_requested' && b.status != QuotationStatus.cancelled;
    final statusCol = _getStatusColor(b, isCancellationRequested: isCancRequested);
    final statusLabel = _getStatusLabel(b, isCancRequested);
    final initial = b.customerName.isNotEmpty ? b.customerName[0].toUpperCase() : "C";

    return _HoverableTableRow(
      child: Row(
        children: [
          // 0. Checkbox
          const SizedBox(
            width: 30,
            child: Icon(
              Icons.check_box_outline_blank_rounded,
              size: 15,
              color: Color(0x66ECC24A),
            ),
          ),

          // 1. BOOKING ID
          Expanded(
            flex: 14,
            child: Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Text(
                b.publicId.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.montserrat(
                  fontSize: 11,
                  color: goldColor,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),

          // 2. CUSTOMER
          Expanded(
            flex: 18,
            child: Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Row(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFF162B20),
                      shape: BoxShape.circle,
                      border: Border.all(color: goldColor.withValues(alpha: 0.4), width: 0.8),
                    ),
                    child: Text(
                      initial,
                      style: const TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                        color: goldColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          b.customerName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.montserrat(
                            fontSize: 11.5,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          b.customerPhone,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 9.5, color: Colors.white54),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. SERVICE
          Expanded(
            flex: 20,
            child: Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Text(
                serviceName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11, color: Colors.white70),
              ),
            ),
          ),

          // 4. EVENT DATE
          Expanded(
            flex: 13,
            child: Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppFormatters.formatShortDate(b.eventDate),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    b.eventTime,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 9.5, color: Colors.white54),
                  ),
                ],
              ),
            ),
          ),

          // 5. VENUE
          Expanded(
            flex: 11,
            child: Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Text(
                b.location,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11, color: Colors.white70),
              ),
            ),
          ),

          // 6. AMOUNT
          Expanded(
            flex: 10,
            child: Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Text(
                AppFormatters.formatCurrency(b.grandTotal),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // 7. STATUS
          Expanded(
            flex: 11,
            child: Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: isCancRequested
                        ? const Color(0xFFEF4444).withValues(alpha: 0.15)
                        : statusCol.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isCancRequested
                          ? const Color(0xFFEF4444)
                          : statusCol.withValues(alpha: 0.7),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    statusLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      color: isCancRequested ? const Color(0xFFEF4444) : statusCol,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 8. ACTION
          Expanded(
            flex: 11,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isCancRequested) ...[
                    IconButton(
                      icon: const Icon(Icons.rate_review_outlined, size: 15, color: Color(0xFFEF4444)),
                      tooltip: "Review Cancellation",
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => showAdminCancellationReviewDialog(context, b),
                    ),
                    const SizedBox(width: 4),
                  ],
                  InkWell(
                    onTap: () => showAdminBookingDetailsDialog(context, b),
                    borderRadius: BorderRadius.circular(5),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: goldColor,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: const Text(
                        "Details",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF091410),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 3),
                  IconButton(
                    icon: const Icon(Icons.more_vert_rounded, size: 15, color: goldColor),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: "More Options",
                    onPressed: () => showAdminBookingDetailsDialog(context, b),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tableWidth = constraints.maxWidth > 940 ? constraints.maxWidth : 940.0;
        final needsHorizontalScroll = constraints.maxWidth < 940;

        return Theme(
          data: Theme.of(context).copyWith(
            scrollbarTheme: ScrollbarThemeData(
              thumbColor: WidgetStateProperty.all(goldColor.withValues(alpha: 0.35)),
              trackColor: WidgetStateProperty.all(Colors.transparent),
              thickness: WidgetStateProperty.all(4.0),
              radius: const Radius.circular(4),
            ),
          ),
          child: SingleChildScrollView(
            controller: _horizontalScrollController,
            scrollDirection: Axis.horizontal,
            physics: needsHorizontalScroll
                ? const ClampingScrollPhysics()
                : const NeverScrollableScrollPhysics(),
            child: SizedBox(
              width: tableWidth,
              child: Column(
                children: [
                  // Pinned Header
                  _buildTableHeader(),
                  const Divider(
                    height: 1,
                    thickness: 0.6,
                    color: Color(0xFF1E352B),
                  ),
                  // Scrollable Body
                  Expanded(
                    child: Scrollbar(
                      controller: _verticalScrollController,
                      thumbVisibility: true,
                      child: ListView.separated(
                        controller: _verticalScrollController,
                        itemCount: widget.bookings.length,
                        separatorBuilder: (_, __) => const Divider(
                          height: 1,
                          thickness: 0.6,
                          color: Color(0xFF14261E),
                        ),
                        itemBuilder: (context, index) => _buildTableRow(context, widget.bookings[index]),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _HoverableTableRow extends StatefulWidget {
  final Widget child;

  const _HoverableTableRow({required this.child});

  @override
  State<_HoverableTableRow> createState() => _HoverableTableRowState();
}

class _HoverableTableRowState extends State<_HoverableTableRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        height: 50,
        color: _isHovered ? const Color(0xFF13221C) : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: widget.child,
      ),
    );
  }
}
