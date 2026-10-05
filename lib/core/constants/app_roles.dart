/// Centralized administrator role type name constants.
class AppRoles {
  AppRoles._();

  /// Full-access super administrator.
  static const String superAdmin = 'super_admin';

  /// Read/limited-write demo administrator.
  static const String demoAdmin = 'demo_admin';

  /// Standard administrative role.
  static const String admin = 'admin';

  /// Manager role.
  static const String manager = 'manager';

  /// Operations staff role.
  static const String staff = 'staff';

  /// Standard customer / visitor.
  static const String customer = 'customer';

  /// System-created record marker.
  static const String system = 'system';

  /// Checks if a role string represents an administrative/staff role.
  static bool isAdminRole(String? role) {
    if (role == null || role.trim().isEmpty) return false;
    final r = role.toLowerCase().trim();
    return r == superAdmin ||
        r == demoAdmin ||
        r == admin ||
        r == manager ||
        r == staff;
  }
}
