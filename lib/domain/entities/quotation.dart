import 'quotation_version.dart';
import 'quotation_status.dart';
import 'quotation_item.dart';
import 'quotation_timeline_event.dart';

export 'quotation_status.dart';
export 'quotation_item.dart';
export 'quotation_timeline_event.dart';
export 'quotation_automation_log.dart';

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
  final List<QuotationVersion> versions;

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
  final String? internalNotes;

  // Financial locking & operational fields
  final bool isFinancialLocked;
  final bool isPermanentlyLocked;
  final String? operationalNotes;
  final String? bookingDetails;
  final String? staffAssignment;
  final String? logistics;

  // Digital Consent fields
  final DateTime? acceptedAt;
  final int? acceptedVersion;
  final double? acceptedAmount;
  final String? acceptedBy;
  final String? acceptedDevice;
  final String? acceptedIp;
  final String? consentTextVersion;

  // Automation fields
  final List<String> sentReminders;

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
    this.versions = const [],
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
    this.internalNotes,
    this.isFinancialLocked = false,
    this.isPermanentlyLocked = false,
    this.operationalNotes,
    this.bookingDetails,
    this.staffAssignment,
    this.logistics,
    this.acceptedAt,
    this.acceptedVersion,
    this.acceptedAmount,
    this.acceptedBy,
    this.acceptedDevice,
    this.acceptedIp,
    this.consentTextVersion,
    this.sentReminders = const [],
  }) : assert(customerId != '', 'customerId cannot be empty');

  // Backward compatibility getters for Client Portal integration
  String get quotationNumber => publicId;
  double get amount => grandTotal;
  DateTime get expiryDate => createdAt.add(const Duration(days: 7));

  Quotation copyWith({
    String? id,
    String? publicId,
    String? customerPhone,
    String? customerName,
    DateTime? eventDate,
    String? eventTime,
    String? location,
    String? notes,
    double? subtotal,
    double? discount,
    double? deliveryCharge,
    double? travelCharge,
    double? gstPercent,
    double? gstAmount,
    double? grandTotal,
    String? pdfUrl,
    QuotationStatus? status,
    List<QuotationItem>? items,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? customerId,
    List<QuotationVersion>? versions,
    int? version,
    DateTime? publishedAt,
    String? publishedBy,
    String? revisionReason,
    String? revisionMessage,
    String? adminMessage,
    String? customerAction,
    DateTime? customerActionAt,
    DateTime? customerViewedAt,
    DateTime? lastPublishedAt,
    String? internalNotes,
    bool? isFinancialLocked,
    bool? isPermanentlyLocked,
    String? operationalNotes,
    String? bookingDetails,
    String? staffAssignment,
    String? logistics,
    DateTime? acceptedAt,
    int? acceptedVersion,
    double? acceptedAmount,
    String? acceptedBy,
    String? acceptedDevice,
    String? acceptedIp,
    String? consentTextVersion,
    List<String>? sentReminders,
  }) {
    return Quotation(
      id: id ?? this.id,
      publicId: publicId ?? this.publicId,
      customerPhone: customerPhone ?? this.customerPhone,
      customerName: customerName ?? this.customerName,
      eventDate: eventDate ?? this.eventDate,
      eventTime: eventTime ?? this.eventTime,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      deliveryCharge: deliveryCharge ?? this.deliveryCharge,
      travelCharge: travelCharge ?? this.travelCharge,
      gstPercent: gstPercent ?? this.gstPercent,
      gstAmount: gstAmount ?? this.gstAmount,
      grandTotal: grandTotal ?? this.grandTotal,
      pdfUrl: pdfUrl ?? this.pdfUrl,
      status: status ?? this.status,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      customerId: customerId ?? this.customerId,
      versions: versions ?? this.versions,
      version: version ?? this.version,
      publishedAt: publishedAt ?? this.publishedAt,
      publishedBy: publishedBy ?? this.publishedBy,
      revisionReason: revisionReason ?? this.revisionReason,
      revisionMessage: revisionMessage ?? this.revisionMessage,
      adminMessage: adminMessage ?? this.adminMessage,
      customerAction: customerAction ?? this.customerAction,
      customerActionAt: customerActionAt ?? this.customerActionAt,
      customerViewedAt: customerViewedAt ?? this.customerViewedAt,
      lastPublishedAt: lastPublishedAt ?? this.lastPublishedAt,
      internalNotes: internalNotes ?? this.internalNotes,
      isFinancialLocked: isFinancialLocked ?? this.isFinancialLocked,
      isPermanentlyLocked: isPermanentlyLocked ?? this.isPermanentlyLocked,
      operationalNotes: operationalNotes ?? this.operationalNotes,
      bookingDetails: bookingDetails ?? this.bookingDetails,
      staffAssignment: staffAssignment ?? this.staffAssignment,
      logistics: logistics ?? this.logistics,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      acceptedVersion: acceptedVersion ?? this.acceptedVersion,
      acceptedAmount: acceptedAmount ?? this.acceptedAmount,
      acceptedBy: acceptedBy ?? this.acceptedBy,
      acceptedDevice: acceptedDevice ?? this.acceptedDevice,
      acceptedIp: acceptedIp ?? this.acceptedIp,
      consentTextVersion: consentTextVersion ?? this.consentTextVersion,
      sentReminders: sentReminders ?? this.sentReminders,
    );
  }

  Quotation resetConsent() {
    return Quotation(
      id: id,
      publicId: publicId,
      customerPhone: customerPhone,
      customerName: customerName,
      eventDate: eventDate,
      eventTime: eventTime,
      location: location,
      notes: notes,
      subtotal: subtotal,
      discount: discount,
      deliveryCharge: deliveryCharge,
      travelCharge: travelCharge,
      gstPercent: gstPercent,
      gstAmount: gstAmount,
      grandTotal: grandTotal,
      pdfUrl: pdfUrl,
      status: status,
      items: items,
      createdAt: createdAt,
      updatedAt: updatedAt,
      customerId: customerId,
      versions: versions,
      version: version,
      publishedAt: publishedAt,
      publishedBy: publishedBy,
      revisionReason: revisionReason,
      revisionMessage: revisionMessage,
      adminMessage: adminMessage,
      customerAction: customerAction,
      customerActionAt: customerActionAt,
      customerViewedAt: customerViewedAt,
      lastPublishedAt: lastPublishedAt,
      internalNotes: internalNotes,
      isFinancialLocked: isFinancialLocked,
      isPermanentlyLocked: isPermanentlyLocked,
      operationalNotes: operationalNotes,
      bookingDetails: bookingDetails,
      staffAssignment: staffAssignment,
      logistics: logistics,
      acceptedAt: null,
      acceptedVersion: null,
      acceptedAmount: null,
      acceptedBy: null,
      acceptedDevice: null,
      acceptedIp: null,
      consentTextVersion: null,
      sentReminders: sentReminders,
    );
  }

  List<QuotationTimelineEvent> get timeline {
    final events = <QuotationTimelineEvent>[];

    // 1. Created Event
    events.add(QuotationTimelineEvent(
      title: 'Proposal Initiated',
      description: 'Initial quotation draft created in system.',
      timestamp: createdAt,
      status: QuotationStatus.draft,
    ));

    // 2. Published Event
    if (publishedAt != null) {
      events.add(QuotationTimelineEvent(
        title: 'Proposal Published',
        description: 'Design proposal published by Admin.',
        timestamp: publishedAt!,
        status: QuotationStatus.published,
      ));
    }

    // 3. Viewed Event
    if (customerViewedAt != null) {
      events.add(QuotationTimelineEvent(
        title: 'Proposal Viewed',
        description: 'Opened and reviewed in Customer Portal.',
        timestamp: customerViewedAt!,
        status: QuotationStatus.viewed,
      ));
    }

    // 4. Historical Versions (Snapshots)
    for (var ver in versions) {
      events.add(QuotationTimelineEvent(
        title: 'Revision v${ver.versionNumber} Published',
        description: ver.revisionReason != null && ver.revisionReason!.isNotEmpty
            ? 'Reason: ${ver.revisionReason}'
            : 'Revised proposal published by Admin.',
        timestamp: ver.publishedAt,
        status: QuotationStatus.republished,
      ));
    }

    // 5. Current State Specific Actions / Timeline Events
    if (status == QuotationStatus.revisionRequested && customerActionAt != null) {
      events.add(QuotationTimelineEvent(
        title: 'Revision Requested',
        description: revisionReason != null && revisionReason!.isNotEmpty
            ? 'Feedback: $revisionReason'
            : 'Customer requested layout/pricing adjustments.',
        timestamp: customerActionAt!,
        status: QuotationStatus.revisionRequested,
      ));
    }

    if (status == QuotationStatus.underRevision) {
      events.add(QuotationTimelineEvent(
        title: 'Under Revision',
        description: 'Admin is updating design and pricing details.',
        timestamp: updatedAt,
        status: QuotationStatus.underRevision,
      ));
    }

    if (status == QuotationStatus.acceptedByClient && customerActionAt != null) {
      final consentDetailStr = acceptedBy != null 
          ? '\nSigned by: $acceptedBy on $acceptedDevice (v$acceptedVersion)' 
          : '';
      events.add(QuotationTimelineEvent(
        title: 'Proposal Accepted',
        description: 'Customer approved celebration quotation with legal digital consent.$consentDetailStr',
        timestamp: customerActionAt!,
        status: QuotationStatus.acceptedByClient,
      ));
    }

    if (status == QuotationStatus.rejectedByClient && customerActionAt != null) {
      events.add(QuotationTimelineEvent(
        title: 'Proposal Declined',
        description: 'Customer declined layout proposal.',
        timestamp: customerActionAt!,
        status: QuotationStatus.rejectedByClient,
      ));
    }

    if (status == QuotationStatus.bookingConfirmed) {
      events.add(QuotationTimelineEvent(
        title: 'Booking Confirmed',
        description: 'Quotation successfully converted to active booking.',
        timestamp: updatedAt,
        status: QuotationStatus.bookingConfirmed,
      ));
    }

    if (status == QuotationStatus.completed) {
      events.add(QuotationTimelineEvent(
        title: 'Event Completed',
        description: 'Curated experience was successfully executed.',
        timestamp: updatedAt,
        status: QuotationStatus.completed,
      ));
    }

    if (status == QuotationStatus.cancelled) {
      events.add(QuotationTimelineEvent(
        title: 'Proposal Cancelled',
        description: 'Layout contract has been cancelled.',
        timestamp: updatedAt,
        status: QuotationStatus.cancelled,
      ));
    }

    if (status == QuotationStatus.expired) {
      events.add(QuotationTimelineEvent(
        title: 'Proposal Expired',
        description: 'Proposal expired without customer response.',
        timestamp: updatedAt,
        status: QuotationStatus.expired,
      ));
    }

    if (status == QuotationStatus.archived) {
      events.add(QuotationTimelineEvent(
        title: 'Proposal Archived',
        description: 'This proposal was archived by Admin.',
        timestamp: updatedAt,
        status: QuotationStatus.archived,
      ));
    }

    // Sort events chronologically, with a fallback if timestamps are identical
    events.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return events;
  }
}
