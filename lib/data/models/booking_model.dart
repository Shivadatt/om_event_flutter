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
      bookingNumber: json['bookingNumber'] ?? '',
      quotationId: json['quotationId'] ?? '',
      advanceAmount: (json['advanceAmount'] as num?)?.toDouble() ?? 0.0,
      paymentStatus: json['paymentStatus'] ?? 'pending',
      status: json['status'] ?? 'pending',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookingNumber': bookingNumber,
      'quotationId': quotationId,
      'advanceAmount': advanceAmount,
      'paymentStatus': paymentStatus,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
