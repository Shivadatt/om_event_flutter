class AdminRole {
  final String uid;
  final String name;
  final String email;
  final String role;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final String roleType; // 'super_admin' or 'demo_admin'
  final Map<String, bool> permissions;

  // Extended profile fields
  final String phone;
  final String designation;
  final String bio;
  final String address;
  final String photoUrl;
  final DateTime? lastLogin;

  const AdminRole({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    required this.roleType,
    required this.permissions,
    this.phone = '',
    this.designation = '',
    this.bio = '',
    this.address = '',
    this.photoUrl = '',
    this.lastLogin,
  });

  bool hasPermission(String permissionName) {
    if (roleType == 'super_admin') return true;
    return permissions[permissionName] ?? false;
  }
}
