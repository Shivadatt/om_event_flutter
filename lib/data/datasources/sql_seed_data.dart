import 'seeds/category_seed.dart';
import 'seeds/items_seed.dart';
import 'seeds/review_seed.dart';
import 'seeds/settings_seed.dart';
import 'seeds/booking_seed.dart';
import 'seeds/payment_seed.dart';

/// Legacy Seed Data gateway forwarding queries to modular, domain-specific seed files.
class SqlSeedData {
  /// User authentication bootstrap records.
  static List<Map<String, dynamic>> get users => SettingsSeed.users;

  /// Decor catalog categories.
  static List<Map<String, dynamic>> get categories => CategorySeed.categories;

  /// Decor catalog items.
  static List<Map<String, dynamic>> get decorationItems =>
      ItemsSeed.decorationItems;

  /// Secondary gallery images.
  static List<Map<String, dynamic>> get itemImages => ItemsSeed.itemImages;

  /// CRM client entities.
  static List<Map<String, dynamic>> get customers => SettingsSeed.customers;

  /// CRM studio leads.
  static List<Map<String, dynamic>> get leads => SettingsSeed.leads;

  /// Event proposals and quotations.
  static List<Map<String, dynamic>> get quotations => PaymentSeed.quotations;

  /// Quotation line item details.
  static List<Map<String, dynamic>> get quotationItems =>
      PaymentSeed.quotationItems;

  /// Studio venue bookings.
  static List<Map<String, dynamic>> get bookings => BookingSeed.bookings;

  /// Published review list.
  static List<Map<String, dynamic>> get reviews => ReviewSeed.reviews;

  /// System audit activity logs.
  static List<Map<String, dynamic>> get activityLogs =>
      SettingsSeed.activityLogs;
}
