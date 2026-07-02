import '../../domain/entities/customer_booking.dart';
import '../../core/utils/date_parser.dart';

class CustomerBookingModel extends CustomerBooking {
  const CustomerBookingModel({
    required super.id,
    required super.customerId,
    required super.bookingNumber,
    required super.eventName,
    required super.package,
    required super.branch,
    required super.decorationType,
    required super.date,
    required super.venue,
    required super.amount,
    required super.advancePaid,
    required super.remainingAmount,
    required super.assignedBranch,
    required super.assignedContact,
    required super.status,
  });

  factory CustomerBookingModel.fromJson(Map<String, dynamic> json, String id) {
    return CustomerBookingModel(
      id: id,
      customerId: json['customerId'] ?? '',
      bookingNumber: json['bookingNumber'] ?? '',
      eventName: json['eventName'] ?? '',
      package: json['package'] ?? '',
      branch: json['branch'] ?? '',
      decorationType: json['decorationType'] ?? '',
      date: DateParser.parse(json['date']),
      venue: json['venue'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      advancePaid: (json['advancePaid'] as num?)?.toDouble() ?? 0.0,
      remainingAmount: (json['remainingAmount'] as num?)?.toDouble() ?? 0.0,
      assignedBranch: json['assignedBranch'] ?? '',
      assignedContact: json['assignedContact'] ?? '',
      status: json['status'] ?? 'Pending',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'bookingNumber': bookingNumber,
      'eventName': eventName,
      'package': package,
      'branch': branch,
      'decorationType': decorationType,
      'date': date.toIso8601String(),
      'venue': venue,
      'amount': amount,
      'advancePaid': advancePaid,
      'remainingAmount': remainingAmount,
      'assignedBranch': assignedBranch,
      'assignedContact': assignedContact,
      'status': status,
    };
  }
}
