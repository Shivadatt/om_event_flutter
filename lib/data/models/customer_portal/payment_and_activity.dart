import '../../../domain/entities/customer_payment.dart';
import '../../../domain/entities/customer_activity.dart';
import '../../../domain/entities/customer_wishlist.dart';
import '../../../core/utils/date_parser.dart';

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
