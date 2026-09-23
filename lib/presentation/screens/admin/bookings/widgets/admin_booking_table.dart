import 'package:flutter/material.dart';
import '../../../../../core/config/app_theme.dart';
import '../../../../../core/utils/formatters.dart';
import '../../../../../domain/entities/quotation.dart';
import 'admin_booking_details_dialog.dart';
import 'admin_cancellation_review_dialog.dart';

class AdminBookingTable extends StatelessWidget {
  final List<Quotation> bookings;

  const AdminBookingTable({super.key, required this.bookings});

  Color _getStatusColor(QuotationStatus status) {
    switch (status) {
      case QuotationStatus.published:
      case QuotationStatus.draft:
      case QuotationStatus.viewed:
      case QuotationStatus.republished:
        return const Color(0xFFF59E0B);
      case QuotationStatus.acceptedByClient:
        return const Color(0xFF3B82F6);
      case QuotationStatus.bookingConfirmed:
      case QuotationStatus.inProgress:
        return const Color(0xFF10B981);
      case QuotationStatus.completed:
        return const Color(0xFFD4AF37);
      case QuotationStatus.cancelled:
      case QuotationStatus.rejectedByClient:
        return const Color(0xFFEF4444);
      default:
        return Colors.white54;
    }
  }

  @override
  Widget build(BuildContext context) {
    final goldColor = const Color(0xFFD4AF37);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width - 320),
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(const Color(0xFF0C1714)),
          dataRowColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.hovered)) {
              return const Color(0xFF162923);
            }
            return Colors.transparent;
          }),
          dividerThickness: 0.6,
          horizontalMargin: 20,
          columnSpacing: 24,
          columns: [
            DataColumn(label: Text("BOOKING ID", style: AppTheme.sansBody(fontSize: 10, color: goldColor, fontWeight: FontWeight.bold))),
            DataColumn(label: Text("CUSTOMER", style: AppTheme.sansBody(fontSize: 10, color: goldColor, fontWeight: FontWeight.bold))),
            DataColumn(label: Text("SERVICE", style: AppTheme.sansBody(fontSize: 10, color: goldColor, fontWeight: FontWeight.bold))),
            DataColumn(label: Text("EVENT DATE", style: AppTheme.sansBody(fontSize: 10, color: goldColor, fontWeight: FontWeight.bold))),
            DataColumn(label: Text("VENUE", style: AppTheme.sansBody(fontSize: 10, color: goldColor, fontWeight: FontWeight.bold))),
            DataColumn(label: Text("AMOUNT", style: AppTheme.sansBody(fontSize: 10, color: goldColor, fontWeight: FontWeight.bold))),
            DataColumn(label: Text("STATUS", style: AppTheme.sansBody(fontSize: 10, color: goldColor, fontWeight: FontWeight.bold))),
            DataColumn(label: Text("ACTION", style: AppTheme.sansBody(fontSize: 10, color: goldColor, fontWeight: FontWeight.bold))),
          ],
          rows: bookings.map((b) {
            final serviceName = b.items.firstOrNull?.name ?? "Event Decor";
            final isCancRequested = b.customerAction == 'cancellation_requested' && b.status != QuotationStatus.cancelled;

            return DataRow(
              cells: [
                DataCell(
                  Text(
                    b.publicId,
                    style: AppTheme.sansBody(fontSize: 12, color: goldColor, fontWeight: FontWeight.bold),
                  ),
                ),
                DataCell(
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(b.customerName, style: AppTheme.sansBody(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600)),
                      Text(b.customerPhone, style: AppTheme.sansBody(fontSize: 10, color: Colors.white54)),
                    ],
                  ),
                ),
                DataCell(Text(serviceName, style: AppTheme.sansBody(fontSize: 12, color: Colors.white70))),
                DataCell(
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppFormatters.formatDate(b.eventDate), style: AppTheme.sansBody(fontSize: 12, color: Colors.white)),
                      Text(b.eventTime, style: AppTheme.sansBody(fontSize: 10, color: Colors.white54)),
                    ],
                  ),
                ),
                DataCell(
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 160),
                    child: Text(
                      b.location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.sansBody(fontSize: 12, color: Colors.white70),
                    ),
                  ),
                ),
                DataCell(Text(AppFormatters.formatCurrency(b.grandTotal), style: AppTheme.sansBody(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold))),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _getStatusColor(b.status).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: _getStatusColor(b.status)),
                    ),
                    child: Text(
                      isCancRequested ? "CANCELLATION REQ" : b.status.name.toUpperCase(),
                      style: AppTheme.sansBody(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: isCancRequested ? const Color(0xFFEF4444) : _getStatusColor(b.status),
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isCancRequested)
                        IconButton(
                          icon: const Icon(Icons.rate_review_outlined, size: 18, color: Color(0xFFEF4444)),
                          tooltip: "Review Cancellation",
                          onPressed: () => showAdminCancellationReviewDialog(context, b),
                        ),
                      ElevatedButton(
                        onPressed: () => showAdminBookingDetailsDialog(context, b),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF162923),
                          foregroundColor: goldColor,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                            side: BorderSide(color: goldColor.withValues(alpha: 0.4)),
                          ),
                        ),
                        child: const Text("Details", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
