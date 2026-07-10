enum QuotationStatus {
  draft,
  published,
  viewed,
  revisionRequested,
  underRevision,
  republished,
  acceptedByClient,
  rejectedByClient,
  expired,
  bookingConfirmed,
  inProgress,
  completed,
  cancelled,
  archived;

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
      case 'underrevision':
        return QuotationStatus.underRevision;
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
      case 'archived':
        return QuotationStatus.archived;
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
        return to == QuotationStatus.published ||
            to == QuotationStatus.cancelled ||
            to == QuotationStatus.archived;
      case QuotationStatus.published:
        return to == QuotationStatus.viewed ||
            to == QuotationStatus.acceptedByClient ||
            to == QuotationStatus.rejectedByClient ||
            to == QuotationStatus.revisionRequested ||
            to == QuotationStatus.underRevision ||
            to == QuotationStatus.expired ||
            to == QuotationStatus.cancelled ||
            to == QuotationStatus.archived;
      case QuotationStatus.viewed:
        return to == QuotationStatus.acceptedByClient ||
            to == QuotationStatus.rejectedByClient ||
            to == QuotationStatus.revisionRequested ||
            to == QuotationStatus.underRevision ||
            to == QuotationStatus.expired ||
            to == QuotationStatus.cancelled ||
            to == QuotationStatus.archived;
      case QuotationStatus.revisionRequested:
        return to == QuotationStatus.underRevision ||
            to == QuotationStatus.republished ||
            to == QuotationStatus.cancelled ||
            to == QuotationStatus.draft ||
            to == QuotationStatus.archived;
      case QuotationStatus.underRevision:
        return to == QuotationStatus.republished ||
            to == QuotationStatus.cancelled ||
            to == QuotationStatus.archived;
      case QuotationStatus.republished:
        return to == QuotationStatus.viewed ||
            to == QuotationStatus.acceptedByClient ||
            to == QuotationStatus.rejectedByClient ||
            to == QuotationStatus.revisionRequested ||
            to == QuotationStatus.underRevision ||
            to == QuotationStatus.expired ||
            to == QuotationStatus.cancelled ||
            to == QuotationStatus.archived;
      case QuotationStatus.acceptedByClient:
        return to == QuotationStatus.bookingConfirmed ||
            to == QuotationStatus.cancelled ||
            to == QuotationStatus.archived;
      case QuotationStatus.bookingConfirmed:
        return to == QuotationStatus.inProgress ||
            to == QuotationStatus.completed ||
            to == QuotationStatus.cancelled ||
            to == QuotationStatus.archived;
      case QuotationStatus.inProgress:
        return to == QuotationStatus.completed ||
            to == QuotationStatus.cancelled;
      case QuotationStatus.rejectedByClient:
        return to == QuotationStatus.republished ||
            to == QuotationStatus.cancelled ||
            to == QuotationStatus.archived;
      case QuotationStatus.expired:
        return to == QuotationStatus.republished ||
            to == QuotationStatus.cancelled ||
            to == QuotationStatus.draft ||
            to == QuotationStatus.archived;
      case QuotationStatus.completed:
      case QuotationStatus.cancelled:
      case QuotationStatus.archived:
        return false;
    }
  }
}
