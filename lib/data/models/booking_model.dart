class BookingModel {
  final String id;
  final String bookingNumber;
  final String quotationId;
  final double advanceAmount;
  final String paymentStatus;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  BookingModel({
    required this.id,
    required this.bookingNumber,
    required this.quotationId,
    required this.advanceAmount,
    required this.paymentStatus,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json, String id) {
    return BookingModel(
      id: id,
      bookingNumber: json['booking_number'] ?? json['bookingNumber'] ?? '',
      quotationId: json['quotation_id'] ?? json['quotationId'] ?? '',
      advanceAmount: ((json['advance_amount'] ?? json['advanceAmount']) as num?)?.toDouble() ?? 0.0,
      paymentStatus: json['payment_status'] ?? json['paymentStatus'] ?? 'pending',
      status: json['status'] ?? 'pending',
      createdAt: (json['created_at'] ?? json['createdAt']) != null 
          ? DateTime.parse((json['created_at'] ?? json['createdAt'])) 
          : DateTime.now(),
      updatedAt: (json['updated_at'] ?? json['updatedAt']) != null 
          ? DateTime.parse((json['updated_at'] ?? json['updatedAt'])) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'booking_number': bookingNumber,
      'quotation_id': quotationId,
      'advance_amount': advanceAmount,
      'payment_status': paymentStatus,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
