enum QuotationStatus {
  draft,
  published,
  viewed,
  revisionRequested,
  republished,
  acceptedByClient,
  rejectedByClient,
  expired,
  bookingConfirmed,
  inProgress,
  completed,
  cancelled;

  String get nameStr => name;

  static QuotationStatus fromString(String val) {
    switch (val.replaceAll('_', '').replaceAll(' ', '').toLowerCase()) {
      case 'draft':
        return QuotationStatus.draft;
      case 'published':
      case 'pending':
        return QuotationStatus.published;
      case 'viewed':
        return QuotationStatus.viewed;
      case 'revisionrequested':
        return QuotationStatus.revisionRequested;
      case 'republished':
        return QuotationStatus.republished;
      case 'acceptedbyclient':
      case 'accepted':
        return QuotationStatus.acceptedByClient;
      case 'rejectedbyclient':
      case 'declinedbyclient':
      case 'rejected':
      case 'declined':
        return QuotationStatus.rejectedByClient;
      case 'expired':
        return QuotationStatus.expired;
      case 'bookingconfirmed':
      case 'confirmed':
        return QuotationStatus.bookingConfirmed;
      case 'inprogress':
        return QuotationStatus.inProgress;
      case 'completed':
        return QuotationStatus.completed;
      case 'cancelled':
        return QuotationStatus.cancelled;
      default:
        return QuotationStatus.draft;
    }
  }
}

class QuotationStatusTransitions {
  static bool isValid(QuotationStatus from, QuotationStatus to) {
    if (from == to) return true;
    switch (from) {
      case QuotationStatus.draft:
        return to == QuotationStatus.published || to == QuotationStatus.cancelled;
      case QuotationStatus.published:
        return to == QuotationStatus.viewed ||
            to == QuotationStatus.acceptedByClient ||
            to == QuotationStatus.rejectedByClient ||
            to == QuotationStatus.revisionRequested ||
            to == QuotationStatus.expired ||
            to == QuotationStatus.cancelled;
      case QuotationStatus.viewed:
        return to == QuotationStatus.acceptedByClient ||
            to == QuotationStatus.rejectedByClient ||
            to == QuotationStatus.revisionRequested ||
            to == QuotationStatus.expired ||
            to == QuotationStatus.cancelled;
      case QuotationStatus.revisionRequested:
        return to == QuotationStatus.republished || to == QuotationStatus.cancelled || to == QuotationStatus.draft;
      case QuotationStatus.republished:
        return to == QuotationStatus.viewed ||
            to == QuotationStatus.acceptedByClient ||
            to == QuotationStatus.rejectedByClient ||
            to == QuotationStatus.revisionRequested ||
            to == QuotationStatus.expired ||
            to == QuotationStatus.cancelled;
      case QuotationStatus.acceptedByClient:
        return to == QuotationStatus.bookingConfirmed || to == QuotationStatus.cancelled;
      case QuotationStatus.bookingConfirmed:
        return to == QuotationStatus.inProgress || to == QuotationStatus.cancelled;
      case QuotationStatus.inProgress:
        return to == QuotationStatus.completed || to == QuotationStatus.cancelled;
      case QuotationStatus.rejectedByClient:
        return to == QuotationStatus.republished || to == QuotationStatus.cancelled;
      case QuotationStatus.expired:
        return to == QuotationStatus.republished || to == QuotationStatus.cancelled || to == QuotationStatus.draft;
      case QuotationStatus.completed:
      case QuotationStatus.cancelled:
        return false;
    }
  }
}

class QuotationItem {
  final String experienceId;
  final String name;
  final int quantity;
  final double unitPrice;
  final String color;
  final String theme;
  final String notes;

  const QuotationItem({
    required this.experienceId,
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.color,
    required this.theme,
    required this.notes,
  });

  double get totalPrice => unitPrice * quantity;
}

class Quotation {
  final String id;
  final String publicId;
  final String customerPhone;
  final String customerName;
  final DateTime eventDate;
  final String eventTime; // e.g. "18:00"
  final String location;
  final String notes;
  final double subtotal;
  final double discount;
  final double deliveryCharge;
  final double travelCharge;
  final double gstPercent;
  final double gstAmount;
  final double grandTotal;
  final String pdfUrl;
  final QuotationStatus status;
  final List<QuotationItem> items;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String customerId;
  final List<String> versionHistory;

  // New versioning and revision tracking fields
  final int version;
  final DateTime? publishedAt;
  final String? publishedBy;
  final String? revisionReason;
  final String? revisionMessage;
  final String? adminMessage;
  final String? customerAction;
  final DateTime? customerActionAt;
  final DateTime? customerViewedAt;
  final DateTime? lastPublishedAt;

  const Quotation({
    required this.id,
    required this.publicId,
    required this.customerPhone,
    required this.customerName,
    required this.eventDate,
    required this.eventTime,
    required this.location,
    required this.notes,
    required this.subtotal,
    required this.discount,
    required this.deliveryCharge,
    required this.travelCharge,
    required this.gstPercent,
    required this.gstAmount,
    required this.grandTotal,
    required this.pdfUrl,
    required this.status,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
    required this.customerId,
    this.versionHistory = const [],
    this.version = 1,
    this.publishedAt,
    this.publishedBy,
    this.revisionReason,
    this.revisionMessage,
    this.adminMessage,
    this.customerAction,
    this.customerActionAt,
    this.customerViewedAt,
    this.lastPublishedAt,
  }) : assert(customerId != '', 'customerId cannot be empty');

  // Backward compatibility getters for Client Portal integration
  String get quotationNumber => publicId;
  double get amount => grandTotal;
  DateTime get expiryDate => createdAt.add(const Duration(days: 7));
}
