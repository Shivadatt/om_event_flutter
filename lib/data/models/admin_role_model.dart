import '../../domain/entities/admin_role.dart';

class AdminRoleModel extends AdminRole {
  const AdminRoleModel({
    required super.uid,
    required super.name,
    required super.email,
    required super.role,
    required super.isActive,
    required super.createdAt,
    required super.updatedAt,
    required super.createdBy,
    required super.roleType,
    required super.permissions,
    super.phone,
    super.designation,
    super.bio,
    super.address,
    super.photoUrl,
    super.lastLogin,
  });

  factory AdminRoleModel.fromJson(Map<String, dynamic> json, String uid) {
    // Safely parse timestamps
    DateTime parseTime(dynamic val) {
      if (val == null) return DateTime.now();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
      return DateTime.now();
    }

    DateTime? parseNullableTime(dynamic val) {
      if (val == null) return null;
      if (val is String) return DateTime.tryParse(val);
      if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
      return null;
    }

    final rawPermissions = json['permissions'];
    final Map<String, bool> parsedPermissions = {};
    if (rawPermissions is Map) {
      rawPermissions.forEach((key, value) {
        parsedPermissions[key.toString()] = value as bool? ?? false;
      });
    }

    return AdminRoleModel(
      uid: uid,
      name: json['name'] ?? json['display_name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'admin',
      isActive: (json['is_active'] ?? json['isActive']) as bool? ?? true,
      createdAt: parseTime(json['created_at'] ?? json['createdAt']),
      updatedAt: parseTime(json['updated_at'] ?? json['updatedAt']),
      createdBy: json['created_by'] ?? json['createdBy'] ?? '',
      roleType: json['role_type'] ?? json['roleType'] ?? 'demo_admin',
      permissions: parsedPermissions,
      phone: json['phone'] ?? '',
      designation: json['designation'] ?? '',
      bio: json['bio'] ?? '',
      address: json['address'] ?? '',
      photoUrl: json['photo_url'] ?? json['photoUrl'] ?? '',
      lastLogin: parseNullableTime(json['last_login'] ?? json['lastLogin']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'display_name': name,
      'email': email,
      'role': role,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'created_by': createdBy,
      'role_type': roleType,
      'permissions': permissions,
      'phone': phone,
      'designation': designation,
      'bio': bio,
      'address': address,
      'photo_url': photoUrl,
      if (lastLogin != null) 'last_login': lastLogin!.toIso8601String(),
    };
  }
}
