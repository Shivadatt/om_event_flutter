import '../../domain/entities/lead.dart';

class LeadModel extends Lead {
  const LeadModel({
    required super.id,
    required super.name,
    required super.phone,
    required super.email,
    required super.requestType,
    super.eventDate,
    super.budget,
    required super.requirements,
    required super.status,
    super.assignedStaffId,
    required super.createdAt,
    required super.updatedAt,
  });

  static DateTime? _parseNullableDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    try {
      if (value.runtimeType.toString().contains('Timestamp')) {
        return value.toDate();
      }
    } catch (_) {}
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  static DateTime _parseDateTime(dynamic value) {
    return _parseNullableDateTime(value) ?? DateTime.now();
  }

  factory LeadModel.fromJson(Map<String, dynamic> json, String documentId) {
    return LeadModel(
      id: documentId,
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      requestType: json['request_type'] ?? json['requestType'] ?? 'callback',
      eventDate: _parseNullableDateTime(
        json['event_date'] ?? json['eventDate'],
      ),
      budget: (json['budget'] as num?)?.toDouble(),
      requirements: json['requirements'] ?? '',
      status: json['status'] ?? 'new',
      assignedStaffId: json['assigned_staff_id'] ?? json['assignedStaffId'],
      createdAt: _parseDateTime(json['created_at'] ?? json['createdAt']),
      updatedAt: _parseDateTime(json['updated_at'] ?? json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'request_type': requestType,
      'event_date': eventDate?.toIso8601String(),
      'budget': budget,
      'requirements': requirements,
      'status': status,
      'assigned_staff_id': assignedStaffId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
