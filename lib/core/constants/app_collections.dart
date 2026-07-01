/// Centralized Firestore collection name constants.
/// All collection queries must use these identifiers.
class AppCollections {
  AppCollections._();

  /// Administrator role profiles.
  static const String admin = 'admin';

  /// Published event categories.
  static const String categories = 'categories';

  /// Decoration service items.
  static const String items = 'items';

  /// Item secondary gallery images.
  static const String itemImages = 'item_images';

  /// CRM customer profiles.
  static const String customers = 'customers';

  /// Contact form & inquiry leads.
  static const String leads = 'leads';

  /// Event quotations (proposals).
  static const String quotations = 'quotations';

  /// Quotation line items.
  static const String quotationItems = 'quotation_items';

  /// Studio bookings.
  static const String bookings = 'bookings';

  /// Published customer reviews.
  static const String reviews = 'reviews';

  /// Activity audit logs.
  static const String activityLogs = 'activity_logs';

  /// Application configuration.
  static const String settings = 'settings';

  /// Registered app users.
  static const String users = 'users';

  /// Payment records.
  static const String payments = 'payments';
}
