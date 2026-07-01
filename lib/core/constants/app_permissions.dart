/// Centralized Firestore permission key constants used in RBAC role documents.
class AppPermissions {
  AppPermissions._();

  /// Master flag granting unrestricted access.
  static const String manageEverything = 'can_manage_everything';

  /// Permission to create, edit, or delete categories.
  static const String manageCategories = 'can_manage_categories';

  /// Permission to create, edit, or delete service items.
  static const String manageItems = 'can_manage_items';

  /// Permission to view and manage CRM customers.
  static const String manageCustomers = 'can_manage_customers';

  /// Permission to view and manage admin users.
  static const String manageUsers = 'can_manage_users';

  /// Permission to approve or delete customer reviews.
  static const String manageReviews = 'can_manage_reviews';

  /// Permission to create or update event quotations.
  static const String manageQuotes = 'can_manage_quotes';

  /// Permission to manage sales leads.
  static const String manageLeads = 'can_manage_leads';

  /// Permission to modify global business settings.
  static const String manageSettings = 'can_manage_settings';

  /// Permission to permanently delete records.
  static const String canDelete = 'can_delete';

  /// Permission to create new records.
  static const String canCreate = 'can_create';

  /// Permission to edit existing records.
  static const String canEdit = 'can_edit';

  /// Provides the full set of permissions for a super admin.
  static Map<String, bool> get superAdminPermissions => {
    manageEverything: true,
    manageCategories: true,
    manageItems: true,
    manageCustomers: true,
    manageUsers: true,
    manageReviews: true,
    manageQuotes: true,
    manageLeads: true,
    manageSettings: true,
    canDelete: true,
    canCreate: true,
    canEdit: true,
  };

  /// Provides a limited permission set for demo administrators.
  static Map<String, bool> get demoAdminPermissions => {
    manageCategories: true,
    manageItems: true,
    manageCustomers: true,
    manageUsers: false,
    manageReviews: false,
    manageQuotes: true,
    manageLeads: true,
    manageSettings: false,
    canDelete: false,
    canCreate: true,
    canEdit: true,
  };

  /// Provides a completely restricted set for regular customers.
  static Map<String, bool> get customerPermissions => {
    manageCategories: false,
    manageItems: false,
    manageCustomers: false,
    manageUsers: false,
    manageReviews: false,
    manageQuotes: false,
    manageLeads: false,
    manageSettings: false,
    canDelete: false,
    canCreate: false,
    canEdit: false,
  };
}
