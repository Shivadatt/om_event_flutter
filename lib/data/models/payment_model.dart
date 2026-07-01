import '../../core/utils/date_parser.dart';

class PaymentModel {
  final String id;
  final String bookingId;
  final String provider;
  final String reference;
  final double amount;
  final String status;
  final DateTime? paidAt;
  final DateTime createdAt;

  PaymentModel({
    required this.id,
    required this.bookingId,
    required this.provider,
    required this.reference,
    required this.amount,
    required this.status,
    this.paidAt,
    required this.createdAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json, String id) {
    return PaymentModel(
      id: id,
      bookingId: json['booking_id'] ?? json['bookingId'] ?? '',
      provider: json['provider'] ?? 'cash',
      reference: json['reference'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'pending',
      paidAt: DateParser.parseNullable(json['paid_at'] ?? json['paidAt']),
      createdAt: DateParser.parse(json['created_at'] ?? json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'booking_id': bookingId,
      'provider': provider,
      'reference': reference,
      'amount': amount,
      'status': status,
      'paid_at': paidAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
