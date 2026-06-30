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
      userId: json['userId'],
      action: json['action'] ?? '',
      entityType: json['entityType'] ?? '',
      entityId: json['entityId'] ?? '',
      ipAddress: json['ipAddress'] ?? '',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (userId != null) 'userId': userId,
      'action': action,
      'entityType': entityType,
      'entityId': entityId,
      'ipAddress': ipAddress,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
