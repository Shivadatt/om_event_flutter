import '../../domain/entities/customer_quotation.dart';
import '../../domain/entities/booking_timeline.dart';
import '../../domain/entities/customer_payment.dart';
import '../../domain/entities/customer_notification.dart';
import '../../domain/entities/customer_document.dart';
import '../../domain/entities/booking_gallery.dart';
import '../../domain/entities/customer_wishlist.dart';
import '../../domain/entities/rebook_request.dart';
import '../../domain/entities/offer.dart';
import '../../domain/entities/customer_activity.dart';
import '../../domain/entities/support_ticket.dart';
import '../../domain/entities/coupon.dart';
import '../../domain/entities/coordinator.dart';
import '../../domain/entities/inventory_item.dart';
import '../../domain/entities/staff_log.dart';
import '../../domain/entities/expense_item.dart';
import '../../domain/entities/booking_agreement.dart';
import '../../core/utils/date_parser.dart';

// 1. CustomerQuotationModel
class CustomerQuotationItemModel extends CustomerQuotationItem {
  const CustomerQuotationItemModel({
    required super.experienceId,
    required super.name,
    required super.quantity,
    required super.unitPrice,
    required super.color,
    required super.theme,
    required super.notes,
  });

  factory CustomerQuotationItemModel.fromJson(Map<String, dynamic> json) {
    return CustomerQuotationItemModel(
      experienceId: json['experienceId'] ?? json['decoration_item_slug'] ?? '',
      name: json['name'] ?? '',
      quantity: json['quantity'] ?? 1,
      unitPrice: (json['unitPrice'] ?? json['unit_price'] as num?)?.toDouble() ?? 0.0,
      color: json['color'] ?? '',
      theme: json['theme'] ?? '',
      notes: json['notes'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'experienceId': experienceId,
      'name': name,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'color': color,
      'theme': theme,
      'notes': notes,
    };
  }
}

class CustomerQuotationModel extends CustomerQuotation {
  const CustomerQuotationModel({
    required super.id,
    required super.customerId,
    required super.quotationNumber,
    required super.date,
    required super.amount,
    required super.status,
    required super.expiryDate,
    required super.pdfUrl,
    super.notes,
    super.versionHistory,
    required List<CustomerQuotationItemModel> super.items,
  });

  factory CustomerQuotationModel.fromJson(Map<String, dynamic> json, String id) {
    final rawItems = json['items'] as List? ?? [];
    final itemsList = rawItems
        .map((e) => CustomerQuotationItemModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    return CustomerQuotationModel(
      id: id,
      customerId: json['customerId'] ?? '',
      quotationNumber: json['quotationNumber'] ?? '',
      date: DateParser.parse(json['date']),
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'pending',
      expiryDate: DateParser.parse(json['expiryDate']),
      pdfUrl: json['pdfUrl'] ?? '',
      notes: json['notes'] ?? '',
      versionHistory: List<String>.from(json['versionHistory'] ?? []),
      items: itemsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'quotationNumber': quotationNumber,
      'date': date.toIso8601String(),
      'amount': amount,
      'status': status,
      'expiryDate': expiryDate.toIso8601String(),
      'pdfUrl': pdfUrl,
      'notes': notes,
      'versionHistory': versionHistory,
      'items': items.map((e) => (e as CustomerQuotationItemModel).toJson()).toList(),
    };
  }
}

// 2. BookingTimelineModel
class BookingTimelineModel extends BookingTimeline {
  const BookingTimelineModel({
    required super.id,
    required super.bookingId,
    required super.status,
    required super.updatedTime,
    super.notes,
  });

  factory BookingTimelineModel.fromJson(Map<String, dynamic> json, String id) {
    return BookingTimelineModel(
      id: id,
      bookingId: json['bookingId'] ?? '',
      status: json['status'] ?? '',
      updatedTime: DateParser.parse(json['updatedTime']),
      notes: json['notes'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookingId': bookingId,
      'status': status,
      'updatedTime': updatedTime.toIso8601String(),
      'notes': notes,
    };
  }
}

// 3. CustomerPaymentModel
class CustomerPaymentModel extends CustomerPayment {
  const CustomerPaymentModel({
    required super.id,
    required super.customerId,
    required super.bookingId,
    required super.amount,
    required super.status,
    required super.method,
    required super.receiptUrl,
    required super.invoiceUrl,
    required super.paymentDate,
  });

