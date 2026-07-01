class ActivityLogModel {
  final String id;
  final String? userId;
  final String action;
  final String entityType;
  final String entityId;
  final String ipAddress;
  final DateTime createdAt;

  ActivityLogModel({
    required this.id,
    this.userId,
    required this.action,
    required this.entityType,
    required this.entityId,
    required this.ipAddress,
    required this.createdAt,
  });

  factory ActivityLogModel.fromJson(Map<String, dynamic> json, String id) {
    return ActivityLogModel(
      id: id,
      userId: json['user_id'] ?? json['userId'],
      action: json['action'] ?? '',
      entityType: json['entity_type'] ?? json['entityType'] ?? '',
      entityId: json['entity_id'] ?? json['entityId'] ?? '',
      ipAddress: json['ip_address'] ?? json['ipAddress'] ?? '',
      createdAt:
          (json['created_at'] ?? json['createdAt']) != null
              ? DateTime.parse((json['created_at'] ?? json['createdAt']))
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (userId != null) 'user_id': userId,
      'action': action,
      'entity_type': entityType,
      'entity_id': entityId,
      'ip_address': ipAddress,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
