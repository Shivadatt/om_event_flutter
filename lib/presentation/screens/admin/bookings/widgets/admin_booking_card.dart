import 'package:flutter/material.dart';
import '../../../../../core/config/app_theme.dart';
import '../../../../../core/utils/formatters.dart';
import '../../../../../domain/entities/quotation.dart';
import 'admin_booking_details_dialog.dart';
import 'admin_cancellation_review_dialog.dart';

class AdminBookingCard extends StatelessWidget {
  final Quotation booking;

  const AdminBookingCard({super.key, required this.booking});

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
    final serviceName = booking.items.firstOrNull?.name ?? "Event Decor";
    final packageName = booking.items.firstOrNull?.theme ?? (booking.bookingDetails ?? "Standard");
    final isCancRequested = booking.customerAction == 'cancellation_requested' && booking.status != QuotationStatus.cancelled;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF122018),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1E332B), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                booking.publicId,
                style: AppTheme.sansBody(fontSize: 13, color: goldColor, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _getStatusColor(booking.status).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: _getStatusColor(booking.status)),
                ),
                child: Text(
                  isCancRequested ? "CANCELLATION REQ" : booking.status.name.toUpperCase(),
                  style: AppTheme.sansBody(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: isCancRequested ? const Color(0xFFEF4444) : _getStatusColor(booking.status),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            booking.customerName,
            style: AppTheme.sansBody(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
          ),
          Text(
            booking.customerPhone,
            style: AppTheme.sansBody(fontSize: 11, color: Colors.white54),
          ),
          const SizedBox(height: 8),
          Text(
            "$serviceName • $packageName",
            style: AppTheme.sansBody(fontSize: 12, color: Colors.white70),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.event_outlined, size: 13, color: Color(0xFFD4AF37)),
              const SizedBox(width: 4),
              Text(
                "${AppFormatters.formatDate(booking.eventDate)} at ${booking.eventTime}",
                style: AppTheme.sansBody(fontSize: 11, color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 13, color: Color(0xFFD4AF37)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  booking.location,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.sansBody(fontSize: 11, color: Colors.white60),
                ),
              ),
            ],
          ),
          const Divider(color: Color(0xFF1E332B), height: 16),
          Row(
            children: [
              Text(
                AppFormatters.formatCurrency(booking.grandTotal),
                style: AppTheme.sansBody(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              if (isCancRequested)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: OutlinedButton(
                    onPressed: () => showAdminCancellationReviewDialog(context, booking),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFEF4444)),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    ),
                    child: const Text("Review Cancel", style: TextStyle(fontSize: 11, color: Color(0xFFEF4444))),
                  ),
                ),
              ElevatedButton(
                onPressed: () => showAdminBookingDetailsDialog(context, booking),
                style: ElevatedButton.styleFrom(
                  backgroundColor: goldColor,
                  foregroundColor: const Color(0xFF0F1B18),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                child: const Text("View Details", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