  factory CustomerPaymentModel.fromJson(Map<String, dynamic> json, String id) {
    return CustomerPaymentModel(
      id: id,
      customerId: json['customerId'] ?? '',
      bookingId: json['bookingId'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'pending',
      method: json['method'] ?? 'UPI',
      receiptUrl: json['receiptUrl'] ?? '',
      invoiceUrl: json['invoiceUrl'] ?? '',
      paymentDate: DateParser.parse(json['paymentDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'bookingId': bookingId,
      'amount': amount,
      'status': status,
      'method': method,
      'receiptUrl': receiptUrl,
      'invoiceUrl': invoiceUrl,
      'paymentDate': paymentDate.toIso8601String(),
    };
  }
}

// 4. CustomerNotificationModel
class CustomerNotificationModel extends CustomerNotification {
  const CustomerNotificationModel({
    required super.id,
    required super.customerId,
    required super.title,
    required super.body,
    required super.type,
    required super.isRead,
    super.branch,
    required super.createdAt,
    super.isArchived,
    super.priority,
    super.expiresAt,
  });

  factory CustomerNotificationModel.fromJson(Map<String, dynamic> json, String id) {
    return CustomerNotificationModel(
      id: id,
      customerId: json['customerId'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      type: json['type'] ?? 'Announcement',
      isRead: json['isRead'] ?? false,
      branch: json['branch'] ?? '',
      createdAt: DateParser.parse(json['createdAt']),
      isArchived: json['isArchived'] ?? false,
      priority: json['priority'] ?? 'normal',
      expiresAt: json['expiresAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'title': title,
      'body': body,
      'type': type,
      'isRead': isRead,
      'branch': branch,
      'createdAt': createdAt.toIso8601String(),
      'isArchived': isArchived,
      'priority': priority,
      'expiresAt': expiresAt,
    };
  }
}

// 5. CustomerDocumentModel
class CustomerDocumentModel extends CustomerDocument {
  const CustomerDocumentModel({
    required super.id,
    required super.customerId,
    required super.bookingId,
    required super.name,
    required super.url,
    required super.type,
    required super.createdAt,
  });

  factory CustomerDocumentModel.fromJson(Map<String, dynamic> json, String id) {
    return CustomerDocumentModel(
      id: id,
      customerId: json['customerId'] ?? '',
      bookingId: json['bookingId'] ?? '',
      name: json['name'] ?? '',
      url: json['url'] ?? '',
      type: json['type'] ?? 'Invoice',
      createdAt: DateParser.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'bookingId': bookingId,
      'name': name,
      'url': url,
      'type': type,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

// 6. BookingGalleryModel
class BookingGalleryModel extends BookingGallery {
  const BookingGalleryModel({
    required super.id,
    required super.customerId,
    required super.bookingId,
    required super.mediaUrls,
    required super.createdAt,
  });

  factory BookingGalleryModel.fromJson(Map<String, dynamic> json, String id) {
    return BookingGalleryModel(
      id: id,
      customerId: json['customerId'] ?? '',
      bookingId: json['bookingId'] ?? '',
      mediaUrls: List<String>.from(json['mediaUrls'] ?? []),
      createdAt: DateParser.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'bookingId': bookingId,
      'mediaUrls': mediaUrls,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

// 7. CustomerWishlistModel
class CustomerWishlistModel extends CustomerWishlist {
  const CustomerWishlistModel({
    required super.id,
    required super.customerId,
    required super.experienceId,
    required super.addedAt,
  });

  factory CustomerWishlistModel.fromJson(Map<String, dynamic> json, String id) {
    return CustomerWishlistModel(
      id: id,
      customerId: json['customerId'] ?? '',
      experienceId: json['experienceId'] ?? '',
      addedAt: DateParser.parse(json['addedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'experienceId': experienceId,
      'addedAt': addedAt.toIso8601String(),
    };
  }
}

// 8. RebookRequestModel
class RebookRequestModel extends RebookRequest {
  const RebookRequestModel({
    required super.id,
    required super.customerId,
    required super.previousBookingId,
    required super.newDate,
    required super.status,
    required super.createdAt,
  });

  factory RebookRequestModel.fromJson(Map<String, dynamic> json, String id) {
    return RebookRequestModel(
      id: id,
      customerId: json['customerId'] ?? '',
      previousBookingId: json['previousBookingId'] ?? '',
      newDate: DateParser.parse(json['newDate']),
      status: json['status'] ?? 'Pending',
      createdAt: DateParser.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'previousBookingId': previousBookingId,
      'newDate': newDate.toIso8601String(),
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

// 9. OfferModel
class OfferModel extends Offer {
  const OfferModel({
    required super.id,
    required super.title,
    required super.description,
    required super.imageUrl,
    required super.isActive,
    required super.priority,
    required super.expiryDate,
    required super.branch,
  });

  factory OfferModel.fromJson(Map<String, dynamic> json, String id) {
    return OfferModel(
      id: id,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      isActive: json['isActive'] ?? true,
      priority: (json['priority'] as num?)?.toInt() ?? 0,
      expiryDate: DateParser.parse(json['expiryDate']),
      branch: json['branch'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'isActive': isActive,
      'priority': priority,
      'expiryDate': expiryDate.toIso8601String(),
      'branch': branch,
    };
  }
}

// 10. CustomerActivityModel
class CustomerActivityModel extends CustomerActivity {
  const CustomerActivityModel({
    required super.id,
    required super.customerId,
    required super.status,
    required super.updatedAt,
    super.details,
  });

  factory CustomerActivityModel.fromJson(Map<String, dynamic> json, String id) {
    return CustomerActivityModel(
      id: id,
      customerId: json['customerId'] ?? '',
      status: json['status'] ?? 'Registered',
      updatedAt: DateParser.parse(json['updatedAt']),
      details: json['details'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'status': status,
      'updatedAt': updatedAt.toIso8601String(),
      'details': details,
    };
  }
}

// 11. SupportTicketModel
class SupportTicketModel extends SupportTicket {
  const SupportTicketModel({
    required super.id,
    required super.customerId,
    required super.subject,
    required super.status,
    required super.messages,
    required super.createdAt,
  });

  factory SupportTicketModel.fromJson(Map<String, dynamic> json, String id) {
    return SupportTicketModel(
      id: id,
      customerId: json['customerId'] ?? '',
      subject: json['subject'] ?? '',
      status: json['status'] ?? 'Open',
      messages: List<String>.from(json['messages'] ?? []),
      createdAt: DateParser.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'subject': subject,
      'status': status,
      'messages': messages,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

// 12. CouponModel
class CouponModel extends Coupon {
  const CouponModel({
    required super.id,
    required super.code,
    required super.discount,
    required super.validity,
    required super.usageLimit,
    required super.branch,
  });

  factory CouponModel.fromJson(Map<String, dynamic> json, String id) {
    return CouponModel(
      id: id,
      code: json['code'] ?? '',
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      validity: DateParser.parse(json['validity']),
      usageLimit: (json['usageLimit'] as num?)?.toInt() ?? 0,
      branch: json['branch'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'discount': discount,
      'validity': validity.toIso8601String(),
      'usageLimit': usageLimit,
      'branch': branch,
    };
  }
}

// 13. CoordinatorModel
class CoordinatorModel extends Coordinator {
  const CoordinatorModel({
    required super.id,
    required super.name,
    required super.phone,
    required super.photoUrl,
    required super.isActive,
  });

  factory CoordinatorModel.fromJson(Map<String, dynamic> json, String id) {
    return CoordinatorModel(
      id: id,
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      photoUrl: json['photoUrl'] ?? '',
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'photoUrl': photoUrl,
      'isActive': isActive,
    };
  }
}

// 14. InventoryItemModel
class InventoryItemModel extends InventoryItem {
  const InventoryItemModel({
    required super.id,
    required super.name,
    required super.stock,
    required super.lowStockThreshold,
    required super.supplierName,
  });

  factory InventoryItemModel.fromJson(Map<String, dynamic> json, String id) {
    return InventoryItemModel(
      id: id,
      name: json['name'] ?? '',
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      lowStockThreshold: (json['lowStockThreshold'] as num?)?.toInt() ?? 5,
      supplierName: json['supplierName'] ?? 'General Supplier',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'stock': stock,
      'lowStockThreshold': lowStockThreshold,
      'supplierName': supplierName,
    };
  }
}

// 15. StaffLogModel
class StaffLogModel extends StaffLog {
  const StaffLogModel({
    required super.id,
    required super.name,
    required super.attendance,
    required super.taskDescription,
    required super.date,
  });

  factory StaffLogModel.fromJson(Map<String, dynamic> json, String id) {
    return StaffLogModel(
      id: id,
      name: json['name'] ?? '',
      attendance: json['attendance'] ?? 'Present',
      taskDescription: json['taskDescription'] ?? '',
      date: DateParser.parse(json['date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'attendance': attendance,
      'taskDescription': taskDescription,
      'date': date.toIso8601String(),
    };
  }
}

// 16. ExpenseItemModel
class ExpenseItemModel extends ExpenseItem {
  const ExpenseItemModel({
    required super.id,
    required super.category,
    required super.amount,
    required super.date,
    required super.bookingId,
  });

  factory ExpenseItemModel.fromJson(Map<String, dynamic> json, String id) {
    return ExpenseItemModel(
      id: id,
      category: json['category'] ?? 'Decorations',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      date: DateParser.parse(json['date']),
      bookingId: json['bookingId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'amount': amount,
      'date': date.toIso8601String(),
      'bookingId': bookingId,
    };
  }
}

// 17. BookingAgreementModel
class BookingAgreementModel extends BookingAgreement {
  const BookingAgreementModel({
    required super.id,
    required super.bookingId,
    required super.terms,
    required super.digitalSignature,
    required super.accepted,
  });

  factory BookingAgreementModel.fromJson(Map<String, dynamic> json, String id) {
    return BookingAgreementModel(
      id: id,
      bookingId: json['bookingId'] ?? '',
      terms: json['terms'] ?? '',
      digitalSignature: json['digitalSignature'] ?? '',
      accepted: json['accepted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookingId': bookingId,
      'terms': terms,
      'digitalSignature': digitalSignature,
      'accepted': accepted,
    };
  }
}
