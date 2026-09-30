import '../../domain/entities/customer_lead.dart';
import '../../core/utils/date_parser.dart';

class CustomerLeadModel extends CustomerLead {
  const CustomerLeadModel({
    required super.id,
    required super.customerId,
    super.customerName,
    super.customerEmail,
    super.customerPhone,
    required super.leadNumber,
    required super.date,
    required super.service,
    required super.branch,
    required super.budget,
    required super.eventDate,
    required super.status,
    super.adminNotes,
    super.serviceId = '',
    super.serviceSlug = '',
    super.imageUrl = '',
    super.categoryId = '',
  });

  factory CustomerLeadModel.fromJson(Map<String, dynamic> json, String id) {
    return CustomerLeadModel(
      id: id,
      customerId: json['customerId'] ?? json['customer_id'] ?? '',
      customerName: json['customerName'] ?? json['customer_name'] ?? '',
      customerEmail: json['customerEmail'] ?? json['customer_email'] ?? '',
      customerPhone: json['customerPhone'] ?? json['customer_phone'] ?? '',
      leadNumber: json['leadNumber'] ?? json['lead_number'] ?? '',
      date: DateParser.parse(json['date'] ?? json['created_at']),
      service: json['service'] ?? json['service_required'] ?? '',
      branch: json['branch'] ?? json['branch_location'] ?? '',
      budget: (json['budget'] ?? json['approx_budget'] as num?)?.toDouble() ?? 0.0,
      eventDate: DateParser.parse(json['eventDate'] ?? json['target_event_date']),
      status: json['status'] ?? 'Pending',
      adminNotes: json['adminNotes'] ?? json['notes'] ?? '',
      serviceId: json['serviceId'] ?? json['service_id'] ?? json['itemId'] ?? json['item_id'] ?? '',
      serviceSlug: json['serviceSlug'] ?? json['service_slug'] ?? json['slug'] ?? '',
      imageUrl: json['imageUrl'] ?? json['image_url'] ?? json['coverImage'] ?? json['cover_image'] ?? '',
      categoryId: json['categoryId'] ?? json['category_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'customer_id': customerId,
      'customerName': customerName,
      'customer_name': customerName,
      'customerEmail': customerEmail,
      'customer_email': customerEmail,
      'customerPhone': customerPhone,
      'customer_phone': customerPhone,
      'leadNumber': leadNumber,
      'lead_number': leadNumber,
      'date': date.toIso8601String(),
      'service': service,
      'service_required': service,
      'branch': branch,
      'branch_location': branch,
      'budget': budget,
      'approx_budget': budget,
      'eventDate': eventDate.toIso8601String(),
      'target_event_date': eventDate.toIso8601String(),
      'status': status,
      'adminNotes': adminNotes,
      'notes': adminNotes,
      'serviceId': serviceId,
      'service_id': serviceId,
      'serviceSlug': serviceSlug,
      'service_slug': serviceSlug,
      'imageUrl': imageUrl,
      'image_url': imageUrl,
      'categoryId': categoryId,
      'category_id': categoryId,
      'created_at': date.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }
}
