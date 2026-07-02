import '../../domain/entities/customer_lead.dart';
import '../../core/utils/date_parser.dart';

class CustomerLeadModel extends CustomerLead {
  const CustomerLeadModel({
    required super.id,
    required super.customerId,
    required super.leadNumber,
    required super.date,
    required super.service,
    required super.branch,
    required super.budget,
    required super.eventDate,
    required super.status,
    super.adminNotes,
  });

  factory CustomerLeadModel.fromJson(Map<String, dynamic> json, String id) {
    return CustomerLeadModel(
      id: id,
      customerId: json['customerId'] ?? '',
      leadNumber: json['leadNumber'] ?? '',
      date: DateParser.parse(json['date']),
      service: json['service'] ?? '',
      branch: json['branch'] ?? '',
      budget: (json['budget'] as num?)?.toDouble() ?? 0.0,
      eventDate: DateParser.parse(json['eventDate']),
      status: json['status'] ?? 'Pending',
      adminNotes: json['adminNotes'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'leadNumber': leadNumber,
      'date': date.toIso8601String(),
      'service': service,
      'branch': branch,
      'budget': budget,
      'eventDate': eventDate.toIso8601String(),
      'status': status,
      'adminNotes': adminNotes,
    };
  }
}
