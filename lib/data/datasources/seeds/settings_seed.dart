/// Seed data configurations for administrator accounts, clients, and activity logs.
class SettingsSeed {
  /// Static configuration list of system users.
  static const List<Map<String, dynamic>> users = [
    {
      'id': 'u-1',
      'name': 'Administrator',
      'email': 'admin@omevents.in',
      'role': 'admin',
      'is_active': true,
      'created_at': '2026-06-28T08:27:46Z',
    },
  ];

  /// Static configuration list of registered CRM customers.
  static const List<Map<String, dynamic>> customers = [
    {
      'id': 'cust-1',
      'name': 'goswami pushpdant',
      'phone': '7567822153',
      'email': '',
      'address': '',
      'city': '',
      'map_location': '',
      'created_at': '2026-06-28T09:07:54Z',
      'updated_at': '2026-06-28T09:07:54Z',
    },
  ];

  /// Static configuration list of raw leads.
  static const List<Map<String, dynamic>> leads = [];

  /// Static configuration list of audit logs.
  static const List<Map<String, dynamic>> activityLogs = [];
}
